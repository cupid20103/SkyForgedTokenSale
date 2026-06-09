/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { INFURA_API_KEY, PRIVATE_KEY, SCAN_API_KEY } = process.env;

// Only attach a signing account when a private key is provided, so that local
// tasks like `compile` and `test` work without secrets configured.
const accounts = PRIVATE_KEY ? [`0x${PRIVATE_KEY}`] : [];

module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      chainId: 1,
      gasPrice: 2000000000,
      accounts,
    },
    sepolia: {
      url: `https://ethereum-sepolia-rpc.publicnode.com`,
      chainId: 11155111,
      gasPrice: 20000000000,
      accounts,
    },
    holesky: {
      url: `https://endpoints.omniatech.io/v1/eth/holesky/public`,
      chainId: 17000,
      gasPrice: 20000000000,
      accounts,
    },
    mainnet_bsc: {
      url: "https://bsc-dataseed.binance.org",
      chainId: 56,
      gasPrice: 20000000000,
      accounts,
    },
    testnet_bsc: {
      url: "https://endpoints.omniatech.io/v1/bsc/testnet/public",
      chainId: 97,
      gasPrice: 20000000000,
      accounts,
    },
    mainnet_polygon: {
      url: "https://matic-mainnet.chainstacklabs.com",
      chainId: 137,
      gasPrice: 2000000000,
      accounts,
    },
    testnet_polygon: {
      url: "https://polygon-mumbai-bor-rpc.publicnode.com",
      chainId: 80001,
      gasPrice: 2000000000,
      accounts,
    },
    base_sepolia: {
      url: "https://base-sepolia.blockpi.network/v1/rpc/public",
      chainId: 84532,
      gasPrice: 2000000000,
      accounts,
    },
  },
  etherscan: {
    apiKey: SCAN_API_KEY,
  },
};
