# Entorno local

## Requisitos
- git y python3 (para el hook de seguridad)
- Lo que pida el stack del proyecto: se anota aquí en la fase F03
- `make`
- Opcional: Node.js LTS (para las herramientas de lint de la CI)

## Primera vez
```bash
git clone https://github.com/serbenda/NOMBRE_DEL_PROYECTO.git
cd NOMBRE_DEL_PROYECTO
git switch development
git config core.hooksPath .githooks
cp .env.example .env    # solo si el proyecto usa variables de entorno
```

## Día a día
| Comando | Qué hace |
|---|---|
| `make dev` | Arranca el proyecto en local (se define en la fase F03) |
| `make test` | Ejecuta las pruebas |
| `make verify` | Lo mismo que la CI: hay que pasarlo antes de dar algo por terminado |
| `make help` | Lista todos los comandos |

Si el proyecto tiene servidor local, `.claude/launch.json` lo define también para la vista previa de Claude Code.

## Variables de entorno
Están en [`.env.example`](../.env.example) con su explicación. Los valores reales van en `.env`, que nunca se sube al repo.
