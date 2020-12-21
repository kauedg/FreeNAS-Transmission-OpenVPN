#!/bin/sh

. /etc/rc.subr

name="transmissionvpn"
start_cmd="${name}_start"
stop_cmd="${name}_stop"

transmissionvpn_start()
{
    /opt/transmissionvpn/run.sh
}

transmissionvpn_stop()
{
    /opt/transmissionvpn/stop.sh
}

load_rc_config $name
run_rc_command "$1"
