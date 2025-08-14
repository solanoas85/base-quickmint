// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importa bibliotecas do OpenZeppelin (já disponíveis no Remix se você ativar "Remix Libraries")
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseQuickMint is ERC721URIStorage, Ownable {
    uint256 public nextTokenId = 1;
    uint256 public immutable MAX_SUPPLY;
    string public baseTokenURI;
    mapping(address => bool) public minted; // 1 mint por carteira

    event Minted(address indexed to, uint256 indexed tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxSupply
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        require(_maxSupply > 0, "max supply must be > 0");
        baseTokenURI = _baseURI;
        MAX_SUPPLY = _maxSupply;
    }

    function mint() external {
        require(!minted[msg.sender], "already minted");
        require(nextTokenId <= MAX_SUPPLY, "sold out");

        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI(tokenId));
        minted[msg.sender] = true;

        emit Minted(msg.sender, tokenId);
    }

    // tokenURI = baseURI + tokenId + ".json"
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "nonexistent token");
        return string(abi.encodePacked(baseTokenURI, _toString(tokenId), ".json"));
    }

    // Converte uint para string
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // Permite mudar o baseURI (opcional)
    function setBaseURI(string calldata _base) external onlyOwner {
        baseTokenURI = _base;
    }
}
