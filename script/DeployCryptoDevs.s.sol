// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CryptoDevs} from "../src/CryptoDevs.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployCryptoDevs is Script {
    function run() external returns (CryptoDevs) {
        address wladdr = DevOpsTools.get_most_recent_deployment(
            "Whitelist",
            block.chainid
        );
        vm.startBroadcast();
        CryptoDevs cryptoDevs = new CryptoDevs(wladdr);
        vm.stopBroadcast();

        return cryptoDevs;
    }
}
