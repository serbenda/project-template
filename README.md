# NOMBRE_DEL_PROYECTO

> Una frase que explique qué es y para quién.

## Qué hace
- Funcionalidad principal 1
- Funcionalidad principal 2

## Fuentes de datos
| Fuente | Qué aporta | Licencia |
|---|---|---|
| _Ej.: Red Eléctrica (REData)_ | _Precio de la luz_ | _Uso libre con atribución_ |

## Uso en local
```bash
git clone https://github.com/serbenda/NOMBRE_DEL_PROYECTO.git
cd NOMBRE_DEL_PROYECTO
git switch development
make help        # comandos disponibles (make dev se define al elegir el stack)
```

## Estructura
```
.
├── docs/
│   ├── VISION.md        # qué es, para quién y qué NO hacer
│   ├── STATE.md         # estado vivo (≤150 líneas): lo primero que lee el agente
│   ├── ROADMAP.md       # etapas E0… con criterio de salida
│   ├── fases/           # una ficha por bloque de trabajo (F01…)
│   ├── decisiones/      # ADR numerados
│   ├── ARQUITECTURA.md  # piezas, flujo de datos, fuentes externas
│   ├── RIESGOS.md       # registro de riesgos
│   ├── SETUP.md         # entorno local
│   ├── DEFINITION_OF_DONE.md
│   └── SEGURIDAD.md
├── scripts/       # setup-repo.sh y pruebas
├── .claude/       # permisos, hook, skills, subagentes, comandos y launch.json
├── .githooks/     # hook de git: quita firmas de IA y comprueba el autor
├── .vscode/       # extensiones recomendadas y ajustes del proyecto
├── Makefile       # make dev · make test · make verify (= CI); detecta el stack
├── .env.example   # variables de entorno documentadas, sin valores
├── AGENTS.md      # normas para cualquier agente de IA
└── CLAUDE.md      # importa AGENTS.md y añade lo específico de Claude Code
```

## Cómo se trabaja con Claude

```
/estado                      al empezar cada sesión
/nueva-fase <qué>            ficha + plan → lo apruebas → Claude implementa en development
make verify                  lo mismo que la CI
/cerrar-fase                 criterios + DoD + actualiza STATE, ROADMAP y CHANGELOG
/preparar-pr                 revisores + PR development → main (la fusionas tú)
/decision <qué>              cuando haya que elegir algo difícil de deshacer
```

## Cómo contribuir
Lee [CONTRIBUTING.md](CONTRIBUTING.md) y la [Definition of Done](docs/DEFINITION_OF_DONE.md).

## Licencia
Sin licencia: © Sergio Santiago Bendaña Quesada. Todos los derechos reservados.
El código se puede consultar, pero no copiar, modificar ni redistribuir sin permiso escrito del autor.

---

<details>
<summary>📦 Cómo usar esta plantilla (borra esta sección en el proyecto nuevo)</summary>

1. En GitHub: **Use this template → Create a new repository**.
2. Clona el repo nuevo y ejecuta:
   ```bash
   ./scripts/setup-repo.sh
   ```
   Crea la rama `development`, protege `main` y activa las alertas de seguridad y el hook de git.
   Con commits firmados: `FIRMAS=1 ./scripts/setup-repo.sh`.
3. Sustituye `NOMBRE_DEL_PROYECTO` en este README (el script ya lo cambia en el resto).
4. Escribe [docs/VISION.md](docs/VISION.md) (o díctasela a Claude y revísala).
5. Con Claude: `/decision stack del proyecto`, y luego `/nueva-fase` para la primera fase de la Etapa 0.
6. En la fase F03 (entorno local), Claude define `make dev`, `.claude/launch.json`, el setup del stack en la CI y el lenguaje de CodeQL.
7. Borra esta sección.
8. Una sola vez en tu Mac: sigue [docs/SEGURIDAD.md](docs/SEGURIDAD.md) → "Lo que tienes que hacer tú".

</details>
