
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
    bytes32[] proof;

    function setUp() public{
        owner = address(this);
        user = address(1);
        rareSkillsNFT = new RareSkillsNFT(0xf95c14e6953c95195639e8266ab1a6850864d59a829da9f9b13602ee522f672b);
        stakingContract = new NFTStaker(rareSkillsNFT);
        proof.push(0xd52688a8f926c816ca1e079067caba944f158e764817b83fc43594370ca9cf62);
    }

    function testMintAndDeposit() public{
        vm.startPrank(user);
        rareSkillsNFT.whiteListMerkleMint(proof);
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
        rareSkillsNFT.whiteListMerkleMint(proof);
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