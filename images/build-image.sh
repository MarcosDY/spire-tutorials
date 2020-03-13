#!/bin/bash

# Builds and push docker image into "gcr.io/spiffe-io"
GCR_REPOSITORY="gcr.io/spiffe-io"
DOCKER_IMAGE="aws-cli"

echo "Building ${DOCKER_IMAGE}"
docker build --no-cache --tag ${DOCKER_IMAGE} .

if [[ "$1" == 'push' ]]
then
  echo "Tagging image ${DOCKER_IMAGE} as ${GCR_REPOSITORY}/${DOCKER_IMAGE}"
  docker tag ${DOCKER_IMAGE} ${GCR_REPOSITORY}/${DOCKER_IMAGE}

  echo "Publishing image ${GCR_REPOSITORY}/${DOCKER_IMAGE}"
  docker push ${GCR_REPOSITORY}/${DOCKER_IMAGE}
fi
