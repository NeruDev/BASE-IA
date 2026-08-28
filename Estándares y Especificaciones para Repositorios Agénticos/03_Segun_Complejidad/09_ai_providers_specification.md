---
id: spec_63evsy15jhb1yay7srswp0cjbm
name: 09_ai_providers_specification
title: "Especificación de Archivos para Proveedores de IA (CLAUDE, GEMINI, COPILOT, CURSOR)"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/09_ai_providers_specification.md
version: 1.0.0
category: templates
tags: [ai-providers, claude, gemini, copilot, cursor, prompt-engineering]
description: "Especificación de archivos para proveedores de IA (CLAUDE.md, GEMINI.md, copilot)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 09 - Especificación de Archivos para Proveedores de IA

## 1. Definición y Estrategia Anti-Duplicación

### El Desafío del Ecosistema Multimodal

Diversas herramientas de asistencia de código requieren archivos con nombres propios:

- CLAUDE.md: Claude Code

- GEMINI.md: Gemini CLI

- .github/copilot-instructions.md: GitHub Copilot

- .cursorrules: Cursor IDE

### Estrategia de Arquitectura Recomendada:

Para evitar mantener 4 archivos duplicados:

1.  AGENTS.md contiene la **verdad canónica y universal** del repositorio.

2.  Los archivos específicos de cada proveedor actúan como **punteros ligeros** que referencian AGENTS.md y configuran únicamente particularidades de su interfaz.

## 2. Plantillas Canónicas por Proveedor

### CLAUDE.md (Para Claude Code)

# Instrucciones para Claude Code

Este repositorio se rige por [AGENTS.md](AGENTS.md) y [ARCHITECTURE.md](ARCHITECTURE.md).

## Comandos Principales

- Tests: `pytest tests/unit/`

- Linter: `ruff check . && black --check .`

- Typecheck: `mypy src/`

## Reglas Clave

- Respeta estrictamente los Google Docstrings en todo código nuevo.

- Nunca elimines pruebas existentes.

### GEMINI.md (Para Gemini CLI)

# Instrucciones para Gemini CLI

Consulta el contrato operativo en [AGENTS.md](AGENTS.md).

Mantén tipado estricto con Python `typing` y validación Pydantic v2.

### .github/copilot-instructions.md (Para GitHub Copilot)

# GitHub Copilot Custom Instructions

- Genera código compatible con Python 3.11+.

- Usa Google Style Docstrings con secciones `Args:`, `Returns:`, `Raises:`.

- No generes llamadas `print()` en funciones de negocio; usa el sistema centralizado de logging.