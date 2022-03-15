//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract VeryCoolPoolTokens is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;
    mapping(address => uint256) public balanceOfA;
    mapping(address => uint256) public balanceOfB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function getEncodedData(uint128 amountA, uint128 amountB) external pure returns (bytes memory) {
        return abi.encode(amountA, amountB);
    }

    function deposit(
        address from,
        uint128 amountA,
        uint128 amountB,
        address staker
    ) external {
        // Here safeTransferFrom for amountA and amountB is called and LP tokens added to Staker
        console.log("Deposit of LP Tokens - from: %s, amountA: %s, amountB: %s", from, amountA, amountB);
        console.log("Staker: %s", staker);
    }

    function withdraw(address from, address staker) external onlyOwner {
        // Here LP tokens are withdrawn from staker and tokens returned to 'from'
    }
}
