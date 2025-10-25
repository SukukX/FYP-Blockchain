const hre = require("hardhat");

async function main() {
  const PropertyToken = await hre.ethers.getContractFactory("PropertyToken");
  const propertyToken = await PropertyToken.deploy();
  await propertyToken.waitForDeployment();

  console.log("PropertyToken deployed to:", await propertyToken.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
