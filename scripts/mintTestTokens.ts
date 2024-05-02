import hre from "hardhat";

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const tokenFactory = await hre.ethers.getContractFactory("Token");

  const tokenSyms = ["wBTC", "wETH", "USDT", "USDC"];
  const addresses = [];

  for (let i = 0; i < tokenSyms.length; i++) {
    const token = await tokenFactory.deploy(tokenSyms[i], tokenSyms[i]);
    addresses.push(await token.getAddress());
  }

  const output = [];
  for (let i = 0; i < tokenSyms.length; i++) {
    output.push({ symbol: tokenSyms[i], address: addresses[i], decimals: 18 });
  }
  console.log(JSON.stringify(output));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
