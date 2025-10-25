const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SmartSukukToken", function () {
  let SmartSukukToken, sukuk, owner, investor1, investor2;

  beforeEach(async () => {
    [owner, investor1, investor2] = await ethers.getSigners();
    SmartSukukToken = await ethers.getContractFactory("SmartSukukToken");
    sukuk = await SmartSukukToken.deploy();
    await sukuk.waitForDeployment();
  });

  it("should allow owner to create and issue a partition", async () => {
    const partition = ethers.keccak256(ethers.toUtf8Bytes("RealEstate"));
    await sukuk.addToWhitelist(investor1.address);
    await sukuk.createPartition("RealEstate");
    await sukuk.issueByPartition(partition, investor1.address, 1000n);

    const bal = await sukuk.balanceOfByPartition(partition, investor1.address);
    expect(bal).to.equal(1000n);
  });

  it("should restrict non-whitelisted users", async () => {
    const partition = ethers.keccak256(ethers.toUtf8Bytes("Gold"));
    await sukuk.createPartition("Gold");
    await expect(
      sukuk.issueByPartition(partition, investor2.address, 500n)
    ).to.be.revertedWith("Not whitelisted");
  });

  it("should allow transfer within partition between whitelisted users", async () => {
    const partition = ethers.keccak256(ethers.toUtf8Bytes("Bond"));
    await sukuk.addToWhitelist(investor1.address);
    await sukuk.addToWhitelist(investor2.address);
    await sukuk.createPartition("Bond");
    await sukuk.issueByPartition(partition, investor1.address, 2000n);

    await sukuk.connect(investor1).transferByPartition(partition, investor2.address, 500n);
    const bal2 = await sukuk.balanceOfByPartition(partition, investor2.address);
    expect(bal2).to.equal(500n);
  });
});
