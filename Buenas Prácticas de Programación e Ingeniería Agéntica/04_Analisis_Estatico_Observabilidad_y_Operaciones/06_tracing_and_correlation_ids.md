---
id: bp_30mn3pxw4rbsts1m4zgj4y0k9g
name: 06_tracing_and_correlation_ids
title: "Trazabilidad Distribuida y Correlation IDs"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/06_tracing_and_correlation_ids.md
version: 1.1.0
category: code_standards
tags: [tracing, correlation-ids, distributed-tracing, opentelemetry, multi-agent, contextvars, universal_principles]
description: "Tracing Distribuido: propagación de Correlation IDs y Spans para seguimiento causal de transacciones multi-agente."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 06 - Trazabilidad Distribuida y Correlation IDs

## 1. Definición y Fundamento Teórico

Basada en el diseño pionero del sistema **Dapper** de Google (2010) y formalizada en los estándares de la **W3C (Trace Context)** y **OpenTelemetry (CNCF)**, la **Trazabilidad Distribuida** establece:

> *"Cada solicitud o interacción que ingresa a un sistema debe asociarse a un identificador único e inmutable (**Correlation ID / Trace ID**), el cual se propaga a través de todas las fronteras de red, procesos asíncronos, subagentes y llamadas a bases de datos, permitiendo reconstruir el grafo acíclico dirigido completo de la ejecución (*Trace*) compuesto por segmentos individuales (*Spans*)."*

Los conceptos clave son:
- **Trace ID:** Identificador global único para toda la transacción desde el inicio hasta el fin.
- **Span ID:** Identificador de una unidad de trabajo específica dentro de la traza (ej. una consulta SQL o una llamada a un LLM).
- **Parent Span ID:** Referencia al segmento que originó la operación actual, permitiendo armar el árbol jerárquico.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reconstrucción Causal en Microservicios:** Permite seguir el flujo exacto de una petición a través de 20 servicios diferentes con una sola búsqueda por ID.
- **Detección de Cuellos de Botella de Latencia:** Mide con precisión cuánto tiempo consumió cada salto de red, base de datos o llamada a API externa en la cascada.
- **Aislamiento de la Causa Raíz de Errores:** Identifica el componente exacto que detonó el fallo original dentro de una cadena compleja de eventos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Trazabilidad en Enjambres de Subagentes (*Multi-Agent Swarms*):** Si un agente principal delega una tarea a un subagente de investigación, que a su vez invoca a un agente de código, el Correlation ID permite auditar toda la genealogía de razonamiento bajo una única traza.
- **Observabilidad de Tool Calling:** Mide la latencia y tasa de éxito individual de cada herramienta externa invocada por los LLMs.
- **Depuración de Respuestas Tardías:** Permite determinar si una respuesta lenta fue provocada por la inferencia del modelo o por la latencia de una API de terceros.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Logs Desconectados sin Propagación de Contexto)

```python
# Antipatrón: Cada agente o servicio genera sus propios IDs aleatorios inconexos
import uuid

def agente_planificador(prompt: str):
    plan_id = str(uuid.uuid4())
    print(f"[{plan_id}] Generando plan...")
    # Llama al ejecutor pero NO propaga el identificador
    agente_ejecutor("Escribir código")

def agente_ejecutor(tarea: str):
    ejecutor_id = str(uuid.uuid4()) # ID desconectado: imposible correlacionar con plan_id
    print(f"[{ejecutor_id}] Ejecutando tarea: {tarea}")
```

### ✅ Código Correcto (Conforme a Tracing: ContextVars y Propagación Automática)

```python
# src/core/tracing.py
import uuid
import contextvars
from dataclasses import dataclass

# Variable de contexto asíncrona (Thread-safe y Asyncio-safe)
correlation_id_ctx: contextvars.ContextVar[str] = contextvars.ContextVar("correlation_id", default="")

def generar_correlation_id() -> str:
    return f"trace_{uuid.uuid4().hex[:16]}"

def establecer_correlation_id(trace_id: str | None = None) -> str:
    cid = trace_id or generar_correlation_id()
    correlation_id_ctx.set(cid)
    return cid

def obtener_correlation_id() -> str:
    cid = correlation_id_ctx.get()
    return cid if cid else establecer_correlation_id()

# src/agents/multi_agent_flow.py
from src.core.tracing import obtener_correlation_id, establecer_correlation_id

def agente_coordinador(solicitud_usuario: str) -> None:
    # 1. Se inicializa el Trace ID en el punto de entrada
    trace_id = establecer_correlation_id()
    print(f"[{trace_id}] [Coordinador] Recibida solicitud: '{solicitud_usuario}'")
    
    # 2. Se delega al subagente manteniendo el mismo contexto
    subagente_investigador("Buscar datos relevantes")

def subagente_investigador(consulta: str) -> None:
    # El subagente hereda automáticamente el mismo Correlation ID
    trace_id = obtener_correlation_id()
    print(f"[{trace_id}] [Investigador] Ejecutando consulta: '{consulta}'")
    subagente_generador_codigo("Generar script Python")

def subagente_generador_codigo(tarea: str) -> None:
    trace_id = obtener_correlation_id()
    print(f"[{trace_id}] [GeneradorCodigo] Tarea completada con éxito.")
```

## 5. Descripción Didáctica de los Cambios

1. **Uso de `contextvars`:** Permite almacenar y acceder al `correlation_id` de forma transparente y segura en flujos multihilo y asíncronos (`asyncio`).
2. **Propagación Continua:** Toda la jerarquía de subagentes (Coordinador -> Investigador -> Generador) emite registros bajo el mismo `trace_id`.
3. **Consulta Unificada:** Un ingeniero o agente auditor puede buscar `trace_a1b2c3d4` y obtener la secuencia temporal cronológica completa de todas las operaciones realizadas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Propagación Manual en Protocolos Heterogéneos:** Si los servicios se comunican a través de sockets crudos o colas sin soporte nativo de metadatos, la inyección y extracción de headers de trazabilidad debe implementarse manualmente.
- **Sobrecarga de Almacenamiento de Trazas:** Almacenar trazas completas con todos sus payloads en sistemas de alta frecuencia genera un volumen gigantesco de datos; se debe aplicar **muestreo inteligente (*Head/Tail-based Sampling*)**.
- **Innecesario en Scripts Locales Aislados:** Para ejecutables CLI de un solo proceso sin red ni concurrencia, la trazabilidad distribuida es redundante frente a logs simples.

## 7. Checklist de Verificación

- [ ] ¿Cada solicitud entrante recibe o genera un Correlation ID (`X-Correlation-ID` / `traceparent`)?
- [ ] ¿El Correlation ID se propaga automáticamente a todas las llamadas HTTP salientes, mensajes de cola y subagentes?
- [ ] ¿Todas las líneas de log estructurado incluyen el Correlation ID actual?
- [ ] ¿Las herramientas y APIs externas registran la duración de cada Span individual?