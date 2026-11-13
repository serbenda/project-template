#!/usr/bin/env bash
# Hook PreToolUse de Claude Code: bloquea acciones peligrosas o que rompen las normas del repo.
# Recibe el JSON de la herramienta por stdin. Salir con 2 bloquea la acción y muestra stderr al agente.
# Falla en modo cerrado: si no puede leer la entrada, bloquea.
# Es una capa más, no la única: la protección real de main es el ruleset de GitHub y la CI.
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
hay() { printf '%s' "$2" | grep -Eiq -- "$1"; }   # hay <regex> <texto>

cmd_raw="$(extraer command)" || bloquear "no se pudo leer la entrada del hook."
ruta="$(extraer file_path)$(extraer path)" || true
contenido="$(extraer content)$(extraer new_string)" || true
patron_buscar="$(extraer pattern)" || true

# Comando normalizado: sin comillas ni barras invertidas, para que 'main' o "main" no esquiven las reglas
cmd="$(printf '%s' "$cmd_raw" | tr -d "\"'\\\\")"

# --- Configuración de seguridad: el agente no puede tocar sus propias barreras ---
if [[ -n "$ruta" ]] && hay '(^|/)(\.claude/(settings(\.local)?\.json|hooks/|agents/|commands/|skills/)|\.githooks/)' "$ruta"; then
  hay '"tool_name" *: *"(Read|Grep|Glob)"' "$entrada" ||
    bloquear "la configuración de seguridad (.claude/, .githooks/) solo la cambia el propietario."
fi
if [[ -n "$cmd" ]] && hay '(\.claude/(settings|hooks|agents|commands|skills)|\.githooks)' "$cmd" &&
   hay '(>|sed +-i|tee |cp |mv |rm |chmod |ln |truncate|perl +-[a-z]*i|python3? +-c)' "$cmd"; then
  bloquear "la configuración de seguridad (.claude/, .githooks/) solo la cambia el propietario."
fi

# --- Archivos con secretos (Read/Edit/Write/Grep/Glob) ---
for r in "$ruta" "$patron_buscar"; do
  [[ -z "$r" ]] && continue
  if hay '(^|/)\.env($|\.)|\.pem$|\.key$|id_rsa|id_ed25519|/\.ssh/|/\.aws/|/\.config/gh/|/\.npmrc$|/\.netrc$|/\.kube/|/\.docker/config' "$r" &&
     ! hay '\.env\.example$' "$r"; then
    bloquear "acceso a un archivo con secretos ($r)."
  fi
done

# --- Secretos escritos en archivos ---
if [[ -n "$contenido" ]] && printf '%s' "$contenido" | grep -Eq \
  '(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|gh[ousr]_[A-Za-z0-9]{36}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{40,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}|eyJhbGciOi[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.)'; then
  bloquear "el contenido parece incluir un secreto o token. Usa GitHub Secrets o variables de entorno."
fi

[[ -z "$cmd" ]] && exit 0

# Se analiza cada subcomando por separado (separados por ; && || | y saltos de línea)
mapfile -t partes < <(printf '%s\n' "$cmd" | sed -E 's/(\&\&|\|\||;|\|)/\n/g')

for p in "${partes[@]}"; do
  p="$(printf '%s' "$p" | sed -E 's/^[[:space:]]+//')"
  [[ -z "$p" ]] && continue
  esgit=0; hay '^(env [^ ]+ +)*git( +-[cC] +[^ ]+)* ' "$p" && esgit=1

  # --- Saltarse los hooks de git ---
  if (( esgit )); then
    hay '(-c +core\.hooksPath|--no-verify|commit( +[^ ]+)* +-[a-zA-Z]*n[a-zA-Z]*( |$))' "$p" &&
      bloquear "no se pueden saltar los hooks de git (--no-verify, -n, -c core.hooksPath)."
  fi

  # --- Ramas protegidas ---
  if (( esgit )) && hay ' push( |$)' "$p"; then
    hay '(--force|( |^)-f( |$)|--force-with-lease|--mirror|--delete|( |^)-d( |$)|--all|( |:|\+)(refs/heads/)?(main|master)( |$))' "$p" &&
      bloquear "push a main, forzado, de borrado, --all o mirror no permitido. Trabaja en development y abre una PR."
    rama="$(git branch --show-current 2>/dev/null || true)"
    if [[ "$rama" =~ ^(main|master)$ ]] && ! hay ' push +[^ -][^ ]* +[^ ]+' "$p"; then
      bloquear "estás en $rama: cambia a development antes de hacer push."
    fi
  fi
  if (( esgit )) && hay ' commit( |$)' "$p" && [[ "$(git branch --show-current 2>/dev/null)" =~ ^(main|master)$ ]]; then
    bloquear "no se hacen commits en main. Usa: git switch development"
  fi

  # --- Remotos: no se cambia a dónde va el código ---
  (( esgit )) && hay ' remote +(add|set-url|rename)' "$p" &&
    bloquear "no se cambian los remotos de git: el propietario decide a dónde va el código."

  # --- Identidad de git ---
  if (( esgit )) && hay ' config( +--(global|local))? +(user\.(name|email)|core\.hooksPath)' "$p"; then
    valor="$(printf '%s' "$p" | sed -E 's/.* (user\.(name|email)|core\.hooksPath) +//')"
    [[ "$valor" == "serbenda@gmail.com" || "$valor" == "Sergio Santiago Bendaña Quesada" || "$valor" == ".githooks" ]] ||
      bloquear "no se cambia la identidad de git ni la ruta de hooks."
  fi
  (( esgit )) && hay '--author|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' "$p" &&
    bloquear "no se cambia el autor de los commits."
done

# --- Firmas de IA en commits, PRs e issues ---
if hay '(git( +-[cC] +[^ ]+)* +(commit|tag)|gh +(pr|issue) +(create|edit|comment)|gh +api)' "$cmd" &&
   hay '(co-authored-by|generated (with|by) \[?(claude|cursor|copilot|codex)|claude-session|noreply@anthropic|claude\.ai/code|claude\.com/claude-code|🤖)' "$cmd"; then
  bloquear "los commits, PRs e issues van sin coautor ni firmas de herramientas de IA (ver AGENTS.md)."
fi

# --- Acciones que solo hace el propietario ---
hay '(gh +pr +merge|gh +repo +(delete|archive|rename|transfer)|gh +repo +edit.*(--visibility|--default-branch)|gh +secret|gh +ssh-key|gh +auth +(token|refresh|logout)|gh +api.*(-X|--method)[ =]*(DELETE|PUT|PATCH)|gh +api.*visibility|gh +api.*/(rulesets|protection|collaborators|keys|hooks))' "$cmd" &&
  bloquear "fusionar PRs, borrar o hacer público un repo, secretos, claves, protecciones o colaboradores: lo hace el propietario."

# --- Destructivo ---
hay '(^|[ ;&|])rm( +-[a-zA-Z-]+)+ +(-- +)?(/|~|\$HOME|\.\.?/?)( |$)' "$cmd" && hay '( -[a-zA-Z]*r| --recursive)' "$cmd" &&
  bloquear "borrado recursivo peligroso."
hay 'git( +-[cC] +[^ ]+)* +(reset +--hard|clean +-[a-z]*f|filter-(branch|repo)|update-ref +-d|reflog +expire)' "$cmd" &&
  bloquear "comando que destruye trabajo o reescribe historial. Pide confirmación al propietario."

# --- Ejecutar código descargado ---
hay '(curl|wget)[^|]*\|[[:space:]]*(sudo +)?(ba|z|da)?sh\b|(ba|z)?sh +<\( *(curl|wget)|(curl|wget).*\| *(python3?|node|perl|ruby)\b' "$cmd" &&
  bloquear "no se ejecutan scripts descargados de internet."

# --- Secretos y credenciales desde la shell ---
hay '(^|[^a-zA-Z0-9_])\.env($|[^.a-zA-Z]|\.(local|production|development|prod|dev)\b)|\.ssh/|id_rsa|id_ed25519|\.aws/credentials|\.netrc|\.config/gh|/proc/[^ ]*/environ|security +find-' "$cmd" &&
  bloquear "acceso a archivos con credenciales desde la shell."
hay '(^|[ ;&|])(printenv|env|set|export +-p|declare +-x)( *$| *\|| *>)|echo[^;]*\$\{?(GITHUB_TOKEN|GH_TOKEN|[A-Z_]*SECRET|[A-Z_]*API_KEY|[A-Z_]*TOKEN)' "$cmd" &&
  bloquear "volcado de variables de entorno o tokens."

exit 0
