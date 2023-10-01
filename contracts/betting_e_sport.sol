// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract BettingESport {
    address public owner;
    mapping(uint256 => Betting) public betting;
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
        uint256 score;
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

    function createBetting(Betting memory newBetting) external onlyOwner {
        // Ensure teams have unique IDs
        require(newBetting.firstTeam.id != newBetting.secondTeam.id, "Team IDs must be unique");

        // Ensure the bet name is not empty
        require(bytes(newBetting.name).length > 0, "Bet name cannot be empty");

        // Increment bet counter
        betCounter++;

        // Create new betting instance
        Betting memory bettingInstance = Betting({
            id: betCounter,
            name: newBetting.name,
            isFinished: false,
            firstTeam: Team({id: newBetting.firstTeam.id, name: newBetting.firstTeam.name, score: 0}),
            secondTeam: Team({id: newBetting.secondTeam.id, name: newBetting.secondTeam.name, score: 0})
        });

        betting[betCounter] = bettingInstance;

        emit BetPlaced(msg.sender, betCounter, bettingInstance);
    }
    //get all betting
    function getAllBetting() external view returns (Betting[] memory) {
        Betting[] memory bettings = new Betting[](betCounter);
        for (uint256 i = 0; i < betCounter; i++) {
            bettings[i] = betting[i + 1];
        }
        return bettings;
    }

}

