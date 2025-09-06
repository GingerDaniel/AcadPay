// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/acadpay.sol";


/* 
ERIC, INCASE YOU RUN FURTHER TESTS LOCALLY AND IT FAILS, PLEASE LET ME KNOW SIR OR YOU CAN FIX IT YOURSELF.



THE MOCK USDC CONTRACT BELOW IS ONLY FOR TESTING PURPOSES.
 */

contract MockUSDC {
    string public constant name = "Mock USDC";
    string public constant symbol = "mUSDC";
    uint8 public constant decimals = 6;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Not enough balance");
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

contract AcadPayTest is Test {
    AcadPay acadPay;
    MockUSDC usdc;

    address admin = address(1);
    address university = address(2);
    address student = address(3);

    function setUp() public {
        // Deploy mock USDC
        usdc = new MockUSDC();

        // Deploy AcadPay contract as admin
        vm.startPrank(admin);
        acadPay = new AcadPay(address(usdc));
        vm.stopPrank();

        // Mint some USDC to student
        usdc.mint(student, 1000e6); // 1000 USDC (6 decimals)
    }

    function testRegisterUniversity() public {
        vm.startPrank(admin);
        uint256 id = acadPay.registerUniversity("UNILAG", university);
        vm.stopPrank();

        (string memory name, address wallet, bool registered) = acadPay.universities(id);
        assertEq(name, "UNILAG");
        assertEq(wallet, university);
        assertTrue(registered);
    }

    function testMakePayment() public {
        // Admin registers a university
        vm.startPrank(admin);
        uint256 id = acadPay.registerUniversity("UNILAG", university);
        vm.stopPrank();

        // Student approves USDC for AcadPay contract
        vm.startPrank(student);
        usdc.approve(address(acadPay), 500e6);

        // Make payment
        bytes32 txId = acadPay.makePayment(
            id,
            "UNILAG",
            "Reg123",
            "Kemi",
            200e6 // 200 USDC
        );
        vm.stopPrank();

        // Verify balances
        assertEq(usdc.balanceOf(university), 200e6);
        assertEq(usdc.balanceOf(student), 800e6);

        // Verify stored payment
        (
            string memory studentId,
            string memory studentName,
            string memory universityName,
            uint256 amount,
            uint256 timestamp
        ) = acadPay.payments(txId);

        assertEq(studentId, "Reg123");
        assertEq(studentName, "Kemi");
        assertEq(amount, 200e6);
    }
}
