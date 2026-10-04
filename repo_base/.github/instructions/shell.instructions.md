---
description: "Reglas para scripts de shell y hooks de git: POSIX sh, shellcheck y comportamiento determinista."
applyTo: "scripts/**,.githooks/**"
---

# Reglas para scripts de shell

- POSIX `sh` con `#!/bin/sh`, sin bashismos (`[[ ]]`, arrays, `local`, `source`, `pipefail`).
- Cada chequeo se sitúa en la raíz del repo con `cd "$(dirname "$0")/../.."` y usa rutas relativas con `/`.
- Usar `set -u` y comprobar los errores explícitamente. Códigos de salida: 0 éxito, 1 fallo de chequeo, 2 error de entorno.
- Informar con `err`, `warn` e `info` de `scripts/lib/common.sh`, indicando el archivo y la causa.
- Deterministas e idempotentes: sin red (salvo lychee), sin modificar archivos y sin depender de la hora.
- Un script en `scripts/checks/` por invariante, sin repetir lo que ya valida un linter (ver [ARCHITECTURE.md](../../ARCHITECTURE.md)).
- No usar `find` ni `sort`: al lanzar `sh` desde PowerShell o VS Code pueden resolverse a `find.exe` y `sort.exe` de Windows. Usar `list_files` y `awk`.
- Detectar los linters opcionales con `command -v` y, si faltan, degradar con un aviso.
- Pasar `shellcheck -x`; cada `# shellcheck disable=` lleva su justificación en la misma línea.
