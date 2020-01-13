'use strict';

const { X509WalletMixin } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const FabricUtils = require('./utils.js');

function validateParameters() {
    if (!process.env.CONNECTION_PROFILE) {
        console.error(`Failed to enroll user : No "CONNECTION_PROFILE" environment variable setup.`);
        process.exit(1);
    }

    if (!process.env.ORG_NAME) {
        console.error(`Failed to register user : No "ORG_NAME" environment variable setup.`);
        process.exit(1);
    }

    if (!process.env.MSP_ID) {
        console.error(`Failed to register user : No "MSP_ID" environment variable setup.`);
        process.exit(1);
    }

    if (process.argv.slice(2).length !== 2) {
        console.error(`Failed to register user : wrong application arguments account setup. (expected: 2, [%user_name%, %user_secret%])`);
        process.exit(1);
    }

    if (!process.env.USER_NAME) {
        console.error(`Failed to register user : No "USER_NAME" environment variable setup.`);
        process.exit(1);
    }
}

async function registerUser(userName, userSecret) {
    // Create a new file system based wallet for managing identities.
    const wallet = FabricUtils.initFileWallet(ORG_NAME);

    // Check to see if we've already enrolled the user.
    const userExists = await wallet.exists(userName);
    if (userExists) {
        return 'An identity for the user "' + userName + '" already exists in the wallet';
    }

    // Check to see if we've already enrolled the admin user.
    const adminExists = await wallet.exists(USER_NAME);
    if (!adminExists) {
        return 'An identity for the admin user "'+ USER_NAME + '" does not exist in the wallet, run the enrollAdmin.js application before retrying';
    }

    // Create a new gateway for connecting to our peer node.
    const gateway = await FabricUtils.initGateway(wallet, CCP_PATH, USER_NAME);

    // Get the CA client object from the gateway for interacting with the CA.
    const caService = gateway.getClient().getCertificateAuthority();
    const adminUserContext = gateway.getCurrentIdentity();

    // Register the user, enroll the user, and import the new identity into the wallet.
    await caService.register(
        {
            enrollmentID: userName,
            enrollmentSecret: userSecret,
            role: 'client',
            maxEnrollments: -1
        }, 
        adminUserContext
    );
    const enrollment = await caService.enroll({
        enrollmentID: userName,
        enrollmentSecret: userSecret
    });
    const userData = X509WalletMixin.createIdentity(MSP_ID, enrollment.certificate, enrollment.key.toBytes());
    await wallet.import(userName, userData);
    return 'Successfully registered and enrolled user "'+userName + '" and imported it into the wallet';
}

//validate environment and application parameters.
validateParameters();

//load environment and application parameters.
let _newUserName = process.argv.slice(2)[0];
let _newUserSecret = process.argv.slice(2)[1];

const MSP_ID = process.env.MSP_ID;
const USER_NAME = process.env.USER_NAME;
const ORG_NAME = process.env.ORG_NAME;
const CCP_PATH = path.resolve(__dirname, process.env.CONNECTION_PROFILE);

//register user
registerUser(_newUserName, _newUserSecret).then((msg) => {
    console.log(msg);
}).catch((error) => {
    console.error(`Failed to register user ": ${error}`);
    process.exit(1);
});