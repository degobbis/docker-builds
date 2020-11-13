ARG VERSION
ARG TAG="${VERSION:-7.4}-fpm-alpine"

FROM php:${TAG}
LABEL maintainer="Guido De Gobbis"

COPY ./shared/aliases.sh /etc/profile.d/

ARG MY_TZ
ENV TZ=${MY_TZ:-Europe/Berlin} \
    ENV="/etc/profile"

RUN set -eux; \
    apk upgrade --update; \
    apk add --no-cache tzdata shadow; \
    ln -sf /usr/share/zoneinfo/${MY_TZ:-Europe/Berlin} /etc/localtime; \
    rm -rf /var/cache/apk/*

# fix work iconv library with alphine
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

COPY ./php/install-php-extensions /usr/local/bin/
COPY ./shared/httpd-php-entrypoint /usr/local/bin/
COPY ./shared/create_user /usr/local/bin/

RUN set -eux; \
    find /usr/local/bin -type f -exec chmod +x {} \;

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

STOPSIGNAL SIGQUIT
EXPOSE 9000
ENTRYPOINT ["httpd-php-entrypoint"]
CMD ["/usr/local/sbin/php-fpm"]
