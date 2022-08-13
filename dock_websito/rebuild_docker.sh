#!/bin/bash

source ../generic.sh

image_name=dock_websito
container_name=websito

docker container stop ${container_name}
docker container rm ${container_name}
docker rmi ${image_name}

docker_build ${image_name}

./run_site.sh
