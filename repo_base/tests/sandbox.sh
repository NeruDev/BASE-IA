#!/bin/sh
# Regresiones permanentes; todas las mutaciones ocurren en un Git temporal aislado.
set -u
root=$(CDPATH='' cd -P "$(dirname "$0")/.." && pwd -P) || exit 2
work=$(mktemp -d) || exit 2
trap 'rm -rf "$work"' 0
trap 'exit 2' HUP INT TERM
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null CHECK_NO_NETWORK=1
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
mkdir "$work/repo" || exit 2
cd "$root" || exit 2
files=$(git -c core.quotepath=false ls-files --cached --others --exclude-standard -- .) || exit 2
while IFS= read -r file; do
  [ -f "$file" ] || continue
  case "$file" in sandbox/README.md | sandbox/.gitkeep) ;; sandbox/*) continue ;; esac
  mkdir -p "$work/repo/$(dirname "$file")" || exit 2
  cp "$file" "$work/repo/$file" || exit 2
done <<EOF
$files
EOF
cd "$work/repo" || exit 2
git init -q || exit 2
chmod +x .githooks/pre-commit || exit 2
git add . || exit 2
git -c user.name=Fixture -c user.email=fixture@example.invalid commit -qm 'test: fixture

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>' || exit 2
git config core.hooksPath .githooks || exit 2
count=0
ok() { count=$((count + 1)); printf 'OK %02d %s\n' "$count" "$1"; }
stop() { printf 'FALLO %s\n' "$*" >&2; cat "$work/log" >&2; exit 1; }
passes() { label=$1; shift; "$@" >"$work/log" 2>&1 || stop "$label"; ok "$label"; }
rejects() { label=$1; shift; if "$@" >"$work/log" 2>&1; then stop "$label"; fi; ok "$label"; }
make_link() {
  if MSYS=winsymlinks:nativestrict ln -s "$1" "$2" >"$work/log" 2>&1; then return 0; fi
  # Windows sin privilegio de symlink: una junction es un enlace real para MSYS.
  if command -v cygpath >/dev/null 2>&1 && command -v pwsh >/dev/null 2>&1; then
    # shellcheck disable=SC2016 # $env lo interpreta PowerShell, no sh.
    LINK_TARGET=$(cygpath -w "$1") LINK_PATH=$(cygpath -w "$2") \
      pwsh -NoProfile -NonInteractive -Command 'New-Item -ItemType Junction -Path $env:LINK_PATH -Target $env:LINK_TARGET | Out-Null' >"$work/log" 2>&1 || return 1
    printf 'INFO Windows: junction real (sin privilegio de symlink)\n'
    return 0
  fi
  return 1
}

passes 'check.sh en clon limpio' sh scripts/check.sh
mkdir -p sandbox/20261006-test/nested
printf 'dato\n' >sandbox/20261006-test/nested/output.txt
passes 'git check-ignore -v: temporal anidado' git check-ignore -v sandbox/20261006-test/nested/output.txt
[ -z "$(git status --short)" ] || stop 'los temporales ensucian Git'
ok 'git status limpio con temporales'
passes 'check.sh excluye temporales por defecto' sh scripts/check.sh
printf '# borrador sin frontmatter\n' >sandbox/20261006-test/draft.md
rejects 'ruta explícita: documento inválido no se omite' sh scripts/check.sh sandbox/20261006-test/draft.md
if command -v shellcheck >/dev/null 2>&1; then
  printf '#!/bin/sh\n[[ 1 = 1 ]]\n' >sandbox/20261006-test/bad.sh
  rejects 'ruta explícita: shellcheck rechaza bashismo' sh scripts/check.sh sandbox/20261006-test/bad.sh
fi
if command -v markdownlint-cli2 >/dev/null 2>&1; then
  cp sandbox/README.md sandbox/20261006-test/valid.md
  sed 's|file_path: sandbox/README.md|file_path: sandbox/20261006-test/valid.md|; s|name: readme|name: valid|; s|doc_01m49ns433fb7an74k6nngwz5a|doc_01m49ns433fb7an74k6nngwz5b|' sandbox/20261006-test/valid.md >"$work/draft"
  mv "$work/draft" sandbox/20261006-test/valid.md
  passes 'ruta explícita: documento válido pasa' sh scripts/check.sh sandbox/20261006-test/valid.md
  printf '\n## Duplicado\n\n## Duplicado\n' >>sandbox/20261006-test/valid.md
  rejects 'ruta explícita: markdownlint examina ignorados' sh scripts/check.sh sandbox/20261006-test/valid.md
  grep -q MD024 "$work/log" || stop 'markdownlint no examinó el borrador'
fi
if command -v yamllint >/dev/null 2>&1; then
  printf '%s\n' '---' 'a: 1' 'a: 2' >sandbox/20261006-test/bad.yaml
  rejects 'ruta explícita: yamllint examina ignorados' sh scripts/check.sh sandbox/20261006-test/bad.yaml
  grep -q key-duplicates "$work/log" || stop 'yamllint no examinó el borrador'
fi

git add -f sandbox/20261006-test/nested/output.txt || exit 2
rejects 'git add -f bloqueado por check.sh' sh scripts/check.sh
grep -q 'archivo prohibido en el índice' "$work/log" || stop 'falló por una causa ajena'
rejects 'git add -f bloqueado por pre-commit real' git -c user.name=Fixture -c user.email=fixture@example.invalid commit -qm 'test: must reject'
grep -q 'archivo prohibido en el índice' "$work/log" || stop 'hook no examinó el índice'
git restore --staged sandbox/20261006-test/nested/output.txt || exit 2
printf '#!/bin/sh\ncat sandbox/20261006-test/nested/output.txt\n' >scripts/dependent.sh
git add scripts/dependent.sh || exit 2
rejects 'script versionado con dependencia efímera' sh scripts/check.sh
printf '#!/bin/sh\nexit 0\n' >scripts/dependent.sh
rejects 'dependencia preparada aunque la copia de trabajo sea inocua' sh scripts/check.sh
grep -q '(índice)' "$work/log" || stop 'no se examinó el contenido preparado'
printf '#!/bin/sh\ncat SANDBOX/output.txt\n' >scripts/dependent.sh
git add scripts/dependent.sh || exit 2
rejects 'dependencias con mayúsculas también se rechazan' sh scripts/checks/sandbox.sh
git restore --staged scripts/dependent.sh || exit 2
rm scripts/dependent.sh
git add -f sandbox/20261006-test/draft.md || exit 2
passes 'archivo prohibido considerado versionado por Git' git ls-files --error-unmatch sandbox/20261006-test/draft.md
rejects 'archivo versionado bajo sandbox fuera de lista' sh scripts/checks/sandbox.sh
git restore --staged sandbox/20261006-test/draft.md || exit 2
cp .gitignore "$work/gitignore"
sed '\|^/sandbox/\*$|d' .gitignore >"$work/changed"
cp "$work/changed" .gitignore
rejects 'regla de exclusión ausente' sh scripts/checks/sandbox.sh
cp "$work/gitignore" .gitignore
cp docs/memory/entries.md "$work/memory"
printf '\n- evidencia: [temporal](../../sandbox/20261006-test/draft.md)\n' >>docs/memory/entries.md
rejects 'la memoria rechaza evidencia efímera' sh scripts/checks/sandbox.sh
git add docs/memory/entries.md || exit 2
cp "$work/memory" docs/memory/entries.md
rejects 'la memoria rechaza evidencia efímera preparada' sh scripts/checks/sandbox.sh
git restore --staged docs/memory/entries.md || exit 2

passes 'dry-run de limpieza' sh scripts/sandbox-clean.sh
[ -f sandbox/20261006-test/nested/output.txt ] || stop 'dry-run borró contenido'
ok 'dry-run no borra nada'
rejects 'limpieza rechaza .. como argumento' sh scripts/sandbox-clean.sh --yes sandbox/../docs
rejects 'limpieza rechaza .. en la invocación' sh scripts/../scripts/sandbox-clean.sh --yes
rejects 'limpieza rechaza DIAS inválidos' sh scripts/sandbox-clean.sh --older-than -1
(cd scripts && sh sandbox-clean.sh --yes) >"$work/log" 2>&1 && stop 'aceptó otra raíz'
ok 'limpieza rechaza otra raíz'
mkdir sandbox/20260901-old sandbox/20260901-mixed
printf 'viejo\n' >sandbox/20260901-old/output.txt
printf 'viejo\n' >sandbox/20260901-mixed/output.txt
touch -t 200001010000 sandbox/20260901-old/output.txt sandbox/20260901-old sandbox/20260901-mixed/output.txt
passes 'dry-run selectivo por edad' sh scripts/sandbox-clean.sh --older-than 7
grep -q 'sandbox/20260901-old' "$work/log" || stop 'no seleccionó la unidad vieja'
if grep -q 'sandbox/20260901-mixed' "$work/log"; then stop 'seleccionó un subárbol reciente'; fi
ok 'edad considera todo el subárbol'
passes 'antigüedad es aviso, no fallo' sh scripts/check.sh
grep -q 'AVISO.*más de 7' "$work/log" || stop 'no se emitió el aviso de antigüedad'
passes '--yes borra solo unidades antiguas' sh scripts/sandbox-clean.sh --yes --older-than 7
[ ! -e sandbox/20260901-old ] && [ -f sandbox/20260901-mixed/output.txt ] || stop 'selección por edad incorrecta'
ok 'limpieza selectiva conserva trabajo reciente'
passes 'avisa de un descendiente antiguo aunque la unidad sea reciente' sh scripts/check.sh
grep -q 'AVISO.*más de 7' "$work/log" || stop 'no avisó del descendiente antiguo'
dd if=/dev/zero of=sandbox/20261006-test/large bs=1000000 count=21 >"$work/log" 2>&1 || exit 2
passes 'más de 20 MB es aviso, no fallo' sh scripts/check.sh
grep -q 'AVISO.*supera 20 MB' "$work/log" || stop 'no se emitió el aviso de tamaño'
rm sandbox/20261006-test/large
mkdir "$work/outside"
printf 'intacto\n' >"$work/outside/keep"
make_link "$work/outside" sandbox/escape || stop 'no se pudo crear un enlace real'
[ -L sandbox/escape ] || stop 'ln no produjo un enlace simbólico real'
rejects 'rechaza enlace simbólico hacia fuera (dry-run)' sh scripts/sandbox-clean.sh
rejects 'rechaza enlace simbólico hacia fuera (--yes)' sh scripts/sandbox-clean.sh --yes
[ -f "$work/outside/keep" ] && [ -f sandbox/20261006-test/nested/output.txt ] || stop 'se borró algo antes del rechazo'
ok 'rechazo es previo a cualquier borrado; exterior intacto'
rm sandbox/escape
mv sandbox "$work/area"
make_link "$work/area" sandbox || exit 2
rejects 'rechaza raíz simbólica' sh scripts/sandbox-clean.sh --yes
rm sandbox
mv "$work/area" sandbox
mkdir 'sandbox/20261006-con espacios' sandbox/.hidden
printf 'dato\n' >'sandbox/20261006-con espacios/a [1].txt'
passes 'limpieza completa incluye ocultos y espacios' sh scripts/sandbox-clean.sh --yes
[ "$(command -p find sandbox -type f | wc -l)" -eq 2 ] || stop 'quedaron temporales'
[ -f sandbox/README.md ] && [ -f sandbox/.gitkeep ] || stop 'se borraron controles'
ok 'solo quedan README.md y .gitkeep'
passes 'check.sh final' sh scripts/check.sh
[ -z "$(git status --short)" ] || stop 'fixture no quedó limpio'
ok 'git status final limpio'
printf 'RESULTADO: %d pruebas correctas\n' "$count"
