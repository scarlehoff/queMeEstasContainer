#!/bin/bash

source ../generic.sh

image_name=dock_websito
container_name=websito_test

docker_build ${image_name}

./run_site.sh
