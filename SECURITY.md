# Política de seguridad

## Informar de una vulnerabilidad

Por favor, **no abras una issue pública**. Usa el aviso privado de GitHub:
**Security → Report a vulnerability** en este repositorio.

Incluye una descripción del problema, los pasos para reproducirlo y su posible impacto. Responderé lo antes posible.

## Versiones con soporte

Solo la última versión publicada en `main` (la web en GitHub Pages).

## Medidas del repositorio

Detalle completo en [docs/SEGURIDAD.md](docs/SEGURIDAD.md).


- `main` protegida: sin pushes directos, PR obligatoria y CI en verde.
- Escaneo de secretos (Gitleaks) y análisis estático (CodeQL) en cada PR.
- Dependabot mantiene actualizadas las GitHub Actions.
- Permisos mínimos (`contents: read`) por defecto en los workflows.
