//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TokenStaker {}

contract ETHStaker {
    function stake() external payable {
        // Stake sent ETH to accumulate rewards on ETH
    }

    function withdraw(
        uint256 /*amount*/
    ) external {
        // Send all ETH staked + rewards to msg.sender
    }
}

contract PoolETH is Ownable {
    using Address for address payable;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public withdrawalEndTs;

    function getEncodedData(uint256 endTimestamp) external pure returns (bytes memory) {
        return abi.encode(endTimestamp);
    }

    function deposit(
        address from,
        uint256 endTimestamp,
        address staker
    ) external payable onlyOwner {
        /*require(endTimestamp >= block.timestamp, "End timestamp is in the past");
        require(msg.value>0, "No ETH sent for deposit");

        balanceOf[from] += msg.value;
        withdrawalEndTs[from] = endTimestamp;*/

        console.log("Deposit of ETH - from: %s, endTimestamp: %s, staker: %s", from, endTimestamp, staker);
        //ETHStaker(staker).stake{value:msg.value}();
    }

    function withdraw(address payable from, address staker) external onlyOwner {
        uint256 amount = balanceOf[from];

        require(amount > 0, "No ETH to withdraw");
        require(withdrawalEndTs[from] <= block.timestamp, "Cannot withdraw before end of staking period");

        ETHStaker(staker).withdraw(amount);
        from.sendValue(amount);
    }
}

contract PoolTokens is Ownable {
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

contract AMMPeriphery is Ownable {
    using Address for address;

    mapping(address => bool) public isETHPool;
    mapping(address => bool) public isTokenPool;

    address public defaultETHStaker;
    address public defaultTokenStaker;
    PoolETH public defaultETHPool;

    constructor(address ethStaker, address tokenStaker) {
        defaultETHStaker = ethStaker;
        defaultTokenStaker = tokenStaker;

        defaultETHPool = new PoolETH();

        isETHPool[address(defaultETHPool)] = true;
    }

    function addETHPool(address pool) external onlyOwner {
        isETHPool[pool] = true;
    }

    function addTokenPool(address pool) external {
        isTokenPool[pool] = true;
    }

    /**
        Allows to deposit on several pools on one single transaction
     */
    function deposit(
        address[] calldata pools,
        bytes[] calldata params,
        uint256[] calldata sendValues
    ) external payable {
        require(pools.length == params.length, "Number of pools and parameters must match");
        require(pools.length == sendValues.length, "Number of pools and send values must match");

        for (uint256 i = 0; i < pools.length; ++i) {
            bytes memory depositCall = _getCallData(pools[i], params[i]);
            pools[i].functionCallWithValue(depositCall, sendValues[i], "ERROR depositing funds");
        }
    }

    function _getSelector(address pool) internal view returns (bytes4) {
        if (isETHPool[pool]) {
            return bytes4(keccak256(bytes("deposit(address,uint256,address)")));
        } else if (isTokenPool[pool]) {
            return bytes4(keccak256(bytes("deposit(address,uint128,uint128,address)")));
        } else {
            revert("Unknown pool");
        }
    }

    function _getCallData(address pool, bytes calldata params) internal view returns (bytes memory) {
        bytes4 selector = _getSelector(pool);

        if (isTokenPool[pool]) {
            //(uint128 amountA, uint128 amountB) = abi.decode(params, (uint128, uint128));
            return abi.encodePacked(selector, abi.encode(_msgSender()), params, abi.encode(defaultTokenStaker));
        } else if (isETHPool[pool]) {
            //(uint256 endTimestamp) = abi.decode(params, (uint256));
            return abi.encodePacked(selector, abi.encode(_msgSender()), params, abi.encode(defaultETHStaker));
        } else {
            revert("Unknown pool");
        }
    }
}
