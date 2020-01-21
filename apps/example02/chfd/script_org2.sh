echo '######## - (install)ORG2 - ########'
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export ORDERER_TLS_ROOTCERT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b mychannel.block
peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/org2MSPanchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_TLS_ROOTCERT
peer chaincode install -n mycc -v 1.0 -l golang -p github.com/chaincode/chaincode_example02_v1.0/go/

sleep 5
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_TLS_ROOTCERT -C mychannel -n mycc --peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles CORE_PEER_TLS_ROOTCERT_FILE -c '{"Args":["transfer","a","b","10"]}'
sleep 3
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","b"]}'

echo '###################################'