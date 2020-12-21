#!/bin/sh

PYTHON3=$(which python3)
TRANSMISSION_CONFIG=/usr/local/etc/transmission/home/settings.json

service transmission stop
while [ -e '/var/run/transmission/daemon.pid' ]; do
  sleep 1
done

${PYTHON3} fix_ip.py "/usr/local/etc/transmission/home/settings.json" "$4"

service transmission start
