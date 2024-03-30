FROM alpine:latest
ENV NET_DST_V4= \
    NET_DST_V6= \
    NET_SRC_V4= \
    NET_SRC_V6= \
    MAC_SRC_V4= \
    MAC_SRC_V6= \
    TPROXY_PORT= \
    DNS_PORT= \
    DIVERT_SOCKET=true
RUN apk add --no-cache ca-certificates tzdata iptables ipset
ADD entrypoint.sh /
ADD scripts /scripts
VOLUME /iptables
HEALTHCHECK --interval=60s --retries=1 \
  CMD /scripts/health_check.sh
ENTRYPOINT [ "/entrypoint.sh" ]
