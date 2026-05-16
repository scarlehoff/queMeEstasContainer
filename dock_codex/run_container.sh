#!/usr/bin/env bash
set -euo pipefail

# Container to activaet
IMAGE="codex-contained"

# Volume keeping the state
STATE_VOLUME="codex-state"

# Folder to mount for codex to have access to
PROJECT="$(pwd -P)"

# Check whether the volume saving the state already exist, if it doesn't, create it
container volume inspect "${STATE_VOLUME}" >/dev/null 2>&1 \
  || container volume create "${STATE_VOLUME}" >/dev/null

# We need -i to keep stdin open and talk with codex and -t to allocate a pseudo-terminal
RUN_FLAGS=(-it --rm)

container run "${RUN_FLAGS[@]}" \
  --volume "${STATE_VOLUME}:/codex" \
  --volume "${PROJECT}:/workspace" \
  --workdir /workspace \
  "$IMAGE" "$@"
