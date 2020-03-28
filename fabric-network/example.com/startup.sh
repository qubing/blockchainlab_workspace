if [ ! -d "crypto-config/peerOrganizations" ]; then
    ./generate.sh
fi

docker-compose up -d

# if [[ $# = 2 && "$1" == "dev" || "$1" == "DEV" ]]; then
#     if [ "$2" == "go" ]; then
#         docker-compose -f go-dev.yaml up -d
#     fi
# fi

