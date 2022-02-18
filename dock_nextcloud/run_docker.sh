#!/bin/bash

container_name=nextc
local_path=${PWD}/my_nextcloud_data
local_port=8050


mkdir -p ${local_path}
docker run -v "${local_path}:/var/www/html" -d --name ${container_name} -p ${local_port}:80 dock_nextcloud

echo "To follow the logs do ~$ docker logs ${container_name} -f"
