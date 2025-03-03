FROM alpine:latest

WORKDIR /tftproot

RUN apk add --no-cache dnsmasq tini && \
        wget http://boot.ipxe.org/undionly.kpxe
COPY dnsmasq.conf /etc/dnsmasq.conf

ENTRYPOINT ["/sbin/tini", "/usr/sbin/dnsmasq", "--no-daemon", "-C", "/etc/dnsmasq.conf"]
