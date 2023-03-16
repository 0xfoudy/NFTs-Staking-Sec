// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RareSkillsNFT.sol";

contract SpacebearScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        RareSkillsNFT nft = new RareSkillsNFT();

        vm.stopBroadcast();
    }
}