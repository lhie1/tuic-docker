FROM alpine:latest as base

RUN apk add --no-cache curl jq \
    && VERSION=$(curl --silent "https://api.github.com/repos/EAimTY/tuic/releases/latest" | jq -r .tag_name) \
    && echo "$VERSION" > /tmp/tuic_version.subst \
    && apk del curl jq

FROM alpine:latest

COPY --from=base /tmp/tuic_version.subst /tmp/

ARG ARCH=x86_64-unknown-linux-musl
ARG TUIC_VERSION

RUN if [ -z "$TUIC_VERSION" ]; then \
        TUIC_VERSION=$(cat /tmp/tuic_version.subst); \
    fi \
    && apk add --no-cache ca-certificates \
    && wget https://github.com/EAimTY/tuic/releases/download/${TUIC_VERSION}/${TUIC_VERSION}-${ARCH} \
    -O /usr/bin/tuic-server \
    && chmod +x /usr/bin/tuic-server

WORKDIR /etc/tuic
COPY config.json /etc/tuic/

ENTRYPOINT ["tuic-server"]
CMD ["-c", "/etc/tuic/config.json"]