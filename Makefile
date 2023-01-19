.DEFAULT_GOAL := default

default: help

all: ## 🚀 Build dependencies and run all auditing tools 🔒🔍
	$(info ## 🚀 Build dependencies and start security audits 🔒🔍)
	@make clean
	@make build-n-run
	@echo "\n\n==> 🚀 Starting security audits 🔒🔍"
	@make audit

##@ Deps

.PHONY: install-deps
install-deps:	## ❌ (out of scope) Install git and docker if you want to continue
	@echo "git & docker installation are out of scope. You should install them if you want to continue"

# ##@ Build
build-n-run: ## 🛠️ 🐳 Build and start the containers
	@echo "\n\n==> 🛠️ Building auditBox container..."
	@make build-auditbox
	@echo "\n\n==> 🛠️ Building pmapper container..."
	@make build-pmapper
	@make run

## 🛠️ Build auditbox container using Kali Linux rolling as base image
.PHONY: build-auditbox
build-auditbox:
	@docker pull kalilinux/kali-rolling
	@mkdir -p ./auditbox-results ./logs
	@docker build --no-cache --progress=plain --tag kali:auditing . 2>&1 | tee ./logs/dockerbuild-auditbox.log

## 🛠️ Pull latest code from GitHub and build pmapper container
.PHONY: build-pmapper
build-pmapper:
	@rm -rf arsenal/pmapper
	@git submodule add --force --name pmapper -- https://github.com/nccgroup/PMapper arsenal/pmapper
	@pushd arsenal/pmapper && \
		docker build --no-cache --progress=plain --tag pmapper . 2>&1 | tee ../../logs/dockerbuild-pmapper.log

## 🛠️ Pull latest code from GitHub and build pmapper container
.PHONY: build-cloudsploit
build-cloudsploit:
	@rm -rf arsenal/cloudsploit
	@git submodule add --force --name cloudsploit -- https://github.com/aquasecurity/cloudsploit arsenal/cloudsploit
	@pushd arsenal/cloudsploit 														&& \
		patch Dockerfile < ../cloudsploitDockerfile.patch 		&& \
		docker build --no-cache --progress=plain --tag cloudsploit . 2>&1 | tee ../../logs/dockerbuild-cloudsploit.log

# ##@ Run containers
run:
	@(info ## 🐳 Start auditbox, cloudsploit & pmapper containers)
	@make run-auditbox
	@make run-cloudsploit
	@make run-pmapper

# Alternatively you can start each container
run-auditbox:
	@docker run --hostname auditbox --env-file=./env.list --rm -d --name auditbox kali:auditing

run-cloudsploit:
	@docker run --env-file=./env.list --rm -d --entrypoint sh --name cloudsploit cloudsploit -c "sleep infinity & wait"

run-pmapper:
	@docker run --env-file=./env.list --rm -d --name pmapper pmapper bash -c "sleep infinity & wait"


##@ Audit
audit: ## 🔥 Fire up all auditing tools (Prowler, ScoutSuite, CloudSplaining, PMapper, CloudSploit)
	@(info ## 🛡️ Audit AWS account with all the tools (Prowler, ScoutSuite, CloudSplaining, PMapper, CloudSploit))
	@make prowler
	@make scoutsuite
	@make cloudsplaining
	@make pmapper
	@make cloudsploit
	@make gather-results

cloudsplaining: ## 🔍 Audit AWS account with CloudSplaining
	@echo "\n\n==> 🔍 CloudSplaining scan has started."
	@docker exec -it auditbox bash -c "mkdir -p cloudsplaining && \
		pipenv run cloudsplaining download && \
		pipenv run cloudsplaining scan --input-file /home/auditor/default.json --output cloudsplaining"

pmapper: ## 🔍 Evaluate IAM permissions in AWS
	@echo "\n\n==> 🔍 Evaluating IAM permissions with PMapper"
	@docker exec -it pmapper bash -c "pmapper graph create"
	@docker exec -it pmapper bash -c "pmapper visualize --only-privesc --filetype png"

prowler: ## 🔍 Audit AWS account with Prowler v3
	@echo "\n\n==> 🔍 Prowler scan has started."
	@docker exec -it auditbox bash -c "pipenv run prowler aws --no-banner --output-modes {csv,json,json-asff,html} --compliance cis_1.5_aws"

prowler-v2: ## 🔍 Audit AWS account with Prowler v2
	@echo "\n\n==> 🔍 Prowler v2 scan has started."
	@docker exec -it auditbox bash -c "~/tools/prowler/prowler -g cislevel1 -M csv,json-assf,html"

scoutsuite: ## 🔍 Audit AWS account with ScoutSuite
	@echo "\n\n==> 🔍 ScoutSuite scan has started."
	@docker exec -it auditbox bash -c "pipenv run scout aws --report-name scoutsuite --result-format json"

cloudsploit: ## 🔍 Audit AWS account with CloudSploit
	@echo "\n\n ==> 🔍 CloudSploit scan has started."
	@docker exec -it cloudsploit cloudsploit-scan --compliance=cis1 --ignore-ok --collection=cloudsploit-collection.json --console=table --csv=cloudsploit-findings.csv --json cloudsploit-findings.json

gather-results: ## 💾 Copy all scan results locally in auditbox-results directory
	@rm -rf auditbox-results && mkdir auditbox-results
	@docker cp auditbox:/home/auditor/output ./auditbox-results/prowler										|| true
	@docker cp auditbox:/home/auditor/cloudsplaining ./auditbox-results/cloudsplaining			|| true
	@docker cp auditbox:/home/auditor/scoutsuite-report ./auditbox-results/scoutsuite			|| true
	@mkdir -p ./auditbox-results/{pmapper,cloudsploit}/ && \
		docker exec pmapper /bin/sh -c 'tar -cf - /*.png' | tar xvf - --directory=./auditbox-results/pmapper/								|| true
	@docker exec cloudsploit /bin/sh -c 'tar -cf - /cloudsploit-*' | tar xvf - --directory=./auditbox-results/cloudsploit/	|| true
	@docker cp auditbox:/home/auditor/tools/prowler/output ./auditbox-results/prowler-v2																		|| true

##@ Cleanup

.PHONY: clean
clean: ## 🧹 Delete scan results, stop and delete containers
	@echo "🧹 Cleaning has started..."
	@make stop
	@docker rmi -f kali:auditing pmapper cloudsploit 2>/dev/null 	|| true

##@ Debug

restart:	## 🔄 Restart all containers
	@make restart-auditbox
	@make restart-pmapper
	@make restart-cloudsploit

restart-auditbox:
	@echo "\n==> 🔄 Restarting auditbox container"
	@make stop-auditbox
	@make run-auditbox
	@echo "==> ✅ Completed"

restart-pmapper:
	@echo "\n==> 🔄 Restarting pmapper container"
	@make stop-pmapper
	@make run-pmapper
	@echo "==> ✅ Completed"

restart-cloudsploit:
	@echo "\n==> 🔄 Restarting cloudsploit container"
	@make stop-cloudsploit
	@make run-cloudsploit
	@echo "==> ✅ Completed"

stop:
	@make stop-auditbox 2>/dev/null				|| true
	@make stop-pmapper 2>/dev/null 			  || true
	@make stop-cloudsploit 2>/dev/null 		|| true

stop-auditbox:
	@docker stop auditbox

stop-pmapper:
	@docker stop pmapper

stop-cloudsploit:
	@docker stop cloudsploit

# TODO: Use variables whereever you can (eg. `/home/auditor`, docker cmds, etc)
# https://makefiletutorial.com/

DOCKER := $(shell command -v docker 2> /dev/null)
DOCKER_EXEC := $(shell echo ${DOCKER} exec -it) 		# OK
# DOCKER_EXEC := $( $$(DOCKER) exec -it)

# ENV_VAR := $(shell echo $${ENV_VAR-development}) # NOTE: double $ for escaping

DOCKER_RUN := $(shell command -v docker run -it)

dexec: ## (Debug) Docker exec into auditbox
	@$(DOCKER_EXEC) auditbox bash -c "w"

##@ Helpers

.PHONY: help
# Simple help menu
# help: ## ❔ Display this help menu
# 		@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
# 			sort | \
# 			awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Advanced help menu grouped by categories
help:  ## ❔ Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
