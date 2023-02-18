#!/bin/bash
source sh_variables

if [ -d ${easyrsa_folder} ]; then
    echo "This folder will fully regenerate the contents of ${easyrsa_folder}"
    echo "since this is potentially very destructive, please, remove it yourself:"
    echo "sudo rm -rf ${easyrsa_folder}"
fi

if [ ! -f ./client-common.txt.in ]
then
    cp client-common.txt.in client-common.txt
fi

mkdir -p ${easyrsa_folder}

cd ${easyrsa_folder}
${easyrsa} init-pki
${easyrsa} --batch build-ca nopass

export EASYRSA_CERT_EXPIRE=3650
export EASYRSA_CRL_DAYS=3650
${easyrsa} build-server-full server nopass
${easyrsa} gen-crl
sudo openvpn --genkey secret tc.key
sudo chown $USER tc.key

openssl dhparam -out dh.pem 4096 # we could also go down to 2048

cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/crl.pem ${easyrsa_folder}
cd -
