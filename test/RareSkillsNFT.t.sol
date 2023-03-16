
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RareSkillsNFT.sol";
import "forge-std/console.sol";


contract CounterTest is Test {
    RareSkillsNFT public rareSkillsNFT;
    address owner;
    address user;

    function setUp() public{
        owner = address(this);
        user = address(1);
        rareSkillsNFT = new RareSkillsNFT();
    }

    function testMint() public{
        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert("Invalid price");
        rareSkillsNFT.mint{value: 0.2 ether}();

        vm.prank(user);
        rareSkillsNFT.mint{value: 0.001 ether}();
        assertEq(rareSkillsNFT.tokenSupply(),1);
        assertEq(rareSkillsNFT.viewBalance(), 0.001 ether);
        assertEq(rareSkillsNFT.balanceOf(user),1);
        assertEq(rareSkillsNFT.tokenURI(0), "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/0");
    
        console.log(owner.balance);
    }

}