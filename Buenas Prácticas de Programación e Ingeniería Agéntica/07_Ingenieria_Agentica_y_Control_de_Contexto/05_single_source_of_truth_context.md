---
id: bp_76krx070fsa65vfaj6ewtc5nry
name: 05_single_source_of_truth_context
title: "Fuente Única de Verdad para Contexto de IA"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/05_single_source_of_truth_context.md
version: 1.1.0
category: agentic
tags: [single-source-of-truth, ssot, agents-md, claude-md, cursorrules, ai-governance, universal_principles]
description: "Fuente Única de Verdad de Contexto: AGENTS.md central con adaptadores mínimos para herramientas de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 05 - Fuente Única de Verdad para Contexto de IA

## 1. Definición y Fundamento Teórico

Basado en el principio de **Fuente Única de Verdad (Single Source of Truth - SSOT)** y en el **Patrón Adaptador (*Adapter Pattern*)**, el enfoque de **SSOT para Contexto de IA** postula:

> *"Todas las directivas de desarrollo, restricciones de seguridad y estándares de calidad para modelos de lenguaje deben residir en un único archivo canónico y autoritativo (`AGENTS.md`), utilizando los archivos específicos de cada proveedor o IDE (`CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.copilot-instructions.md`) exclusivamente como adaptadores delgados (*Thin Adapters*) que apuntan al archivo central."*

Este modelo evita la fragmentación de reglas y asegura que cualquier agente, sin importar el cliente o modelo utilizado, opere bajo el mismo conjunto inmutable de políticas.

```text
                        ┌───────────────────────────────┐
                        │      AGENTS.md (SSOT Central) │
                        └───────────────┬───────────────┘
                                        │ (Referenciado por)
         ┌──────────────────────────────┼──────────────────────────────┐
         ▼                              ▼                              ▼
 ┌───────────────┐              ┌───────────────┐              ┌───────────────┐
 │   CLAUDE.md   │              │   GEMINI.md   │              │  .cursorrules │
 │ (Thin Pointer)│              │ (Thin Pointer)│              │ (Thin Pointer)│
 └───────────────┘              └───────────────┘              └───────────────┘
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de Políticas Contradictorias:** Evita que un asistente aplique reglas de testing de hace 6 meses mientras otro asistente aplica reglas nuevas.
- **Mantenimiento Cero Duplicado:** Actualizar una directiva de linters o comandos de build se realiza en un único archivo (`AGENTS.md`) y se propaga instantáneamente a todas las herramientas.
- **Independencia de Proveedor (*Vendor Independence*):** No ata el repositorio a las convenciones de un único asistente o editor.

## 3. Relevancia en Sistemas con IA Agéntica

- **Armonización de Enjambres Multi-Asistente:** Permite a equipos heterogéneos donde unos usan Claude Code, otros Gemini CLI y otros Cursor o Copilot trabajar sobre la misma base de código sin conflictos.
- **Auditoría Centralizada:** Simplifica la revisión de políticas de IA en un solo Pull Request enfocado en `AGENTS.md`.
- **Compatibilidad con Nuevas Herramientas:** Si surge un nuevo asistente en el mercado, solo se añade un nuevo puntero delgado de 2 líneas hacia `AGENTS.md`.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Múltiples Archivos de Reglas Desincronizados)

```text
# Antipatrón: 4 archivos independientes con directivas divergentes
- AGENTS.md: "Usar Python 3.11 y uv sync"
- CLAUDE.md: "Usar Python 3.10 y poetry install" (Desactualizado)
- .cursorrules: "Usar pip install -r requirements.txt" (Contradictorio)
- .github/copilot-instructions.md: "Usar Flake8 para linting" (En conflicto con Ruff)
RESULTADO: Cada asistente genera código con herramientas diferentes y rompe el repositorio.
```

### ✅ Estructura Correcta (Conforme a SSOT: AGENTS.md Central + Thin Adapters)

Archivo Central Autoritativo (`AGENTS.md`):
```markdown
# Directivas Canónicas del Proyecto (AGENTS.md)

Este documento es la ÚNICA fuente de verdad autoritativa para asistentes de IA.

## Reglas Principales
1. Gestor de paquetes: `uv` (prohibido `pip` / `poetry`).
2. Linter y Formato: `ruff check --fix` y `ruff format`.
3. Verificación de Tipos: `mypy --strict src/`.
4. Commits: Conventional Commits (`feat:`, `fix:`, `chore:`).
```

Adaptador para Claude (`CLAUDE.md`):
```markdown
# Directivas para Claude Code

Consulta y obedece estrictamente las directivas canónicas definidas en:
[`AGENTS.md`](./AGENTS.md)
```

Adaptador para Cursor (`.cursorrules`):
```markdown
# Cursor Rules Adapter
Por favor, lee y adhiérete estrictamente a las directivas centrales en `AGENTS.md`.
Todas las reglas de tipado, linters y validación están centralizadas en ese archivo.
```

Adaptador para GitHub Copilot (`.github/copilot-instructions.md`):
```markdown
# GitHub Copilot Instructions
Follow all architectural standards and commands specified in `AGENTS.md`.
```

## 5. Descripción Didáctica de los Cambios

1. **Centralización Absoluta:** Todas las directivas residen en `AGENTS.md`.
2. **Adaptadores Mínimos:** Los archivos propietarios (`CLAUDE.md`, `.cursorrules`, `copilot-instructions.md`) contienen solo 2 líneas que redirigen al archivo central.
3. **Cero Mantenimiento Duplicado:** Al cambiar a una nueva versión de linter, solo se edita `AGENTS.md`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Herramientas Sin Soporte de Enlaces Externos:** Si un asistente no tiene la capacidad de leer archivos locales referenciados en su prompt de sistema, se puede utilizar un script de pre-commit que sincronice mecánicamente el contenido de `AGENTS.md` en los demás archivos.
- **Configuraciones Específicas de IDE:** Si Cursor requiere opciones técnicas exclusivas (ej. paths de extensiones), estas pueden coexistir en `.cursorrules` manteniendo las directivas de código enlazadas a `AGENTS.md`.

## 7. Checklist de Verificación

- [ ] ¿Todas las directivas operativas residen en el archivo canónico `AGENTS.md`?
- [ ] ¿Los archivos `CLAUDE.md`, `.cursorrules` y `copilot-instructions.md` actúan como punteros delgados hacia `AGENTS.md`?
- [ ] ¿Se eliminaron reglas de código duplicadas o contradictorias entre los distintos archivos de configuración?
- [ ] ¿Cualquier actualización de directivas técnicas se realiza exclusivamente en `AGENTS.md`?