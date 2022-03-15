import { ethers } from "hardhat";
import { BytesLike } from "ethers";

export enum PatternFlags {
    None,
    FromStart,
    FromEnd,
}

export function findSaltToMatch(
    from: string,
    bytecode: BytesLike,
    pattern: string,
    startingSalt: string = "0x0",
    flags: PatternFlags = PatternFlags.None,
): [string | undefined, string | undefined] {
    const initCodeHash = ethers.utils.keccak256(bytecode);
    let salt = ethers.BigNumber.from(startingSalt);
    let count = 0;

    const limit = ethers.BigNumber.from(2).pow(256);
    while (salt.lt(limit)) {
        const saltString = salt.toHexString().slice(2).padStart(64, "0");

        const address = ethers.utils
            .getCreate2Address(from, Buffer.from(saltString, "hex"), initCodeHash)
            .toLowerCase();

        //console.log(address);
        //console.log(salt.toHexString());

        switch (flags) {
            case PatternFlags.FromStart:
                if (address.startsWith("0x" + pattern)) {
                    console.log(address.startsWith("0x" + pattern));
                    return [salt.toHexString(), address];
                }
                break;
            case PatternFlags.FromEnd:
                if (address.endsWith(pattern)) {
                    return [salt.toHexString(), address];
                }
                break;
            default:
                if (address.indexOf(pattern) !== -1) {
                    return [salt.toHexString(), address];
                }
        }

        salt = salt.add(1);
        count++;

        if (count % 500000 === 0) {
            console.log(`Current salt: ${salt.toHexString()}`);
        }
    }

    return [undefined, undefined];
}
