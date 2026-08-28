---
id: bp_01m13428cnf3a99thz9hnfq7eq
name: 12_continuous_refactoring
title: "Refactorización Continua: Preservación de Invariantes y Reducción de Deuda Técnica"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/12_continuous_refactoring.md
version: 1.0.0
category: code_standards
tags: [refactoring, code-quality, technical-debt, clean-code, invariants, automated-testing]
description: "Metodología y disciplina de refactorización continua de código para preservar la legibilidad y reducir la deuda técnica sin alterar el comportamiento observable."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 12 - Refactorización Continua y Preservación de Invariantes

La **Refactorización Continua** es la disciplina de modificar la estructura interna del código para mejorar su legibilidad, modularidad y mantenibilidad **sin alterar en absoluto su comportamiento observable externo ni sus contratos de dominio** (*Martin Fowler*).

---

## 1. Protocolo de Seguridad para Refactorización Agéntica

Un agente de IA solo puede ejecutar refactorizaciones si sigue estrictamente el siguiente protocolo determinista:

```mermaid
flowchart TD
    A["1. Ejecutar Suite de Tests Previa"] --> B{"¿Tests 100% Verdes?"}
    B -- ❌ No --> C["Detener: Corregir bugs funcionales antes de refactorizar"]
    B -- ✅ Sí --> D["2. Aplicar Refactorización Atómica (Micro-paso)"]
    D --> E["3. Ejecutar Suite de Tests Posterior"]
    E --> F{"¿Tests 100% Verdes?"}
    F -- ❌ No --> G["Rollback inmediato del micro-paso"]
    F -- ✅ Sí --> H["4. Commit atómico de refactorización ('refactor: ...')"]
```

---

## 2. Distinción: Refactorización vs Reescritura Arbitraria

- **Refactorización Legítima:** Extraer un método de 80 líneas en tres funciones puras con Google Docstrings, renombrar variables crípticas (`d` -> `telemetry_data`), reemplazar condicionales anidados con polimorfismo o pattern matching.
- **Reescritura Arbitraria (Prohibida para Agentes):** Reemplazar SQLite por MongoDB *"porque es más moderno"*, cambiar la biblioteca de testing de `pytest` a `unittest`, o alterar esquemas públicos de API sin un ADR aprobado.

---

## 3. Catálogo de Técnicas Esenciales

1. **Extract Method / Function:** Convertir bloques con responsabilidad propia en funciones independientes y testables.
2. **Rename Symbol:** Asignar nombres semánticos que reflejen la intención exacta del dominio.
3. **Introduce Parameter Object / Dataclass:** Reemplazar listas de 7 parámetros primitivos por un objeto o modelo Pydantic validado.
4. **Replace Conditional with Guard Clauses:** Salir temprano (*Early Return*) para reducir la complejidad ciclomática.
