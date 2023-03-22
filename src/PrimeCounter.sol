// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract PrimeCounter {
    IERC721 public enumerableNFT;
    constructor(address addy){
        enumerableNFT = IERC721(addy);
    }

    function countPrimes(address NFTsOwner) external {
        
    }
}