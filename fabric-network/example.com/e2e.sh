echo $#
if [[ $# -eq 0 ]]; then
    docker exec cli bash -c "./scripts/script.sh "
fi
if [[ $# -eq 1 ]]; then
    docker exec cli bash -c "./scripts/script.sh $1"
fi
if [[ $# -eq 2 ]]; then
    docker exec cli bash -c "./scripts/script.sh $1 $2"
fi
# install v1.0 on `peer0.org1.example.com`
# docker exec cli bash ./scripts/script_org2.sh
# upgrade to v1.1
# docker exec cli bash ./scripts/script_upgrade.sh