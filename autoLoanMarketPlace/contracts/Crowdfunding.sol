// SPDX-License-Identifier: MIT
// Specifies the license for the source code

pragma solidity ^0.8.0;
// Specifies the compiler version

contract Crowdfunding {
    // Declare state variables
    address public owner;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    mapping(address => uint256) public contributions;
    bool public goalReached;

    // Declare events
    event ContributionReceived(address indexed contributor, uint256 amount);
    event GoalReached(address indexed owner, uint256 totalFunds);
    event FundsWithdrawn(address indexed contributor, uint256 amount);

    // Constructor to initialize state variables
    constructor(uint256 _fundingGoal) {
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        totalFunds = 0;
        goalReached = false;
    }

    // Modifier to restrict function access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Modifier to restrict function access to contributors
    modifier onlyContributor() {
        require(contributions[msg.sender] > 0, "You did not contribute to the campaign");
        _;
    }

    // Function to contribute to the crowdfunding campaign
    function contribute() public payable {
        require(msg.value > 0, "Contribution must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
// if total funds is reached and goalreached is reverted to true , then we will emit the goalReachec function
        if (totalFunds >= fundingGoal && !goalReached) {
            goalReached = true;
            emit GoalReached(owner, totalFunds);
        }
    }

    // Function to withdraw funds by the owner if the goal is reached
    function withdrawFunds() public onlyOwner {
        require(goalReached, "Funding goal has not been reached");
        payable(owner).transfer(totalFunds);
    }

    // Function to refund contributors if the goal is not reached
    function refund() public onlyContributor {
        require(!goalReached, "Funding goal was reached, cannot refund");
        uint256 contributedAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);

        emit FundsWithdrawn(msg.sender, contributedAmount);
    }
}
