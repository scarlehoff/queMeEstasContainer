#!/bin/bash

container_name=nextc
local_path=${PWD}/my_nextcloud_data
local_port=8050


mkdir -p ${local_path}
docker run -v "${local_path}:/var/www/html" -d --name ${container_name} -p ${local_port}:80 dock_nextcloud

# sudo iptables -A INPUT -p tcp --dport 8050 -s 127.0.0.1 -j ACCEPT
# sudo iptables -A INPUT -p tcp --dport 8050 -j DROP
# sudo iptables -I DOCKER-USER --dport 8050 -i eno1 ! -s 127.0.0.1 -j DROP

# With this group seems to do as expected:
sudo iptables -A INPUT -p tcp --dport 8050 -s 127.0.0.1 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8050 -j DROP
sudo iptables -I DOCKER-USER -i eno1 ! -s 127.0.0.1 -j DROP
sudo iptables -I DOCKER-USER -p tcp -i eno1 --dport 8050 -j REJECT

#sudo iptables -I DOCKER-USER -p tcp -i eno1 --dport 8050 -j DROP

echo "To follow the logs do ~$ docker logs ${container_name} -f"
