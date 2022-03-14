//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//import "@openzeppelin/contracts/utils/

contract SampleERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Empty on purpose
    }
}

interface IETHPool is IERC20 {
    function deposit(uint256 amount, address owner) external;
}

contract ETHPool is IETHPool, ERC20, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    constructor(
        IERC20 _token,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        token = _token;
    }

    function swapIn(uint256 amountAIn) external {
        // do better here
        uint256 amountBOut = amountAIn;

        require(tokenA.balanceOf(_msgSender()) >= amountAIn, "Not enough tokenA");
        require(tokenB.balanceOf(address(this)) >= amountBOut, "Not enough tokenB");

        tokenA.safeTransferFrom(_msgSender(), address(this), amountAIn);
        tokenB.safeTransfer(_msgSender(), amountBOut);
    }

    function swapOut(uint256 amountBIn) external {
        // do better here
        uint256 amountAOut = amountBIn;

        require(tokenB.balanceOf(_msgSender()) >= amountBIn, "Not enough tokenB");
        require(tokenA.balanceOf(address(this)) >= amountAOut, "Not enough tokenA");

        tokenA.safeTransferFrom(_msgSender(), address(this), amountBIn);
        tokenB.safeTransfer(_msgSender(), amountAOut);
    }

    function deposit(uint256 amount, address owner) external payable onlyOwner {
        require(token.balanceOf(owner) >= amount, "Not enough tokenB");

        token.safeTransferFrom(_msgSender(), address(this), amount);
    }
}

contract ETHAMM {
    mapping(address => mapping(address => ETHPool)) private pools;

    function createPool(address token) external {
        require(address(pools[token]) == address(0), "Pool already exists");
        pools[token] = new ETHPool(IERC20(token), "ETHPool-LP", "ETH-LP");
    }

    function getPool(address token) external view returns (ETHPool pool) {
        pool = pools[token];
    }

    function deposit(address token, uint256 amount) external payable {
        require(msg.value < 2**128, "Cannot handle that much ETH for quadratic rewards");

        uint256 quadraticReward = msg.value * msg.value;

        ETHPool memory pool = getPool(token);
        token.deposit(amount, quadraticReward);

        // Would work if we can setup a contract with msg.value address
    }
}
