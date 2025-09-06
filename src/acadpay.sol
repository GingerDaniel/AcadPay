// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// @title AcadPay
// @notice Students pay fees in USDC directly to registered universities
contract AcadPay {
    address public immutable admin;   // AcadPay admin
    address public immutable usdc;    // USDC token contract

    // University details
    // Each university has a unique ID, name, and wallet address
    // Only registered universities can receive payments

    struct University {
        string name;
        address wallet;
        bool registered;
    }

    // Payment details
    // Each payment has a unique txId, student details, university details, amount, and timestamp
    // Payments are stored in a mapping for easy retrieval
    // Students can pay fees to registered universities using USDC
    
    struct Payment {
        string studentId;
        string studentName;
        string universityName;
        uint256 amount;
        uint256 timestamp;
    }


    // Mappings to store universities and payments
    // universityCount keeps track of the number of registered universities
    
    mapping(uint256 => University) public universities;
    mapping(bytes32 => Payment) public payments;       
    uint256 public universityCount;

    // Events for logging university registrations and fee payments
    

    event UniversityRegistered(uint256 indexed universityId, string name, address wallet);
    event FeePaid(
        bytes32 indexed txId,
        uint256 indexed universityId,
        string universityName,
        string studentId,
        string studentName,
        address indexed student,
        uint256 amount,
        uint256 timestamp
    );

    // Modifier to restrict functions to admin only
    // Ensures only the admin can register universities
    

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }
    // Constructor to set admin and USDC token address
    // Admin is the deployer of the contract
    
    constructor(address _usdc) {
        require(_usdc != address(0), "Invalid USDC address");
        admin = msg.sender;
        usdc = _usdc;
    }

    // Register a new university
    // Only admin can register universities
    // Each university must have a unique wallet address
    
    function registerUniversity(string memory _name, address _wallet)
        external
        onlyAdmin
        returns (uint256)
    {
        require(_wallet != address(0), "Invalid wallet");

        universityCount++;
        universities[universityCount] = University({
            name: _name,
            wallet: _wallet,
            registered: true
        });

        emit UniversityRegistered(universityCount, _name, _wallet);
        return universityCount;
    }

    // Pay fees in USDC to a registered university
    function makePayment (
        uint256 _universityId,
        string memory _universityName, // must match the registered name
        string memory _studentId,
        string memory _studentName,
        uint256 _amount
    ) external returns (bytes32) {
        University memory uni = universities[_universityId];
        require(uni.registered, "University not registered");
        
        // This require ensures that the university name provided matches the registered name so students don't make mistakes
        // In solidty, you cant compare strings directly, so i used keccak256 to compare the hashes of the strings

        require(
            keccak256(bytes(uni.name)) == keccak256(bytes(_universityName)), 
            "University name mismatch"
        );
    
        // Amount must be > 0
        // Either studentId or studentName must be provided
        // USDC transfer must succeed
        require(_amount > 0, "Amount must be > 0");
        require(
            bytes(_studentId).length > 0 || bytes(_studentName).length > 0,
            "Student ID or Name required"
        );

        // Transfer USDC from student to university
        bool success = IERC20(usdc).transferFrom(msg.sender, uni.wallet, _amount);
        require(success, "USDC transfer failed");

        // Generate unique txId
        bytes32 txId = keccak256(
            abi.encodePacked(msg.sender, _universityId, block.timestamp, _amount)
        );

        // Save record
        payments[txId] = Payment({
            studentId: _studentId,
            studentName: _studentName,
            universityName: _universityName,
            amount: _amount,
            timestamp: block.timestamp
        });

        emit FeePaid(
            txId,
            _universityId,
            _universityName,
            _studentId,
            _studentName,
            msg.sender,
            _amount,
            block.timestamp
        );

        return txId;
    }
}
