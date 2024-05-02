import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const nftLendingFactory = await hre.ethers.getContractFactory("NftLending");
  const nftLending = await nftLendingFactory.deploy();
  console.log(await nftLending.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
