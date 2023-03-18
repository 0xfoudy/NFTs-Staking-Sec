import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

contract RareSkillsNFT is ERC721, Ownable {

    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 10;
    mapping(address => uint256) whiteListAllocation;

    constructor() ERC721("RareSkillsNFT", "RRSKLZ"){
        whiteListAllocation[address(msg.sender)] = 3;
    }

    function mint() external {
        require(tokenSupply < MAX_SUPPLY, "Supply already at limit");
        _mint(msg.sender, tokenSupply);
        ++tokenSupply;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _baseURI() internal pure override returns (string memory){
        return "ipfs://QmZZzC4v7M6ZTYnuEgfA5qwHQUTm1DwRF8j3CQKtY6EXMF/";
    }

}
