---
id: tmpl_pcrtm16egn49ry9d3jth5j623v
name: playbook_template
title: "Plantilla de Memoria Procedimental y Manual Operativo (PLAYBOOK.md)"
file_path: modules/memory/PLAYBOOK_template.md
version: 2.0.0
category: templates
tags: [memory, procedural, playbook, sops, runbooks, workflows, troubleshooting]
description: "Compendio de procedimientos operativos estándar (SOPs), recetas de despliegue y solución de problemas recurrentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Manual de Procedimientos Operativos (PLAYBOOK.md)

Este documento constituye la **memoria procedimental** del repositorio, documentando recetas canónicas paso a paso (SOPs) para tareas operativas repetibles.

---

## SOP-01: Procedimiento para Agregar un Nuevo Módulo

1. **Definición de Interfaz:** Crear el protocolo o interfaz abstracta en la capa de dominio.
2. **Implementación de Adaptador:** Desarrollar la clase concreta en la capa de adaptadores/infraestructura.
3. **Pruebas Unitarias con Mocks:** Añadir suite de tests en `tests/` con fixtures deterministas.
4. **Registro en Manifiesto:** Si aplica, actualizar `repo_manifest.jsonc`.
5. **Auditoría de Arquitectura:** Ejecutar `python validators/validate_architecture.py` para asegurar 0 violaciones de importación.

---

## SOP-02: Procedimiento de Diagnóstico ante Fallos en CI

1. **Inspección de Logs:** Identificar el step exacto que falló (linter, test unitario o validador de metadatos).
2. **Reproducción Local:**
   ```bash
   # Ejecutar linters
   ruff check .
   # Ejecutar tests
   pytest -v
   # Ejecutar validadores de metadatos
   python validators/validate_metadata.py
   ```
3. **Corrección Atómica:** Aplicar la corrección sin modificar código no relacionado.
4. **Verificación Local:** Re-ejecutar la suite completa antes del commit.
