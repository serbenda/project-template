# Definition of Done (DoD)

Un cambio está **hecho** solo cuando cumple todo lo de esta lista. Si algo no aplica, se indica en la PR con el motivo.

## 1. Código
- [ ] Hace lo que pide la issue y la ficha de fase, y nada más (sin cambios colaterales no pedidos).
- [ ] Cumple los criterios de aceptación de la ficha de fase.
- [ ] Legible: nombres claros, sin código muerto, sin trazas de depuración (`print`, `console.log`…).
- [ ] Sigue el estilo del proyecto (`docs/ARQUITECTURA.md` → Convenciones).
- [ ] Sin dependencias nuevas innecesarias; si las hay, están justificadas en la PR.

## 2. Pruebas
- [ ] Probado en local (ver `docs/SETUP.md`) siguiendo los criterios de aceptación.
- [ ] Tests automáticos añadidos o actualizados para lo que cambia.
- [ ] Los comandos de *Verificar* de `docs/SETUP.md` pasan en local y la CI está en verde.

## 3. Seguridad
- [ ] Ningún secreto, token, clave ni dato personal en el código o en el historial.
- [ ] Las entradas de usuario y los datos externos se tratan como no confiables y se validan antes de llegar a consultas, comandos, rutas o HTML.
- [ ] Las llamadas a APIs externas van por HTTPS y sus fallos se gestionan (timeouts, mensaje claro, sin caerse).
- [ ] El escaneo de secretos no reporta nada nuevo.
- [ ] Si el cambio toca autenticación, datos externos, workflows o dependencias: revisado con la skill `security-audit` (modo guía).
- [ ] Antes de cada versión mayor: auditoría completa con `security-audit`, sin hallazgos `confirmed` abiertos.
- [ ] Antes de cada versión mayor: `repo-security-posture` sin hallazgos Critical ni High.

## 4. Según el tipo de proyecto (borra lo que no aplique)
**Interfaz web o móvil**
- [ ] Accesible: textos alternativos, contraste suficiente, navegable con teclado.
- [ ] Probado en escritorio y móvil, sin errores en consola.
- [ ] Datos externos con `textContent`, nunca `innerHTML`.

**API o backend**
- [ ] Cada endpoint valida la entrada y comprueba la autorización.
- [ ] Errores sin filtrar detalles internos; logs sin secretos ni datos personales.
- [ ] Migraciones de base de datos reversibles o con plan de vuelta atrás.

**CLI o librería**
- [ ] `--help` y README reflejan el cambio; códigos de salida coherentes.

## 5. Documentación
- [ ] README actualizado si cambia el uso, la configuración o las fuentes de datos.
- [ ] Entrada en `docs/BITACORA.md` (qué, por qué, commits, cómo se probó) y, si el cambio es visible, en `CHANGELOG.md` → *Sin publicar*.
- [ ] Ficha de fase con *Resultado* relleno y `docs/STATE.md` actualizado (`/cerrar-fase`).
- [ ] Si se ha tomado una decisión difícil de deshacer, tiene su ADR en `docs/decisiones/`.
- [ ] Las fuentes de datos públicas usadas aparecen citadas con su licencia.

## 6. Integración
- [ ] Trabajo en `development` (o una rama que sale de ella), nunca directamente en `main`.
- [ ] Commits con formato Conventional Commits y autor correcto.
- [ ] PR de `development` → `main` con la plantilla rellena y revisada.
- [ ] Tras el merge, lo desplegado (si hay despliegue) funciona.
- [ ] Issue cerrada y tarjeta movida a *Done* en GitHub Projects.
