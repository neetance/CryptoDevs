// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Whitelist} from "../src/Whitelist.sol";

contract DeployWhiteList is Script {
    function run() external returns (Whitelist) {
        vm.startBroadcast();
        Whitelist whitelist = new Whitelist();
        vm.stopBroadcast();

        return whitelist;
    }
}
