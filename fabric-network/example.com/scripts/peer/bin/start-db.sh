#!/bin/bash

docker run -p 5984:5984 --name fabric-couchdb -d hyperledger/fabric-couchdb -e "COUCHDB_USER=admin" -e "COUCHDB_PASSWORD=adminpw"
