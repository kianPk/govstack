// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Treasury
/// @notice Holds ETH/ERC20; only the owner (Timelock) can spend.
contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    event EthReceived(address indexed from, uint256 amount);
    event EthSpent(address indexed to, uint256 amount);
    event BatchEthSpent(address payable[] recipients, uint256[] amounts);
    event TokenSpent(address indexed token, address indexed to, uint256 amount);

    error ArrayLengthMismatch();
    error ZeroAmount();

    constructor(address owner_) Ownable(owner_) {}

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    function spendETH(address payable to, uint256 amount) external onlyOwner {
        if (amount == 0) revert ZeroAmount();
        (bool ok,) = to.call{value: amount}("");
        require(ok, "ETH_TRANSFER_FAILED");
        emit EthSpent(to, amount);
    }

    /// @notice Pay multiple recipients in one timelock execution.
    function batchSpend(address payable[] calldata recipients, uint256[] calldata amounts)
        external
        onlyOwner
    {
        if (recipients.length != amounts.length) revert ArrayLengthMismatch();
        uint256 len = recipients.length;
        for (uint256 i; i < len; ++i) {
            uint256 amount = amounts[i];
            if (amount == 0) revert ZeroAmount();
            address payable to = recipients[i];
            (bool ok,) = to.call{value: amount}("");
            require(ok, "ETH_TRANSFER_FAILED");
            emit EthSpent(to, amount);
        }
        emit BatchEthSpent(recipients, amounts);
    }

    function spendToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
        emit TokenSpent(token, to, amount);
    }
}
