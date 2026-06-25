#!/usr/bin/env bash
set -e

if command -v fnlo-tk-config &> /dev/null ; then
    exit 0
fi

VERSION=2.6.0-4000
tar xzf /opt/installers/fastnlo_toolkit-${VERSION}.tar.gz
cd fastnlo_toolkit-${VERSION}

./configure --prefix=${INSTALL_DIR}
make -j$(nproc)
make install

