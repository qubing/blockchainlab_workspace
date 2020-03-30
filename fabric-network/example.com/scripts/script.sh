. scripts/utils.sh

echo '######## - (COMMON) setup variables - ########'
setupCommonENV
echo $#
if [[ $# > 0 ]]; then
    if [[ "$1" == "golang" ]]; then
        setGoCC
        echo "Golang CC enabled"
    fi

    if [[ "$1" == "java" ]]; then
        setJavaCC
        echo "Java CC enabled"
    fi

    if [[ "$1" == "node" ]]; then
        setNodeCC
        echo "Node.JS CC enabled"
    fi

    if [[ $# == 2 ]]; then
        export CC_PATH=$2
    fi
else
    echo "by default Golang CC enabled"
fi

echo "'CHAINCODE_LANG' set to '$CC_LANG'"
echo "'CHAINCODE_PATH' set to '$CC_PATH'"

# echo '######## - (ORG1) create channel - ########'
setupPeerENV1
peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo '######## - (ORG1) join channel - ########'
setupPeerENV1
peer channel join -b mychannel.block

echo '######## - (ORG1) update anchor - ########'
setupPeerENV1
peer channel update -o ${ORDERER_ADDRESS} -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo '######## - (ORG2) join channel - ########'
setupPeerENV2
peer channel join -b mychannel.block

echo '######## - (ORG2) update anchor - ########'
setupPeerENV2
peer channel update -o ${ORDERER_ADDRESS} -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo '######## - (ORG1) install chaincode - ########'
setupPeerENV1
peer lifecycle chaincode package ${CC_NAME}_${CC_VERSION}.tar.gz --path ${CC_PATH} --lang $CC_LANG --label ${CC_NAME}_${CC_VERSION}
peer lifecycle chaincode install ${CC_NAME}_${CC_VERSION}.tar.gz

echo '######## - (ORG2) install chaincode - ########'
setupPeerENV2
peer lifecycle chaincode package ${CC_NAME}_${CC_VERSION}.tar.gz --path ${CC_PATH} --lang $CC_LANG --label ${CC_NAME}_${CC_VERSION}
peer lifecycle chaincode install ${CC_NAME}_${CC_VERSION}.tar.gz

echo '######## - (ORG1) approve chaincode - ########'
setupPeerENV1
peer lifecycle chaincode queryinstalled >&log.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo "PACKAGE_ID(ORG1):" ${PACKAGE_ID}
peer lifecycle chaincode approveformyorg --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --init-required --package-id ${PACKAGE_ID} --sequence 1 --waitForEvent 

echo '######## - (ORG2) approve chaincode - ########'
setupPeerENV2
peer lifecycle chaincode queryinstalled >&log.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo "PACKAGE_ID(ORG2):" ${PACKAGE_ID}
peer lifecycle chaincode approveformyorg --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --init-required --package-id ${PACKAGE_ID} --sequence 1 --waitForEvent 

echo '######## - (ORG1) check chaincode approvals - ########'
setupPeerENV1
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence 1 --output json --init-required

echo '######## - (ORG1) commit chaincode definition - ########'
setupPeerENV1
peer lifecycle chaincode commit -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME --name ${CC_NAME} \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
--version ${CC_VERSION} --sequence 1 --init-required
    
echo '######## - (ORG1) check chaincode status - ########'
setupPeerENV1
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} 

# echo '######## - (ORG1) init chaincode - ########'
setupPeerENV1
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
--isInit -c '{"function":"init","Args":["a","100","b","200"]}'

sleep 10
echo '######## - (ORG1) query chaincode - ########'
setupPeerENV1
peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["query","a"]}'

echo '######## - (ORG2) query chaincode - ########'
setupPeerENV2
peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["query","b"]}'

echo '######## - (ORG1) invoke chaincode - ########'
setupPeerENV1
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
-c '{"function":"transfer","Args":["a","b","10"]}'
sleep 5

echo '######## - (ORG2) invoke chaincode - ########'
setupPeerENV2
peer chaincode invoke -o ${ORDERER_ADDRESS} --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME}  \
--peerAddresses $PEER0_ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_TLS_ROOTCERT_FILE \
--peerAddresses $PEER0_ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_TLS_ROOTCERT_FILE \
-c '{"function":"transfer","Args":["b","a","12"]}'
sleep 5

echo '######## - (ORG1) query chaincode - ########'
setupPeerENV1
peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["query","a"]}'

echo '######## - (ORG2) query chaincode - ########'
setupPeerENV2
peer chaincode query -C $CHANNEL_NAME -n $CC_NAME -c '{"Args":["query","b"]}'
echo '############# END ###############'