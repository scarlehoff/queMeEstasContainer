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
else
    cd ${repo_name}
    git pull
    cd -
fi

echo "If you need to update the packages, you might need to update the ownership of the package.json file!"

./run_site.sh
