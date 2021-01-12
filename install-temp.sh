#!/usr/local/bin/bash
echo "Getting a random recommended NordVPN server"

URL="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations"
SERVER=$(/usr/local/bin/curl -s "$URL" --globoff | /usr/local/bin/jq -r '.[].hostname' | sort --random-sort | head -n 1)
SERVER_FILE="https://downloads.nordcdn.com/configs/files/ovpn_tcp/servers/${SERVER}.tcp.ovpn"

/usr/local/bin/wget -q "${SERVER_FILE}" -O "/usr/local/etc/openvpn/client.conf"
