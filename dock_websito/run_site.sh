#!/bin/bash

source ./websito_vars.sh

docker run -p 3000:3000 --mount type=bind,source=${repo_name},target=/websito -dt --name ${container_name} ${image_name}
