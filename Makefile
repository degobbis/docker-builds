DOCKER_COMPOSE_BUILD_DIR=.
DOCKER_COMPOSE_BUILD_HTTPD_FILE=-f $(DOCKER_COMPOSE_BUILD_DIR)/docker-compose-build-httpd.yml
DOCKER_COMPOSE_BUILD_PHP_FILE=-f $(DOCKER_COMPOSE_BUILD_DIR)/docker-compose-build-php.yml
DOCKER_COMPOSE_BUILD_PHP_FILE_EOL=-f $(DOCKER_COMPOSE_BUILD_DIR)/docker-compose-build-php-eol.yml
DOCKER_COMPOSE_BUILD_DB_FILE=-f $(DOCKER_COMPOSE_BUILD_DIR)/docker-compose-build-db.yml
DOCKER_COMPOSE_BUILD=docker-compose --env-file $(DOCKER_COMPOSE_BUILD_DIR)/.env
comma=,
space=
space +=
TAG_LIST = $(subst $(comma),$(space),$(TAGS))

REPLACES=build-all build-php-eol build-httpd build-php build-db build
SERVICE=$(filter-out $(REPLACES),$(MAKECMDGOALS))

DEFAULT_GOAL := help


help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

load-env:
ifneq (,$(wildcard ./.env))
	$(eval include $(DOCKER_COMPOSE_DIR)/.env)
	@echo "$(DOCKER_COMPOSE_DIR)/.env included"
endif


.PHONY: build-all build-httpd build-php build-php-eol build-db


build-all: build-httpd build-php build-db ## Build all latest images and tag as :latest (includes build-httpd build-php build-db)


build-httpd: load-env ## Build all latest httpd images and tag as :latest
	$(DOCKER_COMPOSE_BUILD) $(DOCKER_COMPOSE_BUILD_HTTPD_FILE) build $(SERVICE)


build-php: load-env ## Build all latest php images and tag as :latest (not EOL)
	$(DOCKER_COMPOSE_BUILD) $(DOCKER_COMPOSE_BUILD_PHP_FILE) build $(SERVICE)


build-php-eol: load-env ## Build all EOL latest php images and tag as :latest
	$(DOCKER_COMPOSE_BUILD) $(DOCKER_COMPOSE_BUILD_PHP_FILE_EOL) build $(SERVICE)


build-db: load-env ## Build all latest db images and tag as :latest
	$(DOCKER_COMPOSE_BUILD) $(DOCKER_COMPOSE_BUILD_DB_FILE) build $(SERVICE)
