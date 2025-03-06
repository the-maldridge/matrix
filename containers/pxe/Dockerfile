FROM docker.io/library/alpine:latest AS ipxe_build
ARG IPXE_REV=be3a78ea
WORKDIR /ipxe
RUN apk update && apk add git build-base perl xz-dev && \
    git clone https://github.com/ipxe/ipxe.git . && \
    git checkout ${IPXE_REV} && cd src && \
    make bin/undionly.kpxe bin-x86_64-efi/snponly.efi

FROM alpine:latest
WORKDIR /tftproot
RUN apk add --no-cache dnsmasq tini
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY --from=ipxe_build /ipxe/src/bin/undionly.kpxe .
COPY --from=ipxe_build /ipxe/src/bin-x86_64-efi/snponly.efi .

ENTRYPOINT ["/sbin/tini", "/usr/sbin/dnsmasq", "--no-daemon", "-C", "/etc/dnsmasq.conf"]
