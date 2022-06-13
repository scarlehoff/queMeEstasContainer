#!/bin/bash

source ../generic.sh

image_name=dock_websito
container_name=websito_test

docker container stop ${container_name}
docker container rm ${container_name}

docker_build ${image_name} --network host --no-cache

./run_site.sh
