#!/usr/bin/bash

CONTAINER_NAME=hep-baseline
VOLUME=physics_tools

EXTRA_ARGS=()

if command -v lhapdf-config &> /dev/null
then
    echo "Local version of LHAPDF found, mounting its datadir"
    CONTAINER_DATADIR=$(sudo docker run --rm -v ${VOLUME}:/opt/physics ${CONTAINER_NAME} lhapdf-config --datadir)
    LOCAL_DATADIR=$(lhapdf-config --datadir)
    EXTRA_ARGS+=("-v" "${LOCAL_DATADIR}:${CONTAINER_DATADIR}")
fi

sudo docker run -it --rm ${EXTRA_ARGS[@]} \
    -v ${VOLUME}:/opt/physics \
    ${CONTAINER_NAME}
