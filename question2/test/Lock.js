const { expect } = require("chai");

describe("MultiSigWallet", function () {
  let MultiSigWallet, multiSigWallet, owner1, owner2, owner3, nonOwner;

  beforeEach(async () => {
    MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
    [owner1, owner2, owner3, nonOwner] = await ethers.getSigners();
    multiSigWallet = await MultiSigWallet.deploy([owner1.address, owner2.address], 2);
  });

  describe("submitTransaction", () => {
    it("should allow owners to submit transactions", async () => {
      await multiSigWallet.connect(owner1).submitTransaction(owner3.address, 100, "0x");
      expect(await multiSigWallet.transactionCount()).to.equal(1);
    });

    it("should not allow non-owners to submit transactions", async () => {
      await expect(multiSigWallet.connect(nonOwner).submitTransaction(owner3.address, 100, "0x")).to.be.revertedWith("Only owners can submit transactions");
    });
  });

 

  
});
