#!/usr/local/bin/bash

echo "========================================="
echo $0
echo "========================================="
env
echo "========================================="
# echo "Getting a random recommended NordVPN server"
#
# URL="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations"
# SERVER=$(/usr/local/bin/curl -s "$URL" --globoff | /usr/local/bin/jq -r '.[].hostname' | sort --random-sort | head -n 1)
# /usr/local/bin/wget -q "https://downloads.nordcdn.com/configs/files/ovpn_tcp/servers/${SERVER}.tcp.ovpn" -O "${BASE_DIR}/openvpn/openvpn.conf"
