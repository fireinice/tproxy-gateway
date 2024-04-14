#!/bin/sh
TPMARK=1
DNSMARK=9853

ip rule add fwmark ${TPMARK} table 100
ip route add local 0.0.0.0/0 dev lo table 100

if [ -n "$DNS_HOST" -a -z "$DNS_PORT" ]; then
    DNS_PORT=53
fi

if [ -n "$DNS_PORT" ]; then
    iptables -t nat -N clash_dns
    iptables -t nat -A clash_dns -m set --match-set bypass_private dst -j RETURN
    if [ -z "$DNS_HOST" ]; then
	iptables -t nat -A clash_dns -p udp -j REDIRECT --to-port $DNS_PORT
    else
	if [ "$DNS_HOST" = "${DNS_HOST%:*}" ]; then
	    DNS_HOST=$DNS_HOST:$DNS_PORT
	fi
	iptables -t nat -A clash_dns -j MARK --set-mark ${DNSMARK}
	iptables -t nat -A clash_dns -p udp -j DNAT --to $DNS_HOST
	iptables -t nat -A POSTROUTING -m mark --mark ${DNSMARK} -j MASQUERADE
    fi
    iptables -t nat -A PREROUTING -p udp --dport 53 -j clash_dns
fi

# CREATE TABLE
iptables -t mangle -N clash

# RETURN LOCAL AND LANS
# for later redirect
iptables -t mangle -A clash -p udp --dport 53 -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_private dst -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_dest dst -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_source src -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_mac_src src -j RETURN

# FORWARD ALL
iptables -t mangle -A clash -p udp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark ${TPMARK}
iptables -t mangle -A clash -p tcp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark ${TPMARK}

# REDIRECT
iptables -t mangle -A PREROUTING -j clash

iptables -A OUTPUT -m set --match-set local_ips src,dst -p udp --sport 1000:65535 --dport $TPROXY_PORT -j REJECT
iptables -A OUTPUT -m set --match-set local_ips src,dst -p tcp --sport 1000:65535 --dport $TPROXY_PORT -j REJECT

# SKIP ALL SOCKETS ALREADY CONNECTED AND INSERT INTO HEAD OF Mangle
if [ "$DIVERT_SOCKET" = true ]; then
    # use restore-skmark will cause youtube video load problem
    iptables -t mangle -N DIVERT
    iptables -t mangle -A DIVERT -j MARK --set-mark 1
    iptables -t mangle -A DIVERT -j ACCEPT
    iptables -t mangle -I PREROUTING -p tcp -m socket --transparent -j DIVERT
fi

# ip6tables -t mangle -N clash

# ip6tables -t mangle -A clash -m set --match-set bypass_private_v6 dst -j RETURN
# ip6tables -t mangle -A clash -m set --match-set bypass_dest_v6 dst -j RETURN
# ip6tables -t mangle -A clash -m set --match-set bypass_source_v6 src -j RETURN

# ip6tables -t mangle -A clash -p udp -j TPROXY --on-port $PROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1
# ip6tables -t mangle -A clash -p tcp -j TPROXY --on-port $PROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1
# ip6tables -t mangle -A PREROUTING -j clash

# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升 v6
# ip6tables -t mangle -N DIVERT
# ip6tables -t mangle -A DIVERT -j MARK --set-mark 1
# ip6tables -t mangle -A DIVERT -j ACCEPT
# ip6tables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT
