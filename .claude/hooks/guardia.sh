#!/usr/bin/env bash
# Hook PreToolUse de Claude Code: bloquea acciones peligrosas o que rompen las normas del repo.
# Recibe el JSON de la herramienta por stdin. Salir con 2 bloquea la acción y muestra stderr al agente.
# Falla en modo cerrado: si no puede leer la entrada, bloquea.
set -uo pipefail

entrada="$(cat)"

extraer() {  # extraer <campo> -> imprime tool_input.<campo>
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$entrada" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get(sys.argv[1]) or "")' "$1"
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' "$entrada" | jq -r --arg c "$1" '.tool_input[$c] // ""'
  else
    echo "BLOQUEADO: el hook de seguridad necesita python3 o jq instalados." >&2
    exit 2
  fi
}

bloquear() { echo "BLOQUEADO por .claude/hooks/guardia.sh: $1" >&2; exit 2; }

cmd="$(extraer command)" || bloquear "no se pudo leer la entrada del hook."
ruta="$(extraer file_path)" || true
contenido="$(extraer content)$(extraer new_string)" || true

# --- Archivos con secretos (Read/Edit/Write) ---
if [[ -n "$ruta" ]]; then
  case "$ruta" in
    *.env|*.env.*|*/.env|*.pem|*.key|*id_rsa*|*id_ed25519*|*/.ssh/*|*/.aws/*|*/.config/gh/*|*/.npmrc|*/.netrc)
      [[ "$ruta" == *.env.example ]] || bloquear "acceso a un archivo con secretos ($ruta)." ;;
  esac
fi

# --- Secretos escritos en archivos ---
if [[ -n "$contenido" ]] && printf '%s' "$contenido" | grep -Eq \
  '(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|sk-ant-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,})'; then
  bloquear "el contenido parece incluir un secreto o token. Usa GitHub Secrets o variables de entorno."
fi

[[ -z "$cmd" ]] && exit 0

# --- Firmas de IA en commits y PRs ---
if printf '%s' "$cmd" | grep -Eq '(git (commit|tag)|gh (pr|issue) (create|edit|comment)|gh api)' &&
   printf '%s' "$cmd" | grep -Eiq '(co-authored-by|generated with|claude-session|noreply@anthropic|claude\.ai/code|claude\.com/claude-code|🤖)'; then
  bloquear "los commits, PRs e issues van sin coautor ni menciones a herramientas de IA (ver AGENTS.md)."
fi

# --- Ramas protegidas ---
if printf '%s' "$cmd" | grep -Eq 'git push'; then
  printf '%s' "$cmd" | grep -Eq -- '(--force|-f( |$)|--force-with-lease|--mirror|--delete|:main|:master)' &&
    bloquear "push forzado, de borrado o mirror no permitido."
  printf '%s' "$cmd" | grep -Eq '(origin|upstream)?[[:space:]]+(HEAD:)?(refs/heads/)?(main|master)([[:space:]]|$)' &&
    bloquear "nunca se hace push a main. Trabaja en development y abre una PR."
  rama="$(git branch --show-current 2>/dev/null || true)"
  if [[ "$rama" == "main" || "$rama" == "master" ]] && ! printf '%s' "$cmd" | grep -Eq 'git push [^ ]+ [^ ]+'; then
    bloquear "estás en $rama: cambia a development antes de hacer push."
  fi
fi
if printf '%s' "$cmd" | grep -Eq 'git commit' && [[ "$(git branch --show-current 2>/dev/null)" =~ ^(main|master)$ ]]; then
  bloquear "no se hacen commits en main. Usa: git switch development"
fi

# --- Acciones que solo hace el propietario ---
printf '%s' "$cmd" | grep -Eq 'gh pr merge|gh repo (delete|edit --visibility)|gh secret (set|delete)|gh api .*-X *(DELETE|PUT) .*/(rulesets|branches/.*/protection|collaborators)' &&
  bloquear "fusionar PRs, borrar repos, cambiar visibilidad, secretos o protecciones lo hace el propietario."

# --- Destructivo / exfiltración ---
printf '%s' "$cmd" | grep -Eq 'rm -[a-zA-Z]*r[a-zA-Z]*f? +(/|~|\$HOME|\.\.?)( |/?$)|rm -[a-zA-Z]*f[a-zA-Z]*r +(/|~|\$HOME)' &&
  bloquear "borrado recursivo peligroso."
printf '%s' "$cmd" | grep -Eq 'git reset --hard|git clean -[a-z]*f|git filter-(branch|repo)' &&
  bloquear "comando que destruye trabajo o reescribe historial. Pide confirmación al propietario."
printf '%s' "$cmd" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(ba|z)?sh' &&
  bloquear "no se ejecutan scripts descargados de internet (curl | sh)."
printf '%s' "$cmd" | grep -Eq '(cat|less|more|head|tail|cp|scp|base64)[^;|&]*(\.env([^.]|$)|\.ssh/|id_rsa|id_ed25519|\.aws/credentials|\.netrc)' &&
  bloquear "lectura o copia de archivos con credenciales."
printf '%s' "$cmd" | grep -Eq '(printenv|env)([[:space:]]*$|[[:space:]]*\|)|echo[^;]*\$(GITHUB_TOKEN|GH_TOKEN|.*SECRET|.*API_KEY)' &&
  bloquear "volcado de variables de entorno o tokens."
printf '%s' "$cmd" | grep -Eq 'git config( --global)? (user\.(name|email)|core\.hooksPath)' &&
  ! printf '%s' "$cmd" | grep -Eq 'Sergio Santiago Bendaña Quesada|serbenda@gmail\.com|\.githooks' &&
  bloquear "no se cambia la identidad de git ni la ruta de hooks."

exit 0
