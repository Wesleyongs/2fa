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

venv: ## Create virtual environment if venv directory not present
	`which python3.8` -m venv venv
	venv/Scripts/pip install -U pip pip-tools wheel --no-cache-dir
	venv/Scripts/activate

run: dev ## Run with dev dependencies
	venv/Scripts/activate
	python src/main.py

test: ## Test
	python -m pytest

