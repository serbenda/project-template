# Skills de terceros

Copias **fijadas a un commit**, revisadas antes de incorporarlas. No se editan a mano: para actualizar, se sustituye la carpeta entera por la versión nueva, se revisa el diff en una PR y se actualiza esta tabla.

| Skill | Origen | Commit | Licencia | Revisada |
|---|---|---|---|---|
| `security-audit` | [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) | `c1c8a8c1471069fb0e188eeaff69b8e8db6564a8` | MIT (ver `security-audit/LICENSE`) | 2026-11-10 |
| `repo-security-posture` | [superagent-ai/skills](https://github.com/superagent-ai/skills) → `skills/repo-security-posture` | `0da315b873ed141025fa601ed6e0ebe0c878d5af` | MIT (ver `repo-security-posture/LICENSE`) | 2026-11-11 |

## security-audit

Auditoría de seguridad defensiva en seis fases: reconocimiento, búsqueda, validación adversarial, salida estructurada, verificación independiente e informe.

- **Modo guía** (por defecto): preguntas o revisiones puntuales. No crea archivos.
- **Modo auditoría completa**: solo si se pide explícitamente, por ejemplo: *«haz una auditoría de seguridad completa de este repo»*.
- Los resultados se guardan **fuera del repo** (`~/security-audit-skill/<repo>/run-N`). Si alguna vez se guardan dentro, la carpeta tiene que estar en `.gitignore`.
- Para validar los hallazgos hace falta Node.js:
  `node .claude/skills/security-audit/validate-findings.cjs <findings.json>`

## repo-security-posture

Revisa la configuración del repo en GitHub: protección de ramas, CODEOWNERS, Actions, releases, accesos y dependencias. Entrega una lista de tareas ordenadas por gravedad.

- Revisado: `scripts/collect.py` solo hace peticiones **de lectura** a `api.github.com` y `raw.githubusercontent.com`, no cambia ningún ajuste y oculta los tokens que encuentra en los archivos.
- Uso: `GITHUB_TOKEN=<token de solo lectura> python3 .claude/skills/repo-security-posture/scripts/collect.py serbenda/<repo> --output /tmp/audit.json`
- Usa el token con menos permisos posible (fine-grained, solo lectura, solo ese repo). Complementa a `scripts/setup-repo.sh`: el script aplica la protección y esta skill comprueba que sigue en pie.

## Actualizar `security-audit`
```bash
git clone --depth 1 https://github.com/cloudflare/security-audit-skill /tmp/sas
rm -rf .claude/skills/security-audit
cp -a /tmp/sas/skills/security-audit .claude/skills/
cp /tmp/sas/LICENSE .claude/skills/security-audit/
git -C /tmp/sas rev-parse HEAD   # anota el commit en la tabla
```

Para `repo-security-posture` el proceso es el mismo, copiando `skills/<nombre>` del repo de origen y su `LICENSE`.
