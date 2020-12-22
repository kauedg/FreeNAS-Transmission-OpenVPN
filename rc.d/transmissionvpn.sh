#!/bin/sh

. /etc/rc.subr

name="transmissionvpn"
start_cmd="${name}_start"
stop_cmd="${name}_stop"

transmissionvpn_start()
{
    service transmission status && service transmission stop
    /opt/transmissionvpn/start_vpn.sh
}

transmissionvpn_stop()
{
    service transmission status && service transmission stop
    #/opt/transmissionvpn/stop_vpn.sh
}


load_rc_config $name
run_rc_command "$1"
