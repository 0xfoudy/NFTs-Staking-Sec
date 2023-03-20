import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "forge-std/console.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

contract RareSkillsNFT is ERC721, Ownable {

    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 10;
    mapping(address => uint256) public presaleAllocation;
    bool public publicSaleOpen = false;
    using ECDSA for bytes32; // Elliptic curve digital signature algorithm

    // for public signatures
    mapping (uint256 => address) userAllocationMap;

    uint256 private constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256[1] private ticketsBitMap = [MAX_INT];

    // for merkle tree,
    bytes32 public merkleRoot;

    // because we don't want solidity / ethers to think these are view functions
    // or hardhat won't measure the gas
    uint256 public dummy;

    constructor(bytes32 root) ERC721("RareSkillsNFT", "RRSKLZ"){
        presaleAllocation[address(1)] = 2;
        setAllowList3MerkleRoot(root);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 0);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 2);
        setAllowList2SigningAddress(0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6, 3);

        setAllowList2SigningAddress(address(1), 1);
        setAllowList2SigningAddress(address(1), 4);
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
        require(presaleAllocation[msg.sender] > 0, "Allocation limit reached");
        internalMint();
        presaleAllocation[msg.sender] -= 1;
    }

    function whiteListMerkleMint(bytes32[] calldata proofs) external {
        benchmark3MerkleTree(proofs);
        presaleMint();
    }

    function whiteListDigitalSignatureMint(bytes calldata signature, uint256 ticketNumber) external {
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
        require(ticketNumber < ticketsBitMap.length * 256, "too large");
        uint256 storageOffset = ticketNumber / 256;
        uint256 offsetWithin256 = ticketNumber % 256;
        //shift right, do an AND to zero out everything on the left
        uint256 storedBit = (ticketsBitMap[storageOffset] >> offsetWithin256) & uint256(1);
        require(storedBit == 1, "already taken");


        ticketsBitMap[storageOffset] = ticketsBitMap[storageOffset] & ~(uint256(1) << offsetWithin256);
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
}