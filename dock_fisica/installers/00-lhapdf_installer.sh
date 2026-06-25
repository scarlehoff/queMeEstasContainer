#!/bin/bash
set -e

# LHAPDF version to install
LHAPDF_VERSION="6.5.5"

if command -v lhapdf-config &> /dev/null ; then
    exit 0
fi

wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz
tar -xzf LHAPDF-${LHAPDF_VERSION}.tar.gz
cd LHAPDF-${LHAPDF_VERSION}
./configure --prefix=${INSTALL_DIR}
make -j$(nproc)
make install
