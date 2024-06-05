async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const SkyForgedTokenSale = await ethers.getContractFactory("SkyForgedTokenSale");
  const presaleContract = await SkyForgedTokenSale.deploy(0x6E202Cbb1bDCA017ee34dA4af91cedAEfb055b96, 0xb3342232FbF3A2C435f0b40dC73C181C1fe306Db);
  
  console.log("Contract deployed to address:", presaleContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });