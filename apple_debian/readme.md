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
The python environments are defined using pixi, with the environments prepared in the `pixi-state` (`/pixi_volume`) volume.
If a repository (for instance nnpdf) has a matching `/pixi_volume/<repo_name>` folder, the container will run `pixi shell` first thing.

