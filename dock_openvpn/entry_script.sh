#!/bin/sh

# Entry script for the docker openvpn
# The commented iptables options are from nyr's roadwarrior: https://github.com/Nyr/openvpn-install
# but they doesn't seem to be all that necessary... should look into them more carefully

# # Preparation of iptables firewall
# protocol=udp # could also be TCP
# port=$VPNPORT
# iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
# iptables -I INPUT -p $protocol --dport $port -j ACCEPT
# iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
# iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -t nat -D POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
# iptables -D INPUT -p $protocol --dport $port -j ACCEPT
# iptables -D FORWARD -s 10.8.0.0/24 -j ACCEPT
# iptables -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT"

# Chances are de que todo lo que necesite sea esto:
# sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
cd /etc/openvpn/server/
openvpn server.conf
