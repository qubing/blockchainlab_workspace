#!/bin/bash

source .env
mv /var/hyperledger/logs/*.log /var/hyperledger/logs/backup/
echo "################ FABRIC-CA ################"
echo "Starting..."
LOG_FILE_NAME=/var/hyperledger/logs/`date +%Y%m%d-%H%M%S`.log
nohup fabric-ca-server start -b admin:adminpw > $LOG_FILE_NAME 2>&1 &
echo "Completed."
echo "For runtime logs, please typ \"tail -f "$LOG_FILE_NAME"\""
