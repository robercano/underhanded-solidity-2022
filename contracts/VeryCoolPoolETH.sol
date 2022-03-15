//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./ThirdPartyETHStaker.sol";

contract VeryCoolPoolETH is Ownable {
    using Address for address payable;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public withdrawalEndTs;

    function deposit(
        address from,
        uint256 endTimestamp,
        address staker
    ) external payable onlyOwner {
        require(endTimestamp >= block.timestamp, "End timestamp is in the past");
        require(msg.value > 0, "No ETH sent for deposit");

        balanceOf[from] += msg.value;
        withdrawalEndTs[from] = endTimestamp;

        console.log("Deposit of ETH - from: %s, endTimestamp: %s, staker: %s", from, endTimestamp, staker);
        ETHStaker(staker).stake{ value: msg.value }();
    }

    function withdraw(address payable from, address staker) external onlyOwner {
        uint256 amount = balanceOf[from];

        require(amount > 0, "No ETH to withdraw");
        require(withdrawalEndTs[from] <= block.timestamp, "Cannot withdraw before end of staking period");

        ETHStaker(staker).withdraw(amount);
        from.sendValue(amount);
    }
}
