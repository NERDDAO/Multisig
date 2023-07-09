import { expect } from "chai";
import { ethers } from "hardhat";
import { Delegate } from "../typechain-types";

describe("Delegate", function () {
  // We define a fixture to reuse the same setup in every test.

  let delegate: Delegate;
  before(async () => {
    const [owner] = await ethers.getSigners();
    const delegateFactory = await ethers.getContractFactory("Delegate");
    delegate = (await delegateFactory.deploy(owner.address)) as Delegate;
    await delegate.deployed();
  });

  describe("Deployment", function () {
    it("Should have the right message on deploy", async function () {
      expect(await delegate.greeting()).to.equal("Building Unstoppable Apps!!!");
    });

    it("Should allow setting a new message", async function () {
      const newGreeting = "Learn Scaffold-ETH 2! :)";

      await delegate.setGreeting(newGreeting);
      expect(await delegate.greeting()).to.equal(newGreeting);
    });
  });
});
