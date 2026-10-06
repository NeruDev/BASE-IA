---
id: doc_01m44g0zyqfmc9j4h37yf9b7ks
name: readme
title: "Índice de decisiones de arquitectura (ADR)"
file_path: docs/adr/README.md
category: architecture
tags: [adr, madr, indice, decisiones]
description: "Índice de los ADR del repositorio, con su estado, y plantilla MADR adaptada al esquema de frontmatter del repo."
status: active
updated_at: 2026-10-06T22:36:35Z
---

# Decisiones de arquitectura

Los ADR registran el porqué de las decisiones que un agente o una persona no deben revertir sin un ADR nuevo. Siguen el formato MADR, con el frontmatter de [ADR-0002](0002-frontmatter-schema.md). El procedimiento para crear uno está en [CONTRIBUTING.md](../../CONTRIBUTING.md).

## Índice

| ADR | Título | Estado |
| --- | --- | --- |
| [0001](0001-foundational-decisions.md) | Decisiones fundacionales de la plantilla | accepted |
| [0002](0002-frontmatter-schema.md) | Esquema de frontmatter para un repositorio individual | accepted |
| [0003](0003-scripting-languages.md) | Lenguajes de script: POSIX sh, PowerShell 7 y Python en entorno virtual (sustituye el tema Dependencias de 0001) | accepted |
| [0004](0004-repository-memory.md) | Memoria del repositorio: índice, entradas atómicas y presupuestos verificables | accepted |
| [0005](0005-ephemeral-workspace.md) | Trabajo efímero aislado, limpieza segura y promoción explícita | accepted |

## Plantilla

Las secciones marcadas como opcionales se pueden eliminar. Las tres secciones restantes son obligatorias y las comprueba `scripts/checks/headers.sh`.

```markdown
---
id: adr_<generar>
name: nnnn_titulo_en_kebab_case
title: "Título corto de la decisión"
file_path: docs/adr/NNNN-titulo-en-kebab-case.md
category: architecture
tags: [adr, tema]
description: "Decisión tomada y problema que resuelve, en una o dos frases."
status: proposed
updated_at: AAAA-MM-DDTHH:MM:SSZ
---

# NNNN — Título corto de la decisión

## Contexto y planteamiento del problema

Situación, fuerzas en juego y pregunta que hay que decidir.

## Factores de decisión (opcional)

- Factor 1

## Opciones consideradas

- Opción A
- Opción B

## Resultado de la decisión

Opción elegida: "Opción A", porque...

### Consecuencias

- Positivo: ...
- Negativo: ...

### Confirmación (opcional)

Cómo se verifica que la decisión se cumple (chequeo, revisión...).

## Ventajas y desventajas de las opciones (opcional)

## Más información (opcional)
```
