### Scenario 1: build network

```
#download docker images
./pull-images.sh

#setup fabric-cli into $PATH
export PATH=$PATH:$PWD/fabric-bin/bin

#generate crypto certs and channel-artifacts
cd fabric-network/example.com
./generate.sh

#startup fabric-network 'example.com'
./startup.sh

#run fabric-cli to setup channel, chaincode, and invoke chaincode
./e2e.sh

```

### Scenario 2: access FABRIC-CA 'ca.org1.example.com' and chaincode on FABRIC-PEER 'peer0.org1.example.com'

```
#install required SDK modules
cd apps/example02
npm install --registry=https://registry.npm.taobao.org

#enable tls feature
export TLS_ENABLED=true

#clear local cert wallet
rm -r hfc-key-store

#enroll 'admin' with password 
node enroll_admin.js

#register user 'user1'
node register-user1_admin.js

#query balance of account 'a'
node query-a_user1.js

#transfer 10$ from account 'a' to 'b'
node transfer-a-b-10_user1.js

#query balance of account 'a'
node query-a_user1.js

#query balance of account 'b'
node query-b_user1.js

```

### Scenario 3: stop network 'example.com'

```
#shutdown fabric-network 'example.com' and teardown
./teardown.sh
```