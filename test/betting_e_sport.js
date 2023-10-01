const {ethers} = require('hardhat');
const {assert} = require('chai');

describe("BettingESport Contract", function () {
    let BettingESport;
    let bettingESport;

    before(async () => {
        BettingESport = await ethers.getContractFactory("BettingESport");
        bettingESport = await BettingESport.deploy();
        await bettingESport.deployed();
    });

    it("Should create a new bet", async function () {
        // Votre test ici
        const newBetting = {
            id: 1,
            name: "Sample Bet",
            isFinished: false,
            firstTeam: {id: 1, name: "Team A", score: 0},
            secondTeam: {id: 2, name: "Team B", score: 0}
        };

        await bettingESport.createBetting(newBetting);
        const bet = await bettingESport.betting(1);

        assert.equal(bet.name, newBetting.name, "Bet name should match");
        assert.equal(bet.firstTeam.id, newBetting.firstTeam.id, "First team ID should match");
        assert.equal(bet.firstTeam.name, newBetting.firstTeam.name, "First team name should match");
        assert.equal(bet.firstTeam.score, newBetting.firstTeam.score, "First team score should match");
        assert.equal(bet.secondTeam.id, newBetting.secondTeam.id, "Second team ID should match");
        assert.equal(bet.secondTeam.name, newBetting.secondTeam.name, "Second team name should match");
        assert.equal(bet.secondTeam.score, newBetting.secondTeam.score, "Second team score should match");
    });

    it("Should get all betting", async function () {
        const newBetting = {
            id: 1,
            name: "Sample Bet",
            isFinished: false,
            firstTeam: {id: 1, name: "Team A", score: 0},
            secondTeam: {id: 2, name: "Team B", score: 0}
        };

        await bettingESport.createBetting(newBetting);
        const betting = await bettingESport.getAllBetting();
        const index = betting.length - 1;
        assert.equal(betting[index].name, newBetting.name, "Bet name should match");
        assert.equal(betting[index].firstTeam.id, newBetting.firstTeam.id, "First team ID should match");
        assert.equal(betting[index].firstTeam.name, newBetting.firstTeam.name, "First team name should match");
        assert.equal(betting[index].firstTeam.score, newBetting.firstTeam.score, "First team score should match");
        assert.equal(betting[index].secondTeam.id, newBetting.secondTeam.id, "Second team ID should match");
        assert.equal(betting[index].secondTeam.name, newBetting.secondTeam.name, "Second team name should match");
        assert.equal(betting[index].secondTeam.score, newBetting.secondTeam.score, "Second team score should match");
    });
});
