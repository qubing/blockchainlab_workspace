function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp ./config/templates/ca.org1.example.com.yaml ./config/ca.org1.example.com.yaml
  cp ./config/templates/ca.org2.example.com.yaml ./config/ca.org2.example.com.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  #org1
  cd crypto-config/peerOrganizations/org1.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" ./config/ca.org1.example.com.yaml
  
  #org2
  cd crypto-config/peerOrganizations/org2.example.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" ./config/ca.org2.example.com.yaml
  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm ./config/ca.org1.example.com.yamlt
    rm ./config/ca.org2.example.com.yamlt
  fi
}

#generate certs
function generateCerts() {
    if [ -d "crypto-config" ]; then
        rm -Rf crypto-config
    fi
    cryptogen generate --config=./crypto-config.yaml
}

function copyTLScerts() {
  cp crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt ../../apps/example02/tls/peer0.org1/
  cp crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt ../../apps/example02/tls/peer1.org1/
  cp crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt ../../apps/example02/tls/peer0.org2/
  cp crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt ../../apps/example02/tls/peer1.org2/
  cp crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt ../../apps/example02/tls/orderer/
}

function generateChannelArtifacts() {
    CHANNEL_NAME=mychannel
    configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
    configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
}

generateCerts
copyTLScerts
replacePrivateKey
generateChannelArtifacts
