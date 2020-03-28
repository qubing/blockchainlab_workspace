#!/bin/bash

DOCKER_NS=hyperledger
CA_VERSION=1.4.4
FABRIC_VERSION=2.0.0
OTHER_VERSION=0.4.18

# fabric-ca image
echo "Pulling ${DOCKER_NS}/fabric-ca:${CA_VERSION}"
docker pull ${DOCKER_NS}/fabric-ca:${CA_VERSION}

# fabric images
FABRIC_IMAGES=(fabric-peer fabric-orderer fabric-ccenv fabric-tools fabric-ccenv fabric-javaenv)
for image in ${FABRIC_IMAGES[@]}; do
  echo "Pulling ${DOCKER_NS}/$image:${FABRIC_VERSION}"
  docker pull ${DOCKER_NS}/$image:${FABRIC_VERSION}
done

# other images
OTHER_IMAGES=(fabric-baseos fabric-couchdb)
for image in ${OTHER_IMAGES[@]}; do
  echo "Pulling ${DOCKER_NS}/$image:${OTHER_VERSION}"
  docker pull ${DOCKER_NS}/$image:${OTHER_VERSION}
done
docker rmi -f ${DOCKER_NS}/fabric-baseos:latest
docker tag ${DOCKER_NS}/fabric-baseos:${OTHER_VERSION} ${DOCKER_NS}/fabric-baseos:latest

# kafka images
#KAFKA_IMAGES=(fabric-kafka fabric-zookeeper)
#for image in ${KAFKA_IMAGES[@]}; do
#  echo "Pulling ${DOCKER_NS}/$image:${OTHER_VERSION}"
#  docker pull ${DOCKER_NS}/$image:${OTHER_VERSION}
#done