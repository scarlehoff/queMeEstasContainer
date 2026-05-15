FROM debian:trixie-slim

ARG NVIM_URL=https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    ripgrep \
    fd-find \
    tree-sitter-cli \
    bash \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    tar \
    gzip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz \
    && tar xzf /tmp/nvim.tar.gz -C /opt \
    && ln -s /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

RUN useradd -m -s /bin/bash juacrumar 

COPY --chown=juacrumar:juacrumar ./nvim_config/ /home/juacrumar/.config/nvim/
COPY --chown=juacrumar:juacrumar ./vim/ /home/juacrumar/.vim

USER juacrumar
WORKDIR /work

ENV HOME=/home/juacrumar
ENV XDG_CONFIG_HOME=/home/juacrumar/.config
ENV XDG_DATA_HOME=/home/juacrumar/.local/share
ENV XDG_STATE_HOME=/home/juacrumar/.local/state
ENV XDG_CACHE_HOME=/home/juacrumar/.cache

RUN nvim --headless \
    "+PlugInstall --sync" \
    "+PlugUpdate --sync" \
    "+source ~/.config/nvim/init.lua" \
    "+MasonInstall pyright esbonio emmet-language-server eslint-lsp bash-language-server" \
    "+sleep 120" \
    +qa

CMD ["nvim"]
