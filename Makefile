#!/usr/bin/env make
DOCKER_BUILD_PHP56=./php/php56-fpm/hooks/build
DOCKER_BUILD_PHP73=./php/php73-fpm/hooks/build
DOCKER_BUILD_PHP74=./php/php74-fpm/hooks/build
DOCKER_BUILD_PHP80=./php/php80-fpm/hooks/build
DOCKER_BUILD_PHP81=./php/php81-fpm/hooks/build
DOCKER_BUILD_PHP82=./php/php82-fpm/hooks/build
DOCKER_BUILD_HTTPD_APACHE24=./httpd/apache24/hooks/build
DOCKER_BUILD_DB_MARIADB104=./db/mariadb104/hooks/build
DOCKER_BUILD_DB_MARIADB105=./db/mariadb105/hooks/build
DOCKER_BUILD_DB_MARIADB106=./db/mariadb106/hooks/build
DOCKER_BUILD_DB_MARIADB1011=./db/mariadb1011/hooks/build
DOCKER_BUILD_DB_MYSQL57=./db/mysql57/hooks/build
DOCKER_BUILD_DB_MYSQL80=./db/mysql80/hooks/build
DOCKER_BUILD_MINICA=./minica/hooks/build
export PUSH_TO_DOCKER=0
export ONLY_PUSH_TO_DOCKER=0

ifdef push
	export PUSH_TO_DOCKER=1
endif

ifdef only-push
	export PUSH_TO_DOCKER=1
	export ONLY_PUSH_TO_DOCKER=1
endif

DEFAULT_GOAL := help

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build-all build-all-db build-all-php build-all-php-eol build-all-httpd build-all-mariadb build-all-mysql \
		build-minica build-apache24 \
		build-php56 build-php73 build-php74 build-php80 build-php81 build-php82 \
		build-mariadb104 build-mariadb105 build-mariadb106 build-mariadb1011 build-mysql57 build-mysql80


build-all: build-all-httpd build-all-db build-all-php ## Build all latest images and tag as :latest (includes build-all-httpd build-all-php build-all-php-eol build-all-db)


build-minica: ## Build Minica latest image and tag as :latest
	$(DOCKER_BUILD_MINICA)


build-all-httpd: build-apache24 ## Build all latest httpd images and tag as :latest

build-apache24: ## Build Apache 2.4 latest image and tag as :latest
	$(DOCKER_BUILD_HTTPD_APACHE24)


build-all-php: build-php80 build-php81 build-php82 ## Build all latest php images and tag as :latest (not EOL)

build-php80: ## Build latest PHP8.0 image and tag as :latest
	$(DOCKER_BUILD_PHP80)

build-php81: ## Build latest PHP8.0 image and tag as :latest
	$(DOCKER_BUILD_PHP81)

build-php82: ## Build latest PHP8.0 image and tag as :latest
	$(DOCKER_BUILD_PHP82)


build-all-php-eol: build-php56 build-php73 build-php74 ## Build all EOL latest php images and tag as :latest

build-php56: ## Build latest PHP5.6 image and tag as :latest (EOL)
	$(DOCKER_BUILD_PHP56)

build-php73: ## Build latest PHP7.3 image and tag as :latest (EOL)
	$(DOCKER_BUILD_PHP73)

build-php74: ## Build latest PHP7.4 image and tag as :latest (EOL)
	$(DOCKER_BUILD_PHP74)


build-all-db: build-mariadb1011 build-mariadb106 build-mariadb105 build-mariadb104 build-mysql80 build-mysql57## Build all latest db images and tag as :latest
build-all-mariadb: build-mariadb1011 build-mariadb106 build-mariadb105 build-mariadb104 ## Build all latest db images and tag as :latest for MariaDB
build-all-mysql: build-mysql80 build-mysql57## Build all latest db images and tag as :latest for MySQL

build-mariadb104: ## Build latest MariaDB 10.4 image and tag as :latest
	$(DOCKER_BUILD_DB_MARIADB104)

build-mariadb105: ## Build latest MariaDB 10.5 image and tag as :latest
	$(DOCKER_BUILD_DB_MARIADB105)

build-mariadb106: ## Build latest MariaDB 10.6 image and tag as :latest
	$(DOCKER_BUILD_DB_MARIADB106)

build-mariadb1011: ## Build latest MariaDB 10.11 image and tag as :latest
	$(DOCKER_BUILD_DB_MARIADB1011)

build-mysql57: ## Build latest MySQL 5.7 image and tag as :latest
	$(DOCKER_BUILD_DB_MYSQL57)

build-mysql80: ## Build latest MySQL 8.0 image and tag as :latest
	$(DOCKER_BUILD_DB_MYSQL80)
