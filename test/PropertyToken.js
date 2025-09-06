const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PropertyToken", function () {
  let PropertyToken, propertyToken, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    PropertyToken = await ethers.getContractFactory("PropertyToken");
    propertyToken = await PropertyToken.deploy();
    // await propertyToken.deployed();
  });

  it("should deploy with correct name and symbol", async function () {
    expect(await propertyToken.name()).to.equal("Property Token");
    expect(await propertyToken.symbol()).to.equal("PROP");
  });

  it("should allow a user to tokenize a property and mint tokens", async function () {
    const tx = await propertyToken
      .connect(addr1)
      .tokenizeProperty("Green Villa", 1000000, 1000);

    await tx.wait();

    // PropertyCounter should increment
    expect(await propertyToken.propertyCounter()).to.equal(1);

    // Check property details
    const property = await propertyToken.getProperty(1);
    expect(property.name).to.equal("Green Villa");
    expect(property.valuation).to.equal(1000000);
    expect(property.tokenSupply).to.equal(1000);
    expect(property.owner).to.equal(addr1.address);
    expect(property.exists).to.equal(true);

    // Token balance of addr1 should increase
    expect(await propertyToken.balanceOf(addr1.address)).to.equal(1000);
  });

  it("should revert if token supply is 0", async function () {
    await expect(
      propertyToken.connect(addr1).tokenizeProperty("Zero Villa", 500000, 0)
    ).to.be.revertedWith("Supply must be > 0");
  });

  it("should revert when fetching a non-existing property", async function () {
    await expect(propertyToken.getProperty(999)).to.be.revertedWith(
      "Property does not exist"
    );
  });
});
