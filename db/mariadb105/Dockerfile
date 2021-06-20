FROM alpine:edge

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
    apk add --no-cache tzdata shadow mariadb mariadb-client mariadb-server-utils; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    mkdir /docker-entrypoint-initdb.d; \
    rm -rf /var/cache/apk/*

# comment out a few problematic configuration values
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/my.cnf && \
    sed -i  's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf && \
    # don't reverse lookup hostnames, they are usually another container
    sed -i '/^\[mysqld]$/a skip-host-cache\nskip-name-resolve' /etc/my.cnf && \
    # always run as user mysql
    sed -i '/^\[mysqld]$/a user=mysql' /etc/my.cnf && \
    # allow custom configurations
    echo -e '\n!includedir /etc/mysql/conf.d/' >> /etc/my.cnf && \
    mkdir -p /etc/mysql/conf.d/

VOLUME /var/lib/mysql

COPY ./db/docker-entrypoint /
COPY ./db/backup-databases /usr/local/bin/
COPY ./shared/create_user /usr/local/bin/

RUN set -eux; \
    chmod +x /docker-entrypoint && \
    chmod +x /usr/local/bin/*

STOPSIGNAL "SIGQUIT"
EXPOSE "3306"
ENTRYPOINT ["/docker-entrypoint"]
CMD ["mysqld_safe"]
