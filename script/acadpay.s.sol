// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/acadpay.sol";

contract DeployAcadPay is Script {
    function run() external {
        // Please before deploying sir, load your deployer private key in .env file
        // Example: PRIVATE_KEY=yourkeyhere
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        // Base Sepolia USDC testnet address 

        address usdc = 0x036CbD53842c5426634e7929541eC2318f3dCF7e; // Eric, this is Base sepolia USDC address.

        vm.startBroadcast(deployerKey);

        AcadPay acadPay = new AcadPay(usdc);

        vm.stopBroadcast();

        /* Eric, to deploy, just run the deploy command in the terminal and you will pay gas with ETH and not with USDC. 
        The usdc contract address is only for students to pay with the stable coin instead of a volatile one. 
        
        DEPLOY TO BASE SEPOLIA TESTNET*/

        console.log(" AcadPay deployed at:", address(acadPay));
        console.log(" Using Base Sepolia USDC at:", usdc);
    }
}
