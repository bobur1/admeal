import { expect, use } from "chai";
import { ethers } from "hardhat";
import { BigNumber, ContractTransaction, ContractReceipt } from "ethers";
import chaiAsPromised from "chai-as-promised";

use(chaiAsPromised);

const ONE_ETHER = ethers.utils.parseUnits("1", "ether");
const PRICE = ONE_ETHER.div(1000);
const URL = "https://example.com/api/1.json";
const MAX_SUPPLY = 10000;
const NAME = "Fried Chicken";
const SYMBOL = "FC";

describe("Recipe Factory", function () {
  let RecipeFactory:any;
  let Recipe:any;
  let recipeFactory:any;
  let recipe:any;
  
  let owner:any;
  let addr1:any;
  let addr2:any;
  let addr3:any;
  let addrs:any;

  beforeEach(async () => {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    RecipeFactory = await ethers.getContractFactory("RecipeFactory");
    Recipe = await ethers.getContractFactory("Recipe");
    recipeFactory = await RecipeFactory.deploy();
  });

  it("Create new erc-1155 token type", async () => {
    const contractTx: ContractTransaction = await recipeFactory.createNewRecipe(
        NAME,
        SYMBOL, 
        [MAX_SUPPLY / 2],
        [PRICE.mul(3)],
        [URL]
    );
    const contractReceipt: ContractReceipt = await contractTx.wait();
    const event = contractReceipt.events?.find(event => event.event === 'RecipeCreated');

    const newRecipeAddress = event?.args!['recipe'];
    const newRecipeName = event?.args!['name'];
    const newRecipeSymbol = event?.args!['symbol'];
    const newRecipeOwner = event?.args!['owner'];

    expect(newRecipeName).to.be.equal(NAME);
    expect(newRecipeSymbol).to.be.equal(SYMBOL);
    expect(newRecipeOwner).to.be.equal(owner.address);

    recipe = await Recipe.attach(newRecipeAddress);

    expect(
      await recipe.tokenTypesAmount()
    ).to.be.equal(1);

    const tokenType = await recipe.tokenTypes(0);

    expect(await recipe.owner()).to.be.equal(owner.address);
    expect(tokenType.maxSupply).to.be.equal(MAX_SUPPLY / 2);
    expect(tokenType.pricePerCopy).to.be.equal(PRICE.mul(3));
    expect(tokenType.currentSupply).to.be.equal(0);
  });

  it("Create new erc-1155 token type with 2 token types", async () => {
    const contractTx: ContractTransaction = await recipeFactory.createNewRecipe(
        NAME,
        SYMBOL,
        [MAX_SUPPLY, MAX_SUPPLY / 2],
        [PRICE, PRICE.mul(3)],
        [URL, URL]
    );
    const contractReceipt: ContractReceipt = await contractTx.wait();
    const event = contractReceipt.events?.find(event => event.event === 'RecipeCreated');

    const newRecipeAddress = event?.args!['recipe'];

    recipe = await Recipe.attach(newRecipeAddress);

    expect(
      await recipe.tokenTypesAmount()
    ).to.be.equal(2);

    const tokenType = await recipe.tokenTypes(0);

    expect(tokenType.maxSupply).to.be.equal(MAX_SUPPLY);
    expect(tokenType.pricePerCopy).to.be.equal(PRICE);
    expect(tokenType.currentSupply).to.be.equal(0);
  });
});
