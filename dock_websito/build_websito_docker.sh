#!/bin/bash

source ../generic.sh
source ./websito_vars.sh

docker container stop ${container_name}
docker container rm ${container_name}
docker rmi ${image_name}

docker_build ${image_name}

# Clone the repo if not already done
if [ ! -d ${repo_name} ]
then
    git clone https://github.com/scarlehoff/websito.git ${repo_name}
fi

./run_site.sh
