#!/bin/bash

source ../generic.sh

IMAGE_NAME=dock_radicale
CONT_NAME=test_radicale
DATA_FOLDER=${PWD}/radicale_data
PORT=5467


create_ssl() {
    echo "Installing certbot"
    sudo apt install python3-certbot
    sudo certbot certonly
}

renew_ssl() {
    sudo certbot renew
}

prepare_folder() {
    mkdir -p ${DATA_FOLDER}/calendars
    # The root of docker has 165536 in the outside world
    # radicale is then running as an unprivileged user inside docker
    echo ".. changing permissions for ${DATA_FOLDER}/calendars"
    sudo chown :docker_escritura -R ${DATA_FOLDER}/
    sudo chmod g+rw -R ${DATA_FOLDER}/calendars
}

create_user() {
    if [[ ! -d ${DATA_FOLDER} ]]
    then
        prepare_folder
    fi
    touch ${DATA_FOLDER}/users
    htpasswd ${DATA_FOLDER}/users $1
}

usage() {
    echo "~$ ./runthisall.sh -cbr -sn -f -u USER"
    echo "    -i name of the instance"
    echo "    -s creates ssl certificate"
    echo "    -n renews ssl certificate"
    echo "    -u create a new user"
    echo "    -f prepare radicale folder (permissions and so)"
    echo "    -c remove test container and image"
    echo "    -b build the docker image"
    echo "    -r run docker image"
    echo "    -l see logs"
}

docker_build_radicale() { 
    read -r -p "Do you want to enable SSL directly in docker? [y/N] " response
    cp config.in config
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        sed -i 's/ssl = False/ssl = True/g' config
    else
        sed -i 's/ssl = True/ssl = False/g' config
    fi

    docker_build $1
    rm config
}

while getopts 'i:fcsnu:brl' flag
do
    case "${flag}" in
        i) CONT_NAME=${OPTARG} ;;
        c) docker_full_clean ${IMAGE_NAME} ${CONT_NAME} ;;
        s) create_ssl ;;
        n) renew_ssl ;;
        f) prepare_folder ;;
        u) create_user ${OPTARG} ;;
        b) docker_build_radicale ${IMAGE_NAME} ;;
        r) docker_run ${IMAGE_NAME} ${CONT_NAME} -p $PORT -v ${DATA_FOLDER}:/mnt ;; # -i /bin/sh ;;
        l) docker_logs ${CONT_NAME} ;;
        *) usage
            exit 1 ;;
    esac
done

if [[ $# == 0 ]]
then
    usage
    exit -1
fi
