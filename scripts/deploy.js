const hre = require("hardhat");

async function main() {
  const SmartSukukToken = await hre.ethers.getContractFactory("SmartSukukToken");
  const contract = await SmartSukukToken.deploy();
  await contract.waitForDeployment();

  console.log("SmartSukukToken deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
