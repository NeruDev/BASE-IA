---
id: bp_01m1343cyzez2rt2agmqp1ffvz
name: 20_agent_evaluation_and_benchmarking
title: "Evaluación Sistemática y Benchmarking de Agentes de IA en el Repositorio"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/20_agent_evaluation_and_benchmarking.md
version: 1.0.0
category: agentic
tags: [agent-evaluation, benchmarking, swe-bench, pass-at-1, regression-testing, eval-sets, quantitative-metrics]
description: "Metodología y herramientas para evaluar y benchmarkear cuantitativamente el desempeño, consumo de tokens y tasa de éxito de agentes en el repositorio."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 20 - Evaluación Sistemática y Benchmarking de Agentes de IA

Evaluar la calidad de las instrucciones y la arquitectura agéntica de un repositorio no puede basarse en pruebas anecdóticas (*"probé un prompt y funcionó"*). Requiere un **arnés de evaluación sistemático** basado en casos reales resueltos y métricas cuantitativas (*SWE-bench framework*).

---

## 1. Métricas Cuantitativas Clave

1. **Pass@1:** Proporción de tareas resueltas exitosamente en el primer intento sin asistencia humana.
2. **Tasa de Regresión:** Número de tests previamente verdes que fallaron tras la intervención del agente.
3. **Consumo Promedio de Tokens:** Costo computacional promedio por tarea resuelta.
4. **Llamadas Redundantes a Herramientas:** Cantidad de consultas duplicadas al sistema de archivos causadas por falta de memoria operativa.

---

## 2. Diseño de Suites Internas de Evaluación (*Eval Sets*)

```mermaid
flowchart LR
    Issue["Issue Real Resuelto"] --> Freeze["Congelar Commit Previo (Repo Snapshot)"]
    Freeze --> Prompt["Generar Prompt Estandarizado"]
    Prompt --> Agent["Ejecución de Agente Autónomo"]
    Agent --> Patch["Generación de Patch / Diff"]
    Patch --> Harness["Arnés de Verificación Automática (pytest)"]
    Harness --> Score["Métrica Pass / Fail + Reporte de Telemetría"]
```
