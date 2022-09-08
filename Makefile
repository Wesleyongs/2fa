.PHONY: dev run test format clean db
.DEFAULT: help

help: ## Display this help message
	@echo "Please use \`make <target>\` where <target> is one of"
	@awk -F ':.*?## ' '/^[a-zA-Z]/ && NF==2 {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Remove general artifact files
	find . -name '.coverage' -delete
	find . -name '*.pyc' -delete
	find . -name '*.pyo' -delete
	find . -name '.pytest_cache' -type d | xargs rm -rf
	find . -name '__pycache__' -type d | xargs rm -rf
	find . -name '.ipynb_checkpoints' -type d | xargs rm -rf

format: dev ## Scan and format all files with pre-commit
	venv/Script/pre-commit run --all-files

venv: ## Create virtual environment if venv directory not present
	`which python3.8` -m venv venv
	venv/Script/pip install -U pip pip-tools wheel --no-cache-dir

requirements.txt: venv requirements.in ## Generate requirements for release
	venv/Script/pip-compile -o requirements.txt requirements.in

requirements-dev.txt: venv requirements.txt requirements-dev.in ## Generate requirements for dev
	venv/Script/pip-compile -o requirements-dev.txt requirements-dev.in

update-req: venv requirements.in requirements-dev.in ## Update requirements to fulfil dependencies minimally
	venv/Script/pip-compile -o requirements.txt requirements.in
	venv/Script/pip-compile -o requirements-dev.txt requirements-dev.in

upgrade-req: venv requirements.in requirements-dev.in ## Force updates on all packages requirements to fulfil dependencies fully
	venv/Script/pip-compile -o requirements.txt --upgrade requirements.in
	venv/Script/pip-compile -o requirements-dev.txt --upgrade requirements-dev.in

dev: requirements-dev.txt ## Install dependencies for dev
	venv/Script/pip-sync requirements-dev.txt
	venv/Script/pre-commit install

db: ## Run a Postgres database in the background
	docker run -d --rm \
	-p 5435:5432 \
	--name general-data-provider_db \
	-v "$(PWD)/db:/var/lib/postgresql/data" \
	-e POSTGRES_PASSWORD=superSecur3 -e POSTGRES_DB=winnow-general-data -e TZ=UTC \
	postgres:13-alpine

db-test: ## Run Postgres database for test in the background
	docker run -d --rm \
	-p 5431:5432 \
	--name general-data-provider_db-test \
	-e POSTGRES_PASSWORD=superSecur3 -e POSTGRES_DB=winnow-general-data-test -e TZ=UTC \
	postgres:13-alpine

run: dev ## Run with dev dependencies
	venv/Script/alembic upgrade head
	venv/Script/python -m src.main

test: dev ## Run all tests with coverage
	DB_TEST=1 venv/Script/pytest tests --cov=src -vv --cov-report=term-missing

docker-network: ## Create a common docker network for all winnow services
	docker network create winnow-local || true

docker-build: ## Build docker containers
	docker-compose build

docker-up:  docker-network ## Build and start docker containers
	docker-compose up --build

docker-down: requirements.txt ## Stop and remove docker containers
	docker-compose down

docker-test: requirements.txt ## Run tests using docker container
	docker compose run general-data-provider pytest tests --cov=src -vv --cov-report=term-missing
