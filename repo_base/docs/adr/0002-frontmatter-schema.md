---
id: adr_01m44g101de7mv40k4rx5yxe5c
name: 0002_frontmatter_schema
title: "Esquema de frontmatter para un repositorio individual"
file_path: docs/adr/0002-frontmatter-schema.md
category: architecture
tags: [adr, frontmatter, metadatos, typeid, validacion]
description: "Adopta el esquema de frontmatter del estándar externo sin version, owner, created_at ni schema_version, con un formato restringido que se valida en POSIX sh."
status: accepted
updated_at: 2026-10-04T22:30:00Z
---

# 0002 — Esquema de frontmatter para un repositorio individual

## Contexto y planteamiento del problema

El estándar externo `07_yaml_frontmatter_specification.md`, de las bases teóricas externas, define una cabecera YAML de 13 campos obligatorios. Su objetivo es que un agente o un script obtenga un resumen verificable de cada documento antes de leerlo completo. En un repositorio con un único mantenedor, cuatro de esos campos no aportan información verificable:

- `version` y `created_at` ya los registra git.
- `owner` es siempre la misma persona.
- `schema_version` no tiene ningún consumidor.

Además, la validación debe funcionar sin Python ni Node, como establece el [ADR-0001](0001-foundational-decisions.md).

## Factores de decisión

- Resumen fiable antes de abrir el cuerpo del documento.
- Validable con POSIX `sh` y `awk`, sin un parser YAML.
- Compatibilidad con herramientas que imponen su propio frontmatter (GitHub Copilot, MADR).

## Opciones consideradas

- Esquema completo del estándar 07 (13 campos obligatorios).
- Esquema 07 sin `version`, `owner`, `created_at` ni `schema_version`.
- Sin frontmatter: solo secciones H2 obligatorias.

## Resultado de la decisión

Opción elegida: «esquema 07 sin `version`, `owner`, `created_at` ni `schema_version`», porque conserva la información útil para el agente y elimina la que git ya conserva o nadie consume.

Campos obligatorios:

| Campo | Regla |
| --- | --- |
| `id` | TypeID: prefijo de 2 a 12 letras minúsculas, `_` y 26 caracteres Crockford Base32. Único en el repositorio e inmutable. |
| `name` | Nombre del archivo sin `.md`, en minúsculas, con `-` y `.` sustituidos por `_`. |
| `title` | Entre 5 y 120 caracteres. |
| `file_path` | Ruta POSIX desde la raíz; debe coincidir con la real. |
| `category` | `standards`, `architecture`, `agentic`, `code_standards`, `metadata`, `errors`, `templates`, `guides` o `universal_principles`. |
| `tags` | Lista en línea de 1 a 10 etiquetas en minúsculas, sin espacios. |
| `description` | Entre 10 y 300 caracteres. Debe permitir decidir si leer el cuerpo. |
| `status` | `draft`, `active`, `deprecated` o `archived`. |
| `updated_at` | ISO 8601 en UTC: `AAAA-MM-DDTHH:MM:SSZ`. |

Campos opcionales, con la semántica del estándar externo `04_metadata_and_field_schemas.md`: `domain`, `author`, `maintainers`, `license`, `agent_visibility`, `tool_access_level`, `execution_mode`, `priority`, `timeout_seconds`, `dependencies`, `parent_doc`, `related_specs` y `entrypoint`. Cualquier otro campo es un error.

Formato restringido, para poder validarlo sin un parser YAML:

- El bloque empieza en la línea 1 con `---` y termina con `---`.
- Una clave por línea; las listas van en línea (`[a, b]`).
- Comillas dobles cuando el valor contiene `:`.

Excepciones:

- ADR: `status` usa los valores de MADR (`proposed`, `accepted`, `rejected`, `deprecated` o `superseded by NNNN`). `updated_at` sustituye al campo `date` de MADR, se admiten además `decision-makers`, `consulted` e `informed`, y el prefijo del `id` es `adr`.
- `.github/instructions/*.instructions.md`: solo el frontmatter de Copilot (`applyTo` y `description`).
- `CLAUDE.md` y `.github/copilot-instructions.md`: sin frontmatter, porque son adaptadores que la herramienta inyecta completos.

### Consecuencias

- Positivo: cada documento ofrece un resumen verificable y legible por scripts, sin dependencias.
- Negativo: `updated_at` se actualiza a mano; el chequeo valida su formato, no si está al día.
- Negativo: no se admite YAML multilínea en la cabecera.
- Negativo: la inmutabilidad del `id` no se comprueba de forma automática.

### Confirmación

`scripts/checks/headers.sh` valida campos, valores, unicidad de `id` y secciones obligatorias. yamllint valida la sintaxis YAML de cada cabecera.
