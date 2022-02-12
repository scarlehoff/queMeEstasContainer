FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

# Define variables
ARG PORT=1194

# Install all necessary packages
RUN apk update && apk upgrade && apk add openvpn openssl ca-certificates iptables --no-cache

EXPOSE $PORT

# Copy the VPN configuration
COPY server.conf /etc/openvpn/server/server.conf

# Copy all the easy-rsa keys and information
# Make sure to run ./easy_crypto.sh first to generate all certificates!
RUN mkdir -p /etc/openvpn/server/easy-rsa/
COPY easyrsa_keys/* /etc/openvpn/server/
COPY easyrsa_keys/pki /etc/openvpn/server/easy-rsa/pki
# The group might be different from nobody for other distros
RUN chown nobody:nobody /etc/openvpn/server/crl.pem && chmod o+x /etc/openvpn/server

COPY ./entry_script.sh /usr/local/src/entry_script.sh
RUN chmod +x /usr/local/src/entry_script.sh
ENTRYPOINT /usr/local/src/entry_script.sh
