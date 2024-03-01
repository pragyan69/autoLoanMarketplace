const { ethers } = require("hardhat");
const {expect}   = require("chai")

describe("AutoLoanMarketplace", function () {
  let autoLoanMarketplace
  let owner, dealer, lender, customer;

  before(async function () {
    const AutoLoanMarketplace = await ethers.getContractFactory("AutoLoanMarketplace");
    autoLoanMarketplace = await AutoLoanMarketplace.deploy();

    [owner, dealer, lender, customer] = await ethers.getSigners();
  });

  // Your tests go here...
  describe("User Registration", function () {
    // Registering as Dealer
    it("Should register a dealer", async function () {
      await autoLoanMarketplace.connect(dealer).registerUser("dealer");
      const dealerInfo = await autoLoanMarketplace.users(dealer.address);
      expect(dealerInfo.isRegistered).to.be.true;
      expect(dealerInfo.userType).to.equal("dealer");
    });
    // registering as lender
    it("Should register a lender", async function () {
      await autoLoanMarketplace.connect(lender).registerUser("lender");
      const lenderInfo = await autoLoanMarketplace.users(lender.address);
      expect(lenderInfo.isRegistered).to.be.true;
      expect(lenderInfo.userType).to.equal("lender");
    });
    // Regsitering as Customer
    it("Should register a customer", async function () {
      await autoLoanMarketplace.connect(customer).registerUser("customer");
      const customerInfo = await autoLoanMarketplace.users(customer.address);
      expect(customerInfo.isRegistered).to.be.true;
      expect(customerInfo.userType).to.equal("customer");
    });
  });

  //2nd test
  describe("Loan Application and Approval", function () {
    it("Should allow a customer to apply for a loan", async function () {
      const loanAmount = "1000000000000000000"; // 1 ETH for simplicity
      await autoLoanMarketplace.connect(customer).applyForLoan(loanAmount);
      const loan = await autoLoanMarketplace.loans(0);
      expect(loan.amount).to.equal(loanAmount);
      expect(loan.customer).to.equal(customer.address);
      expect(loan.isApproved).to.be.false;
    });

    it("Should allow a lender to approve a loan", async function () {
      await autoLoanMarketplace.connect(lender).approveLoan(0); // Assuming loan ID is 0
      const loan = await autoLoanMarketplace.loans(0);
      expect(loan.isApproved).to.be.true;
      expect(loan.lender).to.equal(lender.address);
    });
  });
  
  // 3rd test
  describe("Funds Transfer", function () {
    it("Should transfer funds to the dealer upon loan approval", async function () {
      // This would require the contract to handle or simulate ETH transactions, which needs further implementation detail
      // For testing, assuming the function exists and emits an event upon successful transfer
      const loanId = 0; // Assuming the first loan
      await expect(autoLoanMarketplace.connect(lender).fundLoan(loanId, { value: "1000000000000000000" }))
        .to.emit(autoLoanMarketplace, "LoanFunded")
        .withArgs(loanId);
      // Further checks might require inspecting the dealer's balance or the loan's funded status
    });
  });

  // 4th test
  describe("Repayment and Default Handling", function () {
    it("Should allow a customer to make repayments", async function () {
      const loanId = 0;
      const prantu = "500000000000000000"
      await expect(autoLoanMarketplace.connect(customer).makeRepayment(loanId, { value: "500000000000000000" }))
        .to.emit(autoLoanMarketplace, "RepaymentMade")
        .withArgs(customer.address, prantu);

    });
  });
});
