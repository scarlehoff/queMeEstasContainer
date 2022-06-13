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
    sudo chown :docker_escritura -R ${DATA_FOLDER}/calendars
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
    echo "    -s creates ssl certificate"
    echo "    -n renews ssl certificate"
    echo "    -u create a new user"
    echo "    -f prepare radicale folder (permissions and so)"
    echo "    -c remove test container and image"
    echo "    -b build the docker image"
    echo "    -r run docker image"
    echo "    -l see logs"
}

while getopts 'fcsnu:br' flag
do
    case "${flag}" in
        c) docker_full_clean ${IMAGE_NAME} ${CONT_NAME} ;;
        s) create_ssl ;;
        n) renew_ssl ;;
        f) prepare_folder ;;
        u) create_user ${OPTARG} ;;
        b) docker_build ${IMAGE_NAME} ;;
        r) docker_run ${IMAGE_NAME} ${CONT_NAME} -p $PORT -v ${DATA_FOLDER}:/mnt ;; #-i /bin/sh ;;
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
