# Cómo contribuir

## Flujo de trabajo

```
issue  →  development (o feat/xxx desde development)  →  PR a main  →  revisión  →  merge  →  GitHub Pages
```

1. **Toda tarea empieza con una issue** enlazada al GitHub Project.
2. Trabaja en `development`. Para cambios grandes, crea `feat/descripcion-corta` desde `development` y llévala a `development` con una PR.
3. Cuando `development` esté lista, abre una PR **`development → main`**.
4. Rellena la plantilla de PR y comprueba la [Definition of Done](docs/DEFINITION_OF_DONE.md).
5. Solo el propietario fusiona en `main`. `main` está protegida: no admite pushes directos y exige que la CI esté en verde.

## Commits

Se usa [Conventional Commits](https://www.conventionalcommits.org/es/):

| Tipo | Para qué |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de error |
| `docs:` | Solo documentación |
| `refactor:` | Cambio sin efecto funcional |
| `test:` | Pruebas |
| `ci:` | Workflows y automatización |
| `chore:` | Mantenimiento (dependencias, configuración) |

Ejemplo: `feat: añade filtro por provincia en el mapa`

Autor de los commits:

```bash
git config user.name  "Sergio Santiago Bendaña Quesada"
git config user.email "serbenda@gmail.com"
```

## Versiones

[SemVer](https://semver.org/lang/es/) (`vMAJOR.MINOR.PATCH`) con tags en `main` y cambios anotados en [CHANGELOG.md](CHANGELOG.md).
