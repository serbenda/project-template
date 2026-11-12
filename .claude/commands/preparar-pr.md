---
description: Repasa la Definition of Done, lanza los revisores y abre la PR development → main sin firmas de IA.
---

1. Comprueba que estás en `development` y que no hay cambios sin commitear (`git status`).
2. Lanza en paralelo los subagentes `revisor-dod` y `revisor-seguridad`.
3. Si alguno devuelve hallazgos Críticos o Altos, o el veredicto es FALTA: **para**, enséñame el resumen y no abras la PR.
4. Si todo está bien, prepara el texto de la PR con `.github/pull_request_template.md`: rellena qué cambia, cómo se ha probado y marca la DoD. **Sin** líneas de "Generated with", sin enlaces de sesión y sin firmas de herramientas de IA.
5. Enséñame el título y el texto, y abre la PR (`development` → `main`) cuando lo confirme.
6. Nunca fusiones la PR: la fusiono yo.

$ARGUMENTS
