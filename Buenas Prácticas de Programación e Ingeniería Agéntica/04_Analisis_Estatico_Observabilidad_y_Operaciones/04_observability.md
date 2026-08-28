---
id: bp_53n3t74ddwa8w8hr4m7sfjgcvg
name: 04_observability
title: "Observabilidad de Sistemas (Logs, Métricas y Trazas)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/04_observability.md
version: 1.1.0
category: code_standards
tags: [observability, o11y, metrics, logs, traces, opentelemetry, universal_principles]
description: "Observabilidad: pilares de telemetría (Logs, Métricas y Trazas distribuidas) para auditoría cuantitativa."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 04 - Observabilidad de Sistemas (Logs, Métricas y Trazas)

## 1. Definición y Fundamento Teórico

Originada en la **Teoría de Control** por **Rudolf E. Kálmán** (1960) y adaptada a la ingeniería de software distribuida moderna por referentes como **Charity Majors** y **Cindy Sridharan**, la **Observabilidad (O11y)** se define como:

> *"La medida en que el estado interno, la salud y el comportamiento de un sistema de software pueden inferirse y diagnosticarse enteramente a partir del conocimiento de sus salidas externas de telemetría."*

La observabilidad se fundamenta en la tríada canónica de pilares de telemetría:
1. **Logs (Eventos Estructurados):** Registros inmutables con contexto semántico rico que describen un hecho específico en un punto en el tiempo.
2. **Métricas (Series Temporales Cuantitativas):** Valores numéricos agregados a lo largo del tiempo (latencia P95/P99, tasa de errores, consumo de tokens, uso de CPU/RAM).
3. **Trazas Distribuidas (*Distributed Traces*):** Gráfos dirigidos de *Spans* que mapean el recorrido causal de una solicitud a través de múltiples servicios, subagentes y bases de datos.

## 2. Por Qué Existe y Problemas que Resuelve

- **Diagnóstico de Problemas Desconocidos (*Unknown-Unknowns*):** Permite responder preguntas sobre fallos imprevistos que nunca antes habían ocurrido sin necesidad de desplegar nuevo código de depuración.
- **Detección Temprana de Degradaciones de Rendimiento:** Alerta sobre incrementos en la latencia o saturación de cuellos de botella antes de que afecten a los usuarios finales.
- **Auditoría Financiera y de Recursos:** Permite cuantificar el costo operativo por transacción o por usuario.

## 3. Relevancia en Sistemas con IA Agéntica

- **Auditoría de la "Caja Negra" del Agente:** Los agentes de IA toman decisiones estocásticas complejas. La observabilidad permite rastrear exactamente qué razonamiento (*thought*), llamada a herramienta (*tool call*) o prompt causó un resultado erróneo.
- **Control de Presupuesto y Consumo de Tokens:** Emite métricas en tiempo real sobre tokens de entrada/salida y costos acumulados por sesión o subagente.
- **Detección de Bucles Infinitos y Bloqueos:** Alerta automáticamente si un agente ejecuta más de $N$ llamadas sucesivas sin converger en una respuesta.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Sistema "Caja Negra" con Prints sin Métricas)

```python
# Antipatrón: Salida no estructurada en consola; imposible de cuantificar latencias o auditar costos
import time

def ejecutar_tarea_agente_caja_negra(prompt: str):
    print("Iniciando agente...")  # Texto plano sin timestamp ni ID
    # Invocación al LLM
    time.sleep(1.2)
    # Si falla o tarda 30s, no hay métricas de latencia ni registro de tokens consumidos
    print("Agente finalizado con éxito.")
```

### ✅ Código Correcto (Conforme a Observabilidad: Telemetría Estructurada Completa)

```python
# src/telemetry/agent_metrics.py
import time
from dataclasses import dataclass
from datetime import datetime, timezone
import json

@dataclass(frozen=True)
class AgentExecutionTelemetry:
    trace_id: str
    agent_id: str
    task_name: str
    duration_ms: float
    tokens_input: int
    tokens_output: int
    status: str
    cost_usd: float

    def to_json(self) -> str:
        return json.dumps(self.__dict__)

class ObservabilityManager:
    """Gestor central de telemetría para agentes y microservicios."""

    COSTO_POR_1K_INPUT = 0.0015
    COSTO_POR_1K_OUTPUT = 0.0020

    def registrar_ejecucion(
        self,
        trace_id: str,
        agent_id: str,
        task_name: str,
        duration_ms: float,
        tokens_in: int,
        tokens_out: int,
        status: str = "SUCCESS"
    ) -> AgentExecutionTelemetry:
        costo = (tokens_in / 1000 * self.COSTO_POR_1K_INPUT) + (tokens_out / 1000 * self.COSTO_POR_1K_OUTPUT)
        
        telemetria = AgentExecutionTelemetry(
            trace_id=trace_id,
            agent_id=agent_id,
            task_name=task_name,
            duration_ms=round(duration_ms, 2),
            tokens_input=tokens_in,
            tokens_output=tokens_out,
            status=status,
            cost_usd=round(costo, 6)
        )
        
        # Emisión estructurada a colector de telemetría (OpenTelemetry / CloudWatch / Datadog)
        print(f"[TELEMETRY_EVENT] {telemetria.to_json()}")
        return telemetria
```

## 5. Descripción Didáctica de los Cambios

1. **Datos Cuantitativos Precisos:** Registra duración en milisegundos, desglose de tokens de entrada/salida y costo financiero directo de la ejecución.
2. **Contexto de Correlación:** Vincula la ejecución a un `trace_id` e `agent_id` para permitir trazabilidad de extremo a extremo.
3. **Formato JSON Estandarizado:** Los eventos pueden ser ingeridos automáticamente por plataformas como Prometheus, Grafana, Datadog o ElasticSearch.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Explosión de Alta Cardinalidad (*High Cardinality*):** Indexar identificadores únicos de usuario o textos completos de prompts como etiquetas de métricas en Prometheus puede saturar la base de datos de series temporales; los datos de alta cardinalidad deben ir a **Logs/Trazas**, no a etiquetas de métricas.
- **Costo de Almacenamiento de Telemetría:** En sistemas de alto volumen, emitir trazas completas del 100% del tráfico puede ser inviable; se utiliza **muestreo probabilístico (*Sampling*)** (ej. guardar el 5% del tráfico exitoso y el 100% de los errores).
- **Sobrecarga de CPU/Red:** La serialización excesiva de telemetría en el camino crítico debe enviarse de forma asíncrona mediante buffers en memoria o *sidecars* (OpenTelemetry Collector).

## 7. Checklist de Verificación

- [ ] ¿El sistema emite métricas cuantitativas clave (latencia, tasa de errores, consumo de recursos/tokens)?
- [ ] ¿Los eventos de log contienen contexto estructurado (IDs de traza, timestamps UTC y niveles de severidad)?
- [ ] ¿Se cuenta con dashboards y alertas automáticas basadas en umbrales de error y latencia?
- [ ] ¿Se configuró una estrategia de muestreo (*sampling*) para controlar los costos de almacenamiento de telemetría?