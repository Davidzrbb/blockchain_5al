require("@nomiclabs/hardhat-ethers")
const path = require('path');
const dotenvPath = path.resolve(__dirname, './', '.env'); // Go up one level and look for .env file
require('dotenv').config({ path: dotenvPath });
const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY;

module.exports = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
        },
    },
    networks: {
        hardhat: {},
        sepolia: {
            url: `${ALCHEMY_API_URL}`,
            accounts: [walletPrivateKey],
        },
    },
}