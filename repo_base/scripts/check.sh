#!/bin/sh
# Punto de entrada único de la autoevaluación del repositorio.
#
# Uso:        sh scripts/check.sh
# Variables:  CHECK_NO_NETWORK=1  omite las comprobaciones que usan red (lychee).
#             CHECK_STRICT=1      un linter no instalado cuenta como fallo, no como aviso.
# Salida:     0 si todo pasa; 1 si algún chequeo o linter falla.
#
# Reparto (sin solapamientos): scripts/checks/ valida invariantes del repo;
# los linters validan sintaxis y estilo. Detalle en ARCHITECTURE.md.
set -u
cd "$(dirname "$0")/.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

failed=0
skipped=0

section() {
  printf '\n== %s\n' "$1"
}

pass() {
  printf 'OK     %s\n' "$1"
}

fail() {
  printf 'FALLO  %s\n' "$1"
  failed=$((failed + 1))
}

# missing NOMBRE INSTALACIÓN: gestiona un linter ausente según CHECK_STRICT.
missing() {
  if [ "${CHECK_STRICT:-0}" = 1 ]; then
    fail "$1 no está instalado (instalar: $2)"
  else
    warn "$1 no está instalado; se omite. Instalar: $2"
    skipped=$((skipped + 1))
  fi
}

# run_check NOMBRE SCRIPT: ejecuta un chequeo propio de scripts/checks/.
run_check() {
  section "$1"
  if sh "scripts/checks/$2"; then pass "$1"; else fail "$1"; fi
}

# Extrae el frontmatter (desde la línea 1 "---" hasta antes del cierre) de un .md.
frontmatter() {
  awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit } { print }' "$1"
}

lint_shell() {
  list_files | grep -E '^(scripts/.*\.sh|\.githooks/.+)$' | tr '\n' '\0' | xargs -0 shellcheck -x
}

lint_markdown() {
  markdownlint-cli2
}

# yamllint revisa los archivos YAML y el frontmatter de cada .md (por stdin).
lint_yaml() {
  rc=0
  yamllint --strict . || rc=1
  files=$(list_md)
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    fm=$(frontmatter "$f")
    [ -n "$fm" ] || continue
    printf '%s\n' "$fm" | yamllint --strict -f parsable - | sed "s|^stdin|$f|" | grep . && rc=1
  done <<EOF
$files
EOF
  return "$rc"
}

lint_links() {
  list_md | tr '\n' '\0' | xargs -0 lychee --no-progress --scheme https --scheme http
}

# run_linter NOMBRE BINARIO INSTALACIÓN FUNCIÓN
run_linter() {
  section "$1"
  if ! command -v "$2" >/dev/null 2>&1; then
    missing "$2" "$3"
  elif "$4"; then
    pass "$1"
  else
    fail "$1"
  fi
}

printf 'Autoevaluación de %s\n' "$(pwd)"
if [ "$(git config --get core.hooksPath 2>/dev/null)" != .githooks ]; then
  warn "hook pre-commit inactivo; actívelo con: git config core.hooksPath .githooks"
fi

run_check "Archivos obligatorios" required-files.sh
run_check "Cabeceras y secciones" headers.sh
run_check "Numeración de ADRs" adr-numbering.sh
run_check "Enlaces internos" internal-links.sh
run_check "Memoria del repositorio" memory.sh
run_check "Configuración externa" external-config.sh

run_linter "Shell (shellcheck)" shellcheck "scoop install shellcheck" lint_shell
run_linter "Markdown (markdownlint-cli2)" markdownlint-cli2 "npm install -g markdownlint-cli2" lint_markdown
run_linter "YAML (yamllint)" yamllint "pip install yamllint" lint_yaml
if [ "${CHECK_NO_NETWORK:-0}" = 1 ]; then
  section "Enlaces externos (lychee)"
  warn "CHECK_NO_NETWORK=1; se omite la comprobación de URLs externas"
  skipped=$((skipped + 1))
else
  run_linter "Enlaces externos (lychee)" lychee "scoop install lychee" lint_links
fi

printf '\n== Resumen: %d fallo(s), %d omitido(s)\n' "$failed" "$skipped"
[ "$failed" -eq 0 ]
