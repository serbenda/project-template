#!/usr/bin/env bash
# Configura un repo recién creado desde la plantilla.
# Requiere: gh autenticado (gh auth login) con permisos de admin sobre el repo.
# Uso: ./scripts/setup-repo.sh            (detecta el repo del directorio actual)
#      ./scripts/setup-repo.sh owner/repo
set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
NOMBRE="${REPO#*/}"
echo "→ Configurando $REPO"

# 1. Autoría local de los commits
git config user.name  "Sergio Santiago Bendaña Quesada"
git config user.email "serbenda@gmail.com"
# Hook de git que quita firmas de IA de los commits y comprueba el autor
git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh scripts/*.sh

# 2. Sustituye el marcador del nombre del proyecto
grep -rl --exclude-dir=.git --exclude=setup-repo.sh "NOMBRE_DEL_PROYECTO" . | xargs -r sed -i.bak "s/NOMBRE_DEL_PROYECTO/$NOMBRE/g"
find . -name '*.bak' -not -path './.git/*' -delete

# 3. Rama development
if ! git ls-remote --exit-code --heads origin development >/dev/null 2>&1; then
  git push origin "HEAD:refs/heads/development"
fi
git fetch origin development
git switch development 2>/dev/null || git switch -c development --track origin/development

# 4. Ajustes del repo
#    delete_branch_on_merge=false: si no, GitHub borraría development al fusionar la PR a main.
gh api -X PATCH "repos/$REPO" \
  -F delete_branch_on_merge=false \
  -F allow_merge_commit=true \
  -F allow_squash_merge=true \
  -F allow_rebase_merge=false \
  -F has_wiki=false >/dev/null

# 5. Seguridad: alertas de Dependabot, avisos privados de vulnerabilidades,
#    escaneo de secretos y protección en push (gratis en repos públicos)
aviso() { echo "  ⚠ No se pudo activar: $1 (revísalo a mano en Settings → Security)" >&2; }
gh api -X PUT "repos/$REPO/vulnerability-alerts" >/dev/null 2>&1 || aviso "alertas de Dependabot"
gh api -X PUT "repos/$REPO/automated-security-fixes" >/dev/null 2>&1 || aviso "correcciones automáticas de Dependabot"
gh api -X PUT "repos/$REPO/private-vulnerability-reporting" >/dev/null 2>&1 || aviso "avisos privados de vulnerabilidades"
gh api -X PATCH "repos/$REPO" --input - >/dev/null 2>&1 <<'JSON' || aviso "escaneo de secretos y protección en push (en repos privados requiere GitHub Advanced Security)"
{"security_and_analysis": {
  "secret_scanning": {"status": "enabled"},
  "secret_scanning_push_protection": {"status": "enabled"}
}}
JSON

# 6. Protección de main con un ruleset: PR obligatoria, CI en verde, sin force-push ni borrado
gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null <<'JSON'
{
  "name": "Proteger main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true
    }},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": false,
      "required_status_checks": [
        {"context": "Secretos"},
        {"context": "Calidad"},
        {"context": "Autoría"}
      ]
    }}
  ]
}
JSON

# 6b. Opcional: exigir commits firmados (FIRMAS=1 ./scripts/setup-repo.sh). Configura antes tu clave de firma:
#     docs/SEGURIDAD.md → "Firmar commits"
if [[ "${FIRMAS:-0}" == "1" ]]; then
  gh api -X POST "repos/$REPO/rulesets" --input - >/dev/null <<'JSON'
{"name": "Commits firmados", "target": "branch", "enforcement": "active",
 "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH", "refs/heads/development"], "exclude": []}},
 "rules": [{"type": "required_signatures"}]}
JSON
  echo "  ✓ Commits firmados obligatorios en main y development"
fi

# 7. GitHub Pages publicado desde Actions
gh api -X POST "repos/$REPO/pages" -f build_type=workflow >/dev/null 2>&1 \
  || gh api -X PUT "repos/$REPO/pages" -f build_type=workflow >/dev/null

# 8. Etiquetas básicas
for etiqueta in "bug:d73a4a" "enhancement:a2eeef" "docs:0075ca" "security:b60205" "dependencies:0366d6"; do
  gh label create "${etiqueta%%:*}" --color "${etiqueta##*:}" --repo "$REPO" --force >/dev/null
done

echo "✓ Listo. Trabaja en 'development' y abre PR a 'main'."
echo "  Revisa los cambios del marcador con: git status"
