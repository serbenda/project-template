# Comandos del proyecto. `make verify` reproduce en local lo mismo que la CI:
# pásalo antes de dar algo por terminado.
#
# La plantilla trae una web estática. Si el proyecto usa otro stack, cambia
# `dev`, `test` y `lint` aquí y en .github/workflows/ci.yml a la vez.

PUERTO ?= 8000
SHELL := /bin/bash

.DEFAULT_GOAL := help
.PHONY: help dev test lint links verify

help: ## Lista los comandos
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  make %-8s %s\n", $$1, $$2}'

dev: ## Arranca el proyecto en local (http://localhost:$(PUERTO))
	python3 -m http.server --bind 127.0.0.1 $(PUERTO)

test: ## Ejecuta las pruebas
	bash scripts/test-guardia.sh
	@if [ -f package.json ] && grep -q '"test"' package.json; then npm test; fi
	@if [ -f pyproject.toml ]; then python3 -m pytest -q; fi

lint: ## Formato, HTML y scripts de shell
	npx --yes editorconfig-checker@6.2.0 -disable-indent-size -exclude 'LICENSE|\.git/|\.claude/skills/'
	@if find . -name '*.html' -not -path './node_modules/*' | grep -q .; then \
		npx --yes htmlhint@1.9.2 "**/*.html" --ignore "node_modules/**"; fi
	@if command -v shellcheck >/dev/null; then \
		shellcheck --severity=error scripts/*.sh .claude/hooks/*.sh .githooks/*; \
	else echo "⚠ shellcheck no instalado (brew install shellcheck): lo comprobará la CI"; fi
	@if [ -f package.json ] && grep -q '"lint"' package.json; then npm run lint; fi
	@if [ -f pyproject.toml ]; then ruff check . && ruff format --check .; fi

links: ## Enlaces internos rotos en Markdown y HTML
	@if command -v lychee >/dev/null; then \
		lychee --offline --no-progress --include-fragments --exclude-path .claude/skills './**/*.html' './**/*.md'; \
	else echo "⚠ lychee no instalado (brew install lychee): lo comprobará la CI"; fi

verify: lint test links ## Todo lo que comprueba la CI
	@echo "✓ verify: todo en verde"
