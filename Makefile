#!/usr/bin/env make
DOCKER_BUILD_PHP56=./php/php56-fpm/hooks/build
DOCKER_BUILD_PHP73=./php/php73-fpm/hooks/build
DOCKER_BUILD_PHP74=./php/php74-fpm/hooks/build
DOCKER_BUILD_PHP80=./php/php80-fpm/hooks/build
DOCKER_BUILD_HTTPD_APACHE24=./httpd/apache24/hooks/build
DOCKER_BUILD_DB_MARIADB104=./db/mariadb104/hooks/build
DOCKER_BUILD_DB_MARIADB105=./db/mariadb105/hooks/build


DEFAULT_GOAL := help


help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build-all build-httpd build-php build-php-eol build-db


build-all: build-httpd build-php build-db ## Build all latest images and tag as :latest (includes build-httpd build-php build-db)


build-httpd: ## Build all latest httpd images and tag as :latest
	$(DOCKER_BUILD_HTTPD_APACHE24)


build-php: ## Build all latest php images and tag as :latest (not EOL)
	$(DOCKER_BUILD_PHP73)
	$(DOCKER_BUILD_PHP74)
	$(DOCKER_BUILD_PHP80)


build-php-eol: ## Build all EOL latest php images and tag as :latest
	$(DOCKER_BUILD_PHP56)


build-db: ## Build all latest db images and tag as :latest
	$(DOCKER_BUILD_DB_MARIADB104)
	$(DOCKER_BUILD_DB_MARIADB105)
