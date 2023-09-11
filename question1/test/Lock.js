const { expect } = require("chai");
const {ethers} = require ("hardhat");

describe("Crowdfunding", function () {
  let Crowdfunding, crowdfunding, owner, addr1, addr2;

  beforeEach(async function () {
    Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    [owner, addr1, addr2] = await ethers.getSigners();
    crowdfunding = await Crowdfunding.deploy(100);
  });

  describe("Contribution", function () {
    it("Should accept contributions and emit event", async function () {
      await expect(crowdfunding.connect(addr1).contribute({ value: 50 }))
        .to.emit(crowdfunding, "ContributionReceived")
        .withArgs(addr1.address, 50);
    });

    it("Should update total funds", async function () {
      await crowdfunding.connect(addr1).contribute({ value: 50 });
      expect(await crowdfunding.totalFunds()).to.equal(50);
    });
  });

  describe("Goal Reached", function () {
    it("Should emit GoalReached event when goal is reached", async function () {
      await expect(crowdfunding.connect(addr1).contribute({ value: 100 }))
        .to.emit(crowdfunding, "GoalReached")
        .withArgs(owner.address, 100);
    });
  });

  describe("Withdraw Funds", function () {
    it("Owner should be able to withdraw when goal is reached", async function () {
      await crowdfunding.connect(addr1).contribute({ value: 100 });
      await expect(crowdfunding.connect(owner).withdrawFunds())
        .to.changeEtherBalance(owner, 100);
    });
  });

  describe("Refund", function () {
    it("Contributors should be able to refund if goal is not reached", async function () {
      await crowdfunding.connect(addr1).contribute({ value: 50 });
      await expect(crowdfunding.connect(addr1).refund())
        .to.emit(crowdfunding, "FundsWithdrawn")
        .withArgs(addr1.address, 50);
    });
  });
});
