'use strict';
const path = require('path');
const CCP_PATH = path.join(__dirname, '../connection-org1.yaml');

function newWallet() {
    const {FileSystemWallet} = require('fabric-network');
    //instantiate file-system wallet
    const walletPath = path.join(__dirname, 'wallet');
    return new FileSystemWallet(walletPath);
}

async function enrollUser(userName, userSecret) {
    const FabricCAServices = require('fabric-ca-client');
    const {X509WalletMixin, FileSystemWallet, Gateway} = require('fabric-network');

    //instantiate file-system wallet
    const wallet = newWallet();

    //instantiate CA client
    const ca = new FabricCAServices("https://localhost:7054", { trustedRoots: "../crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem", verify: false }, "ca-org1");
    
    //enroll user
    let enrollment = await ca.enroll({
        enrollmentID: userName, 
        enrollmentSecret: userSecret
    });
    console.log(enrollment);
    //import user into wallet
    let userID = X509WalletMixin.createIdentity('Org1MSP', enrollment.certificate, enrollment.key.toBytes());
    await wallet.import(userName, userID);
}

async function registerUser(userName, userSecret) {
    const {X509WalletMixin, Gateway} = require('fabric-network');

    //instantiate file-system wallet
    const wallet = newWallet();

    //instantiate CA client via connection profile
    let gateway = new Gateway();
    await gateway.connect(CCP_PATH, {
        wallet: wallet,
        identity: 'admin',
        discovery: {
            enabled: true,
            asLocalhost: true
        }
    });
    const ca = gateway.getClient().getCertificateAuthority();

    //register user
    await ca.register({
        enrollmentID: userName,
        enrollmentSecret: userSecret,
        role: 'client',
        maxEnrollments: -1
    }, gateway.getCurrentIdentity());

    //enroll user
    let enrollment = await ca.enroll({
        enrollmentID: userName,
        enrollmentSecret: userSecret
    });

    //import user into wallet
    let userID = X509WalletMixin.createIdentity('Org1MSP', enrollment.certificate, enrollment.key.toBytes());
    await wallet.import(userName, userID);
}

async function query(func, ...args) {
    const {Gateway} = require('fabric-network');
 
    //instantiate file-system wallet
    const wallet = newWallet();

    //instantiate CA client via connection profile
    let gateway = new Gateway();
    await gateway.connect(CCP_PATH, {
        wallet: wallet,
        identity: 'user1',
        discovery: {
            enabled: true,
            asLocalhost: true
        }
    });

    let network = await gateway.getNetwork('mychannel');
    let contract = network.getContract('mycc');
    let result = await contract.evaluateTransaction('query', ...args);
    console.log(result.toString());
}

async function invoke(func, ...args) {
    const {Gateway} = require('fabric-network');
 
    //instantiate file-system wallet
    const wallet = newWallet();

    //instantiate CA client via connection profile
    let gateway = new Gateway();
    await gateway.connect(CCP_PATH, {
        wallet: wallet,
        identity: 'user1',
        discovery: {
            enabled: true,
            asLocalhost: true
        }
    });

    let network = await gateway.getNetwork('mychannel');
    let contract = network.getContract('mycc');

    // // create transaction
    // const tx = contract.createTransaction(func);
    // const txID = tx.getTransactionID().getTransactionID();
    // let listener = await network.addCommitListener(txID, (err, transactionId, status, blockNumber) => {
    //     if (err) {
    //         console.error(err);
    //         return;
    //     }
    //     console.log(`Transaction ID: ${transactionId} Status: ${status} Block number: ${blockNumber}`);
    // });

    // let result = await tx.submit(...args);

    let result = await contract.submitTransaction(func, ...args);
    console.log(result.toString());
}

async function main() {
    console.log('======================= BEGIN =====================');
    // console.log('-------- enroll admin');
    // await enrollUser('admin', 'adminpw');
    // console.log('-------- register user1');
    // await registerUser('user1', 'user1pw');
    // console.log('-------- query `a`');
    //await query('query', 'a');
    // console.log('-------- invoke a -> b : 10');
    await invoke('invoke', 'a', 'b', '10');
    console.log('======================== END ======================');
}

main();