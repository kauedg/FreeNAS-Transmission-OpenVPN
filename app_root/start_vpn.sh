#!/usr/local/bin/bash

BASE_DIR="/opt/transmissionvpn/"
LOG_DIR="/var/log/transmissionvpn"
PID_DIR="/var/run/transmissionvpn"
OPENVPN_CONF_FILE="${BASE_DIR}/openvpn/openvpn.conf"

echo "====== Environment cleanup ======"
OPENVPN_COUNT=$(ps -xc -o command | grep -i openvpn -c)
if [ $OPENVPN_COUNT -ne 0 ]; then
  echo -n "- Killing $OPENVPN_COUNT OpenVPN processe(s) "
  OUT=$(pkill openvpn)
  RET=$?

  if [ $RET -ne 0 ]; then
    echo -e "\n[Error]"
    echo "  [!] Return code: $RET"
    echo "  [!] Message: $OUT"
    exit 1
  fi

  echo "[ok]"
else
  echo "- No OpenVPN processes running"
fi

echo ""

# Remove existing tun devices
TUN_COUNT=$(printf '%s\n' $(ifconfig -l) | grep tun* -c)
if [ $TUN_COUNT -ne 0 ]; then
  echo "- Removig $TUN_COUNT TUN interface(s)"

  for IFACE_NAME in $(printf '%s\n' $(ifconfig -l) | grep tun* ); do
    OUT=$(ifconfig "$IFACE_NAME" destroy)
    RET=$?

    if [ $RET -ne 0 ]; then
      echo -e "\n[Error]"
      echo "  [!] Return code: $RET"
      echo "  [!] Message: $OUT"
      exit 3
    fi

    echo "  > Removed [${IFACE_NAME}]"
  done
else
  echo "- No TUN interfaces found"
fi

echo ""
echo "====== TUN Interface ======"
# Create the first available tun device
# ifconfig return codes:
#   0: interface created
#   1: "ifconfig: SIOCIFCREATE2: File exists"
#   2+: inexpected error
echo "- Creating TUN device ";
RET=1
while [ $RET -eq 1 ]; do
  TUN_DEV=$(ifconfig tun create)
  RET=$?

  [ $RET -eq 0 ] && echo "  > Device name: [${TUN_DEV}]";

  [ $RET -ge 1 ] && {
    echo -e "\n[Error]"
    echo "[!] Unexpected error 'ifconfig tun create' return code: $RET";
    echo "[!] Message: $TUN_DEV"
    exit 4
  }
done

echo ""
echo "====== OpenVPN requirements ======"
if ! [ -d "${LOG_DIR}" ]; then
  mkdir -p ${LOG_DIR}
fi
echo "Log directory: ${LOG_DIR}"

if ! [ -d "${PID_DIR}" ]; then
  mkdir -p ${PID_DIR}
fi
echo "PID directory: ${PID_DIR}"

if ! [ -f "${OPENVPN_CONF_FILE}" ]; then
  echo "Getting a random recommended NordVPN server"

  URL="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations"
  SERVER=$(/usr/local/bin/curl -s "$URL" --globoff | /usr/local/bin/jq -r '.[].hostname' | sort --random-sort | head -n 1)
  /usr/local/bin/wget -q "https://downloads.nordcdn.com/configs/files/ovpn_tcp/servers/${SERVER}.tcp.ovpn" -O "${BASE_DIR}/openvpn/openvpn.conf"
fi

if ! [ -f "${BASE_DIR}/openvpn/credentials" ]; then
  echo "Missing OpenVPN credentials file: '${BASE_DIR}/openvpn/credentials'";
  echo "The file must have the following content: "
  echo "    Line 1: [vpn account username]"
  echo "    Line 2: [vpn account password]"
  exit 6;
fi

echo "====== OpenVPN start ======"
echo -n "- Starting OpenVPN client... "
OPENVPN=$(which openvpn)
OUT=$(/usr/local/sbin/openvpn \
  --dev ${TUN_DEV} \
  --daemon openvpn \
  --cd "${BASE_DIR}" \
  --config openvpn/openvpn.conf \
  --up "start_transmission.sh ${TUN_DEV}" \
  --down "stop_transmission.sh" \
  --script-security 2 \
  --log-append "${LOG_DIR}/openvpn.log" \
  --writepid "${PID_DIR}/openvpn.pid" \
  --auth-user-pass openvpn/credentials)

RET=$?

if [ $RET -ne 0 ]; then
  echo "Error"
  echo "[!] Return code: $RET";
  echo "[!] Message: $OUT"
  echo "Check log files for details: "
  echo "  System:  /var/log/messages"
  echo "  OpenVPN: ${LOG_DIR}/openvpn.log"

  exit 7
else
  echo "ok"
fi

echo -n "- Waiting for ${TUN_DEV} IP address lease"
IP_ADDRESS=""
while [ "$IP_ADDRESS" == "" ]; do
  IP_ADDRESS=$(ifconfig ${TUN_DEV} inet | sed -nr 's/.*inet ([0-9\.]+).*/\1/p')
  echo -n "."
  sleep 1
done

echo "Removing default route"
route del default

echo " ${IP_ADDRESS}"

exit 0
