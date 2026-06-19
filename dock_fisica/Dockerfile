FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    cmake \
    cython3 \
    curl \
    fd-find \
    gfortran \
    git \
    gzip \
    imagemagick \
    less \
    libssl-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python-is-python3 \
    python3-pypdf \
    python3-venv \
    ripgrep \
    tar \
    unzip \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=juacrumar
ARG PHYSICS_VOLUME=/opt/physics

ENV USERNAME=${USERNAME}
ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV PHYSICS_VOLUME=${PHYSICS_VOLUME}

ENV LD_LIBRARY_PATH="${PHYSICS_VOLUME}/lib:"
ENV PKG_CONFIG_PATH="${PHYSICS_VOLUME}/lib/pkgconfig:"
ENV CARGO_HOME="${PHYSICS_VOLUME}/.cargo"
ENV RUSTUP_HOME="${PHYSICS_VOLUME}/.rustup"
ENV PATH="${PHYSICS_VOLUME}/bin:${CARGO_HOME}/bin:${PATH}"
ENV INSTALL_DIR="${PHYSICS_VOLUME}"

RUN PY_SITE_PACKAGES=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib').split('/')[-2])") && \
    echo "${PHYSICS_VOLUME}/lib/python3/dist-packages" > "/usr/local/lib/${PY_SITE_PACKAGES}/dist-packages/physics_tools.pth" && \
    echo "${PHYSICS_VOLUME}/lib/${PY_SITE_PACKAGES}/dist-packages" > "/usr/local/lib/${PY_SITE_PACKAGES}/dist-packages/physics_tools.pth"

# Create the user and setup permissions
RUN useradd -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create the target directory and give the user ownership
RUN mkdir -p ${PHYSICS_VOLUME} ${CARGO_HOME} ${RUSTUP_HOME} && chown -R ${USERNAME}:${USERNAME} ${PHYSICS_VOLUME}
COPY installers/ /opt/installers/

# Switch to the non-root user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["/bin/bash"]
