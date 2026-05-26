# Apple Debian development container

This image is a Debian development environment for Apple Containers on macOS.
It includes Neovim, Codex, opencode, and common command-line tools used for
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

or some specific tool directly, like `codex` or `opencode`.

```bash
./run_container.sh codex
./run_container.sh opencode
./run_container.sh nvim .
```

The run script mounts the current working area into the container and sets the
container working directory to the same path. If the current directory is under
`/Volumes/csDisk`, it mounts it all the way to `csDisk`. 
Otherwise, it mounts the enclosing git repository root.

## State

Persistent tool state lives in the `debian-apple-state` volume mounted at `/state_volume`.
Pixi state lives in the `pixi-state` volume mounted at `/pixi_volume`, with
`PIXI_HOME=/pixi_volume/dot_pixi`.

Per-repository pixi projects go under:

```text
/pixi_volume/repository_environments/<repo_name>/pixi.toml
```

When the container starts, the entrypoint walks upward from the current
directory and looks for a matching pixi project by folder name.
If a matching `pixi.toml` exists, the entrypoint activates it with
`pixi shell-hook`, returns to the original working directory, and runs the
requested command. If no matching `pixi.toml` exists, startup behaves normally.
