ARG VERSION
ARG TAG="${VERSION:-2.4}-alpine"

FROM httpd:${TAG}
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

COPY ./httpd/apache24/config/httpd.conf /usr/local/apache2/conf/
COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/

RUN set -eux; \
    chmod +x /usr/local/bin/*

WORKDIR "/srv/www"

STOPSIGNAL SIGWINCH
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["httpd-foreground"]
