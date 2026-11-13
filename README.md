# NOMBRE_DEL_PROYECTO

> Una frase que explique qué es y para quién.

🔗 **Web:** https://serbenda.github.io/NOMBRE_DEL_PROYECTO/

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
python3 -m http.server 8000   # abre http://localhost:8000
```

## Estructura
```
.
├── index.html
├── css/
├── js/
├── assets/
├── docs/          # Definition of Done, guía de seguridad
├── scripts/       # setup-repo.sh y pruebas
├── .claude/       # configuración del agente: permisos, hook, skills, subagentes, comandos
├── .githooks/     # hook de git: quita firmas de IA y comprueba el autor
├── AGENTS.md      # normas para cualquier agente de IA
└── CLAUDE.md      # importa AGENTS.md y añade lo específico de Claude Code
```

## Cómo contribuir
Lee [CONTRIBUTING.md](CONTRIBUTING.md) y la [Definition of Done](docs/DEFINITION_OF_DONE.md).

## Licencia
[MIT](LICENSE) © Sergio Santiago Bendaña Quesada

---

<details>
<summary>📦 Cómo usar esta plantilla (borra esta sección en el proyecto nuevo)</summary>

1. En GitHub: **Use this template → Create a new repository**.
2. Clona el repo nuevo y ejecuta:
   ```bash
   ./scripts/setup-repo.sh
   ```
   Crea la rama `development`, protege `main`, activa Pages, las alertas de seguridad y el hook de git.
   Con commits firmados: `FIRMAS=1 ./scripts/setup-repo.sh`.
3. Sustituye `NOMBRE_DEL_PROYECTO` en este README.
4. Borra esta sección.
5. Una sola vez en tu Mac: sigue [docs/SEGURIDAD.md](docs/SEGURIDAD.md) → "Lo que tienes que hacer tú".

</details>
