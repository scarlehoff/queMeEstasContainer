#!/bin/bash

container_image=dock_dlna
container_name=minidlna
local_media=$HOME/videos

build_container() {
    docker container prune ; docker rmi ${container_image}
    docker build -t "${container_image}:latest" .
}

run_container() {
    echo "[INFO] This docker images will look into $local_media for media files"
    echo "[Warning] The docker minidlna container needs to run within the host namespace in order to share the network"
    echo "          I have not been able to figure out how to expose only particular ports"
    # In principle the only ports needed are 8200 and 1900/udp
    docker run --userns=host --net=host --mount type=bind,source=$local_media,target=/mnt/Videos -dt --name ${container_name}  ${container_image}
}

echo "Run ~$ build_container # to build the container"
echo "and ~$ run_container # to run it"
