# Bitácora

> El **contexto** de cada cambio: qué, por qué, qué se descartó, commits, cómo se probó y qué queda pendiente.
> La mantiene el agente con la skill `registro-cambios`. Entradas nuevas **arriba**.
> Lo visible para quien usa el proyecto va además en [CHANGELOG.md](../CHANGELOG.md); el estado actual, en [STATE.md](STATE.md).

<!--
## AAAA-MM-DD — Título corto del cambio
- **Fase / issue:** F03 · #12 (o «—»)
- **Qué:**
- **Por qué:**
- **Descartado:**
- **Archivos:**
- **Commits:**
- **Probado:**
- **Pendiente:**
-->

## 2026-11-13 — Plantilla solo de Claude y seguridad, con bitácora
- **Fase / issue:** —
- **Qué:** se quita todo lo que no es de Claude ni de seguridad (Makefile, VS Code, formato, CodeQL, Dependabot, plantillas de GitHub) y se añade la skill `registro-cambios` con esta bitácora.
- **Por qué:** la plantilla debe servir para cualquier desarrollo; el stack y sus herramientas se eligen por proyecto. Y sin memoria entre sesiones, el contexto de cada cambio tiene que quedar escrito.
- **Descartado:** dejar solo `.claude/` y `docs/` (sin `setup-repo.sh` ni CI), porque nada impediría firmas de IA ni pushes a `main`.
- **Archivos:** `.claude/skills/registro-cambios/SKILL.md`, `docs/BITACORA.md`, `docs/SETUP.md`, `.github/workflows/ci.yml`, `scripts/setup-repo.sh`.
- **Commits:** el de esta entrada.
- **Probado:** `bash scripts/test-guardia.sh` en macOS (bash 3.2).
- **Pendiente:** comprobar la CI en GitHub; PR `development → main`.
