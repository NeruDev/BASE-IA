---
id: bp_588chn9repaha9trhvmwc3s4ey
name: 11_phased_execution_and_specialized_roles
title: "Flujo de Ejecución por Fases y Roles Agénticos Especializados"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/11_phased_execution_and_specialized_roles.md
version: 1.1.0
category: agentic
tags: [phased-execution, specialized-roles, multi-agent, architect-coder-tester-reviewer, workflow, universal_principles]
description: "Flujo por Fases y Roles Especializados: pipeline secuencial de Architect, Developer, Tester y Reviewer."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 11 - Flujo de Ejecución por Fases y Roles Agénticos Especializados

## 1. Definición y Fundamento Teórico

Basada en la teoría de **Sistemas Multi-Agente Basados en Roles (Role-Based Multi-Agent Systems - MAS)** y en las metodologías de desarrollo por etapas (**Phased Engineering Pipelines**), esta práctica postula:

> *"Las tareas complejas de desarrollo de software no deben confiarse a un único agente monolítico generalista; deben descomponerse en una secuencia estricta de fases ejecutadas por subagentes con roles especializados (*Architect, Developer, Tester, Reviewer*), donde cada rol opera con un prompt de sistema enfocado, herramientas delimitadas y criterios de validación formales antes de transferir el artefacto a la siguiente fase."*

El flujo canónico de 4 etapas opera de forma secuencial:

```text
 ┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
 │  1. ARCHITECT        │ ──► │  2. DEVELOPER (Coder)│ ──► │  3. TESTER (QA)      │ ──► │  4. REVIEWER (Audit) │
 │  Diagnóstico y Plan  │     │  Implementación Pura │     │  Pruebas y Casos Edge│     │  Diff & Seguridad    │
 └──────────────────────┘     └──────────────────────┘     └──────────────────────┘     └──────────────────────┘
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del 'Sesgo de Confirmación' (*Confirmation Bias*):** Un agente que escribe el código tiende a escribir tests complacientes que pasan por alto sus propios errores.
- **Enfoque Atencional Agudo:** Cada rol opera con un contexto más ligero y especializado, maximizando su precisión técnica.
- **Auditoría Independiente de Calidad y Seguridad:** El rol Reviewer no escribió el código y lo audita con una postura crítica e imparcial.

## 3. Relevancia en Sistemas con IA Agéntica

- **Alineación con Subagentes Nativos (`invoke_subagent`):** Permite invocar subagentes especializados (`research`, `coder`, `security-auditor`) en paralelo o secuencia.
- **División de Responsabilidades en Tareas de Gran Escala:** Facilita que proyectos complejos se resuelvan de forma ordenada sin saturar una sola ventana de contexto.
- **Reducción de Alucinaciones Cruzadas:** El desarrollador no tiene que adivinar la arquitectura porque ya recibió el plan aprobado del arquitecto.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Agente Monolítico Generalista Sobrecargado)

```text
# Antipatrón: Un solo agente intenta hacerlo todo a la vez:
Prompt: "Investiga el bug, rediseña la arquitectura, escribe el código, haz los tests y haz el deploy."
# RESULTADO:
# El modelo sufre sobrecarga atencional, escribe tests incompletos que no prueban casos límite,
# ignora los principios de seguridad y reporta un falso éxito sin haber revisado su propio diff.
```

### ✅ Flujo Correcto (Conforme a Fases y Roles Especializados)

Definición de Roles en el Sistema Agéntico (`.agent/roles/`):
```text
.agent/roles/
├── 01_architect.md      # Prompt enfocado en: Diagnóstico, patrones, ADRs y Plan
├── 02_developer.md      # Prompt enfocado en: Código limpio, tipado estricto y PEP 8
├── 03_tester.md         # Prompt enfocado en: Casos límite, Pytest, BDD y Golden Tests
└── 04_reviewer.md       # Prompt enfocado en: SAST, diff inspection y guardrails
```

Protocolo de Ejecución:
```text
Fase 1 (Architect): Inspecciona el repo y emite el artefacto `PLAN.md` con las interfaces requeridas.
Fase 2 (Developer): Lee `PLAN.md` e implementa exclusivamente la lógica en `src/billing/` cumpliendo los tipos.
Fase 3 (Tester): Diseña `tests/unit/billing/test_tax.py` con pruebas de mutación y casos extremos.
Fase 4 (Reviewer): Ejecuta `bandit`, audita el `git diff` y emite el informe final de aprobación.
```

## 5. Descripción Didáctica de los Cambios

1. **Separación de Responsabilidades:** Cada fase produce un artefacto intermedio claro y auditable (`PLAN.md`, `src/`, `tests/`, `REVIEW.md`).
2. **Independencia del Tester:** Las pruebas son diseñadas con una mentalidad adversarial que busca activamente romper el código del desarrollador.
3. **Control de Calidad Riguroso:** Ningún cambio llega a `main` sin pasar por la auditoría del Reviewer.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Tareas Atómicas Simples:** Para fixes de 2 líneas (ej. corregir un typo en una constante), convocar el pipeline de 4 roles añade sobrecarga innecesaria; un solo agente con auto-verificación es suficiente.

## 7. Checklist de Verificación

- [ ] ¿Las tareas complejas se dividen en fases claras (Plan -> Code -> Test -> Review)?
- [ ] ¿Los roles cuentan con directivas y prompts especializados para su función?
- [ ] ¿El rol de testing/review audita de forma independiente el código antes de la entrega final?
- [ ] ¿Cada fase produce un artefacto verificable antes de transferir el control a la siguiente?