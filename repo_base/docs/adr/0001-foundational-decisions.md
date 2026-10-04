---
id: adr_01m44g100tfshagvdez51cwg4v
name: 0001_foundational_decisions
title: "Decisiones fundacionales de la plantilla"
file_path: docs/adr/0001-foundational-decisions.md
category: architecture
tags: [adr, idioma, entorno, agents, madr, dependencias]
description: "Registra las decisiones previas a la construcción de la plantilla: idioma, entorno Windows/PowerShell, AGENTS.md como fuente única, MADR y ausencia de dependencias obligatorias."
status: accepted
updated_at: 2026-10-04T23:30:30Z
---

# 0001 — Decisiones fundacionales de la plantilla

## Contexto y planteamiento del problema

La plantilla será la base de los proyectos futuros de un único mantenedor que trabaja en VS Code con GitHub Copilot como asistente diario. Antes de construirla se fijaron cinco decisiones que condicionan su estructura y que un agente no debe revertir por su cuenta. Este ADR las agrupa como excepción; los siguientes registran una decisión cada uno.

## Factores de decisión

- Un solo mantenedor: pocos archivos, correctos y verificables.
- Documentation-as-Code: la documentación se valida y versiona como el código.
- Independencia del lenguaje del proyecto final.

## Opciones consideradas

| Tema | Opción elegida | Alternativas descartadas |
| --- | --- | --- |
| Idioma | Documentación en español; nombres de archivo en inglés | Todo en inglés; todo en español |
| Entorno | Windows con PowerShell como shell interactiva | Entorno Linux o WSL como requisito |
| Reglas para agentes | `AGENTS.md` como fuente única; `CLAUDE.md` y `.github/copilot-instructions.md` solo apuntan a él | Reglas duplicadas por herramienta |
| Registro de decisiones | MADR en `docs/adr/NNNN-titulo.md`, con índice en `docs/adr/README.md` | Sin registro; formato libre |
| Dependencias | Ninguna obligatoria de Python o Node; linters opcionales que degradan con aviso | Exigir una toolchain de Python o Node |

## Resultado de la decisión

Se adoptan las cinco opciones elegidas de la tabla. Por coherencia con el entorno sin dependencias, los scripts del repositorio se escriben en POSIX `sh`, que se ejecuta con el `sh` incluido en Git para Windows.

### Consecuencias

- Positivo: el repositorio funciona solo con Git para Windows y las reglas no se desincronizan entre herramientas.
- Positivo: los agentes conocen el porqué de cada convención y no la «corrigen».
- Negativo: sin linters instalados solo se validan los invariantes propios.
- Negativo: la mezcla de idiomas (contenido en español, nombres en inglés) requiere atención en las revisiones.

### Confirmación

- `scripts/checks/required-files.sh` exige `AGENTS.md`, los adaptadores y el índice de ADR.
- `scripts/checks/adr-numbering.sh` exige el formato `NNNN-titulo.md` y la presencia en el índice.
- `scripts/check.sh` emite un `AVISO`, en lugar de fallar, cuando falta un linter.

## Más información

El tema «Dependencias» y la regla de escribir todos los scripts en POSIX `sh` los sustituye el [ADR-0003](0003-scripting-languages.md). El resto de este ADR sigue vigente.
