# some generic functions that are common for everyone

docker_logs () {
    docker logs ${1} -f
}

docker_clean_container() {
    docker container rm ${1}
}

docker_full_clean() {
    docker_clean_container ${2}
    docker rmi ${1}
}

docker_build() {
    image_name=${1}
    shift
    docker buildx build --force-rm -t "${image_name}:latest" . $@
}

docker_run() {
    image_name=${1}
    container_name=${2}

    mode="-dt"

    shift 2;
    for arg in $@
    do
        shift
        case $arg in
            -p) ports="-p ${1}:${1}" ;;
            -v) volume="-v ${1}" ;;
            -i) mode="-it"; executable=${1} ;;
        esac
    done

    docker run $ports $volume ${mode} --name ${container_name} ${image_name}:latest ${executable}
}

docker_interactive() {
    # Start interactively docker image ${1}
    docker run -it --entrypoint /bin/sh ${1}
}
