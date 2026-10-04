#!/bin/sh
# Invariante: los enlaces Markdown internos apuntan a archivos o carpetas existentes
# y usan rutas relativas. No valida URLs externas (lychee) ni anclas "#..." (markdownlint).
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

# Emite "línea<TAB>destino" por cada enlace en línea o de referencia fuera de bloques de código.
# shellcheck disable=SC2016 # el programa awk va entre comillas simples a propósito
extract='
function emit(t) {
  sub(/^[ \t]+/, "", t)
  if (t ~ /^</) { sub(/^</, "", t); sub(/>.*$/, "", t) } else sub(/[ \t].*$/, "", t)
  if (t != "") printf "%d\t%s\n", NR, t
}
BEGIN { fence = "" }
{
  if (fence == "" && match($0, /^[ ]*(```|~~~)/)) { fence = substr($0, RSTART + RLENGTH - 3, 3); next }
  if (fence != "") { if ($0 ~ "^[ ]*" fence) fence = ""; next }
  line = $0
  gsub(/`[^`]*`/, "", line)
  if (match(line, /^[ ]*\[[^]]+\]:[ \t]*/)) { emit(substr(line, RLENGTH + 1)); next }
  while (match(line, /\]\([^)]*\)/)) {
    emit(substr(line, RSTART + 2, RLENGTH - 3))
    line = substr(line, RSTART + RLENGTH)
  }
}
'

files=$(list_md)
tab=$(printf '\t')
while IFS= read -r f; do
  [ -n "$f" ] || continue
  dir=$(dirname "$f")
  links=$(awk "$extract" "$f")
  while IFS="$tab" read -r ln target; do
    [ -n "$target" ] || continue
    case "$target" in
      /* | [A-Za-z]:[/\\]* | file:*)
        err "$f:$ln: ruta absoluta prohibida: $target"
        continue
        ;;
      \#* | [A-Za-z]*:*) continue ;; # ancla local o URL con esquema (http:, mailto:, ...)
    esac
    rel=${target%%#*}
    rel=${rel%%\?*}
    rel=$(printf '%s' "$rel" | sed 's/%20/ /g')
    [ -e "$dir/$rel" ] || err "$f:$ln: enlace roto: $target"
  done <<EOF
$links
EOF
done <<EOF
$files
EOF

finish
