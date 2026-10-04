---
id: adr_01m44m2cpxfk9a430anjd6jdmn
name: 0003_scripting_languages
title: "Lenguajes de script: POSIX sh, PowerShell 7 y Python en entorno virtual"
file_path: docs/adr/0003-scripting-languages.md
category: architecture
tags: [adr, shell, powershell, python, venv, json, dependencias]
description: "Amplía los lenguajes permitidos: la autoevaluación sigue en POSIX sh y las utilidades pueden usar PowerShell 7 o Python dentro de .venv/. Sustituye el tema Dependencias del ADR-0001."
status: accepted
updated_at: 2026-10-04T23:30:30Z
---

# 0003 — Lenguajes de script: POSIX sh, PowerShell 7 y Python en entorno virtual

## Contexto y planteamiento del problema

El [ADR-0001](0001-foundational-decisions.md) fijó «ninguna dependencia obligatoria de Python o Node» y, como consecuencia, que todos los scripts del repositorio se escribieran en POSIX `sh`. El mantenedor trabaja a diario con Python, JSON y PowerShell: limitarse a `sh` obliga a reescribir en `awk` utilidades que en Python son triviales y a no aprovechar la shell interactiva del entorno. Hay que decidir qué lenguajes se admiten sin perder la propiedad de que un clon recién creado pase la autoevaluación solo con Git para Windows.

## Factores de decisión

- La autoevaluación debe funcionar en cualquier clon sin instalar nada.
- Las utilidades del proyecto deben poder usar Python y JSON sin contaminar el sistema.
- Entorno Windows con PowerShell 7 como shell interactiva.

## Opciones consideradas

- Mantener solo POSIX `sh` para todo.
- POSIX `sh` para la autoevaluación; PowerShell 7 y Python en un entorno virtual para el resto.
- Migrar también la autoevaluación a Python.

## Resultado de la decisión

Opción elegida: «POSIX `sh` para la autoevaluación; PowerShell 7 y Python en un entorno virtual para el resto», porque amplía lo que se puede automatizar sin que `scripts/check.sh` dependa de un intérprete instalado.

| Ámbito | Lenguaje | Reglas |
| --- | --- | --- |
| Autoevaluación: `scripts/check.sh`, `scripts/checks/`, `.githooks/` | POSIX `sh` | Sin cambios: [shell.instructions.md](../../.github/instructions/shell.instructions.md). |
| Utilidades de Windows | PowerShell 7 (`pwsh`), archivos `.ps1` | UTF-8 sin BOM y LF. Windows PowerShell 5.1 no se admite: lee como ANSI los archivos sin BOM. |
| Utilidades y código Python | Python 3 en `.venv/` de la raíz | Entorno ignorado por git; dependencias declaradas en un archivo versionado; nunca `pip install` fuera del entorno. |
| Datos estructurados | JSON | UTF-8 y 2 espacios. JSONC solo en archivos de configuración cuya herramienta lo admite. |

Comandos del entorno virtual en PowerShell:

| Comando | Uso |
| --- | --- |
| `python -m venv .venv` | Crear el entorno, una vez por clon. |
| `.\.venv\Scripts\Activate.ps1` | Activarlo en cada sesión de terminal. |
| `python -m pip install -r requirements.txt` | Instalar las dependencias declaradas, con el entorno activo. |
| `deactivate` | Salir del entorno. |

Este ADR sustituye la fila «Dependencias» del ADR-0001 y la frase según la cual todos los scripts se escriben en POSIX `sh`. El resto del ADR-0001 sigue vigente.

### Consecuencias

- Positivo: Python, JSON y PowerShell se pueden usar sin reescribirlos en `sh`, y las dependencias de Python quedan aisladas por clon.
- Positivo: la autoevaluación sigue sin requisitos; un linter instalado en `.venv/` se detecta si el entorno está activo.
- Negativo: tres lenguajes en lugar de uno. Aún no hay linter para `.ps1` ni `.py`; se elegirá con el stack del proyecto.
- Negativo: `.venv/` es local; cada clon debe crearlo.

### Confirmación

- `.gitignore` ignora `.venv/`, de modo que `list_files`, markdownlint y yamllint no lo recorren.
- `scripts/check.sh` solo ejecuta scripts `sh`; shellcheck revisa los `.sh` de `scripts/` y los hooks.
