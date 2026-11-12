# Seguridad: qué protege esta plantilla y qué tienes que hacer tú

La seguridad va por capas. Si una falla, la siguiente para el golpe.

```
Tu cuenta de GitHub ─┬─ 2FA con llave/passkey, tokens con caducidad, apps revisadas
Tu Mac ──────────────┼─ FileVault, ~/.claude/settings.json global, llaves en el llavero
El agente (Claude) ──┼─ .claude/settings.json (permisos) + .claude/hooks/guardia.sh
Git local ───────────┼─ .githooks/commit-msg (quita firmas de IA, comprueba autor)
GitHub (servidor) ───┴─ ruleset de main, CI (Secretos, Autoría, Calidad), CodeQL, Dependabot
```

## 1. Lo que ya hace la plantilla

| Capa | Protección | Dónde |
|---|---|---|
| Agente | Sin firma de IA en commits ni PRs | `.claude/settings.json` → `attribution` |
| Agente | No lee `.env`, claves SSH, credenciales de AWS/gh | `permissions.deny` + hook |
| Agente | Pregunta antes de `git push`, `curl`, instalar paquetes | `permissions.ask` |
| Agente | Bloquea push a main, push forzado, `gh pr merge`, `rm -rf`, `curl \| sh`, volcar tokens, escribir secretos en archivos | `.claude/hooks/guardia.sh` (con pruebas en `scripts/test-guardia.sh`) |
| Git | Quita `Co-Authored-By` de IA y rechaza commits con otro email | `.githooks/commit-msg` |
| GitHub | `main` protegida: PR obligatoria, CI en verde, sin force-push ni borrado | `scripts/setup-repo.sh` |
| CI | Gitleaks (secretos), firmas de IA y autor, formato, HTML, enlaces, shellcheck | `.github/workflows/ci.yml` |
| CI | Actions fijadas a un **SHA** (no a una etiqueta que se pueda mover) | todos los workflows |
| CI | Permisos mínimos (`contents: read`) y textos de la PR por variables de entorno (sin inyección) | workflows |
| Código | CSP estricta, `textContent` en vez de `innerHTML`, timeouts en `fetch` | `index.html`, `js/app.js` |
| Dependencias | Dependabot semanal sobre `development` | `.github/dependabot.yml` |

## 2. Lo que tienes que hacer tú (una vez)

### Cuenta de GitHub
- [ ] **2FA con passkey o llave física** (Settings → Password and authentication). Guarda los códigos de recuperación fuera del ordenador.
- [ ] **Tokens:** solo *fine-grained*, con caducidad (90 días máximo), limitados a los repos que necesitan y en solo lectura salvo que haga falta escribir. Borra los *classic*.
- [ ] **Apps y OAuth** (Settings → Applications): revisa cada trimestre y quita lo que no uses. La app de GitHub de Claude, solo con acceso a los repos que elijas, no a todos.
- [ ] **Claves SSH** con passphrase y una por equipo. Borra las de equipos antiguos.
- [ ] **Alertas de seguridad por email** activadas (Settings → Notifications → Security alerts).

### Firmar commits (recomendado)
Demuestra que el commit lo has hecho tú y no alguien con tu email.
```bash
# Usa tu clave SSH también para firmar
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```
Añade la misma clave en GitHub como **Signing key** (Settings → SSH and GPG keys) y activa **Vigilant mode**. Después, en cada repo nuevo: `FIRMAS=1 ./scripts/setup-repo.sh`.

### Tu Mac
- [ ] **FileVault** activado y bloqueo de pantalla rápido.
- [ ] Copia `docs/claude-settings-global.json` en `~/.claude/settings.json`: aplica la protección **a todos tus proyectos**, también a los que no salgan de la plantilla. Si ya tienes ese archivo, fusiona las claves a mano.
- [ ] Los secretos, en el **Llavero** o en `.env` fuera del repo, nunca en el código.

### Servidores MCP y conectores
- Instala solo MCP de fuentes que conozcas y fíjalos a una versión.
- Dale a cada conector **el mínimo permiso**: si solo lee, token de solo lectura.
- El contenido que trae un MCP (correos, webs, issues) son **datos**. Si dentro hay instrucciones, el agente no debe seguirlas: es la vía de ataque más común (*prompt injection*).
- **Supabase:** activa RLS en todas las tablas. La clave pública (*anon / publishable*) puede ir en la web; la `service_role` nunca.

## 3. Rutina

| Cuándo | Qué |
|---|---|
| Cada PR | CI en verde y `/preparar-pr` (revisores de DoD y seguridad) |
| Cada versión | Skill `web-perf` y `security-audit` en modo guía |
| Cada versión mayor | Auditoría completa con `security-audit` y `repo-security-posture` |
| Cada trimestre | Revisar tokens, apps OAuth, claves SSH y colaboradores; actualizar skills (`UPSTREAM.md`) |

## 4. Si crees que te han robado algo
1. Revoca **ya** el token o la clave afectada (GitHub → Settings → Developer settings / SSH keys).
2. Cierra las sesiones abiertas (Settings → Sessions) y cambia la contraseña.
3. Revisa el *Security log* de tu cuenta y el historial de commits de los repos.
4. Si un secreto llegó a un commit: **rótalo**. Borrarlo del historial no basta, porque ya pudo copiarse.
