ARG VERSION="0.0.0"

FROM mysql:${VERSION}

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

VOLUME /var/lib/mysql

COPY ./shared/aliases.sh /root/.bashrc
COPY ./db/docker-entrypoint-mysql /docker-entrypoint
COPY ./db/backup-databases-mysql /usr/local/bin/backup-databases
COPY ./db/restore-databases-mysql /usr/local/bin/restore-databases

RUN set -eu; \
    rm -rf /usr/local/bin/docker-entrypoint.sh /entrypoint.sh; \
    chmod +x /docker-entrypoint; \
    chmod +x /usr/local/bin/*

#STOPSIGNAL "SIGQUIT"
EXPOSE "3306"
ENTRYPOINT ["/docker-entrypoint"]
#CMD ["mysqld"]
CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]
