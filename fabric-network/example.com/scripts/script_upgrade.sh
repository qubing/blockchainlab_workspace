function setupCommonENV() {
    export ORDERER_ADDRESS=orderer.example.com:7050
    export PEER0_ORG1_ADDRESS=peer0.org1.example.com:7051
    export PEER0_ORG2_ADDRESS=peer0.org2.example.com:7051
    export PEER0_ORG1_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export PEER0_ORG2_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CHANNEL_NAME=mychannel
    export CHAINCODE_NAME=mycc
    export CHAINCODE_PATH=github.com/chaincode/chaincode_example02_v1.1/go/build
    export CHAINCODE_VERSION=v1.1
}

function setupPeerENV1() {
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_ADDRESS=$PEER0_ORG1_ADDRESS
    export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
}

function setupPeerENV2() {
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_ADDRESS=$PEER0_ORG2_ADDRESS
    export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
}

echo '######## - (COMMON) setup variables - ########'
setupCommonENV

echo '######## - (ORG1) install chaincode - ########'
setupPeerENV1
peer lifecycle chaincode package ${CHAINCODE_NAME}_${CHAINCODE_VERSION}.tar.gz --path ${CHAINCODE_PATH} --lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}
peer lifecycle chaincode install ${CHAINCODE_NAME}_${CHAINCODE_VERSION}.tar.gz

echo '######## - (ORG2) install chaincode - ########'
setupPeerENV2
peer lifecycle chaincode package ${CHAINCODE_NAME}_${CHAINCODE_VERSION}.tar.gz --path ${CHAINCODE_PATH} --lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}
peer lifecycle chaincode install ${CHAINCODE_NAME}_${CHAINCODE_VERSION}.tar.gz

echo '######## - (ORG1) approve chaincode - ########'
setupPeerENV1
peer lifecycle chaincode queryinstalled >&log.txt
PACKAGE_ID=$(sed -n "/${CHAINCODE_NAME}_${CHAINCODE_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo "PACKAGE_ID(ORG1):" ${PACKAGE_ID}
peer lifecycle chaincode approveformyorg --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --init-required --package-id ${PACKAGE_ID} --sequence 2 --waitForEvent 

echo '######## - (ORG2) approve chaincode - ########'
setupPeerENV2
peer lifecycle chaincode queryinstalled >&log.txt
PACKAGE_ID=$(sed -n "/${CHAINCODE_NAME}_${CHAINCODE_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo "PACKAGE_ID(ORG2):" ${PACKAGE_ID}
peer lifecycle chaincode approveformyorg --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --init-required --package-id ${PACKAGE_ID} --sequence 2 --waitForEvent 

echo '######## - (ORG1) check chaincode approvals - ########'
setupPeerENV1
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 2 --output json --init-required

echo '######## - (ORG1) commit chaincode definition - ########'
setupPeerENV1
peer lifecycle chaincode commit -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME --name ${CHAINCODE_NAME} \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
--version ${CHAINCODE_VERSION} --sequence 2 --init-required

echo '######## - (ORG1) check chaincode status - ########'
setupPeerENV1
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} 

echo '######## - (ORG1) init chaincode - ########'
setupPeerENV1
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
--isInit -c '{"function":"upgrade_1.1","Args":[]}'

sleep 10
echo '######## - (ORG1) query chaincode - ########'
setupPeerENV1
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","a"]}'

echo '######## - (ORG2) query chaincode - ########'
setupPeerENV2
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","b"]}'

echo '######## - (ORG1) invoke chaincode - ########'
setupPeerENV1
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
-c '{"function":"transfer","Args":["a","b","10"]}'
sleep 5

echo '######## - (ORG2) invoke chaincode - ########'
setupPeerENV2
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
-c '{"function":"transfer","Args":["b","a","12"]}'
sleep 5

echo '######## - (ORG1) query chaincode - ########'
setupPeerENV1
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","a"]}'

echo '######## - (ORG2) query chaincode - ########'
setupPeerENV2
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["query","b"]}'
echo '############# END ###############'