#!/usr/bin/env bash
#
# This script works as my development environment under Apple
# It opens a container with neovim already installed and with all plugins pre-installed,
# alongisde other tools such as opencode.
# It mounts the current directory with a few extra checks:
# 1) If it is under the $MAIN_DISK folder at all, it mounts all the way down to the root of $MAIN_DISK
# 2) Otherwise, if it is a git repository, mount all the way up to the root of the repository
# 3) Otherwise just the current directory.
# The work directory (MOUNT_ROOT) is mounted with the same path as the host to facilitate
#
set -euo pipefail

# Important variables
MAIN_DISK=/Volumes/csDisk/
IMAGE=debian-apple-juacrumar
STATE_VOLUME_NAME=debian-apple-state
STATE_VOLUME_PATH=/state_volume
PIXI_VOLUME_NAME=pixi-state
PIXI_VOLUME_PATH=/pixi_volume
NNPDF_DATA_PATH=/nnpdf_data

# Take the actual path (symlinks resolved)
HOST_PWD=$(pwd -P)

# Folder that will be mounted in the container defaulting to the current folder
MOUNT_ROOT=${HOST_PWD}
# but will be changed by the checks below

# If the current HOST_PWD is under MAIN_DISK, just mount MAIN_DISK
# else, check whether we are in a 
case "$HOST_PWD/" in
    "$MAIN_DISK"*) MOUNT_ROOT=$MAIN_DISK ;;
    *)
        # Check whether we are at a git repo and then mount from the root
        if GIT_ROOT=$(git -C "$HOST_PWD" rev-parse --show-toplevel 2>/dev/null); then
            MOUNT_ROOT=$GIT_ROOT
        fi
        ;;
esac

# Check whether the volume saving the state already exist, if it doesn't, create it
container volume inspect "${STATE_VOLUME_NAME}" >/dev/null 2>&1 \
  || container volume create "${STATE_VOLUME_NAME}" >/dev/null
container volume inspect "${PIXI_VOLUME_NAME}" >/dev/null 2>&1 \
  || container volume create "${PIXI_VOLUME_NAME}" >/dev/null

# Then, we mount MOUNT_ROOT and we set the working directory as HOST_PWD
# so that we are at the "right place"
container run --rm -it \
    --name containDev \
    --volume "${STATE_VOLUME_NAME}:${STATE_VOLUME_PATH}" \
    --volume "${PIXI_VOLUME_NAME}:${PIXI_VOLUME_PATH}" \
    --mount type=bind,src="${MOUNT_ROOT}",dst="${MOUNT_ROOT}" \
    --mount type=bind,src="~/.local/share/NNPDF",dst="${NNPDF_DATA_PATH}" \
    --workdir "$HOST_PWD" \
    -e HOST_TMUX="${TMUX:-}" \
    -e TERM="${TERM:-xterm-256color}" \
    -e COLORTERM="${COLORTERM:-truecolor}" \
    -e OMLX_BASE_URL="${OMLX_BASE_URL:-}" \
    -e OMLX_API_KEY="${OMLX_API_KEY:-1234}" \
    ${IMAGE} "$@"
