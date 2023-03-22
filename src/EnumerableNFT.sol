// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract EnumerableNFT is ERC721Enumerable {
    uint256 public tokenSupply;
    uint256 public constant MAX_SUPPLY = 20;

    constructor() ERC721("EnumerableNFT", "NRMBL"){
        tokenSupply = 1; //ids should start from 1 to 20
    }

    function mint() external {
        require(tokenSupply <= MAX_SUPPLY, "Supply already at limit");
        _mint(msg.sender, tokenSupply);
        ++tokenSupply;
    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/";
    }
}