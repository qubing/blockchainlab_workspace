'use strict';

const { Gateway, FileSystemWallet } = require('fabric-network');
const path = require('path');
const FabricUtils = require('./utils.js');

function validateParameters() {
	if (!process.env.CONNECTION_PROFILE) {
		console.error(`Failed to query : No "CONNECTION_PROFILE" environment variable setup.`);
		process.exit(1);
	}

	if (!process.env.ORG_NAME) {
		console.error(`Failed to query : No "ORG_NAME" environment variable setup.`);
		process.exit(1);
	}

	if (process.argv.slice(2).length !== 1) {
		console.error(`Failed to query : wrong application arguments account setup. (expected: 1, [%account_No%])`);
		process.exit(1);
	}

	if (!process.env.USER_NAME) {
		console.error(`Failed to query : No "USER_NAME" environment variable setup.`);
		process.exit(1);
	}
}

async function query(accountNo) {
	//read data by invoking 'query' of 'mycc' on 'mychannel'
	return FabricUtils.query(ORG_NAME, USER_NAME, CCP_PATH, CH_NAME, CC_NAME, FUNC_NAME, [accountNo]);
}

//validate environment and application parameters.
validateParameters();

//load environment and application parameters.
const _accountNo = process.argv.slice(2)[0];

const CCP_PATH = path.resolve(__dirname, process.env.CONNECTION_PROFILE);
const ORG_NAME = process.env.ORG_NAME;
const USER_NAME = process.env.USER_NAME;
const CH_NAME = 'mychannel';
const CC_NAME = 'mycc';
const FUNC_NAME = 'query';

query(_accountNo).then((msg) => {
	console.log(msg);
}).catch((error) => {
	console.error(`Failed to query data: ${error}`);
	process.exit(1);
});