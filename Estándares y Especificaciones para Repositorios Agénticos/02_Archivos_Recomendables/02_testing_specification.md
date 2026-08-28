---
id: spec_19mft06by7axgt36zq111bnhw6
name: 02_testing_specification
title: "Especificación y Plantilla Maestra de TESTING.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/02_testing_specification.md
version: 1.0.0
category: templates
tags: [testing, pytest, mocks, coverage, quality-assurance, guardrails]
description: "Especificación y plantilla de TESTING.md (pirámide de tests, fixtures y regla de inmutabilidad)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 02 - Especificación y Plantilla Maestra de TESTING.md

## 1. Definición y Propósito del Archivo

### ¿Qué es TESTING.md?

TESTING.md documenta la estrategia de aseguramiento de calidad (QA), la pirámide de pruebas, las políticas de cobertura y las reglas de mockeo e inmutabilidad de la suite de tests.

### ¿Por qué existe y qué problemas resuelve?

- **Disciplina de Calidad:** Define cómo estructurar tests unitarios, de integración y end-to-end.

- **Guardrail Crítico para Agentes:** **Prohíbe terminantemente que los agentes eliminen o relajen aserciones de pruebas existentes para forzar que el pipeline pase.** Si un test falla, el agente debe corregir el código productivo o la causa raíz.

## 2. Plantilla Maestra Canónica de TESTING.md

# Estrategia y Guía de Pruebas (TESTING.md)

Este documento rige la arquitectura de pruebas, convenciones de testeo y políticas de ejecución del repositorio.

---

## 1. Pirámide y Estructura de Tests

```yaml
estructura_tests:
  tests:
    unit: "Pruebas unitarias de dominio puro (sin I/O ni red, < 50ms)"
    integration: "Pruebas de integración con adapters y bases de datos locales"
    e2e: "Pruebas de extremo a extremo de pipelines completos"
```

## 2. Reglas Inviolables para Agentes y Desarrolladores

1.  **Inmutabilidad de Pruebas ante Fallos:**

    - ⛔ **PROHIBIDO ELIMINAR O COMENTAR TESTS** que estén fallando para simular éxito.

    - ⛔ **PROHIBIDO RELAJAR ASERCIONES** (assert) sin justificación arquitectónica aprobada.

2.  **Aislamiento de Dominio:**

    - Toda prueba en tests/unit/ debe ejecutarse en memoria y finalizar en < 50ms.

    - Utilizar unittest.mock o pytest-mock para cualquier dependencia externa.

## 3. Comandos de Ejecución

```bash
# Ejecutar suite completa con reporte de cobertura
pytest --cov=src tests/ --cov-report=term-missing

# Ejecutar únicamente tests unitarios
pytest tests/unit/

# Ejecutar tests con depuración y verbose
pytest -vv -s tests/integration/
```