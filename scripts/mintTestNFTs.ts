import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const nftFactory = await hre.ethers.getContractFactory("NFT");

  const tokenIDs = [4314, 5616, 11250, 5814];

  const nft = await nftFactory.deploy(
    "LilPudgys",
    "LP",
    "https://api.pudgypenguins.io/lil/"
  );

  for (let i = 0; i < tokenIDs.length; i++) {
    await nft.safeMint(deployer.address, tokenIDs[i]);
  }

  const nftAddress = await nft.getAddress();
  const nftObj = [];

  for (let i = 0; i < tokenIDs.length; i++) {
    nftObj.push({
      address: nftAddress,
      tokenID: tokenIDs[i],
      name: "LilPudgys",
      image: `https://api.pudgypenguins.io/lil/image/${tokenIDs[i]}`,
    });
  }
  console.log(JSON.stringify(nftObj));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
