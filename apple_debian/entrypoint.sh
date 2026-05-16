#!/usr/bin/env bash
set -euo pipefail

USERNAME="${USERNAME:-juacrumar}"
STATE_VOLUME="${STATE_VOLUME:-/state_volume}"
PORT="${PORT:-11311}"
OPENCODE_CONFIG="${STATE_VOLUME}/opencode/config/opencode/opencode.json"

# Keep tool state in the mounted volume, then run the requested command as USERNAME.

if ! mountpoint -q "$STATE_VOLUME"; then
    echo "FATAL: Volume not mounted at $STATE_VOLUME. Exiting..." >&2
    exit 1
fi

mkdir -p "${STATE_VOLUME}/codex"

# These are the targets of the opencode symlinks created in the Dockerfile.
mkdir -p "${STATE_VOLUME}/opencode/config/opencode" \
         "${STATE_VOLUME}/opencode/share/opencode" \
         "${STATE_VOLUME}/opencode/cache/opencode"

if [[ ! -f "$OPENCODE_CONFIG" ]]; then
  cp /usr/local/share/opencode/opencode.json "$OPENCODE_CONFIG"
fi

# Set up all permissions in the volume before running any tools as the container user.
chown -R "${USERNAME}:${USERNAME}" "$STATE_VOLUME"

if [[ -z "${OMLX_BASE_URL:-}" ]]; then
  OMLX_HOST="$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf)"
  export OMLX_BASE_URL="http://${OMLX_HOST}:${PORT}/v1"
fi

export HOME="/home/${USERNAME}"
export USER="$USERNAME"
export LOGNAME="$USERNAME"
export SHELL=/bin/bash
export TERM="${TERM:-xterm-256color}"

setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups \
  opencode-refresh-models "$OPENCODE_CONFIG"

exec setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups "$@"
