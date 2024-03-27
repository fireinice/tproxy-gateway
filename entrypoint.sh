#!/bin/sh

if [ -z  "$TPROXY_PORT" ]; then
    echo "!!!FAILED:No TPROXY_PORT specified."
    exit 1
fi

cp /scripts/init.ipset /iptables/ipset
/scripts/update_ipset.sh /iptables/ipset

/scripts/iptables.sh
if [ $? -ne 0 ]; then
    exit 1
fi
sleep inf
