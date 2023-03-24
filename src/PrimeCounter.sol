// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeCounter {
    ERC721Enumerable public enumerableNFT;
    constructor(address addy){
        enumerableNFT = ERC721Enumerable(addy);
    }

    function isPrime(uint256 tokenId) internal view returns (bool){
        if(tokenId == 1) return false;
        if(tokenId == 2) return true;
        for(uint256 i = 2; i*i <= tokenId; ++i){
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