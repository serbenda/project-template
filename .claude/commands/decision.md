---
description: Registra una decisión de arquitectura o de producto (ADR) numerada en docs/decisiones/.
argument-hint: "<qué hay que decidir>"
---

Decisión: $ARGUMENTS

1. Lee `docs/decisiones/README.md` y las decisiones aceptadas. Si alguna ya cubre esto, cítala y pregúntame si la queremos sustituir.
2. Calcula el siguiente número (`NNNN`) y crea `docs/decisiones/NNNN-titulo-corto.md` desde `_plantilla.md`.
3. Rellena el contexto con hechos del repo y del proyecto, y al menos **dos opciones reales** con pros y contras honestos. Si falta información para comparar, dilo en vez de inventarla.
4. Deja el estado en **propuesta**, con tu recomendación en *Decisión*, y enséñamela.
5. Cuando la acepte: estado **aceptada**, añádela a la tabla de `docs/decisiones/README.md` y, si sustituye a otra, marca la vieja como "sustituida por NNNN".
6. Si la decisión cambia piezas o flujos, actualiza `docs/ARQUITECTURA.md`.
