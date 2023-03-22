// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "./StakeableNFT.sol"; 

contract NFTStaker is IERC721Receiver {
    IERC721 public stakeableNFT;
    mapping(uint256 => address) public originalOwner;
    mapping(address => stakerInfo) public stakersMap;
    uint256 constant public _rewardsPerDay = 10;
    uint256 constant public _decimals = 18;

    struct stakerInfo {
        uint256 nftsStaked;
        uint256 timeStaked;
    }

    function getStakerInfo(address user) public view returns (stakerInfo memory){
        return stakersMap[user];
    }

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

    function newDeposit(address from) internal {
        collectRewards(from);
        stakersMap[from].nftsStaked += 1;
    }

    function collectRewards(address from) internal {
        stakersMap[from].timeStaked = block.timestamp;
        uint256 rewards = calculateReward(from);
    }

    function calculateReward(address from) public view returns (uint256){
        // The division by seconds in a day is done before decimals multiplication because
        // users can only withdraw 10 tokens every 24 hours, so we need an integer and not float
        return _rewardsPerDay * 10**_decimals * ((block.timestamp - stakersMap[from].timeStaked)/(60*60*24));
    }

    // depositing an additional NFT will let users claim pending reward and start fresh
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        originalOwner[tokenId] = from;
        newDeposit(from);
        return IERC721Receiver.onERC721Received.selector;
    }
}