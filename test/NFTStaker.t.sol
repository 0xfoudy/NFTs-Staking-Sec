
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RareSkillsNFT.sol";
import "../src/NFTStaker.sol";


contract NFTStakerTest is Test {
    NFTStaker public stakingContract;
    RareSkillsNFT public rareSkillsNFT;
    address owner;
    address user;
    uint256 constant testTokenId = 0;

    function setUp() public{
        owner = address(this);
        user = address(1);
        rareSkillsNFT = new RareSkillsNFT();
        stakingContract = new NFTStaker(rareSkillsNFT);
    }

    function testMintAndDeposit() public{
        vm.startPrank(user);
        rareSkillsNFT.mint();
        rareSkillsNFT.approve(address(stakingContract), testTokenId);
        stakingContract.depositNFT(testTokenId);

        assertEq(rareSkillsNFT.balanceOf(user), 0);
        assertEq(rareSkillsNFT.balanceOf(address(stakingContract)),1);
    }

    function testWithdrawAfterDeposit() public {
        testMintAndDeposit();
        stakingContract.withdrawNFT(testTokenId);
        
        assertEq(rareSkillsNFT.balanceOf(user), 1);
        assertEq(rareSkillsNFT.balanceOf(address(stakingContract)), 0);
    }

    function testAndTransfer() public{
        vm.startPrank(user);
        rareSkillsNFT.mint();
        rareSkillsNFT.safeTransferFrom(user, address(stakingContract), 0);

        assertEq(rareSkillsNFT.balanceOf(user), 0);
        assertEq(rareSkillsNFT.balanceOf(address(stakingContract)), 1);
    }

    function testWithdrawAfterTransfer() public {
        testAndTransfer();
        stakingContract.withdrawNFT(testTokenId);
        
        assertEq(rareSkillsNFT.balanceOf(user), 1);
        assertEq(rareSkillsNFT.balanceOf(address(stakingContract)), 0);
    }



}