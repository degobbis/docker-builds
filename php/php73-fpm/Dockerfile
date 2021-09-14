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

RUN set -eu; \
    apk add --no-cache tzdata shadow git ca-certificates; \
    apk upgrade --update; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime

# fix work iconv library with alphine
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

COPY ./php/install-php-extensions /usr/local/bin/
COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/

RUN set -eu; \
    chmod +x /httpd-php-entrypoint && \
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

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer; \
    rm -rf /var/cache/apk/*

WORKDIR "/srv/www"

STOPSIGNAL "SIGQUIT"
EXPOSE "9000"
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["/usr/local/sbin/php-fpm"]
