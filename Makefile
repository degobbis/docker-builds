#!/usr/bin/env make
export ROOT_DIR=$(PWD)
export ENV_FILE=$(ROOT_DIR)/.env
export PUSH_TO_DOCKER=0
export ONLY_PUSH_TO_DOCKER=0
export MULTI_PLATFORMS=0

DOCKER_BUILD_INIT="$(ROOT_DIR)/templates/init"

ifdef multi-platforms
	export MULTI_PLATFORMS=1
endif

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
		build-bind build-minica build-apache24 \
		build-php56 build-php74 build-php80 build-php81 build-php82 build-php83 \
		build-mariadb104 build-mariadb105 build-mariadb106 build-mariadb1011 build-mariadb114 build-mysql57 build-mysql80 build-mysql83 build-mysql84 \
		build-mhs \
		clear-build-cache


build-all: build-all-httpd build-all-db build-all-php ## Build all latest images and tag as :latest (includes build-all-httpd build-all-php build-all-db)


build-minica: ## Build minica latest image and tag as :latest
	$(DOCKER_BUILD_INIT) "minica" "$(ROOT_DIR)/minica/Dockerfile"


build-all-httpd: build-apache24 ## Build all latest httpd images and tag as :latest

build-apache24: ## Build Apache 2.4 latest image and tag as :latest
	$(DOCKER_BUILD_INIT) "apache24" "$(ROOT_DIR)/httpd/apache24/Dockerfile"


build-all-php: build-php81 build-php82 build-php83 ## Build all latest php images and tag as :latest (not EOL)

build-php81: ## Build latest PHP8.1 image and tag as :latest
	$(DOCKER_BUILD_INIT) "php81" "$(ROOT_DIR)/php/php81/Dockerfile"

build-php82: ## Build latest PHP8.2 image and tag as :latest
	$(DOCKER_BUILD_INIT) "php82" "$(ROOT_DIR)/php/php82/Dockerfile"

build-php83: ## Build latest PHP8.3 image and tag as :latest
	$(DOCKER_BUILD_INIT) "php83" "$(ROOT_DIR)/php/php83/Dockerfile"


build-all-php-eol: build-php56 build-php74 build-php80 ## Build all EOL latest php images and tag as :latest

build-php56: ## Build latest PHP5.6 image and tag as :latest (EOL)
	$(DOCKER_BUILD_INIT) "php56" "$(ROOT_DIR)/php/php56/Dockerfile"

build-php74: ## Build latest PHP7.4 image and tag as :latest (EOL)
	$(DOCKER_BUILD_INIT) "php74" "$(ROOT_DIR)/php/php74/Dockerfile"

build-php80: ## Build latest PHP8.0 image and tag as :latest
	$(DOCKER_BUILD_INIT) "php80" "$(ROOT_DIR)/php/php80/Dockerfile"


build-all-db: build-mariadb114 build-mariadb1011 build-mariadb106 build-mariadb105 build-mariadb104 build-mysql84 build-mysql83 build-mysql80 ## Build all latest db images and tag as :latest

build-all-db-eol: build-mysql57 ## Build all EOL latest db images and tag as :latest


build-all-mysql: build-mysql84 build-mysql83 build-mysql80 ## Build all latest MySQL images and tag as :latest

build-mysql80: ## Build latest MySQL 8.0 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mysql80" "$(ROOT_DIR)/db/mysql80/Dockerfile"

build-mysql83: ## Build latest MySQL 8.3 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mysql83" "$(ROOT_DIR)/db/mysql83/Dockerfile"

build-mysql84: ## Build latest MySQL 8.4 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mysql84" "$(ROOT_DIR)/db/mysql84/Dockerfile"


build-all-mysql-eol: build-mysql57 ## Build all EOL latest MySQL images and tag as :latest

build-mysql57: ## Build latest MySQL 5.7 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mysql57" "$(ROOT_DIR)/db/mysql57/Dockerfile"


build-all-mariadb: build-mariadb114 build-mariadb1011 build-mariadb106 build-mariadb105 build-mariadb104 ## Build all latest db images and tag as :latest for MariaDB

build-mariadb104: ## Build latest MariaDB 10.4 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mariadb104" "$(ROOT_DIR)/db/mariadb104/Dockerfile"

build-mariadb105: ## Build latest MariaDB 10.5 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mariadb105" "$(ROOT_DIR)/db/mariadb105/Dockerfile"

build-mariadb106: ## Build latest MariaDB 10.6 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mariadb106" "$(ROOT_DIR)/db/mariadb106/Dockerfile"

build-mariadb1011: ## Build latest MariaDB 10.11 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mariadb1011" "$(ROOT_DIR)/db/mariadb1011/Dockerfile"

build-mariadb114: ## Build latest MariaDB 11.4 image and tag as :latest
	$(DOCKER_BUILD_INIT) "mariadb114" "$(ROOT_DIR)/db/mariadb114/Dockerfile"


build-mhs: ## Build mhsendmail for several architectur
	docker buildx create --driver=docker-container --name=build-multi-arch-mhs --use
	docker buildx build --platform="linux/386,linux/amd64,linux/arm,linux/arm64" --output type=local,dest=./shared/mhsendmail/ --file "$(ROOT_DIR)/mhsendmail/Dockerfile" --build-arg VERSION="1.22" .
	docker buildx rm build-multi-arch-mhs
clear-build-cache: ## Clears the docker buildx cache
	docker buildx rm --all-inactive --force
	docker buildx prune -f
