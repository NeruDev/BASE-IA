---
id: bp_01m1343cyvf078c8s8wp2gxhr3
name: 17_no_unrelated_changes_and_change_budget
title: "No Unrelated Changes y Presupuesto de Modificación (Change Budget)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/17_no_unrelated_changes_and_change_budget.md
version: 1.0.0
category: agentic
tags: [change-budget, scope-creep, guardrails, diff-hygiene, blast-radius, agent-safety]
description: "Directrices estrictas para limitar el alcance de mutación de los agentes, prohibiendo modificaciones no relacionadas y fijando un presupuesto máximo de cambios."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 17 - No Unrelated Changes y Presupuesto de Modificación (Change Budget)

Uno de los comportamientos anómalos más comunes en agentes autónomos es el **hiperactivismo o Scope Creep**: mientras corrigen un bug en un archivo, deciden reformatear módulos adyacentes, actualizar dependencias no relacionadas o alterar comentarios existentes.

---

## 1. La Regla Inviolable: "No Unrelated Changes"

- ⛔ **Prohibición Taxativa:** El agente **únicamente** puede modificar los archivos explícitamente requeridos para resolver la tarea actual.
- ⛔ **Prohibición de Refactorizaciones Adyacentes Espurias:** Si un archivo importado contiene una función obsoleta pero la tarea no pide refactorizarla, el agente debe dejarla intacta.

---

## 2. El Concepto de "Change Budget" (Presupuesto de Cambios)

Para acotar el radio de impacto (*Blast Radius*):

| **Dimensión de la Tarea** | **Límite de Archivos Tocados** | **Límite de Líneas Modificadas (Diff)** |
|:---|:---:|:---:|
| **Corrección de Bug (Bugfix)** | Máx. 1 a 3 archivos | Máx. 50 líneas |
| **Nueva Feature Pequeña** | Máx. 3 a 5 archivos | Máx. 200 líneas |
| **Refactorización Aislada** | Máx. 5 archivos | Máx. 300 líneas |

---

## 3. Protocolo de Auditoría del Diff Pre-Commit

Antes de emitir cualquier commit o finalizar el turno, el agente debe inspeccionar el diff:
```bash
git diff --stat
```
Si el diff muestra cambios en archivos fuera de la lista blanca de la tarea, el agente debe descartarlos inmediatamente (`git checkout -- <archivo_no_relacionado>`).
