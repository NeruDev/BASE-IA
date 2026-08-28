---
id: bp_7ft93k5kbxbc9t8g962jjhwmwe
name: 07_tool_aware_instructions
title: "Instrucciones Conscientes de Herramientas (Tool-Aware Instructions)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/07_tool_aware_instructions.md
version: 1.1.0
category: agentic
tags: [tool-aware, function-calling, tool-use, mcp, cli-commands, powershell-bash, universal_principles]
description: "Instrucciones Conscientes de Herramientas: documentación explícita de comandos exactos, scripts y herramientas disponibles."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 07 - Instrucciones Conscientes de Herramientas (Tool-Aware Instructions)

## 1. Definición y Fundamento Teórico

Basada en el paradigma de **Invocación de Herramientas (*Tool Calling / Function Calling*)** y en el protocolo **MCP (Model Context Protocol)**, la práctica de **Instrucciones Conscientes de Herramientas** establece:

> *"Las directivas operativas del proyecto deben documentar explícitamente el catálogo de herramientas nativas, scripts utilitarios y comandos de terminal exactos compatibles con el sistema operativo anfitrión (Windows/PowerShell vs. Linux/Bash), guiando al agente de IA para que invoque las herramientas precisas con sus parámetros idóneos sin recurrir a comandos adivinados o incompatibles."*

Esta disciplina elimina el ensayo y error en la terminal, proveyendo al modelo una **matriz de capacidades ejecutable**.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Incompatibilidades de Sistema Operativo:** Evita que el agente intente ejecutar `grep`, `cat` o pipelines de Bash cuando opera en un shell PowerShell de Windows.
- **Prevención de Comandos de Prueba Equivocados:** Asegura que el agente utilice el gestor correcto (`uv run pytest` en lugar de un `pytest` global desfasado).
- **Aprovechamiento Óptimo de Herramientas Especializadas:** Fomenta el uso de herramientas semánticas avanzadas (`view_file`, `replace_file_content`, `grep_search`) en lugar de comandos toscos de terminal.

## 3. Relevancia en Sistemas con IA Agéntica

- **Reducción de Fallos en Tool Calling:** Proporciona los esquemas y ejemplos de parámetros válidos para cada herramienta expuesta al LLM.
- **Aceleración del Bucle de Verificación:** El agente sabe exactamente qué script invocar para validar su trabajo en un solo paso (`python scripts/validate.py`).
- **Seguridad en la Ejecución:** Impide que el agente intente instalar dependencias globales o modificar permisos del sistema operativo.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: El Agente Adivina Comandos y Falla por OS Incompatible)

```text
# Situación: El agente opera en Windows (PowerShell) sin instrucciones sobre herramientas.
# ANTIPATRÓN: El agente intenta ejecutar comandos de Linux:
Agente: `run_command(CommandLine="cat src/billing/tax.py | grep def")`
Salida: "The term 'grep' is not recognized as the name of a cmdlet..."
Agente: `run_command(CommandLine="export PYTHONPATH=.")`
Salida: "The term 'export' is not recognized..."
# RESULTADO: 5 turnos desperdiciados por falta de instrucciones conscientes del entorno.
```

### ✅ Instrucciones Tool-Aware en `AGENTS.md` (Compatibles y Precisas)

```markdown
# Catálogo de Herramientas y Comandos Operativos (AGENTS.md)

## 💻 Entorno de Ejecución
- **Sistema Operativo:** Windows 11 (Shell: `pwsh` / PowerShell).
- **Prohibido:** No usar comandos de Linux incompatibles (`grep`, `cat`, `export`, `sed`).
- **Preferencia:** Utilizar siempre las herramientas nativas del agente (`view_file`, `grep_search`, `replace_file_content`) en lugar de scripts de shell cuando sea posible.

## 🛠️ Matriz de Comandos de Terminal Exactos
| Tarea | Comando Canónico Exacto |
| :--- | :--- |
| **Validación Total** | `python scripts/validate.py` |
| **Ejecutar Tests** | `uv run pytest tests/unit/` |
| **Linting y Fix** | `uv run ruff check --fix src/` |
| **Formateo** | `uv run ruff format src/` |
| **Chequeo de Tipos** | `uv run mypy --strict src/` |
| **Auditoría de Seguridad**| `uv run bandit -r src/ -q` |
```

## 5. Descripción Didáctica de los Cambios

1. **Declaración del Entorno:** Se especifica que el shell es PowerShell en Windows, prohibiendo comandos de Linux no disponibles.
2. **Preferencia por Herramientas Nativas:** Se instruye al agente a priorizar `view_file` y `replace_file_content` sobre comandos de consola.
3. **Comandos Prefijados con `uv run`:** Garantiza que las herramientas se ejecuten dentro del entorno virtual determinista del proyecto.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Mantenimiento ante Cambios de Tooling:** Si el proyecto migra de `pytest` a otro runner de pruebas, la tabla en `AGENTS.md` debe actualizarse inmediatamente para no desorientar a los agentes.

## 7. Checklist de Verificación

- [ ] ¿Se especifica el sistema operativo y shell de ejecución (Windows/PowerShell vs. Linux/Bash)?
- [ ] ¿Los comandos de validación y testing están documentados con su sintaxis exacta y flags correspondientes?
- [ ] ¿Se instruye al agente a priorizar herramientas nativas sobre comandos crudos de terminal?
- [ ] ¿Se verificó que todos los comandos documentados se ejecuten exitosamente sin errores de sintaxis?