# Hoja de ruta

> **Un solo sistema de numeración:** etapas `E0, E1, E2…` y, dentro de cada una, fases `F01, F02…` (numeración global, no se reinicia).
> Una etapa termina cuando se cumple su **criterio de salida**, que debe poder comprobarse, no ser una sensación.
> Si cambia el plan, se edita este archivo y se explica en una [decisión](decisiones/).

| Etapa | Objetivo | Criterio de salida | Estado |
|---|---|---|---|
| E0 | Definir | VISION escrita, stack decidido (ADR), entorno local arrancando con `make dev` | ⏳ |
| E1 | Núcleo mínimo | <!-- p. ej.: un usuario puede hacer X de principio a fin en local --> | ⬜ |
| E2 | Probar con gente | <!-- p. ej.: 3 personas lo usan una semana sin ayuda --> | ⬜ |
| E3 | Publicar | <!-- p. ej.: desplegado, con backups y sin riesgos Altos abiertos --> | ⬜ |

Leyenda: ⬜ sin empezar · ⏳ en curso · ✅ hecha

## E0 — Definir

| Fase | Qué | Estado |
|---|---|---|
| F01 | Visión y alcance | ⬜ |
| F02 | Decisión de stack y estructura del código | ⬜ |
| F03 | Entorno local: `make dev`, `make test`, `make verify` | ⬜ |

## E1 — Núcleo mínimo
<!-- Se detalla al terminar E0. No planifiques en detalle más de una etapa por delante. -->
