ARG VERSION="0.0.0"
ARG TAG="$VERSION-alpine"

FROM httpd:$TAG

ARG VERSION="0.0.0"
ARG MAINTAINER="Guido De Gobbis"
ARG BUILD_DATE="1970-01-01T00:00:00UTC"
ARG DOCUMENTATION="no documentation"
ARG MY_TZ="UTC"
ENV TZ="$MY_TZ" \
    ENV="/etc/profile"

LABEL org.opencontainers.image.authors="$MAINTAINER" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.documentation="$DOCUMENTATION" \
      org.opencontainers.image.version="$VERSION"

COPY ./shared/aliases.sh /etc/profile.d/

RUN set -eu; \
    apk add --no-cache tzdata shadow ca-certificates; \
    apk upgrade --update; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    rm -rf /var/cache/apk/*

COPY ./httpd/apache24/config/httpd.conf /usr/local/apache2/conf/
COPY ./shared/httpd-php-entrypoint /
COPY ./shared/create_user /usr/local/bin/

RUN set -eu; \
    chmod +x /httpd-php-entrypoint && \
    chmod +x /usr/local/bin/*

WORKDIR "/srv/www"

STOPSIGNAL "SIGWINCH"
ENTRYPOINT ["/httpd-php-entrypoint"]
CMD ["httpd-foreground"]
