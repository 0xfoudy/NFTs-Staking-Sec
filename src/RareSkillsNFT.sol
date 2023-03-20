import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";
import "forge-std/console.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

contract RareSkillsNFT is ERC721, ERC2981 {
    address public _owner; 
    address public _potentialOwner;
    bool public pendingOwnershipTransfer = false;

    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 10;
    mapping(address => uint256) public presaleAllocation;
    bool public publicSaleOpen = false;
    using ECDSA for bytes32; // Elliptic curve digital signature algorithm
    // for public signatures
    mapping (uint256 => address) userAllocationMap;

    BitMaps.BitMap private allocationBitmap;
    uint256 royalteeDenominator = 10000;
    RoyaltyInfo private _royalties;

    // for merkle tree,
    bytes32 public merkleRoot;
    // to make functions non view
    uint256 public dummy;

    constructor(bytes32 root) ERC721("RareSkillsNFT", "RRSKLZ"){
        _owner = msg.sender;
        presaleAllocation[address(1)] = 2;
        setAllowList3MerkleRoot(root);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 0);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 1);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 2);

        setAllowList2SigningAddress(address(1), 3);
        setAllowList2SigningAddress(address(1), 4);

        _royalties = RoyaltyInfo(msg.sender, 250);
    }

    function _isOwner() internal view virtual {
        require(_owner == msg.sender, "OnlyOwner: caller is not the Owner");
    }

    modifier onlyOwner() {
        _isOwner();
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _potentialOwner = newOwner;
        pendingOwnershipTransfer = true;
    }

    function acceptOwnership() public {
        require(pendingOwnershipTransfer, "no pending ownership transfer");
        require(_potentialOwner == msg.sender, "no ownership invitation for you!");
        _owner = msg.sender;
        pendingOwnershipTransfer = false;
    }

    function openPublicSale() public onlyOwner {
        publicSaleOpen = true;
    }

    function mint() external {
        require(publicSaleOpen, "Public sale still not open");
        internalMint();
    }

    function internalMint() internal {
        require(tokenSupply < MAX_SUPPLY, "Supply already at limit");
        _mint(msg.sender, tokenSupply);
        ++tokenSupply;
    }

    function presaleMint() internal {
        require(!publicSaleOpen, "Presale ended");
        require(presaleAllocation[msg.sender] > 0, "Allocation limit reached");
        internalMint();
        presaleAllocation[msg.sender] -= 1;
    }

    function whiteListMerkleMint(bytes32[] calldata proofs) external {
        require(!publicSaleOpen, "Presale ended");
        benchmark3MerkleTree(proofs);
        presaleMint();
    }

    function whiteListDigitalSignatureMint(bytes calldata signature, uint256 ticketNumber) external {
        require(!publicSaleOpen, "Presale ended");
        claimTicketOrBlockTransaction(ticketNumber);
        benchmark2PublicSignature(signature, ticketNumber);
        internalMint();
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/";
    }

    function setAllowList2SigningAddress(address _signingAddress, uint256 _allowedTickets) public onlyOwner{
        userAllocationMap[_allowedTickets] = (_signingAddress);
    }

    function setAllowList3MerkleRoot(bytes32 root) public onlyOwner{
        merkleRoot = root;
    }

    function benchmark2PublicSignature(bytes calldata _signature, uint256 _ticketNumber) internal {
        require(userAllocationMap[_ticketNumber] == msg.sender, "Ticket not allocated to minter");
        require(
            msg.sender ==
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n64",
                        bytes32(uint256(uint160(msg.sender))),
                        _ticketNumber
                    )
                ).recover(_signature),
            "not allowed"
        );
        if (false) {
            dummy = 1;
        }
    }

    function claimTicketOrBlockTransaction(uint256 ticketNumber) internal {
        require(!BitMaps.get(allocationBitmap,ticketNumber), "already taken");
        BitMaps.set(allocationBitmap,ticketNumber);
    }

    function benchmark3MerkleTree(bytes32[] calldata merkleProof) internal {
        require(
            MerkleProof.verify(
                merkleProof,
                merkleRoot,
                keccak256(
                    abi.encodePacked(msg.sender))),
        "Invalid merkle proof");
        if (false) {
            dummy = 1;
        }
    }

    //receiver gets the royalty amount, first param is for tokenId in case royalt
    function royaltyInfo(uint256, uint256 _salePrice) public view override returns (address, uint256){
        uint256 royaltyAmount = _salePrice * 10**18 * _royalties.royaltyFraction / royalteeDenominator;
        address receiver = _royalties.receiver;
        return(receiver, royaltyAmount);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool){
        return super.supportsInterface(interfaceId);
    }
}