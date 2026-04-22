const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const founderAddress = process.env.FOUNDER_ADDRESS;

  console.log("=== SYMMETRY DEPLOYMENT STARTED ===");
  console.log("Network:", hre.network.name);
  console.log("Deploying with account:", deployer.address);
  console.log("Founder address:", founderAddress);
  console.log("-----------------------------------");

  // 1. Deploy SymmetryToken
  console.log("Deploying SymmetryToken...");
  const SymmetryToken = await hre.ethers.getContractFactory("SymmetryToken");
  const token = await SymmetryToken.deploy(founderAddress, deployer.address);
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("SYM Token deployed to:", tokenAddress);

  // 2. Deploy RewardsVault
  console.log("Deploying RewardsVault...");
  const RewardsVault = await hre.ethers.getContractFactory("RewardsVault");
  const vault = await RewardsVault.deploy(tokenAddress, founderAddress);
  await vault.waitForDeployment();
  const vaultAddress = await vault.getAddress();
  console.log("RewardsVault deployed to:", vaultAddress);

  // 3. Deploy SymmetryVesting
  console.log("Deploying SymmetryVesting...");
  const duration = 365 * 24 * 60 * 60; // 1 year
  const cliff = 30 * 24 * 60 * 60; // 30 days
  const SymmetryVesting = await hre.ethers.getContractFactory("SymmetryVesting");
  const vesting = await SymmetryVesting.deploy(tokenAddress, founderAddress, duration, cliff);
  await vesting.waitForDeployment();
  const vestingAddress = await vesting.getAddress();
  console.log("SymmetryVesting deployed to:", vestingAddress);

  // 4. POST-DEPLOYMENT SETUP
  console.log("-----------------------------------");
  console.log("=== DEPLOYMENT SUMMARY ===");
  console.log("SYM_TOKEN_ADDRESS=" + tokenAddress);
  console.log("REWARDS_VAULT_ADDRESS=" + vaultAddress);
  console.log("VESTING_ADDRESS=" + vestingAddress);
  console.log("===================================");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
