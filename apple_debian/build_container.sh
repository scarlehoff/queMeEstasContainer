#!/usr/bin/env bash
set -euo pipefail # Stop on command errors, unset variables, and failed pipelines.

# Clean up by running rm -rf when you arrive to EXIT
trap 'rm -rf nvim_config vim tmux_config' EXIT 

# we need -L because some of these are links to my dot files folders and docker won't transverse them when copying
cp -RL "$HOME/.config/nvim" nvim_config 
cp -RL "$HOME/.config/tmux" tmux_config 
cp -RL "$HOME/.vim/"  vim

container build --platform linux/arm64 -t debian-apple-juacrumar
