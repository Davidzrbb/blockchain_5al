const { Web3 } = require('web3');
const path = require('path');
const dotenvPath = path.resolve(__dirname, '..', '.env');
require('dotenv').config({ path: dotenvPath });

const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;
const walletAddress = process.env.WALLET_ADDRESS;

const web3 = new Web3(ALCHEMY_API_URL);
const contract = require('../artifacts/contracts/betting_e_sport.sol/BettingESport.json'); // Mettez à jour le chemin du fichier JSON du contrat
const parisEsportContract = new web3.eth.Contract(contract.abi, contractAddress);

async function placeBet() {
    const gasPrice = await web3.eth.getGasPrice();
    const gasEstimate = await parisEsportContract.methods.placeBet().estimateGas();

    const transactionParameters = {
        to: contractAddress,
        data: parisEsportContract.methods.placeBet().encodeABI(),
        gas: gasEstimate,
        gasPrice: gasPrice,
        from: walletAddress,
        value: web3.utils.toWei("1", "ether")
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    console.log('Bet placed. Transaction Hash:', transaction.transactionHash);
}

async function closeBetting() {
    const gasPrice = await web3.eth.getGasPrice();
    const gasEstimate = await parisEsportContract.methods.closeBetting().estimateGas();

    const transactionParameters = {
        to: contractAddress,
        data: parisEsportContract.methods.closeBetting().encodeABI(),
        gas: gasEstimate,
        gasPrice: gasPrice,
        from: walletAddress,
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    console.log('Betting closed. Transaction Hash:', transaction.transactionHash);
}

async function distributePrizes() {
    const gasPrice = await web3.eth.getGasPrice();
    const gasEstimate = await parisEsportContract.methods.distributePrizes().estimateGas();

    const transactionParameters = {
        to: contractAddress,
        data: parisEsportContract.methods.distributePrizes().encodeABI(),
        gas: gasEstimate,
        gasPrice: gasPrice,
        from: walletAddress,
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    console.log('Prizes distributed. Transaction Hash:', transaction.transactionHash);
}

placeBet()
    .then(() => closeBetting())
    .then(() => distributePrizes())
    .catch(error => console.error(error));
