#!/usr/bin/env bash
#
# This script works as my version of neovim
# It opens a container with neovim already installed and with all plugins pre-installed,
# but with no access to the internet.
# It mounts the current directory with a few extra checks:
# 1) If it is under the $MAIN_DISK folder at all, it mounts all the way down to the root of $MAIN_DISK
# 2) Otherwise, if it is a git repository, mount all the way up to the root of the repository
# 3) Otherwise just the current directory.
#
set -euo pipefail

MAIN_DISK=/Volumes/csDisk/

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



# Then, we mount MOUNT_ROOT and we set the working directory as HOST_PWD
# so that we are at the "right place"
container run --rm -it \
  --platform linux/arm64 \
  --network none \
  --volume "$MOUNT_ROOT:$MOUNT_ROOT" \
  --workdir "$HOST_PWD" \
  nvim-alpine-arm64 nvim "$@"
