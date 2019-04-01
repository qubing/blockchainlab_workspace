echo '######## - Prepare(!!!required only at first time!!!) - ########'
#install required SDK modules
cd ~/workspace/apps/example02
npm install --registry=https://registry.npm.taobao.org
echo '################################################################'


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