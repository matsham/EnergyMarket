// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const lockedAmount = hre.ethers.utils.parseEther("1");
  
  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();

  await nft.deployed();

  const MarketBase = await hre.ethers.getContractFactory("MarketBase");
  const marketbase = await MarketBase.deploy();
  await marketbase.deployed();
  
  const MarketFactory = await hre.ethers.getContractFactory("energy_market");
  const marketfactory = await MarketFactory.deploy();
  await marketfactory.deployed();

  const EnergyMarket = await hre.ethers.getContractFactory("energy_market");
  const energymarket = await EnergyMarket.deploy();
  await energymarket.deployed();

  
  
  
  

  console.log(
    `NFT contract deployed to ${nft.address}`
  );

  console.log(
    `market base contract deployed to ${marketbase.address}`
  );

  console.log(
    `market factory contract deployed to ${marketfactory.address}`
  );

  console.log(
    `energymarket contract deployed to ${energymarket.address}`
  );
  
  

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
}
