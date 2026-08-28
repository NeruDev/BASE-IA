---
id: bp_1hjd3h5y9sbravmfzvy625f9qv
name: 01_scoped_tasks
title: "Tareas Delimitadas (Scoped Tasks)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/01_scoped_tasks.md
version: 1.1.0
category: agentic
tags: [scoped-tasks, scope-creep, task-boundaries, agentic-engineering, prompt-contract, universal_principles]
description: "Tareas Delimitadas: definición formal de objetivos, archivos permitidos y prohibidos para evitar desvíos del agente."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 01 - Tareas Delimitadas (Scoped Tasks)

## 1. Definición y Fundamento Teórico

Originada en la disciplina de **Gestión de Alcance en Ingeniería de Software (PMI Scope Management)** y adaptada a la orquestación de modelos de lenguaje, la práctica de **Tareas Delimitadas (Scoped Tasks)** postula:

> *"Toda tarea delegada a un agente de IA debe encapsularse en un contrato operativo explícito que defina con precisión milimétrica su objetivo único, los archivos permitidos para edición, las zonas estrictamente prohibidas y los criterios de aceptación medibles, erradicando la improvisación y la deriva de alcance (*Scope Creep*)."*

Un contrato de tarea delimitada consta de cuatro elementos indispensables:
1. **Objetivo Único y Específico (*Single Goal*):** *"Corregir el redondeo de decimales en el cálculo de impuestos"*.
2. **Archivos Permitidos (*In-Scope*):** Lista explícita de rutas que el agente puede modificar.
3. **Archivos Prohibidos (*Out-of-Scope / Untouchable*):** Archivos que el agente tiene terminantemente prohibido alterar (ej. configuración de base de datos, infraestructura, dependencias).
4. **Criterio de Validación (*Definition of Done*):** Comando exacto que debe retornar código 0 (ej. `pytest tests/unit/billing/test_tax.py`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Refactorizaciones Descontroladas (*Scope Creep*):** Los LLMs tienden a "mejorar" archivos no relacionados o reorganizar carpetas enteras cuando se les da una orden ambigua.
- **Reducción de Regresiones Inesperadas:** Acotar los archivos modificables impide que el agente altere accidentalmente contratos de otros subsistemas.
- **Facilidad de Auditoría Humana:** Los revisores saben de antemano qué archivos debían cambiar y pueden detectar anomalías en segundos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Aislamiento en Enjambres de Agentes (*Multi-Agent Workflows*):** Permite a múltiples subagentes trabajar en paralelo en el mismo repositorio sin generar colisiones de edición.
- **Determinismo y Eficiencia de Tokens:** El agente concentra su razonamiento exclusivamente en los archivos autorizados sin dispersarse explorando módulos irrelevantes.
- **Guardrail de Seguridad Primario:** Impide que un agente con una tarea de backend toque manifiestos de CI/CD o claves de infraestructura.

## 4. Comparativa Didáctica de Código

### ❌ Prompt de Tarea Incorrecto (Antipatrón: Instrucción Vaga y Sin Límites)

```text
# Antipatrón: Prompt vago sin delimitación de archivos ni alcance
"Arregla el sistema de pagos y haz que el código sea más limpio."
# RESULTADO CATASTRÓFICO:
# 1. El agente renombra 15 archivos en src/billing/.
# 2. Actualiza librerías en pyproject.toml introduciendo breaking changes.
# 3. Borra 3 tests antiguos porque "fallaban".
# 4. Modifica la configuración de base de datos en docker-compose.yml.
```

### ✅ Contrato de Tarea Delimitada (Conforme a Scoped Tasks)

Plantilla de Tarea Estructurada (`.agent/task-contract.json` / Prompt de Tarea):
```json
{
  "task_id": "TASK-2026-08-FIX-TAX",
  "objective": "Corregir el error de redondeo bancario en el cálculo de IVA para montos fraccionarios.",
  "in_scope_files": [
    "src/billing/tax_calculator.py",
    "tests/unit/billing/test_tax_calculator.py"
  ],
  "forbidden_files": [
    "pyproject.toml",
    "uv.lock",
    "docker-compose.yml",
    "src/billing/models.py",
    "src/auth/*"
  ],
  "acceptance_criteria": {
    "command": "pytest tests/unit/billing/test_tax_calculator.py",
    "expected_exit_code": 0
  },
  "rules": [
    "No modificar la firma pública de calcular_iva(monto: Decimal) -> Decimal.",
    "Utilizar exclusivamente decimal.ROUND_HALF_EVEN.",
    "Diff total menor a 50 líneas."
  ]
}
```

## 5. Descripción Didáctica de los Cambios

1. **Límites Físicos Claros:** Se declaran explícitamente los 2 únicos archivos editables y las zonas prohibidas (`pyproject.toml`, `src/auth/*`).
2. **Criterio de Aceptación Cuantitativo:** Se especifica el comando exacto de validación sin ambigüedad.
3. **Restricción de Firma e Invariantes:** Se prohíbe romper la firma pública de la función existente.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Tareas de Exploración o Descubrimiento Arquitectónico:** En sesiones de diagnóstico de bugs desconocidos (*root-cause investigation*), delimitar archivos antes de saber cuál falla es prematuro; se debe usar un modo de **solo lectura / diagnóstico** primero y delimitar la tarea de fix una vez identificada la causa.
- **Refactorizaciones Transversales Planificadas:** Tareas que cambian un protocolo global requieren tocar múltiples módulos, pero deben ejecutarse en sub-tareas atómicas secuenciales.

## 7. Checklist de Verificación

- [ ] ¿La tarea define un objetivo único y específico sin mezclar múltiples responsabilidades?
- [ ] ¿Se especificó la lista explícita de archivos permitidos (*In-Scope*)?
- [ ] ¿Se declararon las zonas prohibidas (*Forbidden/Out-of-Scope*)?
- [ ] ¿Existe un comando de prueba automatizada para verificar la finalización exitosa?