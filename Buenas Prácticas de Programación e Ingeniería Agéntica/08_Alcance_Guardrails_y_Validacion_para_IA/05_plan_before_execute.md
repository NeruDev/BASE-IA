---
id: bp_4wgp7ht9tkaqa8nee204dys5re
name: 05_plan_before_execute
title: "Planificar Antes de Ejecutar (Plan Before Execute)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/05_plan_before_execute.md
version: 1.1.0
category: agentic
tags: [plan-before-execute, plan-and-solve, react-loop, agent-reasoning, safety, universal_principles]
description: "Planificar Antes de Ejecutar: fase formal de análisis y diseño de pasos previa a cualquier mutación de archivos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 05 - Planificar Antes de Ejecutar (Plan Before Execute)

## 1. Definición y Fundamento Teórico

Formalizado en la investigación de **Wang et al.** en *Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning by Large Language Models* (ACL 2023) y en las arquitecturas de agentes **Plan-and-Execute**, este principio establece:

> *"Ante cualquier tarea técnica no trivial, el agente de IA debe ejecutar obligatoriamente una fase inicial de inspección y formulación de un plan de trabajo estructurado y secuencial antes de invocar cualquier herramienta de mutación (`replace_file_content`, `write_to_file`) o ejecución de comandos destructivos."*

El flujo opera en dos etapas estrictamente secuenciales:
1. **Fase de Planificación (Solo Lectura):** Inspeccionar contratos existentes, localizar archivos objetivo y redactar un plan con pasos numerados, dependencias y estrategia de validación.
2. **Fase de Ejecución (Mutación Controlada):** Aplicar los cambios paso a paso conforme al plan trazado, validando cada etapa antes de continuar.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Impulsividad de los LLMs:** Evita que el agente empiece a editar código en el primer turno basándose en suposiciones erróneas sobre la arquitectura.
- **Reducción de Bucles de Error Infinitos:** Un agente con un plan claro no se pierde intentando parchear síntomas superficiales.
- **Visibilidad y Control para el Usuario:** Permite a revisores humanos o sistemas de supervisión evaluar y aprobar la estrategia propuesta antes de que se modifique el repositorio.

## 3. Relevancia en Sistemas con IA Agéntica

- **Coordinación entre Agente Planificador y Agente Ejecutor:** En enjambres multi-agente, un subagente senior puede trazar el plan y delegar subtareas acotadas a subagentes ejecutores.
- **Prevención de Alucinaciones Arquitectónicas:** La lectura previa de interfaces garantiza que el plan se fundamente en la realidad del código y no en la memoria estocástica del modelo.
- **Alineación con Slash Commands (`/plan`):** Permite pausar la ejecución para solicitar feedback o refinamiento del usuario antes de proceder.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Edición Impulsiva sin Análisis Previo)

```text
Turno 1: Usuario: "Agrega soporte para pagos con PayPal."
Turno 2: Agente (Sin leer ningún archivo):
         Invoca `write_to_file("src/billing/paypal.py", ...)` creando una clase desconectada.
Turno 3: Agente invoca `replace_file_content("src/api/routes.py", ...)` usando métodos que no existen.
Turno 4: Ejecuta tests -> CRASH: Faltan dependencias, la base de datos no tiene la tabla y la interfaz no coincide.
# El agente entra en pánico y gasta 15 turnos intentando reparar su propio desastre.
```

### ✅ Flujo Correcto (Conforme a Plan Before Execute: Protocolo en Dos Fases)

Fase 1: Inspección y Redacción del Plan (Turno 1 a 2)
```markdown
### 📋 PLAN DE TRABAJO: Integración de PayPal Gateway

#### 1. Diagnóstico e Inspección Previa
- Inspeccionado `src/billing/gateways/base.py` para cumplir el protocolo `PaymentGateway`.
- Verificado que `requests` está disponible en `pyproject.toml`.

#### 2. Pasos de Implementación
1. **Crear Gateway PayPal:** Implementar `PayPalGateway` en `src/billing/gateways/paypal.py` cumpliendo `PaymentGatewayProtocol`.
2. **Suite de Pruebas Unitarias:** Crear `tests/unit/billing/test_paypal.py` con mocks de respuestas HTTP.
3. **Registro en Fábrica:** Registrar el nuevo gateway en `src/billing/factory.py`.

#### 3. Criterio de Verificación
- Ejecutar: `pytest tests/unit/billing/test_paypal.py`
- Ejecutar: `python scripts/validate.py` (Debe retornar código 0).

*¿Deseas proceder con la ejecución de este plan?*
```

Fase 2: Ejecución Controlada y Verificación
- El agente ejecuta paso 1 -> paso 2 -> paso 3 -> validación en verde.

## 5. Descripción Didáctica de los Cambios

1. **Comprensión Previa:** El agente inspeccionó la interfaz base antes de escribir una sola línea.
2. **Planificación Secuencial:** Dividió la tarea en 3 pasos lógicos ordenados y medibles.
3. **Validación Explícita:** Se estableció el criterio de éxito antes de tocar el código fuente.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Micro-correcciones Triviales:** Para tareas atómicas de 1 línea (ej. arreglar un error ortográfico en un comentario o corregir un typo evidente), exigir un plan formal de 3 páginas añade fricción innecesaria.
- **Planes Rígidos e Inmutables:** Si durante la ejecución se descubre una restricción imprevista, el plan debe actualizarse dinámicamente en lugar de insistir ciegamente en un plan obsoleto.

## 7. Checklist de Verificación

- [ ] ¿El agente inspeccionó los archivos y contratos relevantes antes de formular su plan?
- [ ] ¿El plan divide la tarea en pasos secuenciales acotados y testeables?
- [ ] ¿Se definió el criterio de validación automatizada al final del plan?
- [ ] ¿Se pausó la ejecución para verificar que el enfoque respeta la arquitectura del proyecto?