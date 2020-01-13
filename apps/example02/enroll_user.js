'use strict';


const { X509WalletMixin } = require('fabric-network');
const path = require('path');
const FabricUtils = require('./utils.js');

function validateParameters() {
    if (!process.env.CONNECTION_PROFILE) {
        console.error(`Failed to enroll user : No "CONNECTION_PROFILE" environment variable setup.`);
        process.exit(1);
    }

    if (!process.env.ORG_NAME) {
        console.error(`Failed to enroll user : No "ORG_NAME" environment variable setup.`);
        process.exit(1);
    }

    if (!process.env.MSP_ID) {
        console.error(`Failed to enroll user : No "MSP_ID" environment variable setup.`);
        process.exit(1);
    }

    if (process.argv.slice(2).length !== 2) {
        console.error(`Failed to enroll user : wrong application arguments account setup. (expected: 2, [%user_name%, %user_secret%])`);
        process.exit(1);
    }
}

async function enrollUser(orgName, userName, userSecret) {
    // Create a new CA client for interacting with the CA.
    const ca = FabricUtils.newFabricCAServices(CCP_PATH, orgName);

    // Create a new file system based wallet for managing identities.
    const wallet = FabricUtils.initFileWallet(orgName);

    // Check to see if we've already enrolled the user.
    const userExists = await wallet.exists(userName);
    if (userExists) {
        return 'An identity for the user "' + userName + '" already exists in the wallet';
    }

    // Enroll the user, and import the new identity into the wallet.
    const enrollment = await ca.enroll({
        enrollmentID: userName,
        enrollmentSecret: userSecret
    });
    const userData = X509WalletMixin.createIdentity(MSP_ID, enrollment.certificate, enrollment.key.toBytes());
    await wallet.import(userName, userData);
    return `Successfully enrolled user "${userName}" and imported it into the wallet`;
}

//validate environment and application parameters.
validateParameters();

//load environment and application parameters.
let _orgName = process.env.ORG_NAME;
let _userName = process.argv.slice(2)[0];
let _userSecret = process.argv.slice(2)[1];

const MSP_ID = process.env.MSP_ID;
const CCP_PATH = path.resolve(__dirname, process.env.CONNECTION_PROFILE);

//enroll user
enrollUser(_orgName, _userName, _userSecret).then((msg) => {
    console.log(msg);
}).catch((error) => {
    console.error(`Failed to enroll user : ${error}`);
    process.exit(1);
});