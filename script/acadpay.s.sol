// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/acadpay.sol";

contract DeployScript is Script {
    // Base Sepolia USDC contract address
    address constant USDC_BASE_SEPOLIA = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    function run() external {
        vm.startBroadcast();

        // Deploy acadPay with USDC address
        acadPay payment = new acadPay(USDC_BASE_SEPOLIA);

        console.log("acadPay deployed at:", address(payment));
        console.log("Using USDC address:", USDC_BASE_SEPOLIA);

        vm.stopBroadcast();
    }
}
