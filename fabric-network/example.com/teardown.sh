function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /example-network-peer.*.mycc.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /example-network-peer.*.mycc.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}


docker-compose down --volumes --remove-orphans
clearContainers
removeUnwantedImages
rm -r crypto-config/*
rm -r channel-artifacts/*
rm channel-artifacts/*

apps=(example02 example03)
  for app in ${apps[@]}; do
  rm ../../apps/${app}/tls/*/ca.crt
done