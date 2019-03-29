DOMAIN_NAME=example.com

SUBDOMAIN_ORDERER=orderer.$DOMAIN_NAME

SUBDOMAIN_ORG1=org1.$DOMAIN_NAME
DUBDOMAIN_CA_ORG1=ca.$SUBDOMAIN_ORG1
SUBDOMAIN_PEER0_ORG1=peer0.$SUBDOMAIN_ORG1
SUBDOMAIN_PEER1_ORG1=peer1.$SUBDOMAIN_ORG1

SUBDOMAIN_ORG2=org2.$DOMAIN_NAME
DUBDOMAIN_CA_ORG2=ca.$SUBDOMAIN_ORG2
SUBDOMAIN_PEER0_ORG2=peer0.$SUBDOMAIN_ORG2
SUBDOMAIN_PEER1_ORG2=peer1.$SUBDOMAIN_ORG2


HOST_ORDERER=52.231.192.97
ssh -i ssh-key.pem ubuntu@$HOST_ORDERER 'sudo mkdir -p /var/hyperledger/orderer && sudo chown ubuntu:ubuntu /var/hyperledger -R'
scp -i ssh-key.pem ./config/$SUBDOMAIN_ORDERER.yaml ubuntu@$HOST_ORDERER:/var/hyperledger/orderer/orderer.yaml
scp -i ssh-key.pem ./channel-artifacts/genesis.block ubuntu@$HOST_ORDERER:/var/hyperledger/orderer/orderer.genesis.block
scp -i ssh-key.pem -r ./crypto-config/ordererOrganizations/$DOMAIN_NAME/orderers/$SUBDOMAIN_ORDERER/msp ubuntu@$HOST_ORDERER:/var/hyperledger/orderer/msp
scp -i ssh-key.pem -r ./crypto-config/ordererOrganizations/$DOMAIN_NAME/orderers/$SUBDOMAIN_ORDERER/tls ubuntu@$HOST_ORDERER:/var/hyperledger/orderer/tls
ssh -i ssh-key.pem ubuntu@$HOST_ORDERER 'sudo mkdir -p /opt/hyperledger/fabric && sudo chown ubuntu:ubuntu /opt/hyperledger -R'
scp -i ssh-key.pem -r ./scripts/orderer/bin ubuntu@$HOST_ORDERER:/opt/hyperledger/fabric/bin
ssh -i ssh-key.pem ubuntu@$HOST_ORDERER 'chmod +x /opt/hyperledger/fabric/bin/*.sh'


HOST_PEER0_ORG1=52.231.192.97
ssh -i ssh-key.pem ubuntu@$HOST_PEER0_ORG1 'sudo mkdir -p /var/hyperledger/fabric && sudo chown ubuntu:ubuntu /var/hyperledger -R'
scp -i ssh-key.pem ./config/$PREFIX_PEER0.$SUBDOMAIN_ORG1.yaml ubuntu@$HOST_PEER0_ORG1:/var/hyperledger/fabric/core.yaml
scp -i ssh-key.pem -r ./crypto-config/peerOrganizations/$SUBDOMAIN_ORG1/peers/$SUBDOMAIN_PEER0_ORG1/msp ubuntu@$HOST_PEER0_ORG1:/var/hyperledger/fabric/msp
scp -i ssh-key.pem -r ./crypto-config/peerOrganizations/$SUBDOMAIN_ORG1/peers/$SUBDOMAIN_PEER0_ORG1/tls ubuntu@$HOST_PEER0_ORG1:/var/hyperledger/fabric/tls
ssh -i ssh-key.pem ubuntu@$HOST_PEER0_ORG1 'sudo mkdir -p /opt/hyperledger/fabric && sudo chown ubuntu:ubuntu /opt/hyperledger -R'
scp -i ssh-key.pem -r ./scripts/peer/bin ubuntu@$HOST_PEER0_ORG1:/opt/hyperledger/fabric/bin
ssh -i ssh-key.pem ubuntu@$HOST_PEER0_ORG1 'chmod +x /opt/hyperledger/fabric/bin/*.sh'

HOST_CA_ORG1=52.231.192.97
ssh -i ssh-key.pem ubuntu@$HOST_CA_ORG1 'sudo mkdir -p /var/hyperledger/fabric-ca-server && sudo chown ubuntu:ubuntu /var/hyperledger -R'
scp -i ssh-key.pem ./config/DUBDOMAIN_CA_ORG1.yaml ubuntu@$HOST_CA_ORG1:/var/hyperledger/fabric-ca-server/fabric-ca-server-config.yaml
scp -i ssh-key.pem -r ./crypto-config/peerOrganizations/$SUBDOMAIN_ORG1/ca ubuntu@$HOST_CA_ORG1:/var/hyperledger/fabric-ca-server/msp
scp -i ssh-key.pem -r ./crypto-config/peerOrganizations/$SUBDOMAIN_ORG1/ca ubuntu@$HOST_CA_ORG1:/var/hyperledger/fabric-ca-server/tls
ssh -i ssh-key.pem ubuntu@$HOST_CA_ORG1 'sudo mkdir -p /opt/hyperledger/fabric && sudo chown ubuntu:ubuntu /opt/hyperledger -R'
scp -i ssh-key.pem -r ./scripts/ca/bin ubuntu@$HOST_CA_ORG1:/opt/hyperledger/fabric/bin
ssh -i ssh-key.pem ubuntu@$HOST_CA_ORG1 'chmod +x /opt/hyperledger/fabric/bin/*.sh'
