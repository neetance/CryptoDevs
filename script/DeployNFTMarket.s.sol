// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract DeployNFTMarket is Script {
    function run() external returns (NFTMarket) {
        vm.startBroadcast();
        NFTMarket nftMarket = new NFTMarket();
        vm.stopBroadcast();

        return nftMarket;
    }
}
