async function main() {
    const bettingContractFactory = await ethers.getContractFactory("BettingESport")
    const bettingContract = await bettingContractFactory.deploy()
    await bettingContract.deployed()
    console.log("Contract deployed to:", bettingContract.address)
}

main().catch((e) => console.log(e))