#!/usr/bin/env sh

nc -z 127.0.0.1 $TPROXY_PORT
if [ $? -ne 0 ]; then
    echo "!!!FAILED:TPROXY_PORT $TPROXY_PORT not ready for tcp."
    exit 1
fi

nc -uz 127.0.0.1 $TPROXY_PORT
if [ $? -ne 0 ]; then
    echo "!!!FAILED:TPROXY_PORT $TPROXY_PORT not ready for udp."
    exit 1
fi

if [ -n  "$DNS_PORT" ]; then
    nc -uz 127.0.0.1 $TPROXY_PORT
    if [ $? -ne 0 ]; then
	echo "!!!FAILED:DNS_PORT $DNS_PORT not ready."
	exit 1
    fi
fi
