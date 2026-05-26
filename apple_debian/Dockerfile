FROM debian:trixie-slim

# Variables and arguments necessary at build time
ARG NVIM_URL=https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
ARG USERNAME=juacrumar
ARG STATE_VOLUME=/state_volume
ARG PIXI_VOLUME=/pixi_volume

ENV USERNAME=${USERNAME}
ENV STATE_VOLUME=${STATE_VOLUME}
ENV PIXI_VOLUME=${PIXI_VOLUME}

# Install what we can from apt
#     procps: API to read from /proc
#     poppler: utilities to read PDFs
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    git \
    gzip \
    imagemagick \
    jq \
    less \
    nodejs \
    npm \
    openssh-client \
    procps \
    poppler-utils \
    python3 \
    python3-pip \
    python3-pypdf \
    python3-venv \
    ripgrep \
    tar \
    tesseract-ocr \
    tmux \
    tree-sitter-cli \
    vim-tiny \
    unzip \
    && rm -rf /var/lib/apt/lists/*

## Download and install packages not available in APT
# neovim
RUN curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz \
    && tar xzf /tmp/nvim.tar.gz -C /opt \
    && ln -s /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# codex & opencode
RUN npm install -g @openai/codex opencode-ai

# pixi
RUN export PIXI_HOME=/opt/pixi \
    && curl -fsSL https://pixi.sh/install.sh | sh \
    && ln -s /opt/pixi/bin/pixi /usr/local/bin/pixi

# User for the container 
RUN useradd -U -m -s /bin/bash $USERNAME \
    && mkdir -p "/home/${USERNAME}/.config" \
                "/home/${USERNAME}/.local/share" \
                "/home/${USERNAME}/.local/state" \
                "/home/${USERNAME}/.cache"

## Set up the configuration for each tool

# neovim
# Copy configuration files from the host, these should be available to the build context
# the preparation is done by the ./build_container.sh script
# These are:
#   - nvim_config: ~/.config/nvim
#   - vim: ~/.vim
COPY --chown=$USERNAME:$USERNAME ./nvim_config/ /home/$USERNAME/.config/nvim/
COPY --chown=$USERNAME:$USERNAME ./vim/ /home/$USERNAME/.vim

# tmux
COPY --chown=$USERNAME:$USERNAME ./tmux_config/ /home/$USERNAME/.config/tmux

# codex 
# no config needed, everything will be under ${CODEX_HOME} in the mounted volume

# opencode
# opencode does use ~/.config, ~/.local, etc, but we want the state in ${STATE_VOLUME}
# so we will create links inside the XDG directories to the volume
# in addition, we need to copy two configuration files
COPY ./config_files/opencode.json /usr/local/share/opencode/opencode.json
COPY ./config_files/opencode-refresh-models.js /usr/local/bin/opencode-refresh-models
RUN ln -s ${STATE_VOLUME}/opencode/config/opencode "/home/${USERNAME}/.config/opencode" \
 && ln -s ${STATE_VOLUME}/opencode/share/opencode "/home/${USERNAME}/.local/share/opencode" \
 && ln -s ${STATE_VOLUME}/opencode/cache/opencode "/home/${USERNAME}/.cache/opencode" \
 && chmod +x /usr/local/bin/opencode-refresh-models

# Set up permissions
RUN chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"

USER $USERNAME
WORKDIR /work

# codex will be saving all its state, aut, etc to $CODEX_HOME
# make sure that's pointing to the mounted volume
ENV CODEX_HOME=${STATE_VOLUME}/codex

# pixi does something similar
ENV PIXI_HOME=${PIXI_VOLUME}/dot_pixi

ENV HOME=/home/$USERNAME
ENV XDG_CONFIG_HOME=/home/$USERNAME/.config
ENV XDG_DATA_HOME=/home/$USERNAME/.local/share
ENV XDG_STATE_HOME=/home/$USERNAME/.local/state
ENV XDG_CACHE_HOME=/home/$USERNAME/.cache

# Now pre-run the installation of plugins and so
RUN nvim --headless \
    "+PlugInstall --sync" \
    "+PlugUpdate --sync" \
    "+source ~/.config/nvim/init.lua" \
    "+MasonInstall pyright esbonio emmet-language-server eslint-lsp bash-language-server" \
    "+sleep 120" \
    +qa

# Start as root so the entrypoint can repair mounted volume permissions, then
# it drops to USERNAME before running the requested command.
USER root

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["bash"]
