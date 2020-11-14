ARG VERSION
ARG TAG="$VERSION-alpine"

FROM httpd:$TAG

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

COPY ./httpd/apache24/config/httpd.conf /usr/local/apache2/conf/
COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/

RUN set -eux; \
    chmod +x /httpd-php-entrypoint && \
    chmod +x /usr/local/bin/*

WORKDIR "/srv/www"

STOPSIGNAL "SIGWINCH"
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["httpd-foreground"]
