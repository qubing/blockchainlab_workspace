'use strict';

var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var orgName = "org1.example.com";
if (process.env.ORG_NAME) {
    orgName = process.env.ORG_NAME;
}
var mspID = "Org1MSP";
if (process.env.MSP_ID) {
    mspID = process.env.MSP_ID;
}

var store_path = path.join(__dirname, 'hfc-key-store', orgName);
console.log(' Store path:'+store_path);

var caAddress = "localhost:7054";
if (process.env.CA_ADDRESS) {
    caAddress = process.env.CA_ADDRESS;
}
var caName = "ca.org1.example.com";
if (process.env.CA_NAME) {
    caName = process.env.CA_NAME;
}

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path}).then((state_store) => {
    // assign the store to the fabric client
    fabric_client.setStateStore(state_store);
    var crypto_suite = Fabric_Client.newCryptoSuite();
    // use the same location for the state store (where the users' certificate are kept)
    // and the crypto store (where the users' keys are kept)
    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
    crypto_suite.setCryptoKeyStore(crypto_store);
    fabric_client.setCryptoSuite(crypto_suite);
    var	tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    // be sure to change the http to https when the CA is running TLS enabled
    if (process.env.TLS_ENABLED && process.env.TLS_ENABLED === 'true') {
        console.log("process.env.TLS_ENABLED is '%s'", process.env.TLS_ENABLED);
        fabric_ca_client = new Fabric_CA_Client('https://' + caAddress, tlsOptions , caName, crypto_suite);
    } else {
        console.log("process.env.TLS_ENABLED is 'false' or not existing.");
        fabric_ca_client = new Fabric_CA_Client('http://' + caAddress, tlsOptions , caName, crypto_suite);
    }
    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
    } else {
        throw new Error('Failed to get admin.... run enrollAdmin.js');
    }

    // at this point we should have the admin user
    // first need to register the user with the CA server
    return fabric_ca_client.register({
            enrollmentID: 'user1',
            enrollmentSecret: 'user1pwd',
            affiliation: 'org1',
            role: "client",
            maxEnrollments: -1,
            attrs: [
                {name: 'admin', value: 'true', ecert: true},
                {name: 'email', value: 'user1@org1'}
            ]
        }, admin_user);
}).then((secret) => {
    // next we need to enroll the user with CA server
    console.log('Successfully registered `user1` - secret:'+ secret);

    return fabric_ca_client.enroll({
        enrollmentID: 'user1', 
        enrollmentSecret: secret,
        attr_reqs: [
            {name: 'admin', optional: false},
            {name: 'email', optional: true}
        ]}
    );
}).then((enrollment) => {
  console.log('Successfully enrolled member user `user1` ');
  return fabric_client.createUser(
     {username: 'user1',
     mspid: mspID,
     cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
     });
}).then((user) => {
     member_user = user;

     return fabric_client.setUserContext(member_user);
}).then(()=>{
     console.log('`user1` was successfully registered and enrolled and is ready to intreact with the fabric network' + member_user.toString());

}).catch((err) => {
    console.error('Failed to register: ' + err);
	if(err.toString().indexOf('Authorization') > -1) {
		console.error('Authorization failures may be caused by having admin credentials from a previous CA instance.\n' +
		'Try again after deleting the contents of the store directory '+store_path);
	}
});