ARG VERSION
ARG TAG="$VERSION-fpm-alpine"

FROM php:$TAG

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

COPY ./shared/aliases.sh /etc/profile.d/

RUN set -eux; \
    apk upgrade --update; \
    apk add --no-cache tzdata shadow; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    rm -rf /var/cache/apk/*

COPY ./php/install-php-extensions /usr/local/bin/
COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/

RUN set -eux; \
    chmod +x /usr/local/bin/*

ENV PHPIZE_DEPS \
        autoconf \
        coreutils \
        dpkg-dev dpkg \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c

RUN install-php-extensions \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gettext \
        gmp \
        imap \
        intl \
        ldap \
        mysqli \
        opcache \
        pdo_mysql \
        soap \
        sockets \
        xdebug \
        xmlrpc \
        xsl \
        zip

WORKDIR "/srv/www"

STOPSIGNAL "SIGQUIT"
EXPOSE "9000"
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["/usr/local/sbin/php-fpm"]
