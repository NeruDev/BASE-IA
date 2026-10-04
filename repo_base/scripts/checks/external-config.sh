#!/bin/sh
# Invariante: configuración de las bases teóricas externas.
# - El archivo local config/external-bases.local está ignorado por git y no versionado.
# - Si hay una ruta configurada, existe, es un directorio legible y está fuera de este repo.
# Sin configuración solo se avisa: un clon recién creado debe pasar el chequeo.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

local_file=config/external-bases.local
var=EXTERNAL_BASES_DIR

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files --error-unmatch "$local_file" >/dev/null 2>&1; then
    err "$local_file está versionado; retírelo con: git rm --cached $local_file"
  elif ! git check-ignore -q "$local_file"; then
    err ".gitignore debe ignorar $local_file"
  fi
else
  warn "no es un repositorio git; se omite la comprobación de $local_file en .gitignore"
fi

# Resolución: variable de entorno > archivo local. El archivo se lee como datos, nunca se ejecuta.
value=${EXTERNAL_BASES_DIR:-}
origin="variable de entorno $var"
if [ -z "$value" ] && [ -f "$local_file" ]; then
  value=$(sed -n "s/^[[:space:]]*${var}[[:space:]]*=[[:space:]]*//p" "$local_file" | tail -n 1 |
    sed -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/")
  origin="archivo $local_file"
fi

if [ -z "$value" ]; then
  warn "bases teóricas externas sin configurar (defina $var o copie config/external-bases.example a $local_file)"
  finish
fi

if [ ! -d "$value" ]; then
  err "$var=\"$value\" ($origin) no existe o no es un directorio"
elif [ ! -r "$value" ]; then
  err "$var=\"$value\" ($origin) no es legible"
else
  abs=$(cd "$value" && pwd -P)
  root=$(pwd -P)
  case "$abs/" in
    "$root/"*) err "$var=\"$value\" ($origin) está dentro de este repositorio; debe ser un repo externo" ;;
    *) info "bases teóricas externas: $abs ($origin)" ;;
  esac
fi

finish
