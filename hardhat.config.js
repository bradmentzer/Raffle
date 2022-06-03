require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-waffle");

module.exports = {
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 4,
      saveDeployment: true,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  solidity: "0.8.7",
};
