if [ ! -d "crypto-config/peerOrganizations" ]; then
    ./generate.sh
fi

docker-compose up -d