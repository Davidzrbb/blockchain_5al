// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;
import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract BettingESport {
    address public owner;
    mapping(address => uint256) public balances; // Les soldes des utilisateurs
    mapping(address => uint256) public bets; // Les paris des utilisateurs
    address[] public players; // Liste des joueurs
    bool public bettingOpen = true; // La période de paris est ouverte

    event BetPlaced(address indexed player, uint256 amount);
    event BetWinner(address indexed player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut effectuer cette operation");
    _;
    }

    modifier onlyBettingOpen() {
        require(bettingOpen, "La periode de paris est terminee");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function placeBet() external payable onlyBettingOpen {
        require(msg.value > 0, "Le montant du pari doit etre superieur a zero");
        balances[msg.sender] += msg.value;
        bets[msg.sender] += msg.value;
        players.push(msg.sender);
        emit BetPlaced(msg.sender, msg.value);
    }

    function closeBetting() external onlyOwner {
        bettingOpen = false;
    }

    function distributePrizes(address payable winner) external onlyOwner {
        require(!bettingOpen, "La periode de paris n'est pas encore terminee");
        require(bets[winner] > 0, "Le gagnant n'a pas fait de pari");
        uint256 totalBets = 0;
        for (uint256 i = 0; i < players.length; i++) {
            totalBets += bets[players[i]];
        }
        uint256 prize = address(this).balance;
        uint256 winnerShare = (bets[winner] * prize) / totalBets;
        winner.transfer(winnerShare);
        emit BetWinner(winner, winnerShare);
    }


    function withdrawFunds() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Aucun fonds disponibles");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

