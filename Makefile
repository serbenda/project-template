# Comandos del proyecto. `make verify` reproduce en local lo mismo que la CI:
# pásalo antes de dar algo por terminado.
#
# La plantilla no impone stack: `test` y `lint` detectan el que haya
# (package.json, pyproject.toml, pubspec.yaml, go.mod, Cargo.toml).
# `make dev` se define en la fase de entorno local (F03), tras la decisión de stack.
# Si cambias algo aquí, cambia lo mismo en .github/workflows/ci.yml.

SHELL := /bin/bash

.DEFAULT_GOAL := help
.PHONY: help dev test lint links verify

help: ## Lista los comandos
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  make %-8s %s\n", $$1, $$2}'

dev: ## Arranca el proyecto en local
	@echo "make dev aún no está definido: se rellena en la fase F03 (entorno local), tras /decision stack."
	@exit 1

test: ## Ejecuta las pruebas (hook de seguridad + las del stack)
	bash scripts/test-guardia.sh
	@if [ -f package.json ] && grep -q '"test"' package.json; then npm test; fi
	@if [ -f pyproject.toml ]; then python3 -m pytest -q; fi
	@if [ -f pubspec.yaml ]; then flutter test; fi
	@if [ -f go.mod ]; then go test ./...; fi
	@if [ -f Cargo.toml ]; then cargo test; fi

lint: ## Formato, scripts de shell y linters del stack
	npx --yes editorconfig-checker@6.2.0 -disable-indent-size -exclude 'LICENSE|\.git/|\.claude/skills/'
	@if command -v shellcheck >/dev/null; then \
		shellcheck --severity=error scripts/*.sh .claude/hooks/*.sh .githooks/*; \
	else echo "⚠ shellcheck no instalado (brew install shellcheck): lo comprobará la CI"; fi
	@if [ -f package.json ] && grep -q '"lint"' package.json; then npm run lint; fi
	@if [ -f pyproject.toml ]; then ruff check . && ruff format --check .; fi
	@if [ -f pubspec.yaml ]; then flutter analyze; fi
	@if [ -f go.mod ]; then go vet ./...; fi
	@if [ -f Cargo.toml ]; then cargo clippy -- -D warnings; fi

links: ## Enlaces internos rotos en la documentación
	@if command -v lychee >/dev/null; then \
		lychee --offline --no-progress --include-fragments --exclude-path .claude/skills './**/*.md'; \
	else echo "⚠ lychee no instalado (brew install lychee): lo comprobará la CI"; fi

verify: lint test links ## Todo lo que comprueba la CI
	@echo "✓ verify: todo en verde"
