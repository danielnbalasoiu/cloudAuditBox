.DEFAULT_GOAL := default

default: help

# TODO: Use variables whereever you can (eg. `/home/auditor`, docker cmds, etc)

all: ## 🚀 Build dependencies and start security audits 🔒🔍
	@make clean
	@make build-n-run
	@echo "\n\n==> 🚀 Starting security audits 🔒🔍"
	@make audit

audit: ## 🛡️ Audit AWS account with all the tools (Prowler, ScoutSuite, CloudSplaining, PMapper, CloudSploit)
	@make prowler
	@make scoutsuite
	@make cloudsplaining
	@make pmapper
	@make cloudsploit
	@make gather-results

install-deps:	## ❌ (out of scope) Install git and docker if you want to continue
	@echo "git & docker installation are out of scope. You should install them if you want to continue"

build-n-run: ## 🛠️ 🐳 Build and start the containers
	@echo "\n\n==> 🛠️ Building auditBox container..."
	@make build-auditbox
	@echo "\n\n==> 🛠️ Building pmapper container..."
	@make build-pmapper
	@make run

## 🛠️ Build auditbox container using Kali Linux rolling as base image
build-auditbox:
	@docker pull kalilinux/kali-rolling
	@mkdir -p ./auditbox-results ./logs
	@docker build --no-cache --progress=plain -t kali:auditing . 2>&1 | tee ./logs/dockerbuild-auditbox.log

## 🛠️ Pull latest code from GitHub and build pmapper container
build-pmapper:
	@rm -rf arsenal/pmapper
	@git submodule add --force --name pmapper -- https://github.com/nccgroup/PMapper arsenal/pmapper
	@pushd arsenal/pmapper && \
		docker build --no-cache --progress=plain -t pmapper . 2>&1 | tee ../../logs/dockerbuild-pmapper.log

## 🛠️ Pull latest code from GitHub and build pmapper container
build-cloudsploit:
	@rm -rf arsenal/cloudsploit
	@git submodule add --force --name cloudsploit -- https://github.com/aquasecurity/cloudsploit arsenal/cloudsploit
	@pushd arsenal/cloudsploit 														&& \
		patch Dockerfile < ../cloudsploitDockerfile.patch 		&& \
		docker build --no-cache --progress=plain -t cloudsploit . 2>&1 | tee ../../logs/dockerbuild-cloudsploit.log

run: ## 🐳 Start auditbox, cloudsploit & pmapper containers
	@make run-auditbox
	@make run-cloudsploit
	@make run-pmapper

# Alternatively you can start each container
run-auditbox:
	@docker run --env-file=./env.list --rm -d --name auditbox kali:auditing

run-cloudsploit:
	@docker run --env-file=./env.list --rm -d --entrypoint sh --name cloudsploit cloudsploit -c "sleep infinity & wait"

run-pmapper:
	@docker run --env-file=./env.list --rm -d --name pmapper pmapper bash -c "sleep infinity & wait"

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

clean: ## 🧹 Delete scan results, stop and delete containers
	@echo "Cleaning has started..."
	@docker stop auditbox pmapper cloudsploit 2>/dev/null 					|| true
	@docker rm auditbox pmapper cloudsploit 2>/dev/null 						|| true
	@docker rmi -f kali:auditing pmapper cloudsploit 2>/dev/null 	|| true

.PHONY: help
help: ## ❔ Display this help screen
		@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
			sort | \
			awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'