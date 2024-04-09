import { ethers } from "hardhat";
import { parse } from "dotenv";
import { readFileSync, appendFileSync } from "fs";
import hre from "hardhat";

async function main() {
  const net = hre.network.name;

  let config = parse(readFileSync(`.env-${net}`))
  for (const parameter in config) {
      process.env[parameter] = config[parameter];
  }

  // Recipe Factory 
  const RecipeFactory = await ethers.getContractFactory("RecipeFactory");
  const recipeFactory = await RecipeFactory.deploy();
  await recipeFactory.deployed();
  console.log(`Address of factory ${recipeFactory.address}`);

  appendFileSync(
      `.env-${net}`,
      `\r\# Factory deployed at \rFACTORY_CONTRACT_ADDRESS=${recipeFactory.address}\r`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
