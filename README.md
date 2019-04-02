### Prepare
```
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common vim libltdl-dev python make node-gyp -y
```

### Install Golang (v1.11.1)
```
# download go SDK
wget https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz -P ~/Downloads/
sudo tar zxf ~/Downloads/go1.11.1.linux-amd64.tar.gz -C /usr/local/

# set Golang related environment variables
export PATH=$PATH:/usr/local/go/bin
export GOPATH=~/gopath

# create $GOPATH folders
mkdir ~/gopath
cd $GOPATH
mkdir src bin pkg
```

### Install Docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo gpasswd -a ${USER} docker
# relogin linux user required
```

### Install docker-compose (v1.22.0)
```
wget https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -P ~/Downloads
sudo cp ~/Downloads/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
```

### Install Node.JS SDK (v8.x)
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.bashrc
nvm install 8
node -v
npm -v
```

### Download docker images
```
cd ~/workspace
./pull-images.sh
```

#download fabric binaries
```
wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-1.4.0/hyperledger-fabric-linux-amd64-1.4.0.tar.gz -P ~/Downloads/

#extract fabric binaries to `fabric-bin`
tar zxf ~/Downloads/hyperledger-fabric-linux-amd64-1.4.0.tar.gz -C ~/workspace/fabric-bin
```

---

### Scenario 1: build network
```
#setup fabric-cli into $PATH
export PATH=$PATH:~/workspace/fabric-bin/bin

#generate crypto certs and channel-artifacts
cd ~/workspace/fabric-network/example.com
./generate.sh

#startup fabric-network 'example.com'
./startup.sh

#run fabric-cli to setup channel, chaincode, and invoke chaincode
./e2e.sh
```

### Scenario 2: access FABRIC-CA 'ca.org1.example.com' and chaincode on FABRIC-PEER 'peer0.org1.example.com'

```
echo '######## - Prepare(!!!required only at first time!!!) - ########'
#install required SDK modules
cd ~/workspace/apps/example02
npm install --registry=https://registry.npm.taobao.org


echo ###################### - BEGIN - ######################'
#enable tls feature
export TLS_ENABLED=true

#clear local cert wallet
rm -r hfc-key-store

echo '######## - ORG1 - ########'
export ORG_NAME=org1.example.com
export MSP_ID=Org1MSP
export CA_ADDRESS=localhost:7054
export CA_NAME=ca.org1.example.com
export PEER_ADDRESS=localhost:7051
export PEER_NAME=peer0.org1.example.com
export PEER_TLS_CERT="./tls/peer0.org1/ca.crt"

#enroll 'admin' with password 
echo '[ORG1]enroll `admin` and store certs in `hfc-key-store/org1.example.com`'
node enroll_admin.js

#register user 'user1'
echo '[ORG1]register `user1` and store certs in `hfc-key-store/org1.example.com`'
node register-user1_admin.js

#query balance of account 'a'
echo '[ORG1]query balance of account `a`'
node query-a_user1.js

#transfer 10$ from account 'a' to 'b'
echo '[ORG1]transfer 10$ from account `a` to account `b`'
node transfer-a-b-10_user1.js

#query balance of account 'a'
echo '[ORG1]query balance of account `a`'
node query-a_user1.js

#query balance of account 'b'
echo '[ORG1]query balance of account `b`'
node query-b_user1.js

echo '######## - ORG2 - ########'
export ORG_NAME=org2.example.com
export MSP_ID=Org2MSP
export CA_ADDRESS=localhost:6054
export CA_NAME=ca.org2.example.com
export PEER_ADDRESS=localhost:6051
export PEER_NAME=peer0.org2.example.com
export PEER_TLS_CERT="./tls/peer0.org2/ca.crt"

#enroll 'admin' with password 
echo '[ORG2]enroll `admin` and store certs in `hfc-key-store/org2.example.com`'
node enroll_admin.js

#register user 'user1'
echo '[ORG2]register `user1` and store certs in `hfc-key-store/org2.example.com`'
node register-user1_admin.js

#query balance of account 'a'
echo '[ORG2]query balance of account `a`'
node query-a_user1.js

#transfer 10$ from account 'a' to 'b'
echo '[ORG2]transfer 10$ from account `a` to account `b`'
node transfer-a-b-10_user1.js

#query balance of account 'a'
echo '[ORG2]query balance of account `a`'
node query-a_user1.js

#query balance of account 'b'
echo '[ORG2]query balance of account `b`'
node query-b_user1.js

echo '###################### - END - ######################'
```

### Scenario 3: modify chaincode and upgrade on peers
```
#peer0.org1
echo 'upgrade chaincode on peer0.org1...'
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer chaincode install -n mycc -v 1.1 -l golang -p github.com/chaincode/chaincode_example02/go/
peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc -l golang -v 1.1 -c '{"Args":["upgrade"]}'
echo 'OK.'

#peer0.org2
echo 'upgrade chaincode on peer0.org2...'
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

peer channel join -b mychannel.block
peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer chaincode install -n mycc -v 1.1 -l golang -p github.com/chaincode/chaincode_example02/go/
peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc -l golang -v 1.1 -c '{"Args":["upgrade"]}'
echo 'OK.'

```


### Finally: stop network 'example.com'

```
#shutdown fabric-network 'example.com' and teardown
cd ~/workspace/fabric-network/example.com
./teardown.sh
```