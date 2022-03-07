//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//import "@openzeppelin/contracts/utils/

contract MSPool is ERC20 {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    constructor(
        IERC20 _tokenA,
        IERC20 _tokenB,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        tokenA = _tokenA;
        tokenB = _tokenB;
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

    function addLiquitidy(uint256 amountA, uint256 amountB) external {
        require(tokenA.balanceOf(_msgSender()) >= amountA, "Not enough tokenB");
        require(tokenB.balanceOf(_msgSender()) >= amountB, "Not enough tokenB");

        tokenA.safeTransferFrom(_msgSender(), address(this), amountA);
        tokenB.safeTransferFrom(_msgSender(), address(this), amountB);
    }
}

contract MultiswapAMM {
    mapping(address => mapping(address => MSPool)) private poolsAB;
    mapping(address => mapping(address => MSPool)) private poolsBA;

    function createPool(address tokenA, address tokenB) external {
        MSPool newPool = new MSPool(IERC20(tokenA), IERC20(tokenB), "MSPool-LP", "MSLP");

        poolsAB[tokenA][tokenB] = newPool;
        poolsAB[tokenB][tokenA] = newPool;
    }

    function getPool(address tokenA, address tokenB) external view returns (MSPool pool) {
        pool = poolsAB[tokenA][tokenB];
        if (address(pool) == address(0)) {
            pool = poolsBA[tokenA][tokenB];
        }
    }
}
