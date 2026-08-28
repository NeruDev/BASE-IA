---
id: bp_01m13428cpfa29mmwkyc31wz9v
name: 13_acceptance_criteria_and_definition_of_done
title: "Criterios de Aceptación Objetivos y Definition of Done (DoD) Ejecutable"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/13_acceptance_criteria_and_definition_of_done.md
version: 1.0.0
category: code_standards
tags: [definition-of-done, acceptance-criteria, verification, quality-gate, prompt-engineering, determinism]
description: "Especificación de criterios de aceptación objetivos y definición formal de una Definition of Done (DoD) ejecutable y determinista para tareas asignadas a agentes de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 13 - Criterios de Aceptación Objetivos y Definition of Done (DoD) Ejecutable

Para un agente de Inteligencia Artificial, las instrucciones vagas como *"optimiza el código"* o *"agrega autenticación y haz que quede bien"* resultan inútiles y conducen a alucinaciones. Toda tarea asignada debe incluir **Criterios de Aceptación Objetivos** y regirse por una **Definition of Done (DoD) Ejecutable**.

---

## 1. La Definition of Done (DoD) Canónica

Ninguna tarea se considera finalizada por el agente a menos que cumpla **el 100% de la siguiente lista de verificación automatizable**:

```mermaid
flowchart LR
    Task["Tarea Asignada"] --> T1["1. Tests Unitarios Pasan (pytest)"]
    T1 --> T2["2. Tipos Estáticos Verificados (mypy)"]
    T2 --> T3["3. Linter y Formato Limpios (ruff / black)"]
    T3 --> T4["4. Documentación Sincronizada (Docstrings)"]
    T4 --> T5["5. Diff Limpio (Sin artefactos espurios)"]
    T5 --> Done["✅ Tarea Finalizada con Éxito"]
```

---

## 2. Estructura de Tarea Óptima para Prompts Agénticos

Al asignar una tarea a un agente, estructurar la solicitud en el siguiente formato:

```markdown
### Objetivo de la Tarea
Implementar el validador de invariantes de número de serie en la entidad `Dispositivo`.

### Criterios de Aceptación (Gherkin / Verificables)
- [ ] Si el número de serie tiene menos de 8 caracteres, lanzar `ValidationError`.
- [ ] No permitir duplicados en memoria durante el registro.
- [ ] Agregar tests unitarios en `tests/unit/test_device_invariants.py` cubriendo casos límite.

### Comando de Validación DoD
`pytest tests/unit/test_device_invariants.py && mypy src/ && ruff check src/`
```

---

## 3. Automatización de la DoD mediante un Solo Comando

Para facilitar que el agente valide su trabajo con una sola llamada a herramienta, el repositorio debe proveer un script o tarea consolidada:

```bash
# Ejecutar verificación integral de la DoD
python scripts/validate_all.py
```
