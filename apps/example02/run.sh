# echo '######## - Prepare(!!!required only at first time!!!) - ########'
# #install required SDK modules
# npm install --registry=https://registry.npm.taobao.org
# echo '################################################################'

echo '##################### - BEGIN - #####################'
#enable tls feature by default
if [ -z $TLS_ENABLED ]; then
export TLS_ENABLED=true
fi
echo "TLS_ENABLED="$TLS_ENABLED

#clear local cert wallet
rm -r wallet

echo '######## - ORG1 - ########'
export ORG_NAME=org1.example.com
export MSP_ID=Org1MSP
export CONNECTION_PROFILE=connection-org1.json

#enroll 'admin' with password 
echo '[ORG1]enroll `admin` and store certs in `wallet/org1.example.com`'
node enroll_user.js admin adminpw

export USER_NAME=admin
#register user 'user1'
echo '[ORG1]register `user1` and store certs in `wallet/org1.example.com`'
node register_user.js user1 user1pw

node enroll_user.js user1 user1pw

export USER_NAME=user1

#query balance of account 'a'
echo '[ORG1]query balance of account `a`'
node query.js a

#transfer 10$ from account 'a' to 'b'
echo '[ORG1]transfer 10$ from account `a` to account `b`'
node transfer.js a b 10

#query balance of account 'a'
echo '[ORG1]query balance of account `a`'
node query.js a

echo '######## - ORG2 - ########'
export ORG_NAME=org2.example.com
export MSP_ID=Org2MSP
export CONNECTION_PROFILE=connection-org2.json

#enroll 'admin' with password 
echo '[ORG2]enroll `admin` and store certs in `wallet/org2.example.com`'
node enroll_user.js admin adminpw

export USER_NAME=admin
#register user 'user2'
echo '[ORG2]register `user2` and store certs in `wallet/org2.example.com`'
node register_user.js user2 user2pw

node enroll_user.js user2 user2pw

export USER_NAME=user2

#query balance of account 'b'
echo '[ORG2]query balance of account `b`'
node query.js b

#transfer 12$ from account 'b' to 'a'
echo '[ORG2]transfer 12$ from account `b` to account `a`'
node transfer.js b a 12

#query balance of account 'a'
echo '[ORG2]query balance of account `b'
node query.js b

echo '###################### - END - ######################'