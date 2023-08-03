import { ethers } from 'hardhat';

async function main() {
	const ERC20 = await ethers.getContractFactory('ERC20');
	const erc20 = await ERC20.deploy('Name', 'SYM', 18);

	console.log(`Deployed to ${await erc20.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
