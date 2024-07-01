// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract NFTMarket {
    error Token_Not_Available_For_Purchase();
    uint256 price = 0.1 ether;
    mapping(uint256 => address) private tokens;

    //uint256 tokenId = 0;

    function purchase(uint256 _tokenId) external payable {
        if (msg.value < price) revert();
        if (tokens[_tokenId] != address(0))
            revert Token_Not_Available_For_Purchase();

        tokens[_tokenId] = msg.sender;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function getOwner(uint256 _tokenId) public view returns (address) {
        return tokens[_tokenId];
    }
}
