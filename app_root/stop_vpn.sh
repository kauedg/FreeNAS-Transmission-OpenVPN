#!/usr/local/bin/bash

echo "- Stopping transmission service."
service transmission onestatus && service transmission onestop

echo "- Killing running OpenVPN processe(s)... "
ps -xc -o command | grep -i openvpn -c && killall -TERM openvpn

# Remove pending tun devices
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
      exit 1
    fi

    echo "  > Removed [${IFACE_NAME}]"
  done
fi
