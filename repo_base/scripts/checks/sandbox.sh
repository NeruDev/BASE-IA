#!/bin/sh
# Invariante de aislamiento: índice Git, reglas de exclusión y dependencias de rutas.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

for rule in '/sandbox/*' '!/sandbox/README.md' '!/sandbox/.gitkeep'; do
  grep -Fxq "$rule" .gitignore || err ".gitignore: falta la regla $rule"
done
for path in sandbox/probe sandbox/task/probe; do
  git check-ignore --no-index -q -- "$path" || err "no está ignorado: $path"
done
for path in sandbox/README.md sandbox/.gitkeep; do
  [ -f "$path" ] || err "falta el archivo de control $path"
  if git check-ignore --no-index -q -- "$path"; then err "archivo de control ignorado: $path"; fi
done
if [ -f sandbox/README.md ] && [ "$(wc -l <sandbox/README.md)" -gt 20 ]; then
  err 'sandbox/README.md supera 20 líneas'
fi

tracked=$(git -c core.quotepath=false ls-files --cached -- .) || exit 2
prefix=$(git rev-parse --show-prefix) || exit 2
pattern='(^|[^[:alnum:]_-])sandbox([/\\]|[^[:alnum:]_.-]|$)'
while IFS= read -r path; do
  [ -n "$path" ] || continue
  case "$path" in sandbox/README.md | sandbox/.gitkeep) continue ;; esac
  lower=$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')
  case "$lower" in
    sandbox/*) err "archivo prohibido en el índice (incluso git add -f): $path"; continue ;;
  esac
  # Lista técnica cerrada (ADR-0005). Markdown solo puede describir el protocolo.
  case "$path" in
    .gitignore | AGENTS.md | scripts/check.sh | scripts/lib/common.sh | scripts/checks/sandbox.sh | scripts/sandbox-clean.sh | tests/sandbox.sh | .vscode/tasks.json | .vscode/settings.json | .markdownlint-cli2.jsonc) continue ;;
    *.md) continue ;;
  esac
  if [ -f "$path" ] && grep -Eiq "$pattern" "$path"; then
    err "$path: dependencia o referencia operativa al área efímera (copia de trabajo)"
  fi
  if git grep --cached -I -i -q -E -e "$pattern" -- "$path"; then
    err "$path: dependencia o referencia operativa al área efímera (índice)"
  fi
done <<EOF
$tracked
EOF

# La evidencia de memoria debe sobrevivir a la limpieza; se revisan ambas copias.
path=docs/memory/entries.md
if [ -f "$path" ] && grep -Eiq 'evidencia:.*sandbox([/\\]|%2[fF])' "$path"; then
  err "$path: evidencia efímera en la copia de trabajo"
fi
if git show ":$prefix$path" 2>/dev/null | grep -Eiq 'evidencia:.*sandbox([/\\]|%2[fF])'; then
  err "$path: evidencia efímera en el índice"
fi

if sh scripts/sandbox-clean.sh >/dev/null; then
  old=$(command -p find sandbox ! -path sandbox ! -path sandbox/README.md ! -path sandbox/.gitkeep -mtime +7 -print) || exit 2
  [ -z "$old" ] || warn "trabajo con más de 7 días completos; revisar y limpiar:
$old"
else
  err 'área efímera insegura o ilegible; el limpiador rechazó su inspección'
fi
size=$(du -sk sandbox 2>/dev/null | awk '{ print $1 * 1024 }')
if [ -n "$size" ] && awk -v size="$size" 'BEGIN { exit !(size > 20000000) }'; then
  warn 'el área efímera supera 20 MB (20 000 000 bytes de espacio ocupado)'
fi
finish
