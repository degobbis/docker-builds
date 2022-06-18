ARG VERSION

FROM mysql:${VERSION}-debian

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

RUN set -eu; \
    apt-get update && apt-get upgrade -y; \
    apt-get install -y locales tzdata; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    echo "$MY_TZ" >/etc/timezone; \
    echo "de_DE.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" >/etc/locale.gen; \
    locale-gen; \
    dpkg-reconfigure -f noninteractive tzdata; \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/mysql

COPY ./shared/aliases.sh /root/.bashrc
COPY ./db/docker-entrypoint-mysql /docker-entrypoint
COPY ./db/backup-databases-mysql /usr/local/bin/backup-databases
COPY ./db/restore-databases-mysql /usr/local/bin/restore-databases

RUN set -eu; \
    rm -rf /usr/local/bin/docker-entrypoint.sh /entrypoint.sh; \
    chmod +x /docker-entrypoint; \
    chmod +x /usr/local/bin/*

STOPSIGNAL "SIGQUIT"
EXPOSE "3306"
ENTRYPOINT ["/docker-entrypoint"]
#CMD ["mysqld"]
CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--skip-character-set-client-handshake"]
