// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "./StakeableNFT.sol";

contract NFTStaker is IERC721Receiver {
    IERC721 public stakeableNFT;
    mapping(uint256 => address) originalOwner;

    constructor(IERC721 _address) {
        stakeableNFT = _address;
    }

    function depositNFT(uint256 tokenId) external{
        originalOwner[tokenId] = msg.sender;
        stakeableNFT.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function withdrawNFT(uint256 tokenId) external{
        require(originalOwner[tokenId] == msg.sender, "Not original owner");
        stakeableNFT.safeTransferFrom(address(this), msg.sender, tokenId);      
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        originalOwner[tokenId] = from;
        return IERC721Receiver.onERC721Received.selector;
    }
}