// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/PrimeCounter.sol";
import "../src/EnumerableNFT.sol";


contract PrimeCounterTest is Test {
    PrimeCounter public primeCounter;
    EnumerableNFT public enumerableNFT;
    uint256 decimals = 10 ** 18;
    address owner;
    address user1;
    address user2;
    address user3;

    function setUp() public {
        owner = address(this);
        user1 = address(1);
        user2 = address(2);
        user3 = address(3);
        enumerableNFT = new EnumerableNFT();
        primeCounter = new PrimeCounter(address(enumerableNFT));
    }

    function testMintAndPrimes() public {
        for(uint i=0; i<5; ++i){
            enumerableNFT.mint(); // 1-5-9-13-17
            vm.prank(user1); 
            enumerableNFT.mint(); // 2-6-10-14-18
            vm.prank(user2);
            enumerableNFT.mint(); // 3-7-11-15-19
            vm.prank(user3);
            enumerableNFT.mint(); // 4-8-12-16-20
        }
        
        assertEq(primeCounter.countPrimes(owner), 3);
        assertEq(primeCounter.countPrimes(user1), 1);
        assertEq(primeCounter.countPrimes(user2), 4);
        assertEq(primeCounter.countPrimes(user3), 0);
    }

}
