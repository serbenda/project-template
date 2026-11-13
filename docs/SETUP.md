# Entorno local

> Se completa en la fase F03, después de la decisión de stack. Claude lo lee para saber cómo arrancar y verificar el proyecto.

## Requisitos
- git y python3 (para el hook de seguridad)
- Lo que pida el stack del proyecto: <!-- p. ej.: Node.js 22, Python 3.13 con uv… -->

## Primera vez
```bash
git clone https://github.com/serbenda/NOMBRE_DEL_PROYECTO.git
cd NOMBRE_DEL_PROYECTO
git switch development
git config core.hooksPath .githooks
```

## Día a día
| Para | Comando |
|---|---|
| Arrancar en local | <!-- p. ej.: npm run dev --> |
| Ejecutar las pruebas | <!-- p. ej.: pytest --> |

Si el proyecto tiene servidor local, defínelo también en `.claude/launch.json` para la vista previa de Claude Code.

## Verificar
Lo mismo que la CI. Hay que pasarlo antes de dar algo por terminado:
```bash
bash scripts/test-guardia.sh   # hook de seguridad
# + pruebas y lint del stack, p. ej.: npm test && npm run lint
```

## Variables de entorno
Los valores reales van en `.env`, que nunca se sube al repo. Documenta aquí cada variable: para qué sirve y dónde se consigue, nunca su valor.
