#!/bin/bash

# kill ca-server process
for i in `ps -ef|grep 'orderer' |awk '{print $2}'`; do kill -9 $i; done;
for i in `ps -ef|grep 'tail -f /var/hyperledger/logs' |awk '{print $2}'`; do kill -9 $i; done;

# clear data
rm -rf /var/hyperledger/production
