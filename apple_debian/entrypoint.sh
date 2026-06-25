#!/usr/bin/env bash
set -euo pipefail

USERNAME="${USERNAME:-juacrumar}"
STATE_VOLUME="${STATE_VOLUME:-/state_volume}"
PIXI_VOLUME="${PIXI_VOLUME:-/pixi_volume}"
PIXI_HOME="${PIXI_HOME:-${PIXI_VOLUME}/dot_pixi}"
PI_CODING_AGENT_DIR="${PI_CODING_AGENT_DIR:-${STATE_VOLUME}/pi/agent}"
PORT="${PORT:-11311}"
OPENCODE_CONFIG="${STATE_VOLUME}/opencode/config/opencode/opencode.json"
PI_MODELS="${PI_CODING_AGENT_DIR}/models.json"
WORKDIR="$PWD"

# And set some environment variables
export HOME="/home/${USERNAME}"
export USER="$USERNAME"
export LOGNAME="$USERNAME"
export SHELL=/bin/bash
export PIXI_HOME
export PI_CODING_AGENT_DIR

# Check we have the volumes we need:
for volume in "$STATE_VOLUME" "$PIXI_VOLUME"; do
    if ! mountpoint -q "$volume"; then
        echo "FATAL: Volume not mounted at $volume. Exiting..." >&2
        exit 1
    fi
done

### First-run commands ###
# Create the necessary directories to hold the state of the different tools, with permission for $USERNAME
install -d "${STATE_VOLUME}/codex" -o $USERNAME -g $USERNAME
install -d "$PIXI_HOME" "${PIXI_VOLUME}/repository_environments" -o $USERNAME -g $USERNAME
install -d "$PI_CODING_AGENT_DIR" -o $USERNAME -g $USERNAME

# In some cases the tools use XDG directories, which in the container are links to the volume
install -o $USERNAME -g $USERNAME -d "${STATE_VOLUME}/opencode/config/opencode" \
    "${STATE_VOLUME}/opencode/share/opencode" \
    "${STATE_VOLUME}/opencode/cache/opencode"

if [[ ! -f "$OPENCODE_CONFIG" ]]; then
    cp /usr/local/share/opencode/opencode.json "$OPENCODE_CONFIG"
    chown "${USERNAME}:${USERNAME}" $OPENCODE_CONFIG
fi
##########################

# To make sure that opencode finds OMLX
if [[ -z "${OMLX_BASE_URL:-}" ]]; then
    OMLX_HOST="$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf)"
    export OMLX_BASE_URL="http://${OMLX_HOST}:${PORT}/v1"
fi

# Run the model refresher 
setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups \
    opencode-refresh-models "$OPENCODE_CONFIG"
setpriv --reuid="$USERNAME" --regid="$USERNAME" --init-groups \
    pi-refresh-models "$PI_MODELS"

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
        # Start bash explicitly so tmux does not launch login shells that reset PATH.
        bash|/bin/bash) cmd=(tmux -u -2 new-session -A -s dev bash ';' set-option -g default-command bash) ;;
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
