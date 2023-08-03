import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-foundry';

const config: HardhatUserConfig = {
	solidity: {
		version: '0.8.21',
		settings: {
			outputSelection: {
				'*': {
					'*': ['storageLayout'],
				},
			},
		},
	},
};

export default config;
