#!/bin/bash

DOCKER_NS=hyperledger
ARCH=amd64
FABRIC_VERSION=1.4.4
OTHER_VERSION=0.4.18

FABRIC_IMAGES=(fabric-ca fabric-peer fabric-orderer fabric-ccenv fabric-tools fabric-ccenv fabric-javaenv)

for image in ${FABRIC_IMAGES[@]}; do
  echo "Pulling ${DOCKER_NS}/$image:${ARCH}-${FABRIC_VERSION}"
  docker rmi -f ${DOCKER_NS}/$image:latest
  docker pull ${DOCKER_NS}/$image:${ARCH}-${FABRIC_VERSION}
  docker tag ${DOCKER_NS}/$image:${ARCH}-${FABRIC_VERSION} ${DOCKER_NS}/$image:latest
done

OTHER_IMAGES=(fabric-baseos fabric-couchdb fabric-kafka fabric-zookeeper)

for image in ${OTHER_IMAGES[@]}; do
  echo "Pulling ${DOCKER_NS}/$image:${ARCH}-${OTHER_VERSION}"
  docker rmi -f ${DOCKER_NS}/$image:latest
  docker pull ${DOCKER_NS}/$image:${ARCH}-${OTHER_VERSION}
  docker tag ${DOCKER_NS}/$image:${ARCH}-${OTHER_VERSION} ${DOCKER_NS}/$image:latest
done
						
