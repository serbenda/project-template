# CLAUDE.md

Las normas de este repositorio están en AGENTS.md y valen para cualquier agente. Se importan aquí:

@AGENTS.md

## Específico de Claude Code

- **Configuración del proyecto:** `.claude/settings.json` desactiva la firma en commits y PRs, define permisos (deny / ask / allow) y activa el hook `.claude/hooks/guardia.sh`. No los modifiques: los cambios los hace el propietario.
- **Skills:** `.claude/skills/` (`security-audit`, `repo-security-posture`). Las skills globales de `~/.claude/skills` también están disponibles. Están fijadas a un commit; ver `.claude/skills/UPSTREAM.md`.
- **Subagentes:** `revisor-seguridad`, `revisor-dod` y `revisor-arquitectura` en `.claude/agents/`. Lánzalos antes de abrir una PR. Son de solo lectura.
- **Comandos** (`.claude/commands/`):
  - `/estado`: al empezar cada sesión. Resume STATE y dice qué toca.
  - `/nueva-fase <qué>`: crea la ficha y propone el plan. No escribe código hasta que se apruebe.
  - `/cerrar-fase`: comprueba criterios y DoD, rellena el resultado y actualiza STATE, ROADMAP y CHANGELOG.
  - `/decision <qué>`: registra un ADR en `docs/decisiones/`.
  - `/preparar-pr`: `make verify`, revisores y PR `development → main` sin firmas.
- **Vista previa:** `.claude/launch.json` está vacío. Si el proyecto tiene servidor local, se añade en la fase F03 junto con `make dev`.
- Para tareas de más de una fase o con dudas de diseño, usa el modo plan antes de tocar código.
- Si un hook bloquea una acción, **no intentes rodearlo** con otro comando: explica al propietario qué querías hacer y por qué.
