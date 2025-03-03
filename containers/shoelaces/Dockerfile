FROM docker.io/golang:alpine AS build
WORKDIR /shoelaces
COPY void-x86_64-musl-NETBOOT.tar.gz /void-netboot.tar.gz
RUN apk add tini-static git && \
    git clone -b v1.2.0 https://github.com/thousandeyes/shoelaces.git . && \
    go mod vendor && CGO_ENABLED=0 go build -o ./shoelaces . && \
    printf "---\nnetworkMaps:\n" > mappings.yaml && \
    mkdir -p /netboot && tar -zvxf /void-netboot.tar.gz -C /netboot

FROM alpine:latest
COPY --from=build /shoelaces/shoelaces /shoelaces
COPY --from=build /shoelaces/web /static
COPY --from=build /shoelaces/mappings.yaml /data/mappings.yaml
COPY --from=build /netboot/vmlinuz /data/static/void/
COPY --from=build /netboot/initrd /data/static/void/
COPY --from=build /sbin/tini-static /tini
COPY void.ipxe.slc /data/ipxe/
COPY hdd.ipxe.slc /data/ipxe/
COPY autoinstall.cfg /data/static/void/autoinstall.cfg
ENTRYPOINT ["/tini", "/shoelaces", "-data-dir", "/data", "-static-dir", "/static"]
