# Guía de la plantilla (en castellano)

> Esta plantilla está escrita en inglés. Esta guía explica en castellano **qué hay en ella, para qué sirve cada pieza y cómo se trabaja**.
> La portada en inglés está en [README.md](README.md) y todos los flujos dibujados, más abajo y en [docs/WORKFLOWS.md](docs/WORKFLOWS.md). Si creas un proyecto desde la plantilla, puedes conservar o borrar esta guía.

## Qué es

Una plantilla de repositorio para **empezar cualquier proyecto nuevo trabajando con Claude Code**, sea del lenguaje que sea. No trae código de ejemplo: trae tres cosas.

1. **Memoria del proyecto para la IA.** Claude no recuerda nada entre sesiones. La plantilla le da unos documentos en `docs/` (visión, estado, hoja de ruta, fases, decisiones, bitácora) que lee al empezar y actualiza al terminar.
2. **Una forma de trabajar.** Comandos como `/status`, `/new-phase` o `/prepare-pr` que llevan el trabajo por fases pequeñas, con el plan aprobado antes de escribir código.
3. **Seguridad por capas.** Desde tu Mac hasta GitHub: permisos, un guardián que impide a Claude hacer cosas peligrosas, un *sandbox*, un modelo de amenazas antes del código sensible, hooks de git (secretos y autoría) y seis comprobaciones obligatorias en la CI, incluidos análisis estático (Semgrep) y de dependencias vulnerables (OSV-Scanner).

Además incluye 6 **skills**: conocimiento especializado que Claude carga cuando la tarea lo pide (bitácora, seguridad, servidores MCP, pruebas web, diseño de interfaces). Solo van las útiles para desarrollar software: cada skill ocupa contexto en todas las sesiones y compite por activarse.

Y tiene **dos modos**, para no cargar de papeleo un experimento ni dejar sin control un proyecto serio (ver abajo).

## Modo ligero o completo

Se elige al crear el proyecto y queda escrito en `docs/STATE.md` → *Mode*. Claude lo lee y trabaja según el modo.

| | **Ligero** (`light`) | **Completo** (`full`) |
|---|---|---|
| Para | Experimentos, prototipos, herramientas pequeñas | Lo que va a durar o lo usan otros |
| Documentos que se mantienen | `VISION`, `STATE`, `WORKLOG`, `SETUP` y `THREAT_MODEL` (al configurarlo se borran `ROADMAP`, `RISKS` y `phases/`) | Todo `docs/` |
| Planificación | Claude propone el plan en el chat, lo apruebas y queda en *Current work* de `STATE` | Una ficha por fase (`/new-phase`) dentro de las etapas de `ROADMAP` |
| Decisiones (ADR) | Solo las irreversibles | Todo lo difícil de deshacer |
| CHANGELOG y riesgos | No se usan | Sí |
| Ramas, PR, hooks y CI | Igual | Igual |

Claude te **propondrá pasar a completo** (no lo hace por su cuenta) cuando se cumpla algo de esto: lo usa alguien más, se despliega, maneja datos personales o dinero, lleva más de un mes, o colabora otra persona. Pasar es poner *Mode: full*, traer de la plantilla `docs/ROADMAP.md`, `docs/RISKS.md` y `docs/phases/` (el modo ligero los borra) y rellenar `ROADMAP` y la primera fase con lo que ya dicen `STATE` y `WORKLOG`.

## Cómo se empieza un proyecto

1. En GitHub: **Use this template → Create a new repository**.
2. Clona el repo y ejecuta `./scripts/setup-repo.sh`. Configura tu autoría, crea la rama `development`, protege `main` y activa las alertas de seguridad. Con commits firmados: `SIGNED_COMMITS=1 ./scripts/setup-repo.sh`. En modo ligero: `MODE=light ./scripts/setup-repo.sh` (por defecto, completo). Si el agente va a tener **cuenta propia de GitHub** (recomendado en modo completo): `AGENT_BOT=<su usuario> ./scripts/setup-repo.sh`, y sigue *Agent identity* en `docs/SECURITY_GUIDE.md`. Las opciones se pueden combinar.
3. Escribe `docs/VISION.md` (o díctasela a Claude y revísala).
4. En Claude Code: `/decision project stack` para elegir lenguaje y herramientas.
5. `/new-phase` para la primera fase (en modo ligero, el primer plan). En modo completo, la fase P03 sigue la **lista de comprobación del stack** de `docs/SETUP.md`: comandos para arrancar y verificar, `.claude/launch.json`, job de CI con pruebas y lint, Dependabot, CodeQL opcional si el repo es público (Semgrep ya corre siempre en el job SAST) y `.gitignore`. Al terminar, añades tú el nombre del job nuevo a los checks obligatorios de `main`.
6. Una sola vez en tu Mac: sigue `docs/SECURITY_GUIDE.md` → *What you have to do yourself*.

## El día a día con Claude

| Cuándo | Qué haces | Qué pasa |
|---|---|---|
| Al abrir una sesión | `/status` | Claude lee el estado y te dice dónde estás y qué toca |
| Empiezas algo nuevo | `/new-phase <qué>` | Completo: crea la ficha de la fase con objetivo, alcance, criterios y plan. Ligero: te propone el plan en el chat. En los dos casos **no escribe código hasta que lo apruebes** |
| Mientras trabaja | (automático) | Tras cada cambio, la skill `record-changes` anota en la bitácora por qué se hizo, qué se descartó y cómo se probó. Si se le olvida, la CI (**Records**) no deja fusionar la PR |
| Hay que elegir algo difícil de deshacer | `/decision <qué>` | Escribe un ADR con opciones, pros y contras y una recomendación, **la somete a un challenge** y te enseña la comparativa; tú decides |
| Quieres una segunda opinión de lo que sea | `/challenge <qué>` o decir "haz un challenge" | Dos `challenger` que no han visto cómo se llegó a la propuesta la atacan desde dos puntos de vista (coste, riesgos, quien lo mantiene…), si se puede con otro modelo. Te da una tabla: objeción, gravedad, alternativa y qué opina Claude de cada una, y una recomendación final. Vale para código, planes, ideas, textos o compras. Toda decisión que te proponga Claude pasa antes por aquí |
| Termina la fase | `/close-phase` | Comprueba criterios y Definition of Done y actualiza el estado. En completo, además, rellena el resultado de la fase, la hoja de ruta y el CHANGELOG (una vez por fase, sin repetir la bitácora) |
| Quieres llevarlo a `main` | `/prepare-pr` | Va **después** de `/close-phase`: comprueba que las fases están cerradas y que `development` ya tiene todo lo de `main`, pasa la verificación y los tres revisores, y abre la PR `development → main` rellenando la plantilla de PR. **La fusionas tú**; lo que solo se puede comprobar después (que lo desplegado funciona, cerrar la issue, actualizar `development`) es la sección 7 de la DoD, y `/status` te lo recuerda |

## Flujos de trabajo (diagramas)

Todas las formas de usar la plantilla, dibujadas. Empieza por el primero: te manda al flujo que toca según lo que quieras hacer. La versión en inglés, que es la que mantiene Claude, está en [docs/WORKFLOWS.md](docs/WORKFLOWS.md).

### 1. ¿Qué quieres hacer?

```mermaid
flowchart TD
    A{"¿Qué quieres hacer?"} -->|"Empezar algo nuevo"| B["Empezar un proyecto · 2"]
    A -->|"Trabajar en un proyecto"| C["Sesión de trabajo · 4"]
    A -->|"Elegir algo difícil de deshacer<br/>stack, base de datos, auth, hosting"| D["Decisión · 7"]
    A -->|"Llevar mis cambios a main"| E["Del cambio a main · 8"]
    A -->|"Publicar una versión"| F["Antes de publicar · 11"]
    A -->|"Un proyecto hecho con una<br/>versión antigua de la plantilla"| G["Ponerlo al día · 12"]
    A -->|"Claude o la CI me han bloqueado"| H["Cuando algo se bloquea · 10"]
    C --> M{"Mode en docs/STATE.md"}
    M -->|"full"| P["Fase, modo completo · 5"]
    M -->|"light"| L["Trabajo, modo ligero · 6"]
```

### 2. Empezar un proyecto nuevo

```mermaid
flowchart TD
    A["GitHub: Use this template<br/>Create a new repository"] --> B["git clone y cd"]
    B --> C{"¿Experimento o herramienta pequeña?"}
    C -->|"sí"| D["MODE=light ./scripts/setup-repo.sh"]
    C -->|"no"| E["./scripts/setup-repo.sh"]
    D --> F
    E --> F["setup-repo.sh:<br/>autoría y hooks de git, rama development,<br/>regla de main con 6 checks obligatorios,<br/>alertas de Dependabot, etiquetas,<br/>CHANGELOG y bitácora vacíos, README del proyecto"]
    F --> G{"¿Repo privado en GitHub Free?"}
    G -->|"sí"| H["Avisa y sale con error: main no se puede proteger.<br/>Hazlo público o usa GitHub Pro"]
    G -->|"no"| I["Escribe docs/VISION.md<br/>(o díctasela a Claude y revísala)"]
    I --> J["/decision project stack"]
    J --> K["Rellena docs/THREAT_MODEL.md<br/>antes del primer código sensible"]
    K --> L["/new-phase entorno local<br/>= lista del stack de P03"]
    L --> N["SETUP Verify, launch.json, job de CI del stack,<br/>ecosistema de Dependabot, .gitignore"]
    N --> O["Tú: añade el job del stack<br/>a los checks obligatorios de main"]
    O --> P["Día a día: flujo 4"]
```

### 3. Modo ligero o completo

```mermaid
flowchart TD
    A{"¿Se cumple alguna?"} --> B["Lo usa alguien más"]
    A --> C["Está desplegado"]
    A --> D["Datos personales o dinero"]
    A --> E["Más de un mes de trabajo"]
    A --> F["Colabora otra persona"]
    B & C & D & E & F --> G["modo completo"]
    A -->|"ninguna"| H["modo ligero"]
    H --> I["Mantiene VISION, STATE, WORKLOG,<br/>SETUP y THREAT_MODEL"]
    G --> J["Además ROADMAP, fichas de fase, ADR,<br/>RISKS, ARCHITECTURE y CHANGELOG"]
    H -. "/status propone cambiar<br/>en cuanto se cumpla una" .-> G
```

### 4. Una sesión de trabajo con Claude

```mermaid
flowchart TD
    A["Abres Claude Code en el repo"] --> B["/status"]
    B --> C["Claude lee STATE, la bitácora<br/>y, en modo completo, ROADMAP y la fase"]
    C --> D{"¿Y ahora qué?"}
    D -->|"Funcionalidad o bloque nuevo"| E["/new-phase qué"]
    D -->|"Algo difícil de deshacer"| F["/decision qué"]
    D -->|"Arreglo pequeño dentro del plan"| G["Claude lo cambia, pasa Verify,<br/>record-changes escribe la bitácora, commit"]
    D -->|"El trabajo está terminado"| H["/close-phase"]
    D -->|"Listo para main"| I["/prepare-pr"]
    E --> J{"¿Choca con VISION<br/>qué NO hacer o con un ADR?"}
    J -->|"sí"| K["Claude se para y lo cita.<br/>Tú decides: descartarlo o cambiar VISION/ADR"]
    J -->|"no"| L["Plan, tu aprobación y luego código"]
```

### 5. Una fase, en modo completo

```mermaid
sequenceDiagram
    actor O as Tú
    participant C as Claude
    participant R as Revisores
    participant G as CI de GitHub
    O->>C: /new-phase qué
    C->>C: lee VISION, STATE, ROADMAP, ARCHITECTURE, THREAT_MODEL, ADR
    C->>C: docs/phases/PNN-titulo.md con objetivo, In/Out,<br/>criterios, plan e impacto de seguridad
    C-->>O: resumen del plan y preguntas
    O->>C: aprobación y respuestas
    C->>C: anota la aprobación con fecha en la ficha
    loop cada cambio
        C->>C: código + pruebas, Verify, entrada en la bitácora
        C->>C: commit (pre-commit Gitleaks, commit-msg)
    end
    O->>C: /close-phase
    C->>C: Verify, cada criterio y tus aprobaciones
    C->>R: dod-reviewer
    R-->>C: LISTO o FALTA
    C->>C: resultado, STATE, ROADMAP, CHANGELOG una vez, RISKS
    O->>C: /prepare-pr
    C->>C: ¿fases cerradas? ¿development tiene todo main?
    C->>R: revisores de DoD, seguridad y arquitectura
    R-->>C: veredictos y hallazgos
    C-->>O: texto de la PR, desde la plantilla
    O->>C: confirmas
    C->>G: push de development, abre la PR
    G-->>O: 6 checks
    O->>G: fusionas
    O->>O: tras fusionar: sección 7 de la DoD
    O->>C: /status
    C->>C: trae origin/main a development
```

### 6. Un trabajo, en modo ligero

```mermaid
flowchart TD
    A["/new-phase qué"] --> B["Claude revisa VISION y el código"]
    B --> C["Plan en el chat: objetivo, qué queda fuera,<br/>cómo sabremos que funciona, impacto de seguridad"]
    C --> D{"Tu aprobación"}
    D -->|"cambios"| C
    D -->|"aprobado"| E["Plan anotado en<br/>Current work de STATE"]
    E --> F["Código + pruebas, Verify, bitácora, commits"]
    F --> G["/close-phase"]
    G --> H["Verify, plan cumplido,<br/>pasa a Recently done, Next actualizado"]
    H --> I["Sin ficha de fase ni CHANGELOG"]
```

### 7. Una decisión difícil de deshacer

```mermaid
flowchart TD
    A["/decision qué"] --> B{"¿Ya la cubre<br/>un ADR aceptado?"}
    B -->|"sí"| C["Claude lo cita y te pregunta<br/>si quieres sustituirlo"]
    B -->|"no"| D["docs/decisions/NNNN-titulo.md<br/>contexto, 2 o más opciones reales, pros y contras"]
    C -->|"sustituir"| D
    D --> CH["Challenge: 2 challengers atacan<br/>la recomendación sin ver el razonamiento"]
    CH --> E["Estado propuesta, con una recomendación<br/>y la comparativa del challenge"]
    E --> F{"Tú decides"}
    F -->|"aceptar"| G["Estado aceptada, en el índice;<br/>la vieja queda como sustituida"]
    F -->|"rechazar o cambiar"| D
    G --> H["ARCHITECTURE al día<br/>si cambian piezas o flujos"]
```

### 8. Del cambio a `main`

```mermaid
flowchart LR
    A["Cambio en development"] --> B["git commit"]
    B --> C{"pre-commit:<br/>Gitleaks"}
    C -->|"hay un secreto"| X1["Commit rechazado"]
    C -->|"limpio"| D{"commit-msg:<br/>firma de IA, autor"}
    D -->|"autor incorrecto"| X2["Commit rechazado"]
    D -->|"bien"| E["git push<br/>(Claude pregunta antes)"]
    E --> F["CI: Secrets, Hook, Records,<br/>SAST, Dependencies"]
    F --> G["/prepare-pr<br/>3 revisores"]
    G --> H["PR development a main<br/>+ check Authorship"]
    H --> I{"¿6 checks en verde?"}
    I -->|"no"| X3["La regla bloquea la fusión"]
    I -->|"sí"| J["Fusionas tú"]
```

### 9. Seguridad: dónde actúa cada control

```mermaid
flowchart TB
    subgraph MAC["Tu Mac: ~/.claude/settings.json"]
        M1["No leer secretos, datos del navegador ni el Llavero<br/>No editar su configuración, tu shell ni git<br/>Sin modo saltarse permisos, MCP con tu aprobación"]
    end
    subgraph AGENT["Claude en el proyecto"]
        A1["permisos deny / ask / allow"]
        A2["hook guard.sh y sus pruebas"]
        A3["Sandbox: solo escribe en el proyecto,<br/>dominios permitidos, sin credenciales"]
    end
    subgraph DESIGN["Antes y durante el código"]
        D1["THREAT_MODEL.md"]
        D2["Impacto de seguridad por fase"]
        D3["DoD de seguridad por tipo de proyecto"]
        D4["security-reviewer"]
    end
    subgraph GIT["git en local"]
        G1["pre-commit: Gitleaks"]
        G2["commit-msg: firma de IA, autor"]
    end
    subgraph GH["GitHub"]
        H1["CI: Secrets, Authorship, Hook,<br/>Records, SAST, Dependencies"]
        H2["Regla: PR + 6 checks en verde,<br/>sin force-push ni borrado"]
        H3["Dependabot con 7 días de espera"]
    end
    MAC --> AGENT --> DESIGN --> GIT --> GH
```

### 10. Cuando algo se bloquea

```mermaid
flowchart TD
    A{"¿Qué ha bloqueado?"} -->|"guard.sh o una regla deny"| B["Claude se para y explica qué quería hacer.<br/>Nunca busca otro camino"]
    B --> B1{"¿Era legítimo?"}
    B1 -->|"no"| B2["Bien: el control ha funcionado"]
    B1 -->|"sí"| B3["Lo haces tú, o cambias la regla<br/>en .claude/ (solo tú)"]
    A -->|"Sandbox: dominio o ruta"| C["Añade el dominio a sandbox.network.allowedDomains<br/>solo si hace falta, a propósito"]
    A -->|"Hallazgo de SAST"| D["Arregla el código.<br/>Falso positivo: nosemgrep + motivo + tu aprobación"]
    A -->|"Hallazgo de Dependencies"| E["Actualiza la dependencia a la versión corregida"]
    A -->|"Records"| F["Añade la entrada de bitácora o recorta STATE"]
    A -->|"Authorship"| G["Quita la firma de IA o corrige el autor"]
    A -->|"Un revisor: FALTA o REVISAR"| H["Arregla lo que lista y vuelve a /prepare-pr"]
```

### 11. Antes de publicar

```mermaid
flowchart TD
    A["Etapa S3: publicar"] --> B{"¿Riesgos altos abiertos<br/>en RISKS.md?"}
    B -->|"sí"| X["Todavía no: mitígalos"]
    B -->|"no"| C["Auditoría completa con security-audit<br/>(solo cuando la pides tú)"]
    C --> D{"¿Hallazgos confirmados abiertos?"}
    D -->|"sí"| X
    D -->|"no"| E["repo-security-posture:<br/>sin Critical ni High"]
    E --> F["Hay copias de seguridad y se ha probado restaurar"]
    F --> G["CHANGELOG: Unreleased a x.y.z,<br/>etiqueta y release en GitHub"]
```

### 12. Poner al día un proyecto existente

```mermaid
flowchart TD
    A["En el repo de la plantilla"] --> B["scripts/sync-from-template.sh ../proyecto"]
    B --> C["Informe: archivos de la plantilla NEW / CHANGED,<br/>archivos para fusionar a mano,<br/>archivos viejos en castellano"]
    C --> D{"¿Aplicar?"}
    D -->|"no"| E["No cambia nada"]
    D -->|"sí"| F["Proyecto en development o en una rama,<br/>sin cambios sin guardar"]
    F --> G["sync-from-template.sh ../proyecto --apply"]
    G --> H["Archivos de la plantilla sustituidos,<br/>.claude/TEMPLATE_VERSION anotado"]
    H --> I["Fusiona settings.json, ci.yml, AGENTS.md…<br/>a mano, con --diff"]
    I --> J["./scripts/setup-repo.sh en el proyecto,<br/>con las mismas variables,<br/>para actualizar las reglas"]
    J --> K["Pruebas, entrada de bitácora, commit, PR"]
```

### 13. Actualizar una skill de terceros

```mermaid
flowchart TD
    A["Nueva versión en el origen"] --> B["git clone --depth 1 del repo de origen"]
    B --> C["Sustituye la carpeta entera de la skill;<br/>nunca se edita a mano"]
    C --> D["Revisa el diff:<br/>scripts nuevos, llamadas de red, instrucciones"]
    D --> E{"¿Algo sospechoso?"}
    E -->|"sí"| F["Descarta la actualización"]
    E -->|"no"| G["Actualiza commit y fecha en UPSTREAM.md"]
    G --> H["Entrada de bitácora, PR"]
```

## Estructura, archivo por archivo

### Raíz

| Archivo | Para qué sirve |
|---|---|
| `README.md` | En la plantilla, su portada: banner, badges, diagramas y resumen de la seguridad. En un proyecto nuevo, `setup-repo.sh` la sustituye por `docs/templates/README.project.md`, el esqueleto del README del proyecto, con su nombre ya puesto |
| `README.es.md` | Esta guía |
| `AGENTS.md` | **Las normas para cualquier agente de IA**: cómo se organiza el trabajo, autoría, ramas, seguridad, skills e idioma. Vale para Claude, Copilot, Cursor… |
| `CLAUDE.md` | Lo que lee Claude Code al empezar. Importa `AGENTS.md` y añade lo propio de Claude: comandos, subagentes, skills y vista previa |
| `CHANGELOG.md` | Cambios **visibles** del proyecto, una línea cada uno, formato *Keep a Changelog*. Solo en modo completo y se escribe al cerrar cada fase, así no repite la bitácora |
| `SECURITY.md` | Política para informar de vulnerabilidades (aviso privado en GitHub, no issues públicas) |
| `.gitignore` | Lo que nunca se sube: `.env`, claves, dependencias, builds |

### `docs/`: la memoria del proyecto

| Archivo | Para qué sirve |
|---|---|
| `VISION.md` | Qué es el proyecto, para quién y, sobre todo, **qué NO hacer**. Es el filtro para decidir qué entra. Se escribe antes de la primera línea de código |
| `STATE.md` | **Estado actual** en 150 líneas como máximo: etapa, fase en curso, lo último hecho, lo siguiente, bloqueos y riesgos. Lo primero que lee Claude en cada sesión |
| `ROADMAP.md` | Etapas `S0…S3` con un **criterio de salida** comprobable, y dentro de cada una las fases `P01, P02…` (numeración única, no se reinicia) |
| `phases/` | Una ficha por fase (`P01-titulo.md`) con objetivo, alcance (*In* / *Out*), criterios de aceptación, plan, **tus aprobaciones con su fecha** y, al cerrar, el resultado. `_template.md` es la plantilla y `README.md` el índice |
| `decisions/` | Decisiones de arquitectura o producto (ADR) numeradas `0001, 0002…`. Una vez aceptadas no se editan: si cambias de idea, se crea otra que la sustituye. La `0001` explica por qué se trabaja así |
| `ARCHITECTURE.md` | Piezas del sistema, flujo de datos, fuentes externas y convenciones del código |
| `WORKFLOWS.md` | Todos los flujos de trabajo dibujados con Mermaid, en inglés (los mismos que hay en esta guía) |
| `templates/README.project.md` | El README con el que empieza cada proyecto. Solo existe en la plantilla: `setup-repo.sh` lo mueve a la raíz |
| `THREAT_MODEL.md` | **Modelo de amenazas**: qué se protege (cuentas, datos personales, dinero…), quién podría atacar, por dónde entran los datos y qué lo impide. Se rellena **antes del primer código** que maneje entradas, cuentas, datos personales, dinero o red, en los dos modos; cada fase indica su *impacto de seguridad* y `security-reviewer` comprueba cada cambio contra él |
| `RISKS.md` | Registro de riesgos: `OPEN → MITIGATED → CLOSED`. Para publicar no debe quedar ningún riesgo alto abierto |
| `SETUP.md` | Cómo arrancar, probar y **verificar** el proyecto en local. Incluye la lista de comprobación del stack de la fase P03. Claude usa su sección *Verify* antes de dar algo por terminado |
| `WORKLOG.md` | **Bitácora**: el contexto de cada cambio (qué, por qué, qué se descartó, commits, cómo se probó, qué queda pendiente). La mantiene la skill `record-changes`; las entradas nuevas van arriba |
| `DEFINITION_OF_DONE.md` | Qué tiene que cumplir un cambio para darlo por **hecho**: código, pruebas, seguridad, documentación e integración, más bloques según el tipo de proyecto (web/móvil, API, CLI). Las secciones 1 a 6 se comprueban antes de la PR; la 7 (lo desplegado funciona, issue cerrada, `development` al día) es tuya después de fusionar |
| `.github/pull_request_template.md` | La plantilla de cada PR: qué cambia, por qué, cómo se probó, los veredictos de los tres revisores, el impacto de seguridad y la DoD marcada. `/prepare-pr` la rellena |
| `SECURITY_GUIDE.md` | Las capas de seguridad de la plantilla y la lista de lo que tienes que hacer tú una vez: 2FA, tokens, firmar commits, FileVault… Incluye el bloque para tu `~/.claude/settings.json`, que aplica la misma protección a **todos** tus proyectos, también a los que no salen de esta plantilla |

### `.claude/`: configuración de Claude Code

| Archivo | Para qué sirve |
|---|---|
| `settings.json` | Quita la firma de IA de commits y PRs. Define permisos: **deny** (prohibido: leer `.env`, push a `main`, `rm -rf`, fusionar PRs…), **ask** (pregunta antes: `git push`, `curl`, instalar paquetes…) y **allow** (sin preguntar: `git status`, `git diff`, commits…). Activa el hook. Incluye un **sandbox** que impone el propio sistema operativo: los comandos de Claude, Docker incluido, solo pueden escribir dentro del proyecto y **nunca** en `.claude/`, `.githooks/`, `.github/` ni los scripts de control; solo se conectan a GitHub y a los registros de paquetes, y no pueden leer `~/.ssh`, `~/.aws`, `~/.docker`, el token de `gh` ni el Llavero |
| `hooks/guard.sh` | **El guardián.** Se ejecuta antes de cada acción de Claude y bloquea lo peligroso: push a `main` o forzado, borrar historial, leer secretos, escribir tokens en archivos, ejecutar scripts descargados, cambiar la autoría, firmas de IA, tocar su propia configuración… Si algo se bloquea, Claude tiene que explicártelo en vez de buscar otro camino |
| `commands/` | Los comandos `/status`, `/new-phase`, `/close-phase`, `/decision`, `/challenge` y `/prepare-pr` explicados arriba |
| `agents/` | Tres **subagentes revisores** de solo lectura que se lanzan antes de una PR y el `challenger` de las segundas opiniones (ver abajo) |
| `skills/` | Las 6 skills (ver abajo). `UPSTREAM.md` dice de dónde sale cada una, en qué commit está fijada y cómo actualizarla |
| `launch.json` | Servidor local para la vista previa de Claude Code. Vacío hasta la fase P03. Es el **único archivo de `.claude/` que Claude puede editar**; el resto (permisos, hook, comandos, subagentes, skills) solo lo cambias tú |

#### Subagentes revisores

| Subagente | Qué revisa | Veredicto |
|---|---|---|
| `security-reviewer` | Secretos, inyecciones (SQL, shell, rutas, HTML), datos externos sin validar, autenticación, permisos de los workflows y dependencias nuevas | Hallazgos por gravedad: Critical, High, Medium, Low |
| `dod-reviewer` | Que se cumpla la Definition of Done: commits bien escritos y sin firmas de IA, bitácora, README y CHANGELOG al día | **READY FOR PR** o **MISSING** |
| `architecture-reviewer` | Que el cambio respete la visión (*What NOT to do*), las decisiones aceptadas, la arquitectura y el alcance de la fase | **CONSISTENT** o **REVIEW** |
| `challenger` | No revisa la PR: da la **segunda opinión** de `/challenge` y `/decision`. Recibe solo un resumen de la propuesta, nunca el razonamiento, y la ataca desde un punto de vista. Mínimo 3 objeciones reales (sin inventarlas), cada una con gravedad, alternativa y qué le haría cambiar de idea | **GO**, **GO WITH CHANGES** o **RETHINK** |

### `.githooks/`, `.github/` y `scripts/`

| Archivo | Para qué sirve |
|---|---|
| `.github/assets/banner.svg` | El banner de la portada de la plantilla. `setup-repo.sh` lo borra en los proyectos nuevos |
| `.githooks/commit-msg` | Hook de git que vale para cualquier herramienta o persona: quita del mensaje del commit los `Co-Authored-By` y las firmas de IA, y **rechaza el commit si el autor no eres tú** |
| `.githooks/pre-commit` (y `pre-merge-commit`, `pre-applypatch`, que lo reutilizan para fusiones automáticas y parches) | Antes de que exista cada commit: **rechaza cualquier commit que toque los archivos protegidos** (configuración de Claude, hooks, CI, scripts de control), se haya preparado como se haya preparado; solo tú los commiteas, con `GUARDRAILS_OWNER_CHANGE=1`, que el guardián prohíbe a Claude. Y pasa Gitleaks: si encuentra un secreto, o si Gitleaks **no está instalado**, rechaza el commit |
| `.githooks/pre-push` | Antes de cada push, lo escriba quien lo escriba: **rechaza cualquier push a `main` o `master` y cualquier push forzado** (que haría perder commits en el remoto). Es la red que no depende de cómo se escribió el comando |
| `.github/dependabot.yml` | Dependabot actualiza cada semana las GitHub Actions (van fijadas a un commit, así que si no nadie las actualiza) las imágenes de Semgrep y OSV-Scanner y la del contenedor de desarrollo, siempre con una semana de espera. En P03 se añade el ecosistema del stack |
| `.github/CODEOWNERS` | Quién tiene que aprobar los cambios: tú, en todo y en las protecciones en particular. GitHub solo lo exige si el agente tiene cuenta propia (`AGENT_BOT`): entonces cada PR que abre necesita tu aprobación y no puede aprobarla él (fusionarla sí, una vez que la apruebas: tu aprobación es la barrera) |
| `.github/workflows/devcontainer.yml` | Construye el devcontainer en cada PR que lo cambie, para que un pin roto se vea antes de usarlo |
| `.devcontainer/` | Opcional, recomendado en modo completo: Claude Code dentro de un contenedor que solo ve el proyecto (ni tu carpeta personal, ni las claves SSH, ni el Llavero). Imagen fijada por digest, Gitleaks con checksum y Claude Code en una versión de hace al menos una semana |
| `.scanners/` | Un `Dockerfile` por escáner con la imagen fijada por versión y digest. No se construye: la CI lee la línea `FROM` y Dependabot la actualiza como cualquier dependencia |
| `.github/workflows/ci.yml` | La CI en GitHub, con seis comprobaciones obligatorias para fusionar en `main`: **Secrets** (Gitleaks), **Authorship** (autor correcto y sin firmas de IA), **Hook** (shellcheck y pruebas), **Records** (bitácora y tamaño de `STATE`), **SAST** (Semgrep busca inyecciones, criptografía débil, `debug` activado, configuraciones inseguras… en cualquier lenguaje) y **Dependencies** (OSV-Scanner falla si una dependencia tiene una vulnerabilidad conocida). En la fase P03 se añade el job del stack |
| `scripts/setup-repo.sh` | Se ejecuta una vez al crear el repo: autoría local, hook de git, rama `development`, rulesets que protegen `main` (PR obligatoria, los seis checks de GitHub Actions, sin force-push), `development` (sin force-push ni borrado) y las etiquetas (solo los administradores), alertas de Dependabot, avisos privados de vulnerabilidades, escaneo de secretos y etiquetas de issues. Antes de cambiar nada comprueba que tienes permisos de administrador y que la rama por defecto es `main`. En la primera ejecución deja el `CHANGELOG` y la bitácora vacíos (los que trae son los de la propia plantilla), sustituye el README por el esqueleto del proyecto (`docs/templates/README.project.md`) y anota la fecha en `.claude/TEMPLATE_VERSION`. Con `AGENT_BOT=<usuario>` da a esa cuenta permiso de escritura (nada más) y hace que cada PR a `main` necesite tu aprobación como propietario del código; `CODEOWNERS` pasa a nombrar al dueño del repo. Se puede ejecutar más de una vez sin duplicar nada, con las mismas variables: sin `AGENT_BOT` se niega a quitar tu revisión (salvo `REMOVE_OWNER_REVIEW=1`). Si algo de lo que pediste no se pudo configurar, termina con error y lo lista. Lo que cambia toca archivos protegidos, así que lo commiteas tú: `git add -A && GUARDRAILS_OWNER_CHANGE=1 git commit -m "chore: set up from the template"`. **Si el repo es privado y tu cuenta es gratuita**, avisa de que GitHub no permite proteger `main` ni escanear secretos, y termina con error para que no lo des por protegido |
| `scripts/test-guard.sh` | Las pruebas del guardián: lo que debe bloquear (incluidos los trucos que encontró Codex) y lo que debe permitir. `test-githooks.sh` prueba los hooks de git y `test-check-records.sh` la comprobación de la bitácora |
| `scripts/check-records.sh` | La comprobación de **Records**: que exista `STATE.md` y no pase de 150 líneas, y que cada PR con cambios que no sean solo documentación añada una **entrada de bitácora de verdad** (título con fecha, *Why* y *Tested* rellenos). Los `.md` de `.claude/` cuentan como código, porque cambian cómo trabaja el agente. Solo se libran las PR que GitHub dice que abrió Dependabot. Si no puede leer el historial, falla. `test-check-records.sh` tiene sus pruebas |
| `scripts/sync-from-template.sh` | Lleva las mejoras de la plantilla a un **proyecto que ya existe**. Se ejecuta desde la plantilla: `scripts/sync-from-template.sh ../faro`. Sin opciones solo informa; `--diff` enseña los cambios y `--apply` sustituye los archivos que son de la plantilla (hook, comandos, subagentes, scripts, hooks de git). Lo que cada proyecto adapta (permisos, CI, `AGENTS.md`…) nunca lo copia: te dice qué difiere para que lo fusiones tú. Detecta los archivos con nombre en castellano de la versión vieja. No aplica en `main`, ni con cambios sin guardar en el proyecto o **en la plantilla** (solo copia lo que ya tiene commit), ni si hay un enlace simbólico en el camino (no puede escribir fuera del proyecto). Los archivos que copia son protecciones: el commit lo haces tú con `GUARDRAILS_OWNER_CHANGE=1` |
| `scripts/test-scripts.sh` | Prueba `setup-repo.sh` y `sync-from-template.sh` de verdad, en copias de la plantilla y con un `gh` falso que apunta las llamadas a GitHub en vez de hacerlas: proyecto nuevo, segunda ejecución, modo ligero, repo privado gratuito, la propia plantilla, y que el `sync` no aplique en `main`, con cambios sin guardar o a través de enlaces simbólicos |

## Las skills

Una skill es una carpeta con un `SKILL.md` que explica a Claude cómo hacer algo concreto. Claude ve la descripción de todas y **carga solo la que encaja** con lo que le pides; no hace falta invocarlas a mano. Todas están en inglés y fijadas a un commit del original (ver `.claude/skills/UPSTREAM.md`).

### Propia

| Skill | Para qué sirve |
|---|---|
| `record-changes` | Tras cada cambio y antes del commit, anota en `docs/WORKLOG.md` el porqué, lo descartado, los commits, cómo se probó y lo pendiente. Al cerrar una fase en modo completo, escribe las líneas del `CHANGELOG`. Claude la usa siempre, sin que se la pidas |

### Seguridad

| Skill | Origen | Para qué sirve |
|---|---|---|
| `security-audit` | Cloudflare | Revisión de seguridad de código, APIs, servicios y librerías. En **modo guía** responde preguntas o revisa un cambio concreto. La **auditoría completa** (reconocimiento, búsqueda por clases de ataque, validación adversarial e informe) solo se lanza si la pides explícitamente, y guarda los resultados fuera del repo |
| `repo-security-posture` | superagent-ai | Revisa la configuración del repo en GitHub: protección de ramas, CODEOWNERS, Actions, publicación, colaboradores y dependencias. Solo lee; te da una lista de tareas ordenada por gravedad |

### Desarrollo

| Skill | Para qué sirve |
|---|---|
| `mcp-builder` | Guía para crear **servidores MCP** de calidad (Python con FastMCP o TypeScript), que conectan a Claude con APIs o servicios externos, incluidas sus evaluaciones |
| `webapp-testing` | Probar aplicaciones web locales con Playwright: verificar la interfaz, depurar, sacar capturas y leer los logs del navegador |
| `frontend-design` | Criterio de diseño para interfaces nuevas o rediseños: dirección estética y tipografía, sin que parezca una plantilla genérica |

### Las que no van y por qué

El repositorio de Anthropic trae 19 skills; aquí van 3. Las demás se han quitado a propósito, y se pueden recuperar de [anthropics/skills](https://github.com/anthropics/skills) si un proyecto las necesita:
- `docx`, `xlsx`, `pptx`, `pdf` y `skill-creator`: ya vienen con tu cuenta de Claude (`anthropic-skills:`).
- `claude-api`: viene dentro de Claude Code y se actualiza con él. Una copia fija aquí se quedaría vieja y, dentro del proyecto, tendría prioridad.
- `doc-coauthoring`: se solapa con el método de la plantilla para escribir la visión, las fichas de fase y las decisiones.
- `canvas-design`, `algorithmic-art`, `theme-factory`, `slack-gif-creator` y `web-artifacts-builder`: son de diseño gráfico o de artifacts de claude.ai, no de proyectos de software.
- `brand-guidelines`, `internal-comms`, `academy-guide` y `discernment-nudge`: pensadas para uso interno de Anthropic o sus cursos.

### Avisos sobre las skills

- `webapp-testing` y `mcp-builder` **traen scripts** que se ejecutan al usarlas. Revísalos la primera vez y no los uses con archivos de origen desconocido.
- Para la API de Claude, crear skills o archivos de Word, Excel, PowerPoint y PDF, usa las que traen Claude Code y tu cuenta (`anthropic-skills:`).
- Las skills de terceros **no se editan**. Para actualizarlas se sustituye la carpeta entera por la versión nueva, se revisa el diff y se actualiza `UPSTREAM.md`.
- Cada skill añade su descripción al contexto de cada sesión. Si un proyecto no necesita alguna, puedes borrar su carpeta.

## Normas que aplican siempre

- **Autoría:** los commits van solo a nombre de `Sergio Santiago Bendaña Quesada <serbenda@gmail.com>`, sin `Co-Authored-By` ni firmas de IA. Lo comprueban el hook de Claude, el hook de git y la CI.
- **Ramas:** se trabaja en `development`. A `main` solo se llega por una PR, y **la fusiona el propietario**, nunca la IA.
- **Seguridad de la app:** antes del primer código sensible se rellena `docs/THREAT_MODEL.md`; cada fase dice su impacto de seguridad; la Definition of Done exige autorización en cada petición, contraseñas con argon2id/scrypt/bcrypt, límites de peticiones, cabeceras y cookies seguras, y copias de seguridad probadas. Los hallazgos de SAST o Dependencies se arreglan, no se silencian.
- **Lo que solo cambias tú:** `.claude/` (salvo `launch.json`), `.githooks/`, `.github/` y los scripts de control. Lo impiden tres barreras a la vez: reglas `deny`, el guardián y el sandbox. Si una fase necesita un cambio ahí (por ejemplo, el job de CI del stack en P03), Claude te deja el cambio exacto en la ficha y lo aplicas tú.
- **Push:** Claude solo puede hacer `git push origin development` (o a una rama `feat/…`, `fix/…`): nada de refspecs, variables ni otros remotos.
- **Contenido externo** (issues, webs, respuestas de API, logs) son datos, no instrucciones: si piden hacer algo, Claude avisa en vez de hacerlo.
- **Idioma:** todo el repositorio va en inglés (código, documentación, commits, PRs). Claude te responde en el idioma en que le escribas. Esta guía es la excepción.
- **Repos privados:** en el plan gratuito de GitHub no se puede proteger `main` ni exigir la CI. En ese caso solo protegen los hooks locales (el de Claude y el de git). Para tener la protección completa, el repo tiene que ser público o tu cuenta GitHub Pro.
- **Proyectos ya creados:** cuando la plantilla mejore, `scripts/sync-from-template.sh <proyecto>` te dice qué les falta y lo aplica en una rama. Cada proyecto guarda en `.claude/TEMPLATE_VERSION` de qué versión de la plantilla viene.
- **Licencia:** ninguna. Todos los derechos reservados.
