#!/bin/sh
# Invariante: los ADR de docs/adr/ se nombran NNNN-titulo.md, se numeran sin huecos
# ni duplicados desde 0001 y todos aparecen enlazados en docs/adr/README.md.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

dir=docs/adr
index=$dir/README.md
expected=1
found=0

for path in "$dir"/*; do
  [ -e "$path" ] || continue
  f=${path##*/}
  [ "$f" = README.md ] && continue
  if ! printf '%s\n' "$f" | grep -Eq '^[0-9]{4}-[a-z0-9]+(-[a-z0-9]+)*\.md$'; then
    err "$path: nombre no válido (se espera NNNN-titulo-en-kebab-case.md)"
    continue
  fi
  found=$((found + 1))
  num=$(printf '%s' "$f" | cut -c1-4 | sed 's/^0*//')
  num=${num:-0}
  if [ "$num" -lt "$expected" ]; then
    err "$path: número duplicado ($(printf '%04d' "$num"))"
  elif [ "$num" -gt "$expected" ]; then
    err "$path: hueco en la numeración (se esperaba $(printf '%04d' "$expected"))"
    expected=$((num + 1))
  else
    expected=$((expected + 1))
  fi
  if [ -f "$index" ] && ! grep -Fq "]($f)" "$index"; then
    err "$path: no está enlazado en el índice $index"
  fi
done

[ "$found" -gt 0 ] || err "$dir: no hay ningún ADR (se espera al menos 0001)"

finish
