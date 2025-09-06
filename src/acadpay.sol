// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// Import OpenZeppelin's IERC20 and ReentrancyGuard
// this is to ensure that we are using a standard interface for the USDC token

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// AcadPay
// Allows students to pay school fees in USDC only
contract acadPay is ReentrancyGuard {
    IERC20 public immutable usdc; // fixed USDC token contract

    event FeePaid(address indexed student, address indexed school, uint256 amount);

    //_usdc Address of the official USDC token contract (e.g., Base Sepolia USDC)
    constructor(address _usdc) {
        require(_usdc != address(0), "Invalid USDC address");
        usdc = IERC20(_usdc);
    }

    // Pay school fees in USDC
    // schoolAddress Wallet address of the school
    // amount Amount of USDC to pay (in smallest unit, e.g., 6 decimals for USDC)
    function payFees(address schoolAddress, uint256 amount) external nonReentrant {
        require(schoolAddress != address(0), "Invalid school address");
        require(amount > 0, "Amount must be greater than 0");

        // Transfer ONLY USDC from student to school
        bool success = usdc.transferFrom(msg.sender, schoolAddress, amount);
        require(success, "USDC payment failed");

        emit FeePaid(msg.sender, schoolAddress, amount);
    }
}
