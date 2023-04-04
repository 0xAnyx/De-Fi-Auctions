import { HardhatUserConfig } from "hardhat/config";
import "hardhat-abi-exporter";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-deploy";
import "hardhat-tracer";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-web3";
import * as dotenv from "dotenv";
import "hardhat-gas-reporter";
dotenv.config({ path: __dirname + "/.env" });
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  // networks: {
  //   goerli: {
  //     url: "https://goerli.infura.io/v3/2fa7616a97224f70b68b56e5cd3ef2c4",
  //     accounts: [process.env.PRIVATE_KEY || ""],
  //   },
  //   mainnet: {
  //     url: "https://mainnet.infura.io/v3/2fa7616a97224f70b68b56e5cd3ef2c4",
  //     accounts: [process.env.PRIVATE_KEY || ""],
  //   },
  //   polygonMainnet: {
  //     url: "https://polygon-mainnet.g.alchemy.com/v2/MsfKKcvyX7YUvgH2jU7BQTbPzlKKgQba",
  //     accounts: [process.env.PRIVATE_KEY || ""],
  //   },
  //   mumbai: {
  //     url: "https://polygon-mumbai.infura.io/v3/6422400310bc4cb784d6a819632808b9",
  //     accounts: [process.env.PRIVATE_KEY || ""],
  //   },
  // },

  etherscan: {
    apiKey: {
      polygonMumbai: "VIT7XVFNT1RIGIMPDPY6QKEVJJ94DSNVVW",
      polygon: "9UHP9XAJW9C5CGVRG5IQ29ZEKTB7N12TRE",
      goerli: "31WXEYFAGW4JBBSRRJZRJQB2GB5D6MB48W",
      mainnet: "31WXEYFAGW4JBBSRRJZRJQB2GB5D6MB48W",
    },
  },

  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report-mint-burn.txt",
    showTimeSpent: true,
    noColors: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },

};

export default config;