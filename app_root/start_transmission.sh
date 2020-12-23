#!/usr/local/bin/bash

# Parameters provided by the openvpn "--up" option:
# $0  cmd
# $1  tun_dev
# $2  tun_mtu
# $3  link_mtu
# $4  ifconfig_local_ip
# $5  ifconfig_remote_ip
# $6 [init | restart]
# Example: tun0 1500 1587 10.7.1.3 255.255.255.0 init
TUN_DEV=$1
VPN_LOCAL_IP_ADDRESS=$4

TRANSMISSION_CONFIG=/usr/local/etc/transmission/home/settings.json

# This script's output will be written to the "openvpn.log" file
echo "----- Begin $0"

/sbin/resolvconf -u

echo "- IP Address: ${IP_ADDRESS}"

if ! [ -f "${TRANSMISSION_CONFIG}" ]; then
  echo "Missing ''${TRANSMISSION_CONFIG}'' file.";
  exit 1;
fi

echo ""
echo "- Setting the VPN IP address in the 'settings.json' file"
OUT=$(sed -i -e "s/\(\"bind-address-ipv4\"\).*/\1: \"$IP_ADDRESS\",/" "${TRANSMISSION_CONFIG}")
RET=$?

[ $? -ne 0 ] && { echo "Error"; exit 2; }

echo ""
echo "- Starting transmission service"
service transmission onestart

[ $? -ne 0 ] && { echo "Error"; exit 3; }

echo "----- End $0"

exit 0
