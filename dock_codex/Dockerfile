FROM docker.io/library/node:22-trixie

ARG USERNAME=node

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    build-essential \
    procps \
    less \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex

COPY codex-entrypoint.sh /usr/local/bin/codex-entrypoint

RUN mkdir -p /codex /workspace "/home/${USERNAME}" \
    && rm -rf "/home/${USERNAME}/.codex" \
    && ln -s /codex "/home/${USERNAME}/.codex" \
    && chown -R "${USERNAME}:${USERNAME}" /codex /workspace "/home/${USERNAME}" \
    && chown -h "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.codex" \
    && chmod +x /usr/local/bin/codex-entrypoint

ENV HOME=/home/node
ENV CODEX_HOME=/codex
ENV XDG_CONFIG_HOME=/codex/config
ENV XDG_DATA_HOME=/codex/share
ENV XDG_CACHE_HOME=/codex/cache

WORKDIR /workspace

ENTRYPOINT ["codex-entrypoint"]
CMD ["codex"]
