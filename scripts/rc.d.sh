#!/bin/sh

. /etc/rc.subr

name="transmissionvpn"
start_cmd="${name}_start"
stop_cmd="${name}_stop"

: ${vpn_dir=/opt/transmissionvpn}

transmissionvpn_start()
{
    $transmission_dir/run.sh
}

transmissionvpn_stop()
{
    $transmission_dir/stop.sh
}


load_rc_config $name
run_rc_command "$1"
