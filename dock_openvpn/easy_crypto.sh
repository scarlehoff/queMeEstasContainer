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

cn_name=$(cat client-common.txt | grep x509 | cut -d ' ' -f 2)

mkdir -p ${easyrsa_folder}

cd ${easyrsa_folder}
${easyrsa} init-pki
${easyrsa} --batch build-ca nopass

export EASYRSA_CERT_EXPIRE=3650
export EASYRSA_CRL_DAYS=3650
# The CN here shoud match the name in client-common.txt
${easyrsa} build-server-full ${cn_name} nopass
${easyrsa} gen-crl
sudo openvpn --genkey secret tc.key
sudo chown $USER tc.key

openssl dhparam -out dh.pem 2048 # we could also go down to 2048

cp pki/issued/${cn_name}.crt ${easyrsa_folder}/server.crt
cp pki/private/${cn_name}.key ${easyrsa_folder}/server.key
cp pki/ca.crt pki/private/ca.key pki/crl.pem ${easyrsa_folder}
cd -
