// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const {ethers , upgrades} = require("hardhat");

async function main() {
  try {
    let owner;
    [owner] = await ethers.getSigners();

    console.log("Deploying contracts with admin address:", owner.address);

    const MultiCont = await ethers.getContractFactory("MulstiSend");
    const MultiDep = await NftDistribution.deploy();
    console.log("Deployment tx: ", MultiDep.deployTransaction);
    await MultiDep.deployed();
    console.log("NftDistribution deployed to:", MultiDep.address);

  } catch (error) {
    console.log(`error`, error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
