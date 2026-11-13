# 0001 — Organización del trabajo con agentes de IA

- **Estado:** aceptada
- **Fecha:** 2026-11-13

## Contexto
Los agentes de IA no recuerdan nada entre sesiones. Sin una memoria escrita del proyecto, cada sesión vuelve a descubrir el estado, repite discusiones ya cerradas o amplía el alcance por su cuenta. En proyectos anteriores funcionó un archivo de estado compacto, fichas de fase y decisiones escritas; y causó confusión mezclar dos numeraciones (fases y etapas) a la vez.

## Opciones
| Opción | A favor | En contra |
|---|---|---|
| Solo issues de GitHub | Ya existe, se ve en el Project | El agente no lo lee por defecto; mezcla bugs con planificación |
| Un único documento largo de plan | Simple | Crece sin control y se queda obsoleto |
| STATE + ROADMAP + fichas de fase + ADR en `docs/` | Cada pieza tiene un propósito y un tamaño acotado; vive con el código | Hay que mantenerlo (lo automatizan `/nueva-fase` y `/cerrar-fase`) |

## Decisión
Se usa la tercera opción: `docs/VISION.md`, `docs/STATE.md` (≤150 líneas), `docs/ROADMAP.md` con etapas `E0…` y fases `F01…` de numeración única, fichas en `docs/fases/` y decisiones en `docs/decisiones/`. Las normas para agentes van en `AGENTS.md`; `CLAUDE.md` solo lo importa y añade lo propio de Claude Code.

## Consecuencias
- Cada sesión empieza con `/estado` y cada fase termina con `/cerrar-fase`, que actualiza STATE.
- El alcance de una fase se aprueba antes de escribir código.
- Las decisiones aceptadas no se reabren sin una nueva decisión que las sustituya.
