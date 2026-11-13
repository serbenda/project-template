# Definition of Done (DoD)

Un cambio está **hecho** solo cuando cumple todo lo de esta lista. Si algo no aplica, se indica en la PR con el motivo.

## 1. Código
- [ ] Hace lo que pide la issue y la ficha de fase, y nada más (sin cambios colaterales no pedidos).
- [ ] Cumple los criterios de aceptación de la ficha de fase.
- [ ] Legible: nombres claros, sin código muerto, sin `console.log` de depuración.
- [ ] Sigue `.editorconfig` y el estilo del proyecto.
- [ ] Sin dependencias nuevas innecesarias; si las hay, están justificadas en la PR.

## 2. Pruebas
- [ ] Probado en local (`python3 -m http.server` o equivalente) en escritorio **y** móvil.
- [ ] Probado en al menos dos navegadores (Chrome/Edge y Firefox o Safari).
- [ ] Tests automáticos añadidos o actualizados si el proyecto los tiene.
- [ ] `make verify` pasa en local y la CI está en verde.

## 3. Seguridad
- [ ] Ningún secreto, token, clave ni dato personal en el código o en el historial.
- [ ] Las entradas de usuario y los datos externos se tratan como no confiables (sin `innerHTML` con datos externos; usar `textContent`).
- [ ] Las llamadas a APIs externas van por HTTPS y sus fallos se gestionan (mensaje al usuario, sin romper la página).
- [ ] El escaneo de secretos y CodeQL no reportan nada nuevo.
- [ ] Si el cambio toca autenticación, datos externos, workflows o dependencias: revisado con la skill `security-audit` (modo guía).
- [ ] Antes de cada versión mayor: auditoría completa con `security-audit`, sin hallazgos `confirmed` abiertos.
- [ ] Antes de cada versión mayor: `repo-security-posture` sin hallazgos Critical ni High.

## 4. Calidad web (si el proyecto tiene interfaz web)
- [ ] Accesible: textos alternativos, contraste suficiente, navegable con teclado, `lang` correcto.
- [ ] Responsive: se ve bien de 360 px a escritorio.
- [ ] Sin errores en la consola del navegador.
- [ ] Rendimiento razonable: imágenes optimizadas y nada bloqueante innecesario.
- [ ] Antes de cada versión: revisión con la skill `web-perf`, con Core Web Vitals en verde.

## 5. Documentación
- [ ] README actualizado si cambia el uso, la configuración o las fuentes de datos.
- [ ] Entrada en `CHANGELOG.md` en la sección *Sin publicar*.
- [ ] Ficha de fase con *Resultado* relleno y `docs/STATE.md` actualizado (`/cerrar-fase`).
- [ ] Si se ha tomado una decisión difícil de deshacer, tiene su ADR en `docs/decisiones/`.
- [ ] Las fuentes de datos públicas usadas aparecen citadas con su licencia.

## 6. Integración
- [ ] Trabajo en `development` (o una rama que sale de ella), nunca directamente en `main`.
- [ ] Commits con formato Conventional Commits y autor correcto.
- [ ] PR de `development` → `main` con la plantilla rellena y revisada.
- [ ] Tras el merge, la web publicada en GitHub Pages funciona.
- [ ] Issue cerrada y tarjeta movida a *Done* en GitHub Projects.
