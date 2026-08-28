---
id: bp_01m1343cyyf71vk7bxqkgng6va
name: 19_task_artifacts_and_state_retention
title: "Task Artifacts y Retención de Memoria Operativa en Sesiones Agénticas"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/19_task_artifacts_and_state_retention.md
version: 1.0.0
category: agentic
tags: [task-artifacts, state-retention, episodic-memory, working-memory, progress-tracking, agentic-workflows]
description: "Práctica de generación, estructuración y persistencia de artefactos de tarea para retener memoria operativa a lo largo de sesiones multi-turno."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 19 - Task Artifacts y Retención de Memoria Operativa

Los modelos de lenguaje son *stateless* por naturaleza. En flujos multi-paso extensos donde el contexto se compacta o se reinicia entre sesiones, la única forma de retener memoria operativa y evitar loops repetitivos es la **persistencia estructurada de artefactos de tarea (*Task Artifacts*)**.

---

## 1. Tipos Canónicos de Artefactos de Tarea

| **Tipo de Artefacto** | **Ubicación Típica** | **Propósito Operativo** |
|:---|:---|:---|
| **Plan de Ejecución (`plan.md`)** | Directorio de tarea / scratch | Desglose de subtareas con checkboxes de estado en tiempo real. |
| **Bitácora de Investigación (`research.md`)** | Scratch space | Hallazgos del análisis de código antes de mutar el sistema. |
| **Registro de Decisiones (`decisions.md`)** | Docs / Scratch | Alternativas consideradas y compensaciones evaluadas durante la tarea. |

---

## 2. Estructura Estándar de un Artefacto de Tarea

```markdown
---
task_id: task_01j7w2b8k4r90v3ysx1pxk7y23
status: in_progress
created_at: 2026-08-27T17:00:00Z
---

# Plan de Implementación: Refactor de Módulo de Auth

## 1. Estado de Avance
- [x] Subtarea 1: Análisis estático y localización de llamadas deprecadas.
- [x] Subtarea 2: Creación de tests unitarios de caracterización.
- [/] Subtarea 3: Implementación del nuevo validador (En progreso).
- [ ] Subtarea 4: Validación de DoD y suite verde.

## 2. Invariantes Clave Descubiertas
- No alterar la firma del método público `authenticate_token()`.
```
