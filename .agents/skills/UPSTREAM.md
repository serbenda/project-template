# Skills de terceros

Copias **fijadas a un commit**, revisadas antes de incorporarlas. No se editan a mano: para actualizar, se sustituye la carpeta entera por la versión nueva, se revisa el diff en una PR y se actualiza esta tabla.

| Skill | Origen | Commit | Licencia | Revisada |
|---|---|---|---|---|
| `security-audit` | [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) | `c1c8a8c1471069fb0e188eeaff69b8e8db6564a8` | MIT (ver `security-audit/LICENSE`) | 2026-11-10 |

## security-audit

Auditoría de seguridad defensiva en seis fases: reconocimiento, búsqueda, validación adversarial, salida estructurada, verificación independiente e informe.

- **Modo guía** (por defecto): preguntas o revisiones puntuales. No crea archivos.
- **Modo auditoría completa**: solo si se pide explícitamente, por ejemplo: *«haz una auditoría de seguridad completa de este repo»*.
- Los resultados se guardan **fuera del repo** (`~/security-audit-skill/<repo>/run-N`). Si alguna vez se guardan dentro, la carpeta tiene que estar en `.gitignore`.
- Para validar los hallazgos hace falta Node.js:
  `node .agents/skills/security-audit/validate-findings.cjs <findings.json>`

### Actualizar
```bash
git clone --depth 1 https://github.com/cloudflare/security-audit-skill /tmp/sas
rm -rf .agents/skills/security-audit
cp -a /tmp/sas/skills/security-audit .agents/skills/
cp /tmp/sas/LICENSE .agents/skills/security-audit/
git -C /tmp/sas rev-parse HEAD   # anota el commit en la tabla
```
