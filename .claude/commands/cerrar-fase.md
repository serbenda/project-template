---
description: Cierra la fase en curso. Comprueba criterios y Definition of Done, rellena el resultado y actualiza STATE, ROADMAP y CHANGELOG.
argument-hint: "[FNN]"
---

Fase a cerrar: $ARGUMENTS (si está vacío, la "Fase en curso" de `docs/STATE.md`).

1. Lee la ficha de la fase y `docs/DEFINITION_OF_DONE.md`.
2. Ejecuta `make verify`. Si falla, **para** y enséñame el error.
3. Repasa cada criterio de aceptación: ✅ cumplido (con la prueba: test, comando o paso manual) o ❌ no cumplido. Si hay algún ❌, **para**: la fase no se cierra.
4. Lanza el subagente `revisor-dod`. Si su veredicto es FALTA, para y enséñame lo que falta.
5. Rellena la sección **Resultado** de la ficha: qué se hizo, cómo se probó, qué quedó fuera y por qué, y lo aprendido. Estado ✅ y fecha de fin.
6. Actualiza:
   - `docs/STATE.md`: "Hecho recientemente" (máximo 5 entradas; quita la más antigua), "Siguiente", bloqueos y riesgos. Mantenlo por debajo de 150 líneas.
   - `docs/ROADMAP.md` y `docs/fases/README.md`: estado de la fase (y de la etapa si se cumple su criterio de salida).
   - `CHANGELOG.md`: entrada en *Sin publicar* si cambia el comportamiento.
   - `docs/RIESGOS.md`: riesgos mitigados o nuevos.
   - `docs/ARQUITECTURA.md`: solo si ha cambiado una pieza o un flujo.
7. Si "Lo aprendido" cambia cómo se trabaja en este repo, propón el cambio a `AGENTS.md` (no lo apliques sin mi visto bueno).
8. Haz un commit `docs: cierra FNN` con esos cambios y dime si conviene ya `/preparar-pr`.
