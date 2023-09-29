const { Web3 } = require('web3');
const path = require('path');
const dotenvPath = path.resolve(__dirname, '..', '.env');
require('dotenv').config({ path: dotenvPath });


const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY
const contractAddress = process.env.CONTRACT_ADDRESS;
const walletAddress = process.env.WALLET_ADDRESS;

const web3 = new Web3(ALCHEMY_API_URL);
const contract = require('../artifacts/contracts/greet.sol/greet.json');
const contracts = new web3.eth.Contract(contract.abi, contractAddress);

const incrementGreetings = async () => {
    const gasPrice = await web3.eth.getGasPrice();
    const gasEstimate = await contracts.methods.greetings().estimateGas();

    const transactionParameters = {
        to: contractAddress,
        data: contracts.methods.greetings().encodeABI(),
        gas: gasEstimate,
        gasPrice: gasPrice,
        from: walletAddress,
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    console.log('Transaction Hash:', transaction.transactionHash);
}
getContractMessage = async () => {
    const message = await contracts.methods.getAmountOfGreetings().call();
    console.log(message);
}
incrementGreetings().then(() => {
    getContractMessage().then(r => console.log("finished"));
});
