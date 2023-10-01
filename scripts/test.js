const {Web3} = require('web3');
const path = require('path');
const dotenvPath = path.resolve(__dirname, '..', '.env');
require('dotenv').config({path: dotenvPath});
const ABIDecoder = require('abi-decoder');

const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;
const walletAddress = process.env.WALLET_ADDRESS;

const web3 = new Web3(ALCHEMY_API_URL);
const contract = require('../artifacts/contracts/betting_e_sport.sol/BettingESport.json'); // Mettez à jour le chemin du fichier JSON du contrat
const parisEsportContract = new web3.eth.Contract(contract.abi, contractAddress);
ABIDecoder.addABI(parisEsportContract._jsonInterface);

async function placeBet() {
    const gasPrice = await web3.eth.getGasPrice();

    const transactionParameters = {
        to: contractAddress,
        data: parisEsportContract.methods.createBetting().encodeABI(),
        gas: 3000000,
        gasPrice: gasPrice,
        from: walletAddress
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    const receipt = await web3.eth.getTransactionReceipt(transaction.transactionHash);

    // Parse the receipt logs to find the emitted event
    const logs = ABIDecoder.decodeLogs(receipt.logs);
    const betPlacedEvent = logs.find(log => log.name === 'BetPlaced');
    if (betPlacedEvent) {
        const sender = betPlacedEvent.events[0].value;
        const betValue = betPlacedEvent.events[1].value;
        console.log(`Bet placed by ${sender} with a value of ${betValue}`);
    } else {
        console.log('BetPlaced event not found in the transaction receipt logs');
    }
}

//display betting
async function displayBetting() {
    const gasPrice = await web3.eth.getGasPrice();

    const transactionParameters = {
        to: contractAddress,
        data: parisEsportContract.methods.displayBetting().encodeABI(),
        gas: 3000000,
        gasPrice: gasPrice,
        from: walletAddress
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionParameters, walletPrivateKey);
    const transaction = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
    const receipt = await web3.eth.getTransactionReceipt(transaction.transactionHash);

    // Parse the receipt logs to find the emitted event
    const logs = ABIDecoder.decodeLogs(receipt.logs);
    const betPlacedEvent = logs.find(log => log.name === 'BetPlaced');
    if (betPlacedEvent) {
        const sender = betPlacedEvent.events[0].value;
        const betValue = betPlacedEvent.events[1].value;
        const betting = betPlacedEvent.events[2].value;
        console.log(`Bet placed by ${sender} with a value of ${betValue} on ${betting}`);
    } else {
        console.log('BetPlaced event not found in the transaction receipt logs');
    }
}

placeBet().then(() => {
    displayBetting();
});
