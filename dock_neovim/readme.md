This container is a bit different from all the others, in that the goal is to use Apple's containers: https://github.com/apple/container to isolate `neovim` and all of their plugins from the rest of the system.

The build script moves the vim/neovim configuration files into the Dockerfile context and installs it,
then upon building it also installs all plugins and mason, etc.

Then we have a run script, `./run_container.sh`, which is basically running the container with vim.

```sh
./run_container.sh file.py
```
