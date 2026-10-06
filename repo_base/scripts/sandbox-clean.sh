#!/bin/sh
# Limpia unidades completas de trabajo; nunca acepta una ruta como argumento.
set -u

refuse() { printf 'ERROR  %s\n' "$*" >&2; exit 2; }

case "/$0/" in */../*) refuse 'no se admiten componentes ..' ;; esac
root=$(CDPATH='' cd -P "$(dirname "$0")/.." && pwd -P) || exit 2
[ "$(pwd -P)" = "$root" ] || refuse 'ejecute desde la raíz de la plantilla'
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || refuse 'no es un repositorio Git'

yes=0
days=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes) yes=1; shift ;;
    --older-than)
      [ "$#" -ge 2 ] || refuse 'falta DIAS para --older-than'
      days=$2
      case "$days" in '' | *[!0-9]*) refuse 'DIAS debe ser un entero no negativo' ;; esac
      [ "${#days}" -le 6 ] || refuse 'DIAS debe tener como máximo 6 dígitos'
      days=$(printf '%s\n' "$days" | sed 's/^0*//')
      days=${days:-0}
      shift 2
      ;;
    *) refuse "argumento no admitido: $1" ;;
  esac
done

safe_tree() {
  [ ! -L sandbox ] || refuse 'el directorio de trabajo es un enlace simbólico'
  [ -d sandbox ] || refuse 'falta el directorio de trabajo'
  resolved=$(CDPATH='' cd -P sandbox && pwd -P) || exit 2
  [ "$resolved" = "$root/sandbox" ] || refuse 'ruta resuelta fuera del área permitida'
  links=$(command -p find sandbox -type l -print) || refuse 'no se pudo inspeccionar el área'
  [ -z "$links" ] || refuse 'se encontraron enlaces simbólicos; no se borra nada'
}

safe_tree
work=$(mktemp -d) || exit 2
trap 'rm -rf "$work"' 0
trap 'exit 2' HUP INT TERM

newline='
'
for item in sandbox/* sandbox/.[!.]* sandbox/..?*; do
  [ -e "$item" ] || continue
  case "$item" in *"$newline"*) refuse 'no se admiten nombres de unidad con saltos de línea' ;; esac
  case "$item" in sandbox/README.md | sandbox/.gitkeep) continue ;; esac
  if [ -n "$days" ]; then
    recent=$(command -p find "$item" ! -mtime "+$days" -print) || refuse "no se pudo inspeccionar $item"
    [ -z "$recent" ] || continue
  fi
  printf '%s\n' "$item" >>"$work/targets"
done

[ -f "$work/targets" ] || exit 0
while IFS= read -r item; do
  case "$item" in
    sandbox/README.md | sandbox/.gitkeep | */../*) refuse "ruta protegida o no válida: $item" ;;
    sandbox/*) ;;
    *) refuse "ruta fuera del área permitida: $item" ;;
  esac
  if [ "$yes" -eq 1 ]; then
    safe_tree
    rm -rf "$item" || refuse "no se pudo borrar $item"
    printf 'BORRADO %s\n' "$item"
  else
    printf 'BORRAR  %s\n' "$item"
  fi
done <"$work/targets"
