const {ethers} = require('hardhat');
const {assert} = require('chai');

describe("Card Contract", function () {
    let Card;
    let card;

    before(async () => {
        Card = await ethers.getContractFactory("Card");
        card = await Card.deploy();
        await card.deployed();
    });

    it("Should mint a new card", async function () {
        // Votre test ici
        // const newBetting = {
        //     id: 0,
        //     name: "Sample Bet 1",
        //     isFinished: false,
        //     firstTeam: {id: 0, name: "Team A", value: 0},
        //     secondTeam: {id: 1, name: "Team B", value: 0}
        // };

        // await bettingESport.createBetting(newBetting);
        // const bet = await bettingESport.betting(1);

        // assert.equal(bet.name, newBetting.name, "Bet name should match");
        // assert.equal(bet.firstTeam.name, newBetting.firstTeam.name, "First team name should match");
        // assert.equal(bet.firstTeam.value, newBetting.firstTeam.value, "First team score should match");
        // assert.equal(bet.secondTeam.name, newBetting.secondTeam.name, "Second team name should match");
        // assert.equal(bet.secondTeam.value, newBetting.secondTeam.value, "Second team score should match");
    });


    
});
