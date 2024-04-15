import { run } from "hardhat";
import { TASK_VERIFY_VERIFY } from '@nomicfoundation/hardhat-verify/internal/task-names';

async function main() {

    console.log("Verifying contract...");
    try {
        await run(TASK_VERIFY_VERIFY, {
            address: "0x64aa481C7297D7B92B5Ca5667560aC566bf2D127",
            constructorArguments: [
                "Fried Chicken",
                "FC",
                "0x3aE511AB22716afbB4acC7fEf5B39D2B38c870BF", 
                [ "115792089237316195423570985008687907853269984665640564039457584007913129639935", "100" ],
                [ "0", "1000000000000000" ],
                [
                    "ipfs://QmZiDsySVEAmV6XPETwzTbDZuVyr4Mc9CZbjj7S5WXv5MF",
                    "ipfs://QmZiDsySVEAmV6XPETwzTbDZuVyr4Mc9CZbjj7S5WXv5MF"
                ]
            ],
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