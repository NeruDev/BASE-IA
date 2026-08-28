---
id: bp_5yc7wzrgska259dtqqmh2v6pwg
name: 12_test_before_claim
title: "Ejecutar Tests Antes de Declarar Éxito (Test Before Claim)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/12_test_before_claim.md
version: 1.1.0
category: agentic
tags: [test-before-claim, auto-verification, pytest, reactive-loop, self-correction, universal_principles]
description: "Ejecutar Tests Antes de Declarar Éxito: validación programática obligatoria tras cada cambio antes de reportar."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 12 - Ejecutar Tests Antes de Declarar Éxito (Test Before Claim)

## 1. Definición y Fundamento Teórico

Basada en el principio de **Verificación Previa a la Entrega (*Verification Before Claiming*)** y en los bucles de auto-corrección autónoma, la práctica de **Test Before Claim** establece:

> *"Inmediatamente después de aplicar cualquier edición en el código fuente, el agente de IA debe ejecutar de forma automática y obligatoria la suite de pruebas automatizadas relevante, absteniéndose taxativamente de notificar al usuario o declarar éxito hasta que todas las pruebas hayan retornado código de salida 0 (éxito total)."*

Esta regla prohíbe delegar en el usuario humano la tarea de verificar si el código compila o si los tests pasan.

```text
 ┌───────────────┐     ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
 │ Editar Código │ ──► │ Ejecutar Tests │ ──► │ ¿Falló Prueba? │ ──► │ Auto-Corregir  │
 └───────────────┘     └────────────────┘     └───────┬────────┘     └───────┬────────┘
                                                      │ (No)                 │
                                                      ▼                      ▼
                                            ┌───────────────────┐    (Reintentar Test)
                                            │ Notificar Éxito   │
                                            └───────────────────┘
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Pérdida de Tiempo del Usuario:** El desarrollador humano no tiene que hacer de "intérprete de Python" para descubrir que el agente cometió un typo.
- **Activación de la Auto-Corrección Autónoma:** Permite al modelo leer el mensaje de error de `pytest`, razonar sobre la causa y corregir el fallo en el siguiente turno sin intervención externa.
- **Garantía de Calidad Objetiva:** Transforma la validación en un proceso determinista basado en software y no en la autoevaluación subjetiva del LLM.

## 3. Relevancia en Sistemas con IA Agéntica

- **Flujo de Trabajo Autónomo Desatendido:** El agente resuelve incidencias complejas de forma iterativa, probando diferentes hipótesis hasta que la suite pasa al 100%.
- **Detección Inmediata de Regresiones:** Si al modificar la función $A$ se rompió la función $B$, la ejecución de tests alerta al agente instantáneamente.
- **Reducción de Deuda Técnica:** Asegura que ningún commit sea creado sobre un estado roto de pruebas.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Delegar la Validación en el Humano)

```text
Turno 1: Usuario: "Corrige el bug en la función calcular_recargo()."
Turno 2: Agente edita `src/billing/penalties.py`.
Turno 3: Agente responde de inmediato:
         "He modificado la función con la nueva fórmula. Por favor, pruébalo tú en tu terminal
          y avísame si te funciona bien." # ANTIPATRÓN INACEPTABLE: Delegación perezosa
```

### ✅ Flujo Correcto (Conforme a Test Before Claim: Auto-Corrección Autónoma)

```text
Turno 1: Usuario: "Corrige el bug en la función calcular_recargo()."

Turno 2: Agente edita `src/billing/penalties.py` con `replace_file_content`.

Turno 3: Agente ejecuta inmediatamente su herramienta de prueba:
         `run_command(CommandLine="uv run pytest tests/unit/billing/test_penalties.py")`
         Salida: FAILED tests/unit/billing/test_penalties.py::test_recargo_mora - AssertionError: 15.0 != 17.5

Turno 4: Agente analiza el fallo:
         "Razonamiento: El cálculo omitió la tasa base fija de $2.50. Debo ajustar la constante en penalties.py."
         Agente edita nuevamente `src/billing/penalties.py`.

Turno 5: Agente re-ejecuta la prueba:
         `run_command(CommandLine="uv run pytest tests/unit/billing/test_penalties.py")`
         Salida: 4 passed in 0.02s [100%]

Turno 6: Agente notifica al usuario con evidencia de que todos los tests pasaron exitosamente.
```

## 5. Descripción Didáctica de los Cambios

1. **Responsabilidad Autónoma:** El agente no transfirió la carga de prueba al usuario; asumió el rol completo de verificación.
2. **Ciclo de Auto-Corrección:** El fallo en el Turno 3 fue resuelto de forma transparente por el agente en los Turnos 4 y 5.
3. **Entrega Confiable:** El usuario recibe una solución que ya fue validada con código de salida 0.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Límite de Reintentos de Auto-Corrección (*Max Retries Gate*):** Si el agente intenta corregir el test 4 o 5 veces sucesivas sin éxito, debe detenerse y pedir ayuda al usuario explicando exactamente qué hipótesis probó y por qué está bloqueado, evitando consumir tokens en bucles infinitos.

## 7. Checklist de Verificación

- [ ] ¿El agente ejecuta los tests inmediatamente después de realizar cualquier edición de código?
- [ ] ¿Se prohíbe pedirle al usuario que pruebe el código si el agente cuenta con herramientas para ejecutar tests?
- [ ] ¿El agente analiza los errores de terminal de pytest para auto-corregir su solución de forma autónoma?
- [ ] ¿Se cuenta con un límite máximo de reintentos (ej. 4 intentos) para solicitar intervención humana ante bloqueos complejos?