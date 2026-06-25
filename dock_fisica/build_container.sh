#!/usr/bin/bash

CONTAINER_NAME=hep-baseline
VOLUME=physics_tools
PHYSICS_VOLUME_PATH=/opt/physics

# Build the container
docker build -t ${CONTAINER_NAME} .

docker volume inspect "${VOLUME}" >/dev/null 2>&1 \
  || docker volume create "${VOLUME}" >/dev/null

docker run --rm \
    -v ${VOLUME}:${PHYSICS_VOLUME_PATH} \
    ${CONTAINER_NAME} \
    bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'

docker run --rm \
    -v ${VOLUME}:${PHYSICS_VOLUME_PATH} \
    -u root \
    ${CONTAINER_NAME} \
    bash -c 'for script in /opt/installers/*.sh; do bash "$script"; done'

docker run --rm \
    -v ${VOLUME}:${PHYSICS_VOLUME_PATH} \
    ${CONTAINER_NAME} \
    bash -c 'cargo install --locked pineappl_cli --features=fastnlo,evolve,fktable'
