import { AMMPeriphery } from "../typechain/AMMPeriphery";
import { PoolTokens } from "../typechain/PoolTokens";
import { deploy, DeploymentFlags } from "./utils/deployment";
import { ethers } from "ethers";
import hre from "hardhat";

/**
 * Deploy SimpleContract
 */
async function main() {
    // Deploy AMM
    const AMMPeriphery: AMMPeriphery = (await deploy(
        "AMMPeriphery",
        ["0x596b40b23aEdda314AfD810a76bC97B18e2A084E", "0xe5Fe0148D91567591EC859cBb2F8bC03803Bfc7d"],
        DeploymentFlags.Deploy,
    )) as AMMPeriphery;
    console.log(`AMMPeriphery deployed at ${AMMPeriphery.address}`);

    // Deploy token pool
    const PoolTokens: PoolTokens = (await deploy(
        "PoolTokens",
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", "0xdAC17F958D2ee523a2206206994597C13D831ec7"],
        DeploymentFlags.Deploy,
    )) as PoolTokens;
    console.log(`PoolTokens deployed at ${PoolTokens.address}`);

    // Add new token pool
    await AMMPeriphery.addTokenPool(PoolTokens.address);

    // Get encoded data for tokens pool
    //const signer = (await hre.ethers.getSigners())[0];
    const params = await PoolTokens.getEncodedData(22, 33);

    console.log("Params: ", params);

    // Call tokens pool
    const value = ethers.utils.parseEther("0");
    await AMMPeriphery.deposit([PoolTokens.address], [params], [value], { value: value });

    // Register ETH pool as token pool
    const ETHPool = await AMMPeriphery.defaultETHPool();
    await AMMPeriphery.addTokenPool(ETHPool);

    // Deposit on ETH pool
    await AMMPeriphery.deposit([ETHPool], [params], [value], { value: value });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
