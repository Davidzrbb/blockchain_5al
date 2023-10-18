async function main() {
    const battleHelperContractFactory = await ethers.getContractFactory("BattleHelper")
    const battleHelperContract = await battleHelperContractFactory.deploy()
    await battleHelperContract.deployed()
    console.log("Contract deployed to:", battleHelperContract.address)
}

main().catch((e) => console.log(e))