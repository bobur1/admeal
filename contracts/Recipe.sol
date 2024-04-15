// SPDX-License-Identifier: MIT
//
//  /$$$$$$$                      /$$                    
// | $$__  $$                    |__/                    
// | $$  \ $$  /$$$$$$   /$$$$$$$ /$$  /$$$$$$   /$$$$$$ 
// | $$$$$$$/ /$$__  $$ /$$_____/| $$ /$$__  $$ /$$__  $$
// | $$__  $$| $$$$$$$$| $$      | $$| $$  \ $$| $$$$$$$$
// | $$  \ $$| $$_____/| $$      | $$| $$  | $$| $$_____/
// | $$  | $$|  $$$$$$$|  $$$$$$$| $$| $$$$$$$/|  $$$$$$$
// |__/  |__/ \_______/ \_______/|__/| $$____/  \_______/
//                                   | $$                
//                                   | $$                
//                                   |__/                
//                                                                                                    

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Recipe is ERC1155URIStorage, ERC2981 {
    uint256 public tokenTypesAmount;

    string public name;
    string public symbol;

    address public owner;
    address public recipeFactory;

    struct TokenType {
        uint256 maxSupply;
        uint256 currentSupply;
        uint256 pricePerCopy;
    }

    mapping (uint256 => TokenType) public tokenTypes;

    event TokenTypeCreated(uint256 indexed tokenType, uint256 maxSupply, uint256 pricePerCopy, string uri);
    event Minted(uint256 indexed tokenType, address indexed owner);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        uint256[] memory _maxSupply,
        uint256[] memory _pricePerCopy,
        string[] memory _uri
    ) ERC1155("") {
        require(_maxSupply.length == _pricePerCopy.length && _maxSupply.length == _uri.length, "RecipeFactory: Invalid input");
        name = _name;
        symbol = _symbol;
        owner = _owner;

        for(uint256 i = 0; i < _maxSupply.length; i++) {
           _createNewTokenType(_maxSupply[i], _pricePerCopy[i], _uri[i]);
        }

        _setDefaultRoyalty(address(this), 500); // 5%
    }

    function createNewTokenType(
        uint256 _maxSupply,
        uint256 _pricePerCopy,
        string memory _uri
    ) public onlyOwner {
        _createNewTokenType(_maxSupply, _pricePerCopy, _uri);
    }

    function mint(uint256 _tokenType) public payable {
        TokenType storage tokenType = tokenTypes[_tokenType];
        require(tokenType.maxSupply > tokenType.currentSupply, "Recipe: All token copies have been minted");
        require(msg.value >= tokenType.pricePerCopy, "Recipe: Insufficient payment");
        require(balanceOf(msg.sender,_tokenType) == 0, "Recipe: You cannot mint more than one copy of the same token type");

        tokenType.currentSupply++;
        _mint(msg.sender, _tokenType, 1, "");

        if(msg.value > tokenType.pricePerCopy) {
            payable(msg.sender).transfer(msg.value - tokenType.pricePerCopy);
        }

        emit Minted(_tokenType, msg.sender);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if(balance > 0) {
            uint256 devRoyalty = balance / 5; // 1% out of 5% (or 20% out of 100%) owner royalties
            // send 20% to the recipeFactory and 80% to the owner
            payable(recipeFactory).transfer(devRoyalty);
            payable(owner).transfer(balance - devRoyalty);
        }
    }

    function withdraw(address erc20) external onlyOwner {
        uint256 balance = IERC20(erc20).balanceOf(address(this));

        if(balance > 0) {
            uint256 devRoyalty = balance / 5; // 1% out of 5% (or 20% out of 100%) owner royalties
            // send 20% to the recipeFactory and 80% to the owner
            IERC20(erc20).transfer(recipeFactory, devRoyalty);
            IERC20(erc20).transfer(owner, balance - devRoyalty);
        }
    }

    receive() external payable {
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _createNewTokenType(
        uint256 _maxSupply,
        uint256 _pricePerCopy,
        string memory _uri
    ) internal {
        tokenTypes[tokenTypesAmount] = TokenType(_maxSupply, 0, _pricePerCopy);
        _setURI(tokenTypesAmount, _uri);
        tokenTypesAmount++;

        emit TokenTypeCreated(tokenTypesAmount - 1, _maxSupply, _pricePerCopy, _uri);
    }
}