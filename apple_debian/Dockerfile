FROM debian:trixie-slim

# Variables and arguments necessary at build time
ARG NVIM_URL=https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
ARG NODE_DIST_BASE=https://nodejs.org/dist/latest
ARG USERNAME=juacrumar
ARG STATE_VOLUME=/state_volume
ARG PIXI_VOLUME=/pixi_volume
ARG NNPDF_DATA=/nnpdf_data

# Pass some as environment variables
ENV USERNAME=${USERNAME}
ENV STATE_VOLUME=${STATE_VOLUME}
ENV PIXI_VOLUME=${PIXI_VOLUME}
ENV LANG=C.UTF-8
ENV TERM=xterm-256color

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
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

## Download and install packages not available in APT
# neovim
RUN curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz \
    && tar xzf /tmp/nvim.tar.gz -C /opt \
    && ln -s /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# node
RUN set -e; \
    mkdir -p /tmp/node-install; \
    curl -fsSL "${NODE_DIST_BASE}/SHASUMS256.txt" -o /tmp/node-install/SHASUMS256.txt; \
    node_file="$(awk '/node-v.*-linux-arm64.tar.xz$/ { print $2; exit }' /tmp/node-install/SHASUMS256.txt)"; \
    test -n "$node_file"; \
    curl -fsSL "${NODE_DIST_BASE}/${node_file}" -o "/tmp/node-install/${node_file}"; \
    awk -v file="$node_file" '$2 == file { print }' /tmp/node-install/SHASUMS256.txt > /tmp/node-install/SHASUMS256.selected; \
    (cd /tmp/node-install && sha256sum -c SHASUMS256.selected); \
    tar -xJf "/tmp/node-install/${node_file}" -C /opt; \
    mv "/opt/${node_file%.tar.xz}" /opt/node; \
    ln -sf /opt/node/bin/node /usr/local/bin/node; \
    ln -sf /opt/node/bin/npm /usr/local/bin/npm; \
    ln -sf /opt/node/bin/npx /usr/local/bin/npx; \
    rm -rf /tmp/node-install

# codex, opencode & pi
RUN npm install -g @openai/codex opencode-ai \
    && npm install -g --ignore-scripts --min-release-age=0 @earendil-works/pi-coding-agent \
    && ln -sf /opt/node/bin/codex /usr/local/bin/codex \
    && ln -sf /opt/node/bin/opencode /usr/local/bin/opencode \
    && ln -sf /opt/node/bin/pi /usr/local/bin/pi

# pixi
RUN export PIXI_HOME=/opt/pixi \
    && curl -fsSL https://pixi.sh/install.sh | sh \
    && ln -s /opt/pixi/bin/pixi /usr/local/bin/pixi

# User for the container 
RUN useradd -U -m -s /bin/bash $USERNAME \
    && install -d -o $USERNAME -g $USERNAME "/home/${USERNAME}/.config" \
                "/home/${USERNAME}/.local/share" \
                "/home/${USERNAME}/.local/state" \
                "/home/${USERNAME}/.cache" \
                "/home/${USERNAME}/.pi"

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

# nnpdf
COPY --chown=$USERNAME:$USERNAME ./config_files/nnprofile.yaml /home/$USERNAME/.config/NNPDF/nnprofile.yaml
RUN install -d -o $USERNAME -g $USERNAME ${NNPDF_DATA}

# codex 
# no config needed, everything will be under ${CODEX_HOME} in the mounted volume

# opencode
# opencode does use ~/.config, ~/.local, etc, but we want the state in ${STATE_VOLUME}
# so we will create links inside the XDG directories to the volume
# in addition, we need to copy two configuration files
COPY ./config_files/opencode.json /usr/local/share/opencode/opencode.json
COPY ./config_files/opencode-refresh-models.js /usr/local/bin/opencode-refresh-models
COPY ./config_files/pi-refresh-models.js /usr/local/bin/pi-refresh-models
RUN ln -s ${STATE_VOLUME}/opencode/config/opencode "/home/${USERNAME}/.config/opencode" \
 && ln -s ${STATE_VOLUME}/opencode/share/opencode "/home/${USERNAME}/.local/share/opencode" \
 && ln -s ${STATE_VOLUME}/opencode/cache/opencode "/home/${USERNAME}/.cache/opencode" \
 && ln -s ${STATE_VOLUME}/pi/agent "/home/${USERNAME}/.pi/agent" \
 && chmod +x /usr/local/bin/opencode-refresh-models /usr/local/bin/pi-refresh-models

# Make sure permissions are ok
RUN chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" ${NNPDF_DATA}

USER $USERNAME
WORKDIR /work

# codex will be saving all its state, aut, etc to $CODEX_HOME
# make sure that's pointing to the mounted volume
ENV CODEX_HOME=${STATE_VOLUME}/codex

# pixi does something similar
ENV PIXI_HOME=${PIXI_VOLUME}/dot_pixi

# pi keeps settings and sessions under this directory
ENV PI_CODING_AGENT_DIR=${STATE_VOLUME}/pi/agent

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
