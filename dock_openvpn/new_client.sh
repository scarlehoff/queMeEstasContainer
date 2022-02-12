#!/bin/sh
source sh_variables

# Usage: ./new_client.sh <client_name>
# Create configurations files for new clients

client=$1

cd ${easyrsa_folder}
mkdir -p ${clients_folder}
output_file=${clients_folder}/${client}.ovpn

EASYRSA_CERT_EXPIRE=3650 ${easyrsa} build-client-full "$client" nopass

{
	cat ${commonclient_file}
	echo "<ca>"
	cat ${easyrsa_folder}/pki/ca.crt
	echo "</ca>"
	echo "<cert>"
	sed -ne '/BEGIN CERTIFICATE/,$ p' ${easyrsa_folder}/pki/issued/"$client".crt
	echo "</cert>"
	echo "<key>"
	cat ${easyrsa_folder}/pki/private/"$client".key
	echo "</key>"
	echo "<tls-crypt>"
	sed -ne '/BEGIN OpenVPN Static key/,$ p' ${easyrsa_folder}/tc.key
	echo "</tls-crypt>"
} > ${output_file}

echo "Config file ${output_file} created"
