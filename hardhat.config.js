require("@nomiclabs/hardhat-ethers")
const path = require('path');
const dotenvPath = path.resolve(__dirname, './', '.env'); // Go up one level and look for .env file
require('dotenv').config({ path: dotenvPath });
const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY;

module.exports = {
    solidity: "0.8.9",
    networks: {
        hardhat: {},
        sepolia: {
            url: `${ALCHEMY_API_URL}`,
            accounts: [walletPrivateKey],
        },
    },
}