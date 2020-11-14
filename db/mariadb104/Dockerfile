FROM alpine:3.12
LABEL maintainer="Guido De Gobbis"

COPY ./shared/aliases.sh /etc/profile.d/

ARG MY_TZ
ENV TZ=${MY_TZ:-Europe/Berlin} \
    ENV="/etc/profile"

RUN set -eux; \
    apk upgrade --update; \
    apk add --no-cache tzdata shadow mariadb mariadb-client mariadb-server-utils; \
    ln -sf /usr/share/zoneinfo/${MY_TZ:-Europe/Berlin} /etc/localtime; \
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

RUN set -eux; \
    chmod +x /usr/local/bin/*

STOPSIGNAL SIGQUIT
EXPOSE 3306
ENTRYPOINT ["/docker-entrypoint"]
CMD ["mysqld_safe"]
