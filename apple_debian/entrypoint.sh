#!/usr/bin/env bash
set -euo pipefail

USERNAME="${USERNAME:-juacrumar}"
STATE_VOLUME="${STATE_VOLUME:-/state_volume}"
PIXI_VOLUME="${PIXI_VOLUME:-/pixi_volume}"
PIXI_HOME="${PIXI_HOME:-${PIXI_VOLUME}/dot_pixi}"
PORT="${PORT:-11311}"
OPENCODE_CONFIG="${STATE_VOLUME}/opencode/config/opencode/opencode.json"
WORKDIR="$PWD"

# Keep tool state in the mounted volume, then run the requested command as USERNAME.
if ! mountpoint -q "$STATE_VOLUME"; then
    echo "FATAL: Volume not mounted at $STATE_VOLUME. Exiting..." >&2
    exit 1
fi
if ! mountpoint -q "$PIXI_VOLUME"; then
    echo "FATAL: Volume not mounted at $PIXI_VOLUME. Exiting..." >&2
    exit 1
fi

mkdir -p "${STATE_VOLUME}/codex"
mkdir -p "$PIXI_HOME" "${PIXI_VOLUME}/repository_environments"

# These are the targets of the opencode symlinks created in the Dockerfile.
mkdir -p "${STATE_VOLUME}/opencode/config/opencode" \
         "${STATE_VOLUME}/opencode/share/opencode" \
         "${STATE_VOLUME}/opencode/cache/opencode"

if [[ ! -f "$OPENCODE_CONFIG" ]]; then
  cp /usr/local/share/opencode/opencode.json "$OPENCODE_CONFIG"
fi

# Set up all permissions in the volume before running any tools as the container user.
chown -R "${USERNAME}:${USERNAME}" "$STATE_VOLUME"
chown -R "${USERNAME}:${USERNAME}" "$PIXI_VOLUME"

if [[ -z "${OMLX_BASE_URL:-}" ]]; then
  OMLX_HOST="$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf)"
  export OMLX_BASE_URL="http://${OMLX_HOST}:${PORT}/v1"
fi

setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups \
  opencode-refresh-models "$OPENCODE_CONFIG"

export HOME="/home/${USERNAME}"
export USER="$USERNAME"
export LOGNAME="$USERNAME"
export SHELL=/bin/bash
export LANG="${LANG:-C.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-C.UTF-8}"
export COLORTERM="${COLORTERM:-truecolor}"
case "${TERM:-}" in
  ""|xterm) export TERM=xterm-256color ;;
  *) export TERM ;;
esac
export PIXI_HOME

# Act differently depending on whether
# a) We gave a direct command to entrypoint.sh
# b) We are running under TMUX in the host
# c) We are running "free range" in a terminal
if [[ "$#" -eq 0 ]]; then
  cmd=(bash)
else
  cmd=("$@")
fi

if [[ "${#cmd[@]}" -eq 1 && -z "${HOST_TMUX:-}" && -z "${TMUX:-}" && -t 0 && -t 1 ]]; then
  case "${cmd[0]}" in
    bash|/bin/bash) cmd=(tmux -u -2 new-session -A -s dev) ;;
  esac
fi

# Finally, try to figure out whether we have a pixi environment already for this repository
pixi_toml=""
dir="$WORKDIR"
while [[ "$dir" != "/" ]]; do
  folder="${dir##*/}"
  for repo_name in "$folder" "${folder,,}"; do
    candidate="${PIXI_VOLUME}/repository_environments/${repo_name}/pixi.toml"
    if [[ -f "$candidate" ]]; then
      pixi_toml="$candidate"
      break 2
    fi
  done
  dir="${dir%/*}"
  [[ -n "$dir" ]] || dir="/"
done

if [[ -n "$pixi_toml" ]]; then
  exec setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups \
    bash -c 'set -e; hook="$(pixi shell-hook --manifest-path "$1")"; eval "$hook"; export debian_chroot="${PIXI_PROJECT_NAME:-pixi}"; cd "$2"; shift 2; exec "$@"' \
    pixi-entrypoint "$pixi_toml" "$WORKDIR" "${cmd[@]}"
fi

exec setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups "${cmd[@]}"
