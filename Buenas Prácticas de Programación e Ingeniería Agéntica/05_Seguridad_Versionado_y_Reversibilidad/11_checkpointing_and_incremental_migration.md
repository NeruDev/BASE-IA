---
id: bp_01m13428creymbvk9nj5xw7b2g
name: 11_checkpointing_and_incremental_migration
title: "Checkpointing, Commits de Seguridad y Migración Incremental para Tareas Agénticas"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/11_checkpointing_and_incremental_migration.md
version: 1.0.0
category: agentic
tags: [checkpointing, git-safety, reversibility, incremental-migration, rollback, agent-guardrails]
description: "Metodología de creación de puntos de control (checkpoints), commits de seguridad intermedios y migraciones incrementales para garantizar total reversibilidad en tareas agénticas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 11 - Checkpointing y Migración Incremental para Tareas Agénticas

Las tareas extensas ejecutadas por agentes autónomos (refactorizaciones multi-archivo, migraciones de librerías o actualización de documentación masiva) conllevan el riesgo de **destruir el estado previo** si el agente comete un error crítico en pasos avanzados.

---

## 1. El Protocolo de Checkpointing Agéntico

```mermaid
flowchart TD
    A["Inicio de Tarea Compleja"] --> B["1. Verificar Working Tree Limpio ('git status')"]
    B --> C["2. Crear Rama Temporal ('feature/tarea-checkpoint')"]
    C --> D["3. Ejecutar Subtarea 1"]
    D --> E["4. Validar Suite Local"]
    E -- Tests Pasan --> F["5. Checkpoint Commit ('checkpoint: subtarea 1 ok')"]
    E -- Tests Fallan --> G["Rollback a último checkpoint ('git reset --hard')"]
    F --> H{"¿Más subtareas?"}
    H -- Sí --> D
    H -- No --> I["6. Squash & Merge con Conventional Commit canónico"]
```

---

## 2. Comandos de Recuperación Deterministas

- **Crear Checkpoint Seguro:**
  ```bash
  git add -A && git commit -m "checkpoint(safety): snapshot previo a refactor de modulo_x"
  ```
- **Revertir a Checkpoint Anterior ante Alucinación o Error Fatal:**
  ```bash
  git reset --hard HEAD~1
  ```
- **Limpiar Cambios no Confirmados:**
  ```bash
  git clean -fd && git checkout -- .
  ```
