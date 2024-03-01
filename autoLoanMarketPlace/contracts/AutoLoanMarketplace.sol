// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutoLoanMarketplace {
    struct User {
        bool isRegistered;
        string userType; // "dealer", "lender", or "customer"
    }

    struct Loan {
        address customer;
        address lender;
        uint256 amount;
        bool isApproved;
        bool isFunded;
    }

    mapping(address => User) public users;
    Loan[] public loans;

    // Events
    event UserRegistered(address user, string userType);
    event LoanApplied(uint256 loanId, address customer, uint256 amount);
    event LoanApproved(uint256 loanId, address lender);
    event LoanFunded(uint256 loanId);
    event RepaymentMade(address customer, uint256 amount);

    // Modifiers
    modifier onlyRegisteredUser() {
        require(users[msg.sender].isRegistered, "User not registered.");
        _;
    }

    // Register users with a type
    function registerUser(string memory userType) public {
        require(!users[msg.sender].isRegistered, "User already registered.");
        users[msg.sender] = User(true, userType);
        emit UserRegistered(msg.sender, userType);
    }

    // Apply for a loan
    function applyForLoan(uint256 amount) public onlyRegisteredUser {
        require(keccak256(bytes(users[msg.sender].userType)) == keccak256(bytes("customer")), "Only customers can apply for loans.");
        loans.push(Loan(msg.sender, address(0), amount, false, false));
        emit LoanApplied(loans.length - 1, msg.sender, amount);
    }

    // Approve a loan
    function approveLoan(uint256 loanId) public onlyRegisteredUser {
        require(keccak256(bytes(users[msg.sender].userType)) == keccak256(bytes("lender")), "Only lenders can approve loans.");
        Loan storage loan = loans[loanId];
        require(!loan.isApproved, "Loan already approved.");
        loan.lender = msg.sender;
        loan.isApproved = true;
        emit LoanApproved(loanId, msg.sender);
    }

    // Fund a loan
    function fundLoan(uint256 loanId) public payable onlyRegisteredUser {
        Loan storage loan = loans[loanId];
        require(loan.isApproved, "Loan not approved.");
        require(msg.sender == loan.lender, "Only the approved lender can fund the loan.");
        require(msg.value == loan.amount, "Incorrect funding amount.");
        loan.isFunded = true;
        payable(address(uint160(loan.customer))).transfer(msg.value);
        emit LoanFunded(loanId);
    }

    // Make a repayment (simplified)
    function makeRepayment(uint256 loanId) public payable onlyRegisteredUser {
        Loan storage loan = loans[loanId];
        require(loan.isFunded, "Loan not funded.");
        require(msg.sender == loan.customer, "Only the customer can make repayments.");
        // In a real application, you would track repayment amounts, handle overpayments, underpayments, etc.
        emit RepaymentMade(msg.sender, msg.value);
    }

    // View function to get loan details
    function getLoanDetails(uint256 loanId) public view returns (Loan memory) {
        return loans[loanId];
    }
}
