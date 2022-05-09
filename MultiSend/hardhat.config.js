require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });

const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: "https://speedy-nodes-nyc.moralis.io/f6ff47227c3725475f842d37/eth/rinkeby",
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    binanceTest: {
      //url: "https://data-seed-prebsc-2-s3.binance.org:8545/",
      url: "https://speedy-nodes-nyc.moralis.io/f6ff47227c3725475f842d37/bsc/testnet",
      chainId: 97,
      gas: 4200000,
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    binance: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      gas: 4200000,
      accounts: [RINKEBY_PRIVATE_KEY],
    },
  },
};