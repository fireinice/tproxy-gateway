from metacubex/clash-meta:latest
ENV NET_DEST_V4='http://www.ipdeny.com/ipblocks/data/countries/cn.zone'
ENV NET_DEST_V6=
ENV NET_SRC_V4=
ENV NET_SRC_V6=
ENV MAC_SRC_V4=
ENV MAC_SRC_V6=
RUN apk add --no-cache ipset iptables \
    # ip6tables \
    && \
    rm -rf /var/cache/apk/*
ADD entrypoint.sh /
ADD scripts /scripts
VOLUME /iptables
ENTRYPOINT [ "/entrypoint.sh" ]
