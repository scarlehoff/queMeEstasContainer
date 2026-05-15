#!/usr/bin/env bash
set -euo pipefail

# To build it: container build --platform linux/arm64 -t nvim-alpine-arm64

WORKDIR=/Volumes/csDisk/

# Keep the image's default user so /home/juacrumar stays writable.
container run --rm -it \
  --platform linux/arm64 \
  --volume "$WORKDIR:/work" \
  --workdir /work \
  nvim-alpine-arm64 "$@"
#   --network none \
