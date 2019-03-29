#!/bin/bash

# kill ca-server process
for i in `ps -ef|grep 'fabric-ca-server start' |awk '{print $2}'`; do kill -9 $i; done;
for i in `ps -ef|grep 'tail -f /var/hyperledger/logs' |awk '{print $2}'`; do kill -9 $i; done;

# kill couchdb docker container
docker rm -f `docker ps | grep fabric-couchdb|awk '{print$1}'`

# clear data
rm -rf /var/hyperledger/production
