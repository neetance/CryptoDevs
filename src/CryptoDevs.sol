// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Whitelist} from "./Whitelist.sol";

contract CryptoDevs is ERC721, Ownable {
    Whitelist whiteList;
    uint256 maxSupply = 20;
    uint256 reservedTokens;
    uint256 reservedTokensClaimed = 0;
    uint256 totalTokensClaimed;
    uint256 price = 0.1 ether;
    uint256 private _tokenId = 0;
    mapping(address => uint256[]) private _tokenIds;

    error All_Remaining_Tokens_Are_Reserved();
    error Not_Enough_Value_Sent();

    constructor(address wladdr) ERC721("CryptoDevs", "CD") Ownable(msg.sender) {
        whiteList = Whitelist(wladdr);
        reservedTokens = whiteList.maxSupporterLimit();
    }

    function mint() external payable {
        if (whiteList.isSupporter(msg.sender)) _reserveMint(msg.sender);
        else {
            if (
                totalTokensClaimed - reservedTokensClaimed ==
                maxSupply - reservedTokens
            ) revert All_Remaining_Tokens_Are_Reserved();
            if (msg.value < price) revert Not_Enough_Value_Sent();

            _safeMint(msg.sender, _tokenId);
        }
        uint256 balance = balanceOf(msg.sender);
        _tokenIds[msg.sender][balance - 1] = _tokenId;

        _tokenId++;
    }

    function _reserveMint(address user) internal {
        _safeMint(user, _tokenId);
    }

    function getTokenIdFromOwner(
        address owner,
        uint256 index
    ) public view returns (uint256) {
        return _tokenIds[owner][index];
    }
}
