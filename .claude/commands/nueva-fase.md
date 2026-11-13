---
description: Crea la ficha de una fase nueva desde la plantilla y propone el plan. No escribe código hasta que el propietario lo apruebe.
argument-hint: "<qué hay que hacer>"
---

Fase a planificar: $ARGUMENTS

1. Lee `docs/VISION.md`, `docs/STATE.md`, `docs/ROADMAP.md`, `docs/ARQUITECTURA.md` y las decisiones aceptadas de `docs/decisiones/`.
2. Si la petición choca con la sección **Qué NO hacer** de la visión o con una decisión aceptada, **para** y explícalo citando el documento.
3. Calcula el siguiente número de fase (`FNN`, numeración global) mirando `docs/fases/` y `docs/ROADMAP.md`.
4. Explora el código que tocará la fase (solo lectura) para que el plan sea realista.
5. Crea `docs/fases/FNN-titulo-corto.md` desde `docs/fases/_plantilla.md` con: objetivo, alcance (entra / **no entra**), criterios de aceptación comprobables, plan por pasos y riesgos. Estado: ⬜ planificada.
6. Si la fase no cabe en una PR revisable, propón partirla en dos.
7. Añade la fase a la tabla de `docs/fases/README.md` y a su etapa en `docs/ROADMAP.md`.
8. Enséñame un resumen del plan y **espera mi aprobación**. No escribas código de la fase en este paso.

Cuando la apruebe: márcala ⏳ en curso, pon la fecha de inicio y actualiza "Fase en curso" en `docs/STATE.md`.
