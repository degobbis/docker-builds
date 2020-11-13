ARG VERSION
ARG TAG="${VERSION:-5.6}-fpm-alpine"

FROM php:${TAG}

COPY ./shared/aliases.sh /etc/profile.d/

ARG MY_TZ
ENV TZ=${MY_TZ} \
    ENV="/etc/profile"

RUN set -eux; \
    apk upgrade --update; \
    apk add --no-cache tzdata shadow; \
    ln -sf /usr/share/zoneinfo/${MY_TZ} /etc/localtime; \
    rm -rf /var/cache/apk/*

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
