#!/bin/sh

ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

if [ -n "$DNS_PORT" ]; then
iptables -t nat -N clash_dns
iptables -t nat -F clash_dns
iptables -t nat -A clash_dns -m set --match-set bypass_private dst -j RETURN
# iptables -t nat -A clash_dns -m set --match-set bypass_dest dst -j RETURN
iptables -t nat -A clash_dns -p udp -j REDIRECT --to-port $DNS_PORT
iptables -t nat -I PREROUTING -p udp --dport 53 -j clash_dns
fi
# CREATE TABLE
iptables -t mangle -N clash

# RETURN LOCAL AND LANS
iptables -t mangle -A clash -m set --match-set bypass_private dst -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_dest dst -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_source src -j RETURN
iptables -t mangle -A clash -m set --match-set bypass_mac_src src -j RETURN

# FORWARD ALL
iptables -t mangle -A clash -p udp -j TPROXY --on-port $TPROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1
iptables -t mangle -A clash -p tcp -j TPROXY --on-port $TPROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1

# REDIRECT
iptables -t mangle -A PREROUTING -j clash
# ip6tables -t mangle -A PREROUTING -j clash

# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升 v4
iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
iptables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT

# ip6tables -t mangle -N clash

# ip6tables -t mangle -A clash -m set --match-set bypass_private_v6 dst -j RETURN
# ip6tables -t mangle -A clash -m set --match-set bypass_dest_v6 dst -j RETURN
# ip6tables -t mangle -A clash -m set --match-set bypass_source_v6 src -j RETURN

# ip6tables -t mangle -A clash -p udp -j TPROXY --on-port $PROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1
# ip6tables -t mangle -A clash -p tcp -j TPROXY --on-port $PROXY_PORT --on-ip 0.0.0.0 --tproxy-mark 1

# 新建 DIVERT 规则，避免已有连接的包二次通过 TPROXY，理论上有一定的性能提升 v6
# ip6tables -t mangle -N DIVERT
# ip6tables -t mangle -A DIVERT -j MARK --set-mark 1
# ip6tables -t mangle -A DIVERT -j ACCEPT
# ip6tables -t mangle -I PREROUTING -p tcp -m socket -j DIVERT
