#!/bin/sh
cp /scripts/init.ipset /iptables/ipset
/scripts/update_ipset.sh /iptables/ipset
/scripts/iptables.sh
/clash
