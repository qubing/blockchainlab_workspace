'use strict';

const fs = require('fs');
const path = require('path');
const FabricCAServices = require('fabric-ca-client');
const { Gateway, FileSystemWallet } = require('fabric-network');

const WALLET_ROOT = 'wallet';

const RESULT_SUCCESS = "SUCCESS";
const RESULT_FAILURE = "FAILURE";
class InvokeResult {
    static newFailure(error, result) {
        return new InvokeResult(RESULT_FAILURE, result, error);
    }

    static newSuccess(result) {
        return new InvokeResult(RESULT_SUCCESS, result);
    }

    constructor(status = RESULT_SUCCESS, result, error) {
        this.status = status;
        let resultJSON = result.toJSON();
        if (resultJSON.type === "Buffer") {
            this.result = result.toString();
        } else {
            this.result = result.toJSON();
        }
        this.error = error;
    }

    getStatus() {
        return this.status;
    }

    getResult() {
        return this.result;
    }

    getError() {
        return this.error;
    }
}

/**
 * Initialize {FileSystemWallet} by name (sub-folder in wallet root path).
 * @param {string} walletName
 * @returns {FileSystemWallet}
 */
function initFileWallet(walletName) {
    const walletPath = path.join(__dirname, WALLET_ROOT, walletName);
    return new FileSystemWallet(walletPath);
}

/**
 * Initialize {Gateway} by reading connection profile file.
 * @async
 * @param {Wallet} wallet
 * @param {string} ccpPath connection profile file path
 * @param {string} userName name of current user
 * @returns {Gateway}
 */
async function initGateway(wallet, ccpPath, userName) {
    let gateway = new Gateway();
    await gateway.connect(ccpPath, {
        wallet: wallet,
        identity: userName,
        discovery: {
            enabled: true,
            asLocalhost: true
        }
    });

    return gateway;
}

/**
 * Create {FabricCAServices} by reading connection profile file.
 * @param {string} ccpPath connection profile file path
 * @param {string} orgName name of organization which current user belongs to
 * @returns {FabricCAServices}
 */
function newFabricCAServices(ccpPath, orgName) {
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    const caName = ccp["organizations"][orgName]["certificateAuthorities"][0];
    const caInfo = ccp["certificateAuthorities"][caName];
    const caTLSCACerts = caInfo["tlsCACerts"].pem;
    return new FabricCAServices(caInfo.url, {trustedRoots: caTLSCACerts, verify: false}, caInfo.caName);
}

/**
 * Query ledger by accessing peer
 * @async
 * @param {string} walletName name of sub-folder under the wallet root path
 * @param {string} userName name of current user
 * @param {string} ccpPath path of connection profile file
 * @param {string} channelName name of channel where ledger locates
 * @param {string} chaincodeName name of smart contract to query
 * @param {string} funcName name of function of smart contact to query
 * @param {Array<string>} funcArgs array of function of smart contact to query
 * @returns {string}
 */
async function query(walletName, userName, ccpPath, channelName, chaincodeName, funcName, funcArgs) {
    // Create a new file system based wallet for managing identities.
    const wallet = initFileWallet(walletName);

    // Check to see if we've already enrolled the user.
    const userExists = await wallet.exists(userName);
    if (!userExists) {
        return InvokeResult.newFailure(`An identity for the user ${userName} does not exist in the wallet.`);
        //throw new Error(`An identity for the user ${userName} does not exist in the wallet.`);
    }

    // Create a new gateway for connecting to our peer node.
    const gateway = await initGateway(wallet, ccpPath, userName);

    // Get the network (channel) our contract is deployed to.
    const network = await gateway.getNetwork(channelName);

    // Get the contract from the network.
    const contract = network.getContract(chaincodeName);

    // Evaluate the specified transaction.
    try {
        const result = await contract.evaluateTransaction(funcName, ...funcArgs);
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
        return InvokeResult.newSuccess(result);
    } catch (error) {
        return InvokeResult.newFailure(error);
    }
}

/**
 * Update ledger by invoking smart contract
 * @async
 * @param {string} walletName name of sub-folder under the wallet root path
 * @param {string} userName name of current user
 * @param {string} ccpPath path of connection profile file
 * @param {string} channelName name of channel where ledger locates
 * @param {string} chaincodeName name of smart contract to query
 * @param {string} funcName name of function of smart contact to query
 * @param {Array<string>} funcArgs array of function of smart contact to query
 * @returns {string}
 */
async function invoke(walletName, userName, ccpPath, channelName, chaincodeName, funcName, funcArgs) {
    // Create a new file system based wallet for managing identities.
    const wallet = initFileWallet(walletName);

    // Check to see if we've already enrolled the user.
    const userExists = await wallet.exists(userName);
    if (!userExists) {
        return `An identity for the user "${userName}" does not exist in the wallet.`;
    }

    // Create a new gateway for connecting to our peer node.
    const gateway = await initGateway(wallet, ccpPath, userName);

    // Get the network (channel) our contract is deployed to.
    const network = await gateway.getNetwork(channelName);

    // Get the contract from the network.
    const contract = network.getContract(chaincodeName);

    const tx = contract.createTransaction(funcName);

    // Register CommitListener for the transaction
    let listener = await network.addCommitListener(tx.getTransactionID().getTransactionID(), _handleCommitListener);
    let result = await tx.submit(...funcArgs);
    //console.log(result);

    // Unregister CommitListener
    listener.unregister();

    // Disconnect from the gateway.
    await gateway.disconnect();
    //return 'Transaction has been submitted';
    return InvokeResult.newSuccess(result.toJSON());
}

/**
 * Default handler for commit listener
 * @param {Error} err
 * @param {string} transactionId
 * @param {string} status
 * @param {number} blockNumber
 * @returns {Promise<void>}
 * @private
 */
async function _handleCommitListener(err, transactionId, status, blockNumber) {
    if (err) {
        console.error(err);
        return;
    }
    console.log(`Transaction ID: ${transactionId} Status: ${status} Block number: ${blockNumber}`);
}

module.exports.initFileWallet = initFileWallet;
module.exports.initGateway = initGateway;
module.exports.newFabricCAServices = newFabricCAServices;
module.exports.query = query;
module.exports.invoke = invoke;