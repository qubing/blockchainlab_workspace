'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network');
const path = require('path');
const FabricUtils = require('./utils.js');

function validateParameters() {
	if (!process.env.CONNECTION_PROFILE) {
		console.error(`Failed to transfer : No "CONNECTION_PROFILE" environment variable setup.`);
		process.exit(1);
	}

	if (!process.env.ORG_NAME) {
		console.error(`Failed to transfer : No "ORG_NAME" environment variable setup.`);
		process.exit(1);
	}

	if (process.argv.slice(2).length !== 3) {
		console.error(`Failed to transfer : wrong application arguments account setup. (expected: 3, [%sourceAccount%, %targetAccount%, %transferAmount%])`);
		process.exit(1);
	}

	if (!process.env.USER_NAME) {
		console.error(`Failed to transfer : No "USER_NAME" environment variable setup.`);
		process.exit(1);
	}
}

async function transfer(sourceAccount, targetAccount, transferAmount) {
	//make transaction by invoking 'transfer' of 'mycc' on 'mychannel'
	return await FabricUtils.invoke(ORG_NAME, USER_NAME, CCP_PATH, CH_NAME, CC_NAME, FUNC_NAME, [sourceAccount, targetAccount, transferAmount]);
}


//validate environment and application parameters.
validateParameters();

//load environment and application parameters.
let sourceAccount = process.argv.slice(2)[0];
let targetAccount = process.argv.slice(2)[1];
let transferAmount = process.argv.slice(2)[2];

const CCP_PATH = path.resolve(__dirname, process.env.CONNECTION_PROFILE);
const ORG_NAME = process.env.ORG_NAME;
const USER_NAME = process.env.USER_NAME;
const CH_NAME = 'mychannel';
const CC_NAME = 'mycc';
const FUNC_NAME = 'transfer';


transfer(sourceAccount, targetAccount, transferAmount).then((msg) => {
	console.log(msg);
}).catch((error) => {
	console.error(`Failed to invoke transaction: ${error}`);
	process.exit(1);
});