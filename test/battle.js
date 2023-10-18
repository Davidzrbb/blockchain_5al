const {ethers, utils} = require('hardhat');
const {assert} = require('chai');

describe("Battle Contract", function () {
    let BattleHelper;
    let battleHelper;

    before(async () => {
        BattleHelper = await ethers.getContractFactory("BattleHelper");
        battleHelper = await BattleHelper.deploy();

        await battleHelper.deployed();
    });

    it("Should do a battle", async function () {

        const [owner, player1, player2] = await ethers.getSigners();
        
        const data = ethers.utils.hexlify([]);

        const packPrice = ethers.utils.parseEther("0.000001"); // Le prix du pack est de 0.000001 ether
        // // Assurez-vous que le compte possède au moins 0.000001 ether
        // await owner.sendTransaction({ to: player1.address, value: packPrice });
        // Appel de la fonction openPack en envoyant 0.000001 ether
        const openPackTx = await battleHelper.connect(player1).openPack({ value: packPrice });
        const receipt = await openPackTx.wait();
        const cardIdPlayer1 = receipt.events.find((e) => e.event === 'TransferSingle').args.id;
        assert.exists(cardIdPlayer1, "cardIdPlayer1 should exist");
        
        const battlePrice = ethers.utils.parseEther("0.1");
        const txInit = await battleHelper.connect(player1).initBattle(cardIdPlayer1, {value: battlePrice});
        const receiptInit = await txInit.wait();
        
        const battleInitEvent = receiptInit.events.find((e) => e.event === 'BattleInitiated');
        assert.exists(battleInitEvent, "BattleInitiated event should exist");
        const battleId = battleInitEvent.args._battleId;
        assert.equal(battleId, 1, "BattleId should be 1");

        /////////////////////////////

        const openPackTx2 = await battleHelper.connect(player2).openPack({ value: packPrice });
        const receipt2 = await openPackTx2.wait();
        const cardIdPlayer2 = receipt2.events.find((e) => e.event === 'TransferSingle').args.id;
        assert.exists(cardIdPlayer2, "cardIdPlayer2 should exist");

        let statCard4 = [25, 25, 25]; //base stats
        //id 4 is a common card so we can add a total of 5 points among the 3 stats
        statCard4[0] += 2;
        statCard4[1] += 2;
        statCard4[2] += 1;

        const txSelect = await battleHelper.connect(player2).selectBattle(cardIdPlayer2, battleId, statCard4, {value: battlePrice});
        const receiptSelect = await txSelect.wait();

        const battleSelectEvent = receiptSelect.events.find((e) => e.event === 'BattleSelected');
        assert.exists(battleSelectEvent, "BattleSelected event should exist");
        assert.equal(battleSelectEvent.args._res, true, "BattleSelected should be true");

        /////////////////////////////

        let statCard1 = [30, 30, 30]; //base stats
        //id 1 is a legendary card so we can add a total of 15 points among the 3 stats
        statCard1[0] += 5;
        statCard1[1] += 5;
        statCard1[2] += 5;

        const txConfirm = await battleHelper.connect(player1).confirmBattle(battleId, statCard1);
        const receiptConfirm = await txConfirm.wait();

        const battleDoBattleEvent = receiptConfirm.events.find((e) => (e.event === 'BattleDone' || e.event === 'BattleDoneDraw'));
        assert.exists(battleDoBattleEvent, "BattleDone event should exist");
        assert.equal(((battleDoBattleEvent.event === "BattleDone" || battleDoBattleEvent.event === "BattleDoneDraw") 
        && battleDoBattleEvent.args._res) , true, "BattleDone or BattleDoneDraw should be true");

        /////////////////////////////

        console.log("Player1: " + player1.address + " \nPlayer2: " + player2.address);
        console.log("Battle Done. Winner: " + battleDoBattleEvent.args._winner + " Loser: " + battleDoBattleEvent.args._loser);

        /////////////////////////////

        await battleHelper.burn(player1.address, cardIdPlayer1, 1);
        await battleHelper.burn(player2.address, cardIdPlayer2, 1);

    });

    

    

    
});
