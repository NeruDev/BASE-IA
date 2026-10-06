#!/bin/sh
# Invariante: cabeceras de los .md (frontmatter YAML) y secciones obligatorias.
# Esquema: docs/adr/0002-frontmatter-schema.md. La sintaxis YAML la valida yamllint.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

# Tipo de documento según su ruta.
kind_of() {
  case "$1" in
    CLAUDE.md | .github/copilot-instructions.md) echo adapter ;;
    *.instructions.md) echo instructions ;;
    docs/adr/README.md) echo doc ;;
    docs/adr/*.md) echo adr ;;
    *) echo doc ;;
  esac
}

# Títulos exactos obligatorios por archivo, separados por "|".
required_sections() {
  case "$1" in
    AGENTS.md) echo '## Rol|## Contexto operativo|## Estilo de código|## Comandos de verificación|## Límites|## Bases teóricas externas|## Memoria del repositorio' ;;
    README.md) echo '## Inicio rápido|## Mapa de documentación' ;;
    ARCHITECTURE.md) echo '## Estructura de carpetas|## Autoevaluación' ;;
    docs/memory/README.md) echo '## Índice' ;;
    docs/memory/entries.md) echo '## Entradas' ;;
    docs/adr/[0-9][0-9][0-9][0-9]-*.md) echo '## Contexto y planteamiento del problema|## Opciones consideradas|## Resultado de la decisión' ;;
    *) echo '' ;;
  esac
}

# Valida un archivo. Emite "E <mensaje>" por error e "ID <id>" por cada id encontrado.
# shellcheck disable=SC2016 # el programa awk va entre comillas simples a propósito
validate='
function e(m) { print "E " m }
function unq(s) {
  if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) return substr(s, 2, length(s) - 2)
  return s
}
function inset(x, list,   n, a, i) {
  n = split(list, a, " ")
  for (i = 1; i <= n; i++) if (a[i] == x) return 1
  return 0
}
BEGIN { st = 0; closed = 0; fence = ""; nk = 0 }
NR == 1 {
  if ($0 == "---") { st = 1; next }
  st = 2
}
st == 1 {
  if ($0 == "---") { st = 2; closed = 1; next }
  if (match($0, /^[A-Za-z_][A-Za-z0-9_-]*:/)) {
    k = substr($0, 1, RLENGTH - 1)
    val = substr($0, RLENGTH + 1)
    sub(/^[ \t]+/, "", val); sub(/[ \t]+$/, "", val)
    keys[++nk] = k; v[k] = unq(val)
  } else if ($0 !~ /^[ \t]*(#.*)?$/) {
    e("frontmatter, línea " NR ": use \"clave: valor\" en una sola línea (listas en línea: [a, b])")
  }
  next
}
{
  if (fence == "" && match($0, /^[ ]*(```|~~~)/)) { fence = substr($0, RSTART + RLENGTH - 3, 3); next }
  if (fence != "") { if ($0 ~ "^[ ]*" fence) fence = ""; next }
  line = $0; sub(/[ \t]+$/, "", line); h[line] = 1
}
END {
  if (st == 1 && !closed) { e("frontmatter sin delimitador de cierre \"---\""); exit }
  if (!closed) { e("falta el frontmatter YAML (debe empezar con \"---\" en la línea 1)"); exit }

  if (kind == "instructions") {
    if (!("applyTo" in v) || v["applyTo"] == "") e("falta \"applyTo\" en el frontmatter")
    if (!("description" in v) || v["description"] == "") e("falta \"description\" en el frontmatter")
    exit
  }

  req = "id name title file_path category tags description status updated_at"
  opt = "domain author maintainers license agent_visibility tool_access_level execution_mode priority timeout_seconds dependencies parent_doc related_specs entrypoint"
  if (kind == "adr") opt = opt " decision-makers consulted informed"
  for (i = 1; i <= nk; i++) {
    k = keys[i]
    if (inset(k, "version owner created_at schema_version")) e("campo \"" k "\" retirado del esquema (ver ADR-0002)")
    else if (!inset(k, req) && !inset(k, opt)) e("campo desconocido \"" k "\"")
  }
  n = split(req, r, " ")
  for (i = 1; i <= n; i++) if (!(r[i] in v) || v[r[i]] == "") { e("falta el campo obligatorio \"" r[i] "\""); v[r[i]] = "" }

  id = v["id"]
  if (id != "") {
    p = index(id, "_"); pre = substr(id, 1, p - 1); suf = substr(id, p + 1)
    if (p == 0 || pre !~ /^[a-z]+$/ || length(pre) < 2 || length(pre) > 12 || suf !~ /^[0-9a-hjkmnp-tv-z]+$/ || length(suf) != 26)
      e("id \"" id "\" no es un TypeID válido (prefijo de 2-12 letras, \"_\" y 26 caracteres Crockford Base32)")
    else if (kind == "adr" && pre != "adr") e("el id de un ADR debe usar el prefijo \"adr_\"")
    print "ID " id
  }
  if (v["name"] != "" && v["name"] != ename) e("name \"" v["name"] "\" debe ser \"" ename "\" (derivado del nombre de archivo)")
  if (v["title"] != "" && (length(v["title"]) < 5 || length(v["title"]) > 120)) e("title debe tener entre 5 y 120 caracteres")
  if (v["description"] != "" && (length(v["description"]) < 10 || length(v["description"]) > 300)) e("description debe tener entre 10 y 300 caracteres")
  if (v["file_path"] != "" && v["file_path"] != path) e("file_path \"" v["file_path"] "\" no coincide con la ruta real \"" path "\"")
  if (v["category"] != "" && !inset(v["category"], "standards architecture agentic code_standards metadata errors templates guides universal_principles"))
    e("category \"" v["category"] "\" no está en la lista autorizada")

  t = v["tags"]
  if (t != "") {
    if (t !~ /^\[.*\]$/) e("tags debe ser una lista en línea: [etiqueta-1, etiqueta-2]")
    else {
      nt = split(substr(t, 2, length(t) - 2), ta, ","); cnt = 0
      for (i = 1; i <= nt; i++) {
        tg = ta[i]; gsub(/^[ \t]+|[ \t]+$/, "", tg)
        if (tg == "") continue
        cnt++
        if (tg !~ /^[a-z0-9][a-z0-9_-]*$/) e("etiqueta inválida \"" tg "\" (minúsculas, sin espacios)")
      }
      if (cnt < 1 || cnt > 10) e("tags debe tener entre 1 y 10 etiquetas")
    }
  }

  s = v["status"]
  if (s != "") {
    if (kind == "adr") {
      if (s !~ /^(proposed|accepted|rejected|deprecated)$/ && s !~ /^superseded by [0-9][0-9][0-9][0-9]$/)
        e("status de ADR \"" s "\" inválido (proposed, accepted, rejected, deprecated, superseded by NNNN)")
    } else if (!inset(s, "draft active deprecated archived")) e("status \"" s "\" inválido (draft, active, deprecated, archived)")
  }
  if (v["updated_at"] != "" && v["updated_at"] !~ /^[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z$/)
    e("updated_at debe ser ISO 8601 UTC: AAAA-MM-DDTHH:MM:SSZ")

  if ("agent_visibility" in v && !inset(v["agent_visibility"], "public internal restricted")) e("agent_visibility inválido")
  if ("tool_access_level" in v && !inset(v["tool_access_level"], "read_only safe_mutation full_access")) e("tool_access_level inválido")
  if ("execution_mode" in v && !inset(v["execution_mode"], "sync async batch event_driven")) e("execution_mode inválido")
  if ("priority" in v && v["priority"] !~ /^[1-5]$/) e("priority debe ser un entero de 1 a 5")
  if ("timeout_seconds" in v && v["timeout_seconds"] !~ /^[1-9][0-9]*$/) e("timeout_seconds debe ser un entero >= 1")

  ns = split(sections, sec, "|")
  for (i = 1; i <= ns; i++) if (!(sec[i] in h)) e("falta la sección obligatoria \"" sec[i] "\"")
}
'

ids=$(mktemp) || exit 2
trap 'rm -f "$ids"' EXIT

files=$(list_md)
while IFS= read -r f; do
  [ -n "$f" ] || continue
  kind=$(kind_of "$f")
  [ "$kind" = adapter ] && continue
  ename=$(basename "$f" .md | tr '[:upper:]' '[:lower:]' | tr '.-' '__')
  out=$(awk -v path="$f" -v kind="$kind" -v ename="$ename" \
    -v sections="$(required_sections "$f")" "$validate" "$f")
  while IFS= read -r line; do
    case "$line" in
      "ID "*) printf '%s %s\n' "${line#ID }" "$f" >>"$ids" ;;
      "E "*) err "$f: ${line#E }" ;;
    esac
  done <<EOF
$out
EOF
done <<EOF
$files
EOF

# Unicidad global de los id.
dups=$(awk '{ n[$1]++ } END { for (k in n) if (n[k] > 1) print k }' "$ids")
for id in $dups; do
  err "id duplicado $id en: $(grep "^$id " "$ids" | cut -d' ' -f2- | tr '\n' ' ')"
done

finish
