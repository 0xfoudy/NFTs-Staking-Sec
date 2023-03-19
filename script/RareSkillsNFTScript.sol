// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RareSkillsNFT.sol";

contract SpacebearScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        RareSkillsNFT nft = new RareSkillsNFT(0xf95c14e6953c95195639e8266ab1a6850864d59a829da9f9b13602ee522f672b);

        vm.stopBroadcast();
    }
}