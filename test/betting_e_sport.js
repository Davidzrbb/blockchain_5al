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
            id: 0,
            name: "Sample Bet 1",
            isFinished: false,
            firstTeam: {id: 0, name: "Team A", value: 0},
            secondTeam: {id: 1, name: "Team B", value: 0}
        };

        await bettingESport.createBetting(newBetting);
        const bet = await bettingESport.betting(1);

        assert.equal(bet.name, newBetting.name, "Bet name should match");
        assert.equal(bet.firstTeam.name, newBetting.firstTeam.name, "First team name should match");
        assert.equal(bet.firstTeam.value, newBetting.firstTeam.value, "First team score should match");
        assert.equal(bet.secondTeam.name, newBetting.secondTeam.name, "Second team name should match");
        assert.equal(bet.secondTeam.value, newBetting.secondTeam.value, "Second team score should match");
    });


    it("Should place a bet", async function () {
        const bettingInstance = await bettingESport.betting(1);
        const bet = {
            amount: 10,
            bettingId: bettingInstance.id,
            teamId: bettingInstance.firstTeam.id,
            player: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
        };
        await bettingESport.createBet(bet);
        const newBettingInstance = await bettingESport.betting(1);
        assert.equal(newBettingInstance.firstTeam.value, bet.amount, "Bet amount should match");
    });
});
