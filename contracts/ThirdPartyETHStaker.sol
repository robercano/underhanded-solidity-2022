//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ETHStaker {
    using Address for address payable;

    mapping(address => uint256) public balanceOf;

    function stake() external payable {
        // Stake sent ETH to accumulate rewards on ETH
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(amount >= balanceOf[msg.sender], "Not enough balance for sender");

        // Send the required amount back to sender
        payable(msg.sender).sendValue(amount);
    }
}
