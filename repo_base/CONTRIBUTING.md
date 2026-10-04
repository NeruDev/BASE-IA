---
id: doc_01m44g0zy0e0z8t820g100n06q
name: contributing
title: "Guía de contribución"
file_path: CONTRIBUTING.md
category: guides
tags: [contributing, git, commits, adr, frontmatter]
description: "Procedimientos para hacer cambios, instalar los linters opcionales, crear documentos con frontmatter válido, generar ids y registrar ADRs."
status: active
updated_at: 2026-10-04T22:30:00Z
---

# Guía de contribución

## Flujo de trabajo

1. Hacer el cambio junto con la documentación afectada, y actualizar `updated_at` en cada `.md` modificado.
2. Ejecutar `sh scripts/check.sh` y corregir hasta que termine con código 0.
3. Hacer commit con [Conventional Commits](https://www.conventionalcommits.org/): `tipo(ámbito opcional): descripción`. Tipos habituales: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci` y `chore`.

El hook pre-commit repite la autoevaluación sin red. Se activa una vez por clon con `git config core.hooksPath .githooks`.

## Linters opcionales

Ninguno es obligatorio: si falta alguno, `scripts/check.sh` lo omite con un aviso.

| Linter | Instalación en Windows | Requiere |
| --- | --- | --- |
| shellcheck | `scoop install shellcheck` | Scoop |
| markdownlint-cli2 | `npm install -g markdownlint-cli2` | Node.js |
| yamllint | `pip install yamllint` | Python |
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
