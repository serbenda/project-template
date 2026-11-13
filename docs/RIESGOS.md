# Registro de riesgos

> El criterio para publicar no es "está todo programado", sino "no hay riesgos Altos abiertos".
> Estados: `ABIERTO` → `MITIGADO` (corregido y con tests) → `CERRADO` (validado en el mundo real).

| ID | Riesgo | Impacto | Probabilidad | Estado | Mitigación | Fase |
|---|---|---|---|---|---|---|
| R-001 | <!-- p. ej.: se filtran datos personales en los logs --> | Alto | Media | ABIERTO | <!-- qué se hace o se hará --> | |

## Cómo se usa
- Cualquier fase que toque datos, autenticación, dependencias o despliegue revisa esta tabla.
- Un riesgo `MITIGADO` necesita un test o una prueba que lo demuestre, enlazada en *Mitigación*.
- Los riesgos de seguridad se contrastan con la skill `security-audit` (ver [SEGURIDAD.md](SEGURIDAD.md)).
