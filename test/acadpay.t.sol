// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/acadpay.sol";

contract MockUSDC is IERC20 {
    string public constant name = "Mock USDC";
    string public constant symbol = "mUSDC";
    uint8 public constant decimals = 6;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address, uint256) external pure override returns (bool) {
        revert("Not implemented");
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");

        balanceOf[from] -= amount;
        allowance[from][msg.sender] -= amount;
        balanceOf[to] += amount;

        return true;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }
}

contract acadPayPaymentTest is Test {
    acadPay public payment;
    MockUSDC public usdc;

    address student = address(0x1);
    address school = address(0x2);

    function setUp() public {
        usdc = new MockUSDC();
        payment = new acadPay(address(usdc));

        // Mint some USDC to student
        usdc.mint(student, 1000e6); // 1000 USDC (6 decimals)
    }

    function test_PayFeesSuccess() public {
        uint256 amount = 100e6; // 100 USDC

        // Student approves contract
        vm.prank(student);
        usdc.approve(address(payment), amount);

        // Student pays school fees
        vm.prank(student);
        payment.payFees(school, amount);

        // Verify balances
        assertEq(usdc.balanceOf(school), amount);
        assertEq(usdc.balanceOf(student), 900e6);
    }

    function test_RevertWhen_NoApproval() public {
        vm.prank(student);
        vm.expectRevert(); // revert because no approval
        payment.payFees(school, 50e6);
    }

    function test_RevertWhen_InvalidSchoolAddress() public {
        vm.prank(student);
        vm.expectRevert("Invalid school address"); // matches require message
        payment.payFees(address(0), 50e6);
    }
}
