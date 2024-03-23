from metacubex/clash-meta:latest
ENV DEST_V4='http://www.ipdeny.com/ipblocks/data/countries/cn.zone'
ENV DEST_V6=
ENV SOURCE_V4=
ENV SOURCE_V6=
ENV MAC_SRC_V4=
ENV MAC_SRC_V6=
RUN apk add --no-cache ipset iptables \
    # ip6tablesa \
    && \
    rm -rf /var/cache/apk/*
ADD entrypoint.sh /
ADD scripts /scripts
VOLUME /iptables
ENTRYPOINT [ "/entrypoint.sh" ]
