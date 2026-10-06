#!/bin/sh
# Punto de entrada único de la autoevaluación del repositorio.
#
# Uso:        sh scripts/check.sh [RUTA ...]
#             Las rutas explícitas añaden archivos ignorados antes de su promoción.
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
CHECK_PATHS=
root=$(pwd -P)
for path do
  case "/$path/" in
    */../* | //*) printf 'ERROR  ruta relativa sin .. requerida: %s\n' "$path" >&2; exit 2 ;;
  esac
  [ -e "$path" ] || { printf 'ERROR  no existe: %s\n' "$path" >&2; exit 2; }
  if [ -d "$path" ]; then
    resolved=$(CDPATH='' cd -P "$path" && pwd -P) || exit 2
  else
    resolved=$(CDPATH='' cd -P "$(dirname "$path")" && pwd -P) || exit 2
    [ ! -L "$path" ] || { printf 'ERROR  enlace simbólico: %s\n' "$path" >&2; exit 2; }
  fi
  case "$resolved/" in "$root/"*) ;; *) printf 'ERROR  ruta fuera del repo\n' >&2; exit 2 ;; esac
  selected=$(command -p find "./$path" -type f -print | sed 's|^\./||') || exit 2
  CHECK_PATHS="${CHECK_PATHS}${CHECK_PATHS:+
}$selected"
done
export CHECK_PATHS
work=$(mktemp -d) || exit 2
trap 'rm -rf "$work"' 0
trap 'exit 2' HUP INT TERM

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
  files=$(list_files | awk '/\.sh$/ || /^\.githooks\//')
  [ -n "$files" ] || return 0
  printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 shellcheck --shell=sh -x
}

lint_markdown() {
  rc=0
  files=$(list_md | awk -v explicit="$CHECK_PATHS" '
    BEGIN { n = split(explicit, paths, "\n"); for (i = 1; i <= n; i++) selected[paths[i]] = 1 }
    !($0 in selected)')
  if [ -n "$files" ]; then
    printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 markdownlint-cli2 --no-globs || rc=1
  fi
  # stdin evita exclusiones de rutas sin duplicar reglas ni cargar config del borrador.
  while IFS= read -r f; do
    case "$f" in *.md) ;; *) continue ;; esac
    if ! markdownlint-cli2 --no-globs - <"$f" >"$work/markdown.log" 2>&1; then rc=1; fi
    sed "s|stdin:|$f:|g" "$work/markdown.log"
  done <<EOF
$CHECK_PATHS
EOF
  return "$rc"
}

# La selección es común a todos los linters; YAML y frontmatter usan las mismas reglas.
lint_yaml() {
  rc=0
  config=$(sed '/^ignore-from-file:/d' .yamllint.yaml)
  files=$(list_files | awk '/\.ya?ml$/')
  if [ -n "$files" ]; then
    printf '%s\n' "$files" | tr '\n' '\0' | xargs -0 yamllint --strict -d "$config" || rc=1
  fi
  files=$(list_md)
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    fm=$(frontmatter "$f")
    [ -n "$fm" ] || continue
    if ! printf '%s\n' "$fm" | yamllint --strict -d "$config" -f parsable - >"$work/yaml.log"; then rc=1; fi
    sed "s|^stdin|$f|" "$work/yaml.log"
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
if [ "$(git config --get core.hooksPath 2>/dev/null)" != .githooks ] || [ ! -x .githooks/pre-commit ]; then
  warn 'hook pre-commit inactivo; en el repo instanciado: chmod +x .githooks/pre-commit && git config core.hooksPath .githooks'
fi

run_check "Archivos obligatorios" required-files.sh
run_check "Cabeceras y secciones" headers.sh
run_check "Numeración de ADRs" adr-numbering.sh
run_check "Enlaces internos" internal-links.sh
run_check "Memoria del repositorio" memory.sh
run_check "Configuración externa" external-config.sh
run_check "Aislamiento del trabajo efímero" sandbox.sh

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
