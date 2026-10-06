#!/bin/sh
# Invariante: existen y no están vacíos los archivos obligatorios del repositorio.
# Esta lista es la fuente única de archivos obligatorios.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ ! -f "$f" ]; then
    err "falta el archivo obligatorio: $f"
  elif [ ! -s "$f" ]; then
    err "archivo obligatorio vacío: $f"
  fi
done <<'EOF'
README.md
AGENTS.md
ARCHITECTURE.md
CONTRIBUTING.md
CLAUDE.md
.github/copilot-instructions.md
.github/instructions/markdown.instructions.md
.github/instructions/shell.instructions.md
docs/adr/README.md
docs/memory/README.md
docs/memory/entries.md
config/external-bases.example
.editorconfig
.gitattributes
.gitignore
.markdownlint-cli2.jsonc
.yamllint.yaml
.vscode/tasks.json
.githooks/pre-commit
EOF

finish
