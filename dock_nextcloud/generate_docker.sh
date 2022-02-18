#!/bin/bash

container_image="dock_nextcloud"

echo "Assistant for the generation of the docker image for nextcloud behind a nginx reverse proxy"
echo "Write the host address, for instance my.nextcloud.es"
read -r -p "> " host
echo "Write the root for nextcloud, for instance: /"
read -r -p "> /" webroot
# Let's assume that nobody will ever want to add a second level here, it is trivial to change but I'm lazy today

echo "Nextcloud should be accesible from"
echo " https://${host}/${webroot}"
read -r -p "is that correct? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Great!"
else
    exit
fi

cat Dockerfile.in > Dockerfile
sed -i "s/CUSTOMWEBROOT/${webroot}/g" Dockerfile
sed -i "s/CUSTOMHOST/${host}/g" Dockerfile

# This is only necessary if a WEBROOT is used
# in theory the correct thing is to, after creating the image, going inside the docker file
# and then changing config.php and then running occ maintenance:update:htcaccess
# This is the only method I've found to do it at build time without the need for manual configuration
if [ ! -z "${webroot}" ]
then
    sed "s/WEBROOT/${webroot}/g" apache.conf.in > apache.conf
    sed "s/WEBROOT/${webroot}/g" apache-pretty-urls.config.php.in > apache-pretty-urls.config.php
    sed -i 's/#COPY/COPY/g' Dockerfile
fi

docker build -t "${container_image}:latest" .
