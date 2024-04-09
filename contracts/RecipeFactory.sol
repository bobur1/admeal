// SPDX-License-Identifier: MIT
//
//  /$$$$$$$                      /$$                     /$$$$$$$$                   /$$                                  
// | $$__  $$                    |__/                    | $$_____/                  | $$                                  
// | $$  \ $$  /$$$$$$   /$$$$$$$ /$$  /$$$$$$   /$$$$$$ | $$    /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$  /$$   /$$
// | $$$$$$$/ /$$__  $$ /$$_____/| $$ /$$__  $$ /$$__  $$| $$$$$|____  $$ /$$_____/|_  $$_/   /$$__  $$ /$$__  $$| $$  | $$
// | $$__  $$| $$$$$$$$| $$      | $$| $$  \ $$| $$$$$$$$| $$__/ /$$$$$$$| $$        | $$    | $$  \ $$| $$  \__/| $$  | $$
// | $$  \ $$| $$_____/| $$      | $$| $$  | $$| $$_____/| $$   /$$__  $$| $$        | $$ /$$| $$  | $$| $$      | $$  | $$
// | $$  | $$|  $$$$$$$|  $$$$$$$| $$| $$$$$$$/|  $$$$$$$| $$  |  $$$$$$$|  $$$$$$$  |  $$$$/|  $$$$$$/| $$      |  $$$$$$$
// |__/  |__/ \_______/ \_______/|__/| $$____/  \_______/|__/   \_______/ \_______/   \___/   \______/ |__/       \____  $$
//                                   | $$                                                                         /$$  | $$
//                                   | $$                                                                        |  $$$$$$/
//                                   |__/                                                                         \______/ 
//

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Recipe.sol";

contract RecipeFactory is Ownable {
    Recipe[] public RecipeArray;

    function CreateNewRecipe(string memory _name, string memory _symbol) public {
        Recipe recipe = new Recipe(_name, _symbol, msg.sender);
        RecipeArray.push(recipe);
    }

    receive() external payable {
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdraw(address _erc20) public onlyOwner {
        IERC20(_erc20).transfer(owner(), IERC20(_erc20).balanceOf(address(this)));
    }
}