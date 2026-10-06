#!/bin/sh
# Invariante: memoria del repositorio en docs/memory/ (ADR-0004; esquema en CONTRIBUTING.md).
# Valida presupuestos, esquema de las entradas, ids, coherencia entre índice y entradas, y
# ausencia de rutas absolutas, tokens y bloques de código. El frontmatter, las secciones,
# los enlaces y la existencia de los archivos los validan headers.sh, internal-links.sh y
# required-files.sh; aquí no se repiten.
# Fecha de referencia de los avisos de caducidad: CHECK_TODAY=AAAA-MM-DD o la fecha UTC
# actual. Es la única dependencia de la hora (excepción de shell.instructions.md) y solo
# emite avisos, nunca errores.
set -u
cd "$(dirname "$0")/../.." || exit 2
# shellcheck source=scripts/lib/common.sh
. scripts/lib/common.sh

index=docs/memory/README.md
entries=docs/memory/entries.md

# Presupuestos (ADR-0004). Las líneas se cuentan sin el frontmatter.
max_index_lines=40
max_file_lines=120
max_entry_lines=8
max_active=10
max_line_bytes=200
warn_percent=80
stale_days=30

for f in "$index" "$entries"; do
  if [ ! -f "$f" ]; then
    warn "$f no existe; se omite (lo informa «Archivos obligatorios»)"
    finish
  fi
done

today=${CHECK_TODAY:-$(date -u +%Y-%m-%d)}
case "$today" in
  [0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]) ;;
  *)
    printf 'CHECK_TODAY="%s" no tiene el formato AAAA-MM-DD\n' "$today" >&2
    exit 2
    ;;
esac

# Emite "E <mensaje>" por error, "W <mensaje>" por aviso, "I <mensaje>" informativo y
# "C <hash> <id>" por cada commit citado como evidencia (se verifica después con git).
# shellcheck disable=SC2016 # el programa awk va entre comillas simples a propósito
program='
function e(m) { print "E " m }
function w(m) { print "W " m }
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function inset(x, list,   n, a, i) {
  n = split(list, a, " ")
  for (i = 1; i <= n; i++) if (a[i] == x) return 1
  return 0
}
function okdate(s,   y, m, d, ml) {
  if (s !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) return 0
  y = substr(s, 1, 4) + 0; m = substr(s, 6, 2) + 0; d = substr(s, 9, 2) + 0
  if (m < 1 || m > 12 || d < 1) return 0
  if (m == 2) ml = ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28
  else ml = (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31
  return d <= ml
}
# Número de día juliano: permite restar fechas sin depender de date(1).
function jdn(s,   y, m, d, a) {
  y = substr(s, 1, 4) + 0; m = substr(s, 6, 2) + 0; d = substr(s, 9, 2) + 0
  a = int((14 - m) / 12); y = y + 4800 - a; m = m + 12 * a - 3
  return d + int((153 * m + 2) / 5) + 365 * y + int(y / 4) - int(y / 100) + int(y / 400) - 32045
}
function ceilpct(max) { return int((max * wp + 99) / 100) }
function budget(what, n, max) {
  if (n > max) e(what ": " n " de " max " (presupuesto superado: consolidar según CONTRIBUTING.md)")
  else if (n >= ceilpct(max)) w(what ": " n " de " max " (>= " wp " %: consolidar antes de añadir entradas)")
}
# Comprobaciones de cualquier línea del cuerpo: longitud, bloques de código, rutas y tokens.
function common(s, where) {
  if (length(s) > maxbytes) e(where ": línea de " length(s) " bytes (máximo " maxbytes ")")
  if (s ~ /^[ ]*(```|~~~)/) e(where ": bloque de código no admitido (la memoria no guarda trazas ni diffs)")
  if (s ~ /(^|[^A-Za-z])[A-Za-z]:[\\\/]/ || s ~ /(^|[^A-Za-z0-9._-])\/(home|Users|mnt|root)\// || s ~ /(^|[^A-Za-z0-9._-])~\//)
    e(where ": ruta absoluta o privada; use rutas relativas al repositorio")
  if ((match(s, /(ghp|gho|ghu|ghs|ghr|github_pat)_[A-Za-z0-9_]+/) && RLENGTH >= 20) ||
      (match(s, /sk-[A-Za-z0-9_-]+/) && RLENGTH >= 23) ||
      (match(s, /AKIA[0-9A-Z]+/) && RLENGTH >= 20) || s ~ /-----BEGIN [A-Z ]*PRIVATE KEY-----/)
    e(where ": posible secreto o token; la memoria nunca contiene credenciales")
}
# Valida un campo de la entrada en curso y comprueba su orden.
function field(k, val, where,   p, t, s, ok, bad, h) {
  p = 0
  for (t = 1; t <= nwant; t++) if (want[t] == k) p = t
  if (k == "vence") p = nwant + 1
  if (p == 0) { e(where ": campo desconocido \"" k "\""); return }
  if (k in seen) { e(where ": campo \"" k "\" repetido"); return }
  if (p < last) e(where ": campo \"" k "\" fuera de orden (" order ")")
  seen[k] = 1; last = p
  if (val == "") { e(where ": campo \"" k "\" vacío"); return }
  if (k == "estado") {
    if (inset(val, "activa promovida obsoleta")) cst = val
    else e(where ": estado \"" val "\" inválido (activa, promovida u obsoleta)")
  } else if (k == "recurrencias") {
    if (val !~ /^[1-9][0-9]*$/) e(where ": recurrencias debe ser un entero >= 1")
  } else if (k == "fecha" || k == "vence") {
    if (!okdate(val)) e(where ": " k " \"" val "\" no es una fecha AAAA-MM-DD válida")
    else if (k == "fecha") cfecha = val
    else cvence = val
  } else if (k == "origen") {
    if (!inset(val, "comprobado usuario documentación inferido")) e(where ": origen \"" val "\" inválido (comprobado, usuario, documentación o inferido)")
  } else if (k == "evidencia") {
    ok = 0; bad = 0; s = val
    while (match(s, /\]\([^)]*\)/)) {
      t = substr(s, RSTART + 2, RLENGTH - 3)
      if (t ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) bad = 1; else if (t != "") ok = 1
      s = substr(s, RSTART + RLENGTH)
    }
    s = val
    while (match(s, /commit [0-9a-f]+/)) {
      h = substr(s, RSTART + 7, RLENGTH - 7)
      if (length(h) >= 7 && length(h) <= 40) { ok = 1; print "C " h " " cur }
      s = substr(s, RSTART + RLENGTH)
    }
    if (bad) e(where ": evidencia con URL o esquema; use una ruta del repositorio o un commit")
    else if (!ok) e(where ": evidencia debe ser un enlace relativo a un archivo del repositorio o \"commit <hash>\"")
  }
}
function endentry(   t) {
  if (!open) return
  open = 0
  if (cl > maxentry) e(ent ":" cstart ": " cur " ocupa " cl " líneas (máximo " maxentry ")")
  for (t = 1; t <= nwant; t++) if (!(want[t] in seen)) e(ent ":" cstart ": " cur ": falta el campo obligatorio \"" want[t] "\"")
  if (cur == "" || cur in est) return
  ne++; eid[ne] = cur; est[cur] = cst
  if (cst == "activa") active++
  else if (cst != "") w(cur ": estado " cst "; borrar la entrada en la próxima consolidación")
  if (cst == "activa" && cfecha != "") {
    age = tj - jdn(cfecha)
    if (age > stale) w(cur ": sin revisar desde " cfecha " (" age " días; máximo " stale "): confirmar, promover o borrar")
    else if (age < 0) w(cur ": fecha " cfecha " posterior a la de referencia " today)
  }
  if (cvence != "" && jdn(cvence) <= tj) w(cur ": venció el " cvence ": confirmar, promover o borrar")
}
BEGIN {
  order = "disparador síntoma causa regla evidencia estado recurrencias fecha origen"
  nwant = split(order, want, " ")
  order = order " [vence]"
  tj = jdn(today); wp = warnpct
}
FNR == 1 { infm = ($0 == "---"); if (infm) next }
infm { if ($0 == "---") infm = 0; next }
{ body[FILENAME]++; common($0, FILENAME ":" FNR) }

FILENAME == idx && /^Próximo id:/ {
  nexts++
  if ($0 ~ /^Próximo id: MEM-[0-9][0-9][0-9][0-9]$/) nextnum = substr($0, length($0) - 3) + 0
  else e(idx ":" FNR ": formato esperado \"Próximo id: MEM-NNNN\"")
  next
}
FILENAME == idx && /^\|/ {
  if ($0 ~ /^\|[ :|-]+\|[ ]*$/) next
  n = split($0, c, "|")
  if (trim(c[2]) == "Id") next
  where = idx ":" FNR
  if (n != 6) { e(where ": la fila debe tener 4 columnas (Id | Cuándo aplica | Regla | Estado)"); next }
  id = trim(c[2])
  if (id !~ /^MEM-[0-9][0-9][0-9][0-9]$/) { e(where ": id \"" id "\" inválido (se espera MEM-NNNN)"); next }
  if (id in irow) { e(where ": id " id " duplicado en el índice"); next }
  if (trim(c[3]) == "" || trim(c[4]) == "") e(where ": " id ": «Cuándo aplica» y «Regla» no pueden estar vacías")
  ni++; iid[ni] = id; irow[id] = trim(c[5])
  if (!inset(irow[id], "activa promovida obsoleta")) e(where ": " id ": estado \"" irow[id] "\" inválido")
  next
}

FILENAME == ent && /^### / {
  endentry()
  cur = substr($0, 5); cstart = FNR; cl = 1; open = 1; last = 0
  cst = ""; cfecha = ""; cvence = ""
  split("", seen)
  if (!inentries) e(ent ":" FNR ": entrada fuera de la sección \"## Entradas\"")
  if (cur !~ /^MEM-[0-9][0-9][0-9][0-9]$/) { e(ent ":" FNR ": encabezado \"" $0 "\" inválido (se espera \"### MEM-NNNN\")"); cur = "" }
  else if (cur in est) { e(ent ":" FNR ": id " cur " duplicado en las entradas"); cur = "" }
  next
}
FILENAME == ent && /^#/ {
  endentry()
  if ($0 == "## Entradas") inentries = 1
  else if (inentries) e(ent ":" FNR ": no se admiten otras secciones después de \"## Entradas\"")
  next
}
# La línea en blanco que sigue al encabezado (la exige markdownlint) es parte de la entrada;
# cualquier otra la cierra.
FILENAME == ent && open && /^[ \t]*$/ { if (cl == 1) cl++; else endentry(); next }
FILENAME == ent && open {
  cl++; where = ent ":" FNR
  if (!match($0, /^- [^:]+: /)) { e(where ": se espera \"- clave: valor\""); next }
  k = substr($0, 3, RLENGTH - 4); val = trim(substr($0, RLENGTH + 1))
  if (k != "estado") { field(k, val, where); next }
  n = split(val, parts, "; ")
  field("estado", trim(parts[1]), where)
  for (t = 2; t <= n; t++) {
    if (!match(parts[t], /^[^:]+: /)) { e(where ": se espera \"clave: valor\" separados por \"; \""); continue }
    field(substr(parts[t], 1, RLENGTH - 2), trim(substr(parts[t], RLENGTH + 1)), where)
  }
  next
}
FILENAME == ent && inentries && !/^[ \t]*$/ { e(ent ":" FNR ": texto fuera de una entrada") }

END {
  endentry()
  if (nexts != 1) e(idx ": debe haber exactamente una línea \"Próximo id: MEM-NNNN\"")
  budget(idx " (líneas sin frontmatter)", body[idx] + 0, maxidx)
  budget(ent " (líneas sin frontmatter)", body[ent] + 0, maxfile)
  budget("entradas activas", active + 0, maxactive)
  for (t = 1; t <= ne; t++) {
    id = eid[t]
    if (!(id in irow)) e(id ": está en " ent " pero no en el índice " idx)
    else if (est[id] != "" && irow[id] != est[id]) e(id ": estado \"" irow[id] "\" en el índice y \"" est[id] "\" en las entradas")
    if (nextnum && substr(id, 5) + 0 >= nextnum) e(id ": no es menor que \"Próximo id\" (MEM-" sprintf("%04d", nextnum) ")")
  }
  for (t = 1; t <= ni; t++) {
    id = iid[t]
    if (!(id in est)) e(id ": está en el índice pero no en " ent)
  }
  printf "I memoria: %d activa(s) de %d; índice %d/%d líneas; entradas %d/%d líneas\n", active, maxactive, body[idx], maxidx, body[ent], maxfile
}
'

out=$(LC_ALL=C awk -v idx="$index" -v ent="$entries" -v today="$today" \
  -v maxidx="$max_index_lines" -v maxfile="$max_file_lines" -v maxentry="$max_entry_lines" \
  -v maxactive="$max_active" -v maxbytes="$max_line_bytes" -v warnpct="$warn_percent" \
  -v stale="$stale_days" "$program" "$index" "$entries") || exit 2

in_git=0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && in_git=1

while IFS= read -r line; do
  case "$line" in
    "E "*) err "${line#E }" ;;
    "W "*) warn "${line#W }" ;;
    "I "*) info "${line#I }" ;;
    "C "*)
      rest=${line#C }
      hash=${rest%% *}
      id=${rest#* }
      if [ "$in_git" -eq 0 ]; then
        warn "$id: no es un repositorio git; no se verifica el commit $hash"
      elif ! git cat-file -e "$hash^{commit}" 2>/dev/null; then
        err "$id: evidencia: el commit $hash no existe"
      fi
      ;;
  esac
done <<EOF
$out
EOF

finish
