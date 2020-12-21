#!/bin/sh

service transmission stop
while [ -e '/var/run/transmission/daemon.pid' ]; do
  sleep 1
done
