ARG VERSION="0.0.0"
ARG TAG="$VERSION-fpm-alpine"

FROM php:$TAG

ARG TARGETARCH
ARG INST_PHP_EXT
ARG VERSION="0.0.0"
ARG MAINTAINER="Guido De Gobbis"
ARG BUILD_DATE="1970-01-01T00:00:00UTC"
ARG DOCUMENTATION="no documentation"
ARG MY_TZ="UTC"

LABEL org.opencontainers.image.authors="$MAINTAINER" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.documentation="$DOCUMENTATION" \
      org.opencontainers.image.version="$VERSION"

ENV TZ="$MY_TZ" \
    ENV="/etc/profile"

COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/
COPY ./shared/aliases.sh /etc/profile.d/
COPY ./shared/mhsendmail/linux_$TARGETARCH/mhsendmail /usr/local/bin/
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY ./php/install-php-extensions /usr/local/bin/

RUN set -eu; \
    chmod +x /httpd-php-entrypoint; \
    chmod +x /usr/local/bin/* ; \
    apk upgrade --update --no-cache; \
    apk add --no-cache \
        tzdata \
        shadow \
        git \
        ca-certificates \
        gnu-libiconv; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    install-php-extensions ${INST_PHP_EXT}; \
    rm -rf /var/cache/apk/* /tmp/*

WORKDIR "/srv/www"

STOPSIGNAL SIGQUIT
EXPOSE 9000
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["/usr/local/sbin/php-fpm"]
