 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Staking {
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public startTime;

    uint256 public constant lockupPeriod = 30 days;

    mapping(address => uint256) public stakedBalances;

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
        startTime = block.timestamp;
    }

    // Function to stake tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        token.safeTransferFrom(msg.sender, address(this), amount);
        stakedBalances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    // Function to withdraw staked tokens after the lock-up period
    function withdraw() external {
        require(block.timestamp >= startTime + lockupPeriod, "Lock-up period not ended");
        uint256 amount = stakedBalances[msg.sender];
        require(amount > 0, "No staked amount to withdraw");
        stakedBalances[msg.sender] = 0;
        token.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Function to get the current staked balance of a user
    function getStakedBalance(address staker) external view returns (uint256) {
        return stakedBalances[staker];
    }
}
