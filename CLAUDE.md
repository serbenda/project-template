# CLAUDE.md

Las normas de este repositorio están en AGENTS.md y valen para cualquier agente. Se importan aquí:

@AGENTS.md

## Específico de Claude Code

- **Configuración del proyecto:** `.claude/settings.json` desactiva la firma en commits y PRs, define permisos (deny / ask / allow) y activa el hook `.claude/hooks/guardia.sh`. No los modifiques: los cambios los hace el propietario.
- **Skills:** `.claude/skills/` (`security-audit`, `web-perf`, `repo-security-posture`). Están fijadas a un commit; ver `.claude/skills/UPSTREAM.md`.
- **Subagentes:** `.claude/agents/revisor-seguridad.md` y `.claude/agents/revisor-dod.md`. Lánzalos antes de abrir una PR. Son de solo lectura.
- **Comando:** `/preparar-pr` repasa la Definition of Done, lanza los revisores y abre la PR `development → main` sin firmas.
- Si un hook bloquea una acción, **no intentes rodearlo** con otro comando: explica al propietario qué querías hacer y por qué.
