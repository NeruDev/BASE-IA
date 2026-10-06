#!/bin/sh
# Utilidades compartidas; los llamadores ya están en la raíz de la plantilla.
errors=0

err() {
  printf 'ERROR  %s\n' "$*" >&2
  errors=$((errors + 1))
}

warn() { printf 'AVISO  %s\n' "$*" >&2; }
info() { printf 'INFO   %s\n' "$*"; }
finish() { [ "$errors" -eq 0 ]; exit "$?"; }

# Git devuelve rutas relativas también cuando la plantilla está en un repo contenedor.
# CHECK_PATHS añade únicamente las rutas solicitadas explícitamente por check.sh.
list_files() {
  {
    git -c core.quotepath=false ls-files --cached --others --exclude-standard -- . |
      awk '$0 !~ /^sandbox\//'
    printf '%s\n' "${CHECK_PATHS:-}"
  } | awk 'NF && !seen[$0]++'
}

list_md() { list_files | awk '/\.md$/'; }
