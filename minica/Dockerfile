FROM golang:1.15-alpine AS build
RUN apk add --no-cache git \
    && go get -v github.com/jsha/minica

FROM alpine:latest
COPY --from=build /go/bin/minica /usr/local/bin/minica

ARG VERSION
ARG MAINTAINER
ARG BUILD_DATE="1970-01-01T00:00:00UTC"
ARG DOCUMENTATION="no documentation"
ARG MY_TZ
ENV TZ="$MY_TZ" \
    ENV="/etc/profile"

LABEL org.opencontainers.image.authors="$MAINTAINER" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.documentation="$DOCUMENTATION" \
      org.opencontainers.image.version="$VERSION"

RUN set -eux; \
    chmod +x /usr/local/bin/*

WORKDIR /certs

ENTRYPOINT [ "minica" ]
