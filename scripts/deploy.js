async function main() {
    const greetContractFactory = await ethers.getContractFactory("greet")
    const greetContract = await greetContractFactory.deploy()
    await greetContract.deployed()
    console.log("Contract deployed to:", greetContract.address)
}

main().catch((e) => console.log(e))