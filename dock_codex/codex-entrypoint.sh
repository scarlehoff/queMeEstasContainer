#!/usr/bin/env bash
set -euo pipefail

USERNAME="${USERNAME:-node}"

# In order to make the codex state persistent while making the docker container fixed
# the volume with the persistent state needs to be mounted each time, meaning that the
# entry point must ensure (each time) that the permissions in the mounted volume are correct
mkdir -p /codex /codex/config /codex/share /codex/cache
chown -R "${USERNAME}:${USERNAME}" /codex

# We do that as root, and then we drop down to the user
exec runuser -u "${USERNAME}" -- codex "$@"
