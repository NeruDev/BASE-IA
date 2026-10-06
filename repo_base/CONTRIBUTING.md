---
id: doc_01m44g0zy0e0z8t820g100n06q
name: contributing
title: "Guía de contribución"
file_path: CONTRIBUTING.md
category: guides
tags: [contributing, git, commits, adr, frontmatter, memoria]
description: "Procedimientos para hacer cambios, instalar los linters opcionales, crear documentos con frontmatter válido, generar ids, registrar ADRs y mantener la memoria del repositorio."
status: active
updated_at: 2026-10-06T22:36:35Z
---

# Guía de contribución

## Flujo de trabajo

1. Hacer el cambio junto con la documentación afectada, y actualizar `updated_at` en cada `.md` modificado.
2. Ejecutar `sh scripts/check.sh` y corregir hasta que termine con código 0.
3. Hacer commit con [Conventional Commits](https://www.conventionalcommits.org/): `tipo(ámbito opcional): descripción`. Tipos habituales: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci` y `chore`.

El hook pre-commit repite la autoevaluación sin red. Se activa una vez por clon desde `sh` con `chmod +x .githooks/pre-commit && git config core.hooksPath .githooks` (o la tarea *hooks: activar*). El permiso es necesario en sistemas POSIX.

## Trabajo efímero y promoción

Reglas en [sandbox/README.md](sandbox/README.md) y [ADR-0005](docs/adr/0005-ephemeral-workspace.md).

1. Crear una unidad `sandbox/AAAAMMDD-tarea/` únicamente si pipes o variables no bastan.
2. Validar el archivo o directorio explícito con `sh scripts/check.sh sandbox/AAAAMMDD-tarea/archivo`; no se ignora aunque Git lo ignore. Para documentos, usar el frontmatter de su ruta actual.
3. Mover (no copiar) al destino final, actualizar `file_path` si corresponde y repetir `sh scripts/check.sh`.
4. Borrar la unidad propia; revisar `git status --short`. La limpieza colectiva usa `sh scripts/sandbox-clean.sh` (dry-run), `--yes` para borrar y `--older-than 7` para seleccionar unidades antiguas completas.

El área temporal no se recorre por defecto. Las pruebas permanentes se ejecutan con `sh tests/sandbox.sh`; sus repositorios de prueba y registros usan el temporal del sistema y se eliminan con `trap`.

Abrir esta plantilla como carpeta de trabajo de VS Code para aplicar sus tareas y exclusiones. Las exclusiones no impiden abrir archivos ni su acceso explícito por un agente; no son una barrera de seguridad. El hook debe activarse en cada repo instanciado; no se cambia la configuración del Git contenedor.

## Linters opcionales

Ninguno es obligatorio: si falta alguno, `scripts/check.sh` lo omite con un aviso.

| Linter | Instalación en Windows | Requiere |
| --- | --- | --- |
| shellcheck | `scoop install shellcheck` | Scoop |
| markdownlint-cli2 | `npm install -g markdownlint-cli2` | Node.js |
| yamllint | `python -m pip install yamllint`, con `.venv/` activo | Python ([ADR-0003](docs/adr/0003-scripting-languages.md)) |
| lychee | `scoop install lychee` | Scoop |

## Crear un documento

1. Copiar esta cabecera en la línea 1 del archivo nuevo y completarla según [ADR-0002](docs/adr/0002-frontmatter-schema.md):

   ```yaml
   ---
   id: doc_<generar>
   name: nombre_del_archivo
   title: "Título del documento"
   file_path: ruta/desde/la/raiz/nombre_del_archivo.md
   category: guides
   tags: [etiqueta-1, etiqueta-2]
   description: "Qué contiene y cuándo debe leerlo un agente."
   status: draft
   updated_at: AAAA-MM-DDTHH:MM:SSZ
   ---
   ```

2. Generar el `id` con el procedimiento siguiente.
3. Enlazar el documento desde el lugar donde un lector lo buscaría (por ejemplo, el mapa de [README.md](README.md)).
4. Ejecutar `sh scripts/check.sh`.

## Generar un id

Los `id` son TypeID: un prefijo (`doc` para documentos, `adr` para ADRs), `_` y un UUIDv7 en Crockford Base32. Se generan una vez y no cambian. En PowerShell:

```powershell
$prefijo = 'doc'
$alfabeto = '0123456789abcdefghjkmnpqrstvwxyz'
$b = [byte[]]::new(16)
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
$ms = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
0..5 | ForEach-Object { $b[$_] = [byte](($ms -shr (8 * (5 - $_))) -band 255) }
$b[6] = [byte](0x70 -bor ($b[6] -band 15))
$b[8] = [byte](0x80 -bor ($b[8] -band 63))
$bits = '00' + (-join ($b | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }))
"${prefijo}_" + (-join (0..25 | ForEach-Object { $alfabeto[[Convert]::ToInt32($bits.Substring(5 * $_, 5), 2)] }))
```

Para obtener la fecha de `updated_at` en UTC: `(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')`.

## Registrar un ADR

1. Tomar el siguiente número libre de [docs/adr/](docs/adr/README.md). El chequeo detecta huecos y duplicados.
2. Crear `docs/adr/NNNN-titulo-en-kebab-case.md` a partir de la plantilla del índice, con un `id` de prefijo `adr`.
3. Añadir la fila correspondiente a la tabla del índice.
4. Para reemplazar una decisión aceptada, crear un ADR nuevo y cambiar el `status` del anterior a `superseded by NNNN`.

## Registrar memoria

La memoria vive en [docs/memory/](docs/memory/README.md) y la rigen [AGENTS.md](AGENTS.md) y el [ADR-0004](docs/adr/0004-repository-memory.md). Ningún cambio de memoria se aplica sin la aprobación del usuario.

### Dónde va cada cosa

| Información | Destino |
| --- | --- |
| Error repetido, fallo no obvio o decisión de proceso duradera | `docs/memory/` |
| Regla de conducta permanente para agentes | `AGENTS.md` o `.github/instructions/` |
| Decisión con alternativas y consecuencias | `docs/adr/` |
| Procedimiento paso a paso recurrente | Este archivo |
| Invariante que un script puede comprobar | `scripts/checks/` o la configuración de un linter |
| Avance de tareas y cambios realizados | `git log` o `CHANGELOG.md` |
| Hipótesis, trazas y notas de trabajo | No se versionan |

### Plantilla de entrada

Añadir el bloque al final de `docs/memory/entries.md`, separado por una línea en blanco, y la fila al índice con el mismo id y estado. El id es el «Próximo id» del índice, que después se incrementa; los números no se reutilizan.

```markdown
### MEM-0001

- disparador: al <situación en la que aplica>
- síntoma: <qué se observa, resumido>
- causa: <causa raíz>
- regla: <acción concreta, en imperativo>
- evidencia: [archivo](../../ruta/al/archivo) o commit <hash>
- estado: activa; recurrencias: 1; fecha: AAAA-MM-DD; origen: comprobado
```

| Campo | Regla |
| --- | --- |
| `disparador` | Cuándo aplica, como situación. Se resume en la columna «Cuándo aplica» del índice. |
| `síntoma` | Mensaje o comportamiento observable, resumido; nunca la traza completa. |
| `causa` | Causa raíz, no la descripción del síntoma. |
| `regla` | Acción concreta que evita el problema. Se resume en la columna «Regla» del índice. |
| `evidencia` | Enlace relativo a un archivo final versionado o `commit <hash>`; nunca una copia, URL ni ruta de trabajo efímero. |
| `estado` | `activa`; `promovida` u `obsoleta` solo mientras el borrado está pendiente. |
| `recurrencias` | Veces observado, entero mayor o igual que 1. |
| `fecha` | Última confirmación (alta, recurrencia o revisión), en AAAA-MM-DD. La fecha de alta la conserva git. |
| `origen` | `comprobado` (reproducido), `usuario`, `documentación` o `inferido` (sin comprobar). |
| `vence` | Opcional, al final de la última línea: `; vence: AAAA-MM-DD`. Para lecciones atadas a una versión de una herramienta. |

Límites que comprueba `scripts/checks/memory.sh`: 8 líneas por entrada (encabezado, una línea en blanco y seis de campos), 200 bytes por línea, 10 entradas activas, 120 líneas en `entries.md` y 40 en el índice, sin contar el frontmatter.

### Ciclo de vida

| Acción | Cuándo | Qué cambia |
| --- | --- | --- |
| Alta | Se cumple un criterio de entrada y no hay una entrada equivalente | Entrada nueva y fila en el índice. |
| Recurrencia | El problema vuelve a ocurrir | `recurrencias` + 1 y `fecha` del día. |
| Revisión | Se aplicó la regla y sigue siendo válida, o avisa la caducidad de 30 días | Solo `fecha`. |
| Promoción | 3 recurrencias o más, o regla válida para cualquier proyecto | La regla pasa a su destino según la tabla anterior; se borran la entrada y su fila en el mismo commit: `docs(memory): promueve MEM-NNNN a <destino>`. |
| Borrado | La causa ya no existe, la evidencia desapareció, venció o se fusionó con otra | Se borran la entrada y su fila: `docs(memory): borra MEM-NNNN`. Git conserva el histórico; no se crean archivos de archivo. |

### Consolidar la memoria

Se hace antes de cualquier alta cuando `sh scripts/check.sh` emite un aviso o un error de memoria:

1. Ejecutar `sh scripts/checks/memory.sh` y anotar cada aviso y error.
2. Borrar las entradas `promovida` u `obsoleta` y sus filas.
3. Fusionar duplicados (misma causa o misma regla): conservar el id más antiguo, sumar las recurrencias y borrar el resto.
4. Promover las entradas que cumplan el criterio de promoción.
5. Revisar las caducadas o vencidas: confirmar (`fecha` del día) o borrar.
6. Comprobar que quedan como máximo 7 entradas activas y que `sh scripts/check.sh` termina con código 0.
7. Proponer el lote al usuario y, tras su aprobación, hacer un commit `docs(memory): consolida`.
