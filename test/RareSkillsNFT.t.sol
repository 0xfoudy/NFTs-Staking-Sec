
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RareSkillsNFT.sol";


contract RareSkillsNFTTest is Test {
    RareSkillsNFT public rareSkillsNFT;
    address owner;
    address user;

    function setUp() public{
        owner = address(this);
        user = address(1);
        rareSkillsNFT = new RareSkillsNFT();
    }

    function testMint() public{
        vm.prank(user);
        rareSkillsNFT.mint();
        assertEq(rareSkillsNFT.tokenSupply(),1);
        assertEq(rareSkillsNFT.balanceOf(user),1);
        assertEq(rareSkillsNFT.tokenURI(0), "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/0");
    }

}