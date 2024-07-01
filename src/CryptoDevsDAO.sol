// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {CryptoDevs} from "../src/CryptoDevs.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract CryptoDevsDAO is Ownable {
    enum State {
        ONGOING,
        ACCEPTED,
        REJECTED
    }

    struct Proposal {
        State state;
        uint256 startTime;
        uint256 deadline;
        uint256 negVotes;
        uint256 posVotes;
        uint256 id;
        uint256 tokenId;
        //mapping(uint256 => bool) voters;
    }

    error Not_Enough_Balance_To_Create_Proposal();
    error Not_Enough_Balance_To_Vote();
    error Can_Only_Vote_Once();
    error Proposal_Crossed_Deadline();

    event newProposal(address indexed proposer, uint256 nftTokenId);
    event ProposalRejected(uint256 id);
    event ProposalAccepted(uint256 id);

    mapping(uint256 => address) proposers;
    mapping(uint256 proposalId => mapping(uint256 nftTokenId => bool voted)) voters;
    Proposal[] proposals;
    uint256 proposalId = 0;
    uint256 private immutable INTERVAL = 5 minutes;
    uint256 currId = 0;

    CryptoDevs cryptoDevs;
    NFTMarket nftM;

    constructor(address CDaddr, address nftMarketAddr) Ownable(msg.sender) {
        cryptoDevs = CryptoDevs(CDaddr);
        nftM = NFTMarket(nftMarketAddr);
    }

    function propose(uint256 _tokenId) external {
        if (cryptoDevs.balanceOf(msg.sender) == 0)
            revert Not_Enough_Balance_To_Create_Proposal();

        Proposal memory proposal = Proposal({
            state: State.ONGOING,
            startTime: block.timestamp,
            deadline: block.timestamp + INTERVAL,
            negVotes: 0,
            posVotes: 0,
            id: proposalId,
            tokenId: _tokenId
        });

        //proposals[proposalId] = proposal;
        proposals.push(proposal);
        proposers[proposalId] = msg.sender;
        proposalId++;

        //if (currId == proposals.length - 1) currId++;
        emit newProposal(msg.sender, _tokenId);
    }

    function voteFor(uint256 id) external {
        if (cryptoDevs.balanceOf(msg.sender) == 0)
            revert Not_Enough_Balance_To_Vote();

        Proposal memory proposal = proposals[id];
        if (proposal.state != State.ONGOING) revert Proposal_Crossed_Deadline();

        //uint256 usersTokenId = cryptoDevs.getTokenIdFromOwner(msg.sender);
        uint256 balance = cryptoDevs.balanceOf(msg.sender);
        uint256 numVotes = 0;

        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = cryptoDevs.getTokenIdFromOwner(msg.sender, i);
            if (!voters[id][tokenId]) {
                proposal.posVotes++;
                numVotes++;
                voters[id][tokenId] = true;
            }
        }

        if (numVotes == 0) revert Can_Only_Vote_Once();
    }

    function voteAgainst(uint256 id) external {
        if (cryptoDevs.balanceOf(msg.sender) == 0)
            revert Not_Enough_Balance_To_Vote();

        Proposal memory proposal = proposals[id];
        if (proposal.state != State.ONGOING) revert Proposal_Crossed_Deadline();

        //uint256 usersTokenId = cryptoDevs.getTokenIdFromOwner(msg.sender);
        uint256 balance = cryptoDevs.balanceOf(msg.sender);
        uint256 numVotes = 0;

        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = cryptoDevs.getTokenIdFromOwner(msg.sender, i);
            if (!voters[id][tokenId]) {
                proposal.negVotes++;
                numVotes++;
                voters[id][tokenId] = true;
            }
        }

        if (numVotes == 0) revert Can_Only_Vote_Once();
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        if (currId == proposals.length) return (false, "0x0");

        Proposal memory proposal = proposals[currId];
        upkeepNeeded = (proposal.state == State.ONGOING &&
            block.timestamp >= proposal.deadline);

        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        execute(currId);
    }

    function execute(uint256 id) internal {
        Proposal memory proposal = proposals[id];
        uint256 votesFor = proposal.posVotes;
        uint256 votesAgainst = proposal.negVotes;

        if (votesAgainst >= votesFor) {
            proposal.state = State.REJECTED;
            emit ProposalRejected(id);
        } else {
            uint256 nftTokenId = proposal.tokenId;
            nftM.purchase{value: nftM.getPrice()}(nftTokenId);
            proposal.state = State.ACCEPTED;
            emit ProposalAccepted(id);
        }

        currId++;
    }
}
