---
name: registro-cambios
description: Registra cada cambio del repo en CHANGELOG.md y en docs/BITACORA.md (qué se hizo, por qué, archivos, commits, cómo se probó y qué queda pendiente). Úsala SIEMPRE al terminar cualquier cambio (código, configuración, CI, documentación) y antes de hacer commit, aunque nadie la pida. También cuando el propietario pregunte qué se cambió, cuándo o por qué.
---

# Registro de cambios

No recuerdas nada entre sesiones. Lo que no quede escrito aquí se pierde. Hay dos registros con funciones distintas:

| Archivo | Para quién | Qué guarda |
|---|---|---|
| `CHANGELOG.md` | Quien use el proyecto | Cambios **visibles**, en una línea, formato [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) |
| `docs/BITACORA.md` | El propietario y el próximo agente | El **contexto** de cada cambio: por qué, alternativas, archivos, commits, pruebas, pendiente |

`docs/STATE.md` es otra cosa: el estado actual en ≤150 líneas. No copies la bitácora en STATE; como mucho, enlaza la entrada.

## Cuándo

- Al terminar un cambio, **antes del commit**, para que registro y cambio vayan en el mismo commit.
- Si el cambio se hizo en varios commits, una sola entrada al final que los cite todos.
- No registres pasos intermedios ni intentos descartados como entradas propias: van dentro de la entrada, en *Descartado*.

## 1. CHANGELOG.md

Solo si cambia algo que nota quien usa el proyecto (funcionalidad, configuración, comportamiento, seguridad, dependencias). Un refactor interno o un arreglo de typo **no** van.

- Sección `## [Sin publicar]`, en el subapartado que toque, en este orden: `Añadido`, `Cambiado`, `Obsoleto`, `Eliminado`, `Corregido`, `Seguridad`.
- Una línea por cambio, en español, en pasado o como hecho: «Filtro por provincia en el mapa», no «He añadido…».
- Si hay ficha de fase o ADR, enlázalo.
- No reescribas entradas de versiones ya publicadas.

## 2. docs/BITACORA.md

**Siempre**, también para cambios internos. Entrada nueva **arriba** (orden cronológico inverso), con este formato:

```markdown
## AAAA-MM-DD — Título corto del cambio
- **Fase / issue:** F03 · #12 (o «—»)
- **Qué:** lo que cambia, en 1-3 frases.
- **Por qué:** el motivo o el problema que resuelve. Es lo más importante: el qué se ve en el diff, el porqué no.
- **Descartado:** alternativas que se valoraron y por qué no (si las hubo).
- **Archivos:** los principales, con ruta.
- **Commits:** `abc1234` (rellénalo después del commit con un `docs: bitácora` si hace falta, o en la siguiente entrada).
- **Probado:** comando o pasos que demuestran que funciona.
- **Pendiente:** lo que queda abierto, o «nada».
```

Reglas:
- Fecha real del día (`date +%F`), nunca inventada.
- Hechos comprobables: si no lo has probado, escribe «sin probar», no «funciona».
- Sin secretos, tokens, contraseñas ni datos personales, aunque aparezcan en el cambio.
- No edites entradas antiguas salvo para corregir un dato erróneo; en ese caso, añade «(corregido AAAA-MM-DD)».
- Si una decisión es difícil de deshacer, la entrada enlaza el ADR de `docs/decisiones/` en vez de repetir el razonamiento.

## 3. Comprobación final

Antes del commit, repasa:
- [ ] ¿Hay entrada en `docs/BITACORA.md` con *Por qué* y *Probado*?
- [ ] ¿El cambio es visible? Entonces tiene línea en `CHANGELOG.md`.
- [ ] ¿Ha cambiado el estado o el siguiente paso? Entonces actualiza `docs/STATE.md`.
