// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeCounter {
    ERC721Enumerable public enumerableNFT;
    constructor(address addy){
        enumerableNFT = ERC721Enumerable(addy);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function isPrime(uint256 tokenId) internal pure returns (bool){
        if(tokenId == 1 || tokenId == 2) return true;
        for(uint256 i = 2; i < sqrt(tokenId); ++i){
            if(tokenId % i == 0){
                return false;
            }
        }
        return true;
    }

    function countPrimes(address _nftOwner) public view returns (uint256){
        uint256 primeNumbers = 0;
        for(uint256 i = 0; i < enumerableNFT.balanceOf(_nftOwner); ++i){
            if(isPrime(enumerableNFT.tokenOfOwnerByIndex(_nftOwner, i))) {
                ++primeNumbers;
            }
        }    
        return primeNumbers;    
    }
}