// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CryptoDevsDAO} from "../src/CryptoDevsDAO.sol";

contract DeployCryptoDevsDAO is Script {
    address CryptoDevsAddr = 0x1cF8Cc193Be42578fc40c257AaF05A1C15227AE8;
    address nftMarketAddr = 0x403EeF34a5e8cF71C86018d86ACadc99c92fc0b0;

    function run() external returns (CryptoDevsDAO) {
        vm.startBroadcast();
        CryptoDevsDAO cryptoDevsDAO = new CryptoDevsDAO(
            CryptoDevsAddr,
            nftMarketAddr
        );
        vm.stopBroadcast();

        return cryptoDevsDAO;
    }
}
