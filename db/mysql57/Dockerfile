FROM mysql:5.7-debian

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

RUN set -eu; \
    apt-get update; \
    apt-get install -y tzdata; \
    ln -sf /usr/share/zoneinfo/$MY_TZ /etc/localtime; \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/mysql

COPY ./shared/aliases.sh /root/.bashrc
COPY ./db/docker-entrypoint-mysql /docker-entrypoint
COPY ./db/backup-databases-mysql /usr/local/bin/backup-databases
COPY ./db/restore-databases-mysql /usr/local/bin/restore-databases

RUN set -eu; \
    chmod +x /docker-entrypoint; \
    chmod +x /usr/local/bin/*

RUN  rm -rf /usr/local/bin/docker-entrypoint.sh /entrypoint.sh

STOPSIGNAL "SIGQUIT"
EXPOSE "3306"
ENTRYPOINT ["/docker-entrypoint"]
CMD ["mysqld"]
