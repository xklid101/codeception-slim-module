help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  test                    to perform tests."
	@echo "  coverage                to perform tests with code coverage."
	@echo "  static                  to run phpstan and php-cs-fixer check."
	@echo "  static-phpstan          to run phpstan."
	@echo "  static-cs-check         to run php-cs-fixer."
	@echo "  static-cs-fix           to run php-cs-fixer, writing the changes."

.PHONY: test
test:
	vendor/bin/codecept build
	vendor/bin/codecept run

.PHONY: coverage
coverage:
	vendor/bin/codecept build
	vendor/bin/codecept run --coverage --coverage-xml --coverage-html

.PHONY: static
static: static-phpstan static-cs-check

static-phpstan:
	docker run --rm -it -e REQUIRE_DEV=true -v ${PWD}:/app -w /app oskarstark/phpstan-ga:0.12.85 analyze $(PHPSTAN_PARAMS)

static-cs-fix:
	docker run --rm -it -v ${PWD}:/app -w /app oskarstark/php-cs-fixer-ga:2.19.0 --diff-format udiff $(CS_PARAMS)

static-cs-check:
	$(MAKE) static-cs-fix CS_PARAMS="--dry-run"

DOCKER_RUN=docker run --rm -u $(shell id -u):$(shell id -g) -v $(shell pwd):/app -w /app

local-ci:
	$(DOCKER_RUN) -v ~/.composer:/tmp -v ~/.ssh:/root/.ssh composer:2 install
	$(DOCKER_RUN) php:7.2-cli vendor/bin/codecept build
	$(DOCKER_RUN) php:7.2-cli vendor/bin/codecept run
	$(DOCKER_RUN) php:7.3-cli vendor/bin/codecept run
	$(DOCKER_RUN) php:7.4-cli vendor/bin/codecept run
	$(DOCKER_RUN) php:8.0-cli vendor/bin/codecept run
	$(DOCKER_RUN) php:8.1-cli vendor/bin/codecept run
	$(DOCKER_RUN) php:8.2-cli vendor/bin/codecept run
