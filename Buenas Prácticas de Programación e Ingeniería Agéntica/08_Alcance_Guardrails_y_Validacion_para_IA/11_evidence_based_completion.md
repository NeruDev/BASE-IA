---
id: bp_72sm36yre7bgar27nvp6q22ky6
name: 01_evidence_based_completion
title: "Finalización Basada en Evidencia (Evidence-Based Completion)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/11_evidence_based_completion.md
version: 1.1.0
category: agentic
tags: [evidence-based, empirical-verification, anti-sycophancy, test-output, quality-assurance, universal_principles]
description: "Finalización Basada en Evidencia: prohibición estricta de declarar éxito sin salida verificable de tests y linters."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 11 - Finalización Basada en Evidencia (Evidence-Based Completion)

## 1. Definición y Fundamento Teórico

Basada en los postulados de la **Verificación Empírica** y en la mitigación del sesgo de **Complacencia Superficial (*Sycophancy / Hallucinated Success*)** en modelos de lenguaje, esta práctica establece:

> *"Un agente de IA tiene terminantemente prohibido declarar una tarea de desarrollo como completada basándose únicamente en afirmaciones textuales o suposiciones teóricas; toda entrega debe estar respaldada obligatoriamente por la **evidencia empírica verificable** generada por la ejecución real de herramientas (salida de terminal de pruebas, reporte de linters con 0 errores y git diff limpio)."*

Bajo este principio: **"Si no hay salida de consola que demuestre que los tests pasaron, la tarea NO está terminada."**

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de las 'Falsas Victorias' (*Hallucinated Success*):** Los LLMs tienden a asegurar con total elocuencia que "el código funciona a la perfección" cuando en realidad contiene errores de sintaxis o fallos lógicos no probados.
- **Auditoría Transparente para el Revisor:** El desarrollador o subagente auditor puede verificar el resultado en segundos leyendo el bloque de evidencia adjunto.
- **Rigor en Pipelines Desatendidos:** Asegura que ningún Pull Request generado por IA sea fusionado sin un registro de ejecución exitosa en verde.

## 3. Relevancia en Sistemas con IA Agéntica

- **Disciplina Operativa en el Bucle ReAct:** Fuerza al agente a ejecutar el ciclo completo: *Editar -> Ejecutar Pruebas -> Capturar Evidencia -> Reportar con Evidencia*.
- **Prevención de Entregas Prematuras:** Impide que el agente detenga su trabajo antes de verificar casos límite o regresiones en módulos adyacentes.
- **Verificación Autónoma Cruzada:** Permite a subagentes de control de calidad rechazar entregas de subagentes desarrolladores si falta el bloque de evidencia formal.

## 4. Comparativa Didáctica de Código

### ❌ Reporte Incorrecto (Antipatrón: Declaración Verbal de Éxito Sin Evidencia)

```text
# Antipatrón: El agente asegura que todo funciona pero no ejecutó ningún comando
Agente: "¡Listo! He implementado la función de cálculo de impuestos de forma óptima.
El código es completamente limpio, cumple con todos los estándares y funciona a la perfección."
# REALIDAD OCULTA:
# El agente nunca ejecutó pytest. Al probarlo manualmente, la función falla con:
# NameError: name 'Decimal' is not defined (olvidó importar Decimal).
```

### ✅ Reporte Correcto (Conforme a Finalización Basada en Evidencia)

```markdown
### 📋 Reporte de Finalización de Tarea: Cálculo de IVA

#### 1. Resumen de Cambios Aplicados
- Implementada función pura `calcular_iva` con redondeo bancario en `src/billing/tax.py`.
- Añadida suite de pruebas unitarias con 6 casos de prueba en `tests/unit/billing/test_tax.py`.

#### 2. Evidencia Empírica de Validación
Salida de ejecución de `python scripts/validate.py`:
```text
==================================================
 INICIANDO VALIDACIÓN DEL ENTORNO OPERATIVO AGÉNTICO
==================================================
[*] Ejecutando: Linting y Formateo (Ruff)...
[✓] PASÓ: Linting y Formateo (Ruff)
[*] Ejecutando: Análisis Estático de Tipos (Mypy)...
[✓] PASÓ: Análisis Estático de Tipos (Mypy)
[*] Ejecutando: Seguridad Estática (Bandit)...
[✓] PASÓ: Seguridad Estática (Bandit)
[*] Ejecutando: Suite de Pruebas Unitarias (Pytest)...
tests/unit/billing/test_tax.py ......                    [100%]
============================== 6 passed in 0.03s ==============================
[✓] PASÓ: Suite de Pruebas Unitarias (Pytest)

[✓✓✓] TODOS LOS CHEQUEOS PASARON EXITOSAMENTE.
```

#### 3. Inspección del Git Diff
- **Archivos modificados:** 2 (`src/billing/tax.py`, `tests/unit/billing/test_tax.py`)
- **Total líneas:** +34 / -2
```

## 5. Descripción Didáctica de los Cambios

1. **Evidencia Irrefutable:** El reporte incluye la salida real de la consola demostrando que los 6 tests pasaron en 0.03 segundos.
2. **Chequeo Multi-Capa:** Mypy, Ruff y Bandit confirman que no existen errores de tipo, estilo ni seguridad.
3. **Métricas de Diff:** Se detalla con precisión el alcance cuantitativo de los archivos alterados.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Tareas de Documentación Exclusiva:** Para cambios en guías Markdown donde no hay tests unitarios de Python, la evidencia debe consistir en la salida del linter de documentación (`markdownlint`) o la prueba de enlaces.
- **Capturas Masivas Innecesarias:** Adjuntar 5,000 líneas de logs en el reporte satura el contexto; el agente debe adjuntar el **resumen final consolidado de la prueba**.

## 7. Checklist de Verificación

- [ ] ¿El reporte final incluye la salida de terminal real de la ejecución de tests?
- [ ] ¿Se ejecutó el script de validación unificado (`python scripts/validate.py`) antes de dar por terminada la tarea?
- [ ] ¿El conteo de pruebas aprobadas coincide con los requerimientos asignados?
- [ ] ¿Se prohíben afirmaciones subjetivas de éxito si no van acompañadas de la evidencia correspondiente?