// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract BettingESport {
    address public owner;
    mapping(uint256 => Betting) public betting;
    mapping(uint256 => Bet[]) public bets;
    mapping(uint256 => Winner[]) public winners;
    uint256 public bettingCounter;
    mapping(uint256 => uint256) public betCounterByBettingId;
    

    struct Betting {
        uint256 id;
        string name;
        bool isFinished;
        Team firstTeam;
        Team secondTeam;
    }

    struct Winner {
        uint256 id;
        uint256 bettingId;
        address payable player;
        uint256 amount;
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
        require(bet.bettingId > 0 && bet.bettingId <= bettingCounter, "Bet must be valid");
        Betting storage bettingInstance = betting[bet.bettingId];
        require(!bettingInstance.isFinished, "Bet must be open");

        betCounterByBettingId[bet.bettingId] += 1;

        Bet memory newBet = Bet({
            amount: bet.amount,
            bettingId: bet.bettingId,
            teamId: bet.teamId,
            player: payable(bet.player)
        });
        bets[bet.bettingId].push(newBet);

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
        bettingCounter += 1;
        uint256 firstTeamId = bettingCounter + 1;
        uint256 secondTeamId = bettingCounter + 2;
        // Create new betting instance
        Betting memory bettingInstance = Betting({
            id: bettingCounter,
            name: newBetting.name,
            isFinished: false,
            firstTeam: Team({id: firstTeamId, name: newBetting.firstTeam.name, value: 0}),
            secondTeam: Team({id: secondTeamId, name: newBetting.secondTeam.name, value: 0})
        });

        betting[bettingCounter] = bettingInstance;

        emit BetPlaced(msg.sender, bettingCounter, bettingInstance);
    }

    function closeBet(uint256 bettingId, uint256 winnerTeamId) external onlyOwner {
        Betting storage bettingInstance = betting[bettingId];
        require(!bettingInstance.isFinished, "Bet must be open");
        require(winnerTeamId == bettingInstance.firstTeam.id || winnerTeamId == bettingInstance.secondTeam.id, "Team must be valid");

        bettingInstance.isFinished = true;

        for (uint256 index = 0; index < betCounterByBettingId[bettingId]; index++) {
            Bet storage bet = bets[bettingId][index];
            if (bet.bettingId == bettingId && bet.teamId == winnerTeamId) {
                uint256 amountWon = bet.amount;
                Winner memory winnerInstance = Winner({
                    id: bettingId,
                    bettingId: bettingId,
                    player: bet.player,
                    amount: amountWon * 2
                });
                winners[bettingId].push(winnerInstance);
                emit BetWinner(bet.player, amountWon);
            }
        }
    }
}
