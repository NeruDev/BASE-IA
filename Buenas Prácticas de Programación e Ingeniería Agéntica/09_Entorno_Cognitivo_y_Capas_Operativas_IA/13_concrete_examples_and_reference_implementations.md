---
id: bp_01m1343cyzfnzs6rbvwpd9zn95
name: 13_concrete_examples_and_reference_implementations
title: "Ejemplos Concretos e Implementaciones de Referencia (Few-Shot in-Repo)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/13_concrete_examples_and_reference_implementations.md
version: 1.0.0
category: agentic
tags: [examples, few-shot, reference-implementations, in-context-learning, canonical-code, ci-testing]
description: "Guía para el diseño de carpetas de ejemplos canónicos que proporcionen a los modelos de lenguaje patrones de código ejecutables y testeados en CI."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 13 - Ejemplos Concretos e Implementaciones de Referencia

En el aprendizaje en contexto (*In-Context Learning*), **un ejemplo de código concreto, reproducible y testeado vale más que diez páginas de prosa filosófica**.

---

## 1. Jerarquía de Directorios de Ejemplos (`examples/`)

```
examples/
├── 01_basic_usage/        # Caso de uso elemental (mínimas dependencias)
├── 02_intermediate_flow/  # Flujo con persistencia y manejo de errores
└── 03_advanced_pipeline/  # Orquestación distribuida y streaming
```

---

## 2. La Regla de Oro: Los Ejemplos son Tests Activos en CI

- ⛔ **Prohibido mantener ejemplos rotos:** Un ejemplo desactualizado genera alucinaciones inmediatas en los agentes que lo usan como referencia *few-shot*.
- ✅ **Validación en CI:** Todo archivo dentro de `examples/` debe ejecutarse y validarse como parte de la suite de integración en CI/CD:
  ```bash
  pytest tests/integration/test_examples.py
  ```
