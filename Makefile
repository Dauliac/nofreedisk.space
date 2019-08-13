#!make

# HELP
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

init: ## Get theme with git submodule
	@echo "+ $@"
	@git submodule update --init --recursive

srv: ## Run hugo server
	@echo "+ $@"
	@hugo server

build: ## Build reading config.toml
	@echo "+ $@"
	@hugo

