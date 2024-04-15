import fs from "fs"
import dotenv from "dotenv"
import hre from "hardhat"
import { run } from "hardhat";
import { TASK_VERIFY_VERIFY } from '@nomicfoundation/hardhat-verify/internal/task-names';

async function main() {
    const net = hre.network.name;
    const config = dotenv.parse(fs.readFileSync(`.env-${net}`));
    for (const parameter in config) {
        process.env[parameter] = config[parameter];
    }

    console.log("Verifying contract...");
    try {
        await run(TASK_VERIFY_VERIFY, {
            address: config.FACTORY_CONTRACT_ADDRESS,
            constructorArguments: [],
        });
    } catch (e: any) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!");
        } else {
            console.log(e);
        }
    }
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});