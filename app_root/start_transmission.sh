#!/usr/local/bin/bash

TRANSMISSION_CONFIG=/usr/local/etc/transmission/home/settings.json

# This script's output will be written to the "openvpn.log" file
echo "----- Begin $0"

[ -z $1 ] && { echo "Missing the TUN interface name"; exit 1; }

TUN_DEV=$1

echo -n "- Waiting for ${TUN_DEV} IP address lease"
IP_ADDRESS=""
while [ "$IP_ADDRESS" == "" ]; do
  IP_ADDRESS=$(ifconfig ${TUN_DEV} inet | sed -nr 's/.*inet ([0-9\.]+).*/\1/p')
  echo -n "."
  sleep 1
done

echo "  > ${IP_ADDRESS}"

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
