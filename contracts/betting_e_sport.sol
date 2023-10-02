// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract BettingESport {
    address public owner;
    mapping(uint256 => Betting) public betting;
    mapping(uint256 => Bet) public bets;
    uint256 public betCounter;

    struct Betting {
        uint256 id;
        string name;
        bool isFinished;
        Team firstTeam;
        Team secondTeam;
    }

    struct Team {
        uint256 id;
        string name;
        uint256 value;
    }

    struct Bet {
        uint256 amount;
        uint256 bettingId;
        uint256 teamId;
        address payable player;
    }

    event BetPlaced(address indexed player, uint256 amount, Betting betting);
    event BetWinner(address indexed player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut effectuer cette operation");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    function createBet(Bet memory bet) external {
        require(bet.amount > 0, "Bet amount must be greater than 0");
        require(bet.amount <= 100, "Bet amount must be less than 100");
        require(bet.bettingId > 0 && bet.bettingId <= betCounter, "Bet must be valid");
        Betting storage bettingInstance = betting[bet.bettingId];
        require(!bettingInstance.isFinished, "Bet must be open");

        Bet memory newBet = Bet({
            amount: bet.amount,
            bettingId: bet.bettingId,
            teamId: bet.teamId,
            player: payable(msg.sender)
        });

        if (newBet.teamId == bettingInstance.firstTeam.id) {
            bettingInstance.firstTeam.value += newBet.amount;
        } else if (newBet.teamId == bettingInstance.secondTeam.id) {
            bettingInstance.secondTeam.value += newBet.amount;
        } else {
            revert("Team must be valid");
        }

        emit BetPlaced(msg.sender, newBet.amount, bettingInstance);
    }


    function createBetting(Betting memory newBetting) external onlyOwner {
        // Ensure the bet name is not empty
        require(bytes(newBetting.name).length > 0, "Bet name cannot be empty");

        // Increment bet counter
        betCounter += 1;
        uint256 firstTeamId = betCounter + 1;
        uint256 secondTeamId = betCounter + 2;
        // Create new betting instance
        Betting memory bettingInstance = Betting({
            id: betCounter,
            name: newBetting.name,
            isFinished: false,
            firstTeam: Team({id: firstTeamId, name: newBetting.firstTeam.name, value: 0}),
            secondTeam: Team({id: secondTeamId, name: newBetting.secondTeam.name, value: 0})
        });

        betting[betCounter] = bettingInstance;

        emit BetPlaced(msg.sender, betCounter, bettingInstance);
    }
}

