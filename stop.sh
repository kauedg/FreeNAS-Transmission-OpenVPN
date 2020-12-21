#!/usr/bin/env bash

service transmission stop
while [ -e '/var/run/transmission/daemon.pid' ]; do
  sleep 1
done

pkill openvpn
