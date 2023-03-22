// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "./StakeableNFT.sol"; 
import "./StakeRewardToken.sol";
import "forge-std/console.sol";

contract NFTUniqueStaker is IERC721Receiver, Ownable{
    IERC721 public stakeableNFT;
    mapping(uint256 => address) public originalOwner;
    mapping(uint256 => stakerInfo) public tokenIdToStaker;
    uint256[20] public _rewardsPerDay = [54,10,10,13,15,16,17,18,29,50,19,29,53,25,63,23,54,78,17,9];
    uint256 constant public _decimals = 18;
    StakeRewardToken public rewardToken;
    bool isStakingTransfer = false;

    struct stakerInfo {
        address nftOwner;
        uint256 timeStaked;
        uint256 leftover;
    }

    function getStakerInfo(uint256 tokenId) public view returns (stakerInfo memory){
        return tokenIdToStaker[tokenId];
    }

    constructor(IERC721 _address, address _rewardToken) {
        stakeableNFT = _address;
        rewardToken = StakeRewardToken(_rewardToken);
    }

    function depositNFT(uint256 tokenId) external{
        originalOwner[tokenId] = msg.sender;
        isStakingTransfer = true;
        stakeableNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        isStakingTransfer = false;
    }

    function withdrawNFT(uint256 tokenId) external{
        require(originalOwner[tokenId] == msg.sender, "Not original owner");
        delete tokenIdToStaker[tokenId];
        stakeableNFT.safeTransferFrom(address(this), msg.sender, tokenId);      
    }

    function newDeposit(uint256 tokenId) internal {
        tokenIdToStaker[tokenId].nftOwner = originalOwner[tokenId];
    }

    function collectRewards(uint256 tokenId) internal {
        (uint256 toGive, uint256 toRetain) = calculateReward(tokenId);
        rewardToken.mintReward(toGive, msg.sender);
        tokenIdToStaker[tokenId].timeStaked = block.timestamp;
        tokenIdToStaker[tokenId].leftover = toRetain;
    }

    function collectRewards() public {
       //iterate over the tokens held by the owner
        // collectRewards();
    }

    function calculateReward(uint256 tokenId) public view returns (uint256, uint256){
        uint256 timesSinceClaim = block.timestamp - tokenIdToStaker[tokenId].timeStaked;
        uint256 totalRewards = tokenIdToStaker[tokenId].leftover + _rewardsPerDay[tokenId] * 10**_decimals * (timesSinceClaim)/(60*60*24);
        uint256 unitsOfTenRewards = (totalRewards/10**18)*10**18;
        uint256 remainder = totalRewards - unitsOfTenRewards;
        return (unitsOfTenRewards, remainder);
    }

    // depositing an additional NFT will let users claim pending reward and start fresh
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // make sure we can only transfer the NFT collection we want
        require(msg.sender == address(stakeableNFT), "Non acceptable NFT");
        // to prevent random NFTs to be sent
         require(isStakingTransfer, 'Please transfer the NFT through the staking function');
        originalOwner[tokenId] = from;
        newDeposit(tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
}