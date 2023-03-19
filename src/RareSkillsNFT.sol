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
    // uints are slightly more efficient than bools because the EVM casts bools to uint
    mapping(address => uint256) public allowList;

    // for public signatures
    address public allowListSigningAddress = 0xA3FE755e8FB7cFB97FAda75567cF9d7cef04B6f6;

    // for merkle tree, 
    bytes32 public merkleRoot;

    // because we don't want solidity / ethers to think these are view functions
    // or hardhat won't measure the gas
    uint256 public dummy;

    constructor(bytes32 root) ERC721("RareSkillsNFT", "RRSKLZ"){
        presaleAllocation[address(1)] = 2;
        merkleRoot = root;
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

    function whiteListDigitalSignatureMint(bytes calldata signature) external {
        benchmark2PublicSignature(signature);
        presaleMint();
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/";
    }

    // NOT SAFE FOR PRODUCTION, ANYONE CAN EDIT
    function setAllowList1Mapping(address _buyer) public onlyOwner{
        allowList[_buyer] = 1;
    }

    // NOT SAFE FOR PRODUCTION, ANYONE CAN EDIT
    function setAllowList2SigningAddress(address _signingAddress) public onlyOwner{
        allowListSigningAddress = _signingAddress;
    }

    // NOT SAFE FOR PRODUCTION, ANYONE CAN EDIT
    function setAllowList3MerkleRoot(bytes32 root) public onlyOwner{
        merkleRoot = root;
    }

    function benchmark1Mapping() internal {
        require(allowList[msg.sender] == 1, "not allowed");

        //if you execute the following code, the gas will be even lower
        //because the EVM refunds for setting storage to zero

        //allowList[msg.sender] == 0;


        if (false) {
            dummy = 1;
        }
    }

    function benchmark2PublicSignature(bytes calldata _signature) internal {
        console.log(msg.sender);
        console.logBytes32(bytes32(uint256(uint160(msg.sender))));
        console.logBytes32(keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        bytes32(uint256(uint160(msg.sender)))
                    )));
        require(
            allowListSigningAddress ==
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        bytes32(uint256(uint160(msg.sender)))
                    )
                ).recover(_signature),
            "not allowed"
        );
        if (false) {
            dummy = 1;
        }
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