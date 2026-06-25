# Apple Debian development container

This image is a Debian development environment for Apple Containers on macOS.
It includes Neovim, Codex, opencode, pi, and common command-line tools used for
development, testing, and document inspection.

## Build

Build the image with:

```bash
./build_container.sh
```

The build script copies the host Neovim and Vim configuration into the build context before running `container build`.
The container user defaults to `juacrumar` but it can be changed in the Dockerfile.

## Run

Start an interactive shell with:

```bash
./run_container.sh
```

If this is launched from a normal terminal, the container starts a `tmux`
session automatically. If the host is already inside `tmux`, it starts a plain
shell instead. The image defaults to a UTF-8 locale and `xterm-256color`, so
Neovim icons render correctly.

or some specific tool directly, like `codex`, `opencode`, or `pi`.

```bash
./run_container.sh codex
./run_container.sh opencode
./run_container.sh pi
./run_container.sh nvim .
```

Direct commands are not wrapped in `tmux`.

The run script starts the container with 8 CPUs and 16 GB of memory by default.
Override that when needed:

```bash
CONTAINER_MEMORY=8G CONTAINER_CPUS=6 ./run_container.sh
```

The run script mounts the current working area into the container and sets the
container working directory to the same path. If the current directory is under
`/Volumes/csDisk`, it mounts it all the way to `csDisk`. 
Otherwise, it mounts the enclosing git repository root.

## State

Persistent tool state lives in the `debian-apple-state` volume mounted at `/state_volume`.
Pixi state lives in the `pixi-state` volume mounted at `/pixi_volume`, with
`PIXI_HOME=/pixi_volume/dot_pixi`.

Codex state is stored in `/state_volume/codex`. opencode state is stored under
`/state_volume/opencode`. pi state is stored in `/state_volume/pi/agent`, with
`PI_CODING_AGENT_DIR` pointing there.

At startup, the entrypoint refreshes opencode and pi model configuration from
OMLX at `OMLX_BASE_URL`, defaulting to the host resolver on port `11311`.
pi gets an `omlx` provider in `/state_volume/pi/agent/models.json`; use
`pi --list-models omlx` to inspect it and `pi --model omlx/<model>` to use one
directly.

Per-repository pixi projects go under:

```text
/pixi_volume/repository_environments/<repo_name>/pixi.toml
```

When the container starts, the entrypoint walks upward from the current
directory and looks for a matching pixi project by folder name.
If a matching `pixi.toml` exists, the entrypoint activates it with
`pixi shell-hook`, returns to the original working directory, and runs the
requested command. In the auto-started tmux session, panes start with `bash`
so the pixi `PATH` is preserved. If no matching `pixi.toml` exists, startup
behaves normally.
