import { expect } from 'chai';
import { ethers, network } from 'hardhat';
// import { smock } from '@defi-wonderland/smock';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

describe('ERC20', () => {
	const deployERC20 = async () => {
		const addresses = await ethers.getSigners();
		const alice = addresses[0];
		const bob = addresses[1];

		// const ERC20 = await ethers.getContractFactory('ERC20');
		const ERC20 = await ethers.getContractFactory('ERC20Mock');
		// const ERC20 = await smock.mock<ERC20__factory>('ERC20');
		const erc20 = await ERC20.deploy('Name', 'SYM', 18);

		// erc20.setVariable('balanceOf', {
		// 	[alice.address]: 300,
		// });
		// await network.provider.send('evm_mine');

		await erc20.mint(alice.address, 300);
		// await erc20.transfer(bob.address, 100);

		return { erc20, alice, bob };
	};

	it('Success: Transfer tokens', async () => {
		const { erc20, alice, bob } = await loadFixture(deployERC20);
		// Transfer from default address(Alice) to Bob
		await expect(
			await erc20.transfer(bob.address, 100)
		).to.changeTokenBalances(erc20, [alice, bob], [-100, 100]);

		// Transfer from Bob to Alice
		await expect(
			await erc20.connect(bob).transfer(alice.address, 50)
		).to.changeTokenBalances(erc20, [alice, bob], [50, -50]);
	});

	it('Revert: Transfer amount larger than balance', async () => {
		const { erc20, bob } = await loadFixture(deployERC20);
		await expect(erc20.transfer(bob.address, 500)).to.be.revertedWith(
			'ERC20: Insufficient sender balance.'
		);
	});

	it('Event: Transfer event should be emitted', async () => {
		const { erc20, alice, bob } = await loadFixture(deployERC20);
		await expect(erc20.transfer(bob.address, 100))
			.to.emit(erc20, 'Transfer')
			.withArgs(alice.address, bob.address, 100);
	});
});
