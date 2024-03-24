FROM alpine:latest
ENV NET_DEST_V4=
ENV NET_DEST_V6=
ENV NET_SRC_V4=
ENV NET_SRC_V6=
ENV MAC_SRC_V4=
ENV MAC_SRC_V6=
ENV TPROXY_PORT=
ENV DNS_PORT=
ENV DIVERT_SOCKET=true
RUN apk add --no-cache ca-certificates tzdata iptables ipset
ADD entrypoint.sh /
ADD scripts /scripts
VOLUME /iptables
HEALTHCHECK --interval=60s --retries=1 \
  CMD /scripts/health_check.sh
ENTRYPOINT [ "/entrypoint.sh" ]
