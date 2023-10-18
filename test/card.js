const {ethers, utils} = require('hardhat');
const {assert} = require('chai');

describe("Card Contract", function () {
    let CardHelper;
    let cardHelper;

    before(async () => {
        CardHelper = await ethers.getContractFactory("CardHelper");
        cardHelper = await CardHelper.deploy();
        await cardHelper.deployed();
    });

    it("Should mint a new card", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        await cardHelper.mint(owner.address, 1, 1, data);

        let balance = await cardHelper.getBalanceOf(1, owner.address);


        assert.equal(balance, 1, "Should have 1 card of id 1");
        await cardHelper.burn(owner.address, 1, 1);
        balance = await cardHelper.getBalanceOf(1, owner.address);

        assert.equal(balance, 0, "Should have no more card of id 1");

    });

    it("Should count 2 exemple of card id 1 on 2 different mint", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        await cardHelper.mint(owner.address, 1, 1, data);
        await cardHelper.mint(owner.address, 1, 1, data);

        let balance = await cardHelper.getBalanceOf(1, owner.address);


        assert.equal(balance, 2, "Should have 2 card of id 1");
        await cardHelper.burn(owner.address, 1, 2);
        balance = await cardHelper.getBalanceOf(1, owner.address);
        assert.equal(balance, 0, "Should have no more card of id 1");
        
    });

    it("Should count 2 exemple of card id 1 on a single mint", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        await cardHelper.mint(owner.address, 1, 2, data);

        let balance = await cardHelper.getBalanceOf(1, owner.address);


        assert.equal(balance, 2, "Should have 2 card of id 1");
        await cardHelper.burn(owner.address, 1, 2);
        balance = await cardHelper.getBalanceOf(1, owner.address);
        assert.equal(balance, 0, "Should have no more card of id 1");
        
    });

    it("Should count [random] exemple of card id 1 ", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        const random = Math.floor(Math.random() * 100);
        await cardHelper.mint(owner.address, 1, random, data);

        let balance = await cardHelper.getBalanceOf(1, owner.address);


        assert.equal(balance, random, "Should have [random] card of id 1");
        
        await cardHelper.burn(owner.address, 1, random);
        balance = await cardHelper.getBalanceOf(1, owner.address);
        assert.equal(balance, 0, "Should have no more card of id 1");
    });

    it("Should count [random] exemple of card id 1 on [random] amount of mint", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        let total = 0;
        
        const randomMintAmount = Math.floor(Math.random() * 100);

        for (let i = 0; i < randomMintAmount; i++) {
            let random = Math.floor(Math.random() * 100);
            total += random;
            await cardHelper.mint(owner.address, 1, random, data);
        }
        
        let balance = await cardHelper.getBalanceOf(1, owner.address);

        assert.equal(balance, total, "Should have [random] card of id 1");

        await cardHelper.burn(owner.address, 1, total);
        balance = await cardHelper.getBalanceOf(1, owner.address);
        assert.equal(balance, 0, "Should have no more card of id 1");
        
    });

    it("Should mint 2 diffrent card", async function () {

        const [owner] = await ethers.getSigners();
        //const data = utils.toUtf8Bytes("");
        const data = ethers.utils.hexlify([]);
        await cardHelper.mint(owner.address, 1, 3, data);
        await cardHelper.mint(owner.address, 3, 5, data);

        let list = await cardHelper.getAllBalance(owner.address);

        let map = new Map();

        for (let i = 0; i < list.length; i++) {
            if(list[i] != 0){
                map.set(i + 1, list[i]);
            }
        }

        assert.equal(map.get(1), 3, "Should have 3 card id 1");
        assert.equal(map.get(3), 5, "Should have 5 card id 3");
        assert.equal(map.get(2), undefined, "Should not have card id 2");

        await cardHelper.burn(owner.address, 1, 3);
        await cardHelper.burn(owner.address, 3, 5);
        list = await cardHelper.getAllBalance(owner.address);

        map = new Map();

        for (let i = 0; i < list.length; i++) {
            if(list[i] != 0){
                map.set(i + 1, list[i]);
            }
        }

        assert.equal(map.get(1), undefined, "Should not have card id 1");
        assert.equal(map.get(3), undefined, "Should not have card id 3");
        assert.equal(map.get(2), undefined, "Should not have card id 2");

    });

    it("should mint a card", async function() {
        const [owner, addr1] = await ethers.getSigners();
        const packPrice = ethers.utils.parseEther("0.000001"); // Le prix du pack est de 0.000001 ether

        // Assurez-vous que le compte possède au moins 0.000001 ether
        await owner.sendTransaction({ to: owner.address, value: packPrice });

        // Appel de la fonction openPack en envoyant 0.000001 ether
        const openPackTx = await cardHelper.connect(owner).openPack({ value: packPrice });
        const receipt = await openPackTx.wait();

        

       assert.equal(receipt.events != undefined, true, "should emit event");

        assert.equal(receipt.events[0].event, "TransferSingle", "should emit an event");
        assert.equal(receipt.events[0].args.id >= 1 && receipt.events[0].args.id <= 9, true, "should mint a card");
        assert.equal(receipt.events[0].args.value == 1, true, "should mint one card");
        assert.equal(receipt.events[0].args.to, owner.address, "should mint a card for the owner");
        assert.equal(await cardHelper.getBalanceOf(receipt.events[0].args.id, owner.address), 1, "should have the card one time in his balance");

        await cardHelper.burn(owner.address, receipt.events[0].args.id, 1);
        assert.equal(await cardHelper.getBalanceOf(receipt.events[0].args.id, owner.address), 0, "should have no more card in his balance");
    });

    

    
});
