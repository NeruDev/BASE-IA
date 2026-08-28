---
id: bp_01m13428cpfpxb688jnpaw7dsg
name: 11_metrics_and_telemetry
title: "Métricas Cuantitativas y Telemetría de Rendimiento para Sistemas y Agentes"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/11_metrics_and_telemetry.md
version: 1.0.0
category: architecture
tags: [metrics, telemetry, opentelemetry, prometheus, golden-signals, agent-telemetry, token-tracking]
description: "Guía de instrumentación de métricas cuantitativas, 4 Golden Signals y telemetría de rendimiento bajo estándares como OpenTelemetry y Prometheus."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 11 - Métricas Cuantitativas y Telemetría de Rendimiento

Este documento establece los principios de instrumentación de métricas cuantitativas, los 4 Golden Signals de observabilidad y las métricas operativas específicas para la supervisión de agentes autónomos.

---

## 1. Los 4 Golden Signals de Observabilidad (*Google SRE*)

1. **Latencia (*Latency*):** El tiempo que toma procesar una solicitud o invocación de herramienta.
2. **Tráfico (*Traffic*):** La demanda sobre el sistema (peticiones por segundo, tokens por minuto).
3. **Errores (*Errors*):** Tasa de solicitudes que fallan explícita o implícitamente.
4. **Saturación (*Saturation*):** Nivel de uso de los recursos más limitados (memoria, conexiones a DB, ventana de contexto).

---

## 2. Telemetría Especializada para Agentes de IA

| **Métrica Agéntica** | **Tipo** | **Propósito Operativo** |
|:---|:---:|:---|
| `gen_ai.usage.input_tokens` | Contador | Monitorear el consumo de tokens de entrada y detectar saturación de contexto. |
| `gen_ai.usage.output_tokens` | Contador | Medir la verbosidad y costo de las respuestas del modelo. |
| `gen_ai.tool.duration_ms` | Histograma | Medir percentiles (p50, p95, p99) de latencia por herramienta ejecutada. |
| `gen_ai.task.success_rate` | Indicador (0-1) | Proporción de tareas completadas exitosamente sin intervención humana. |
| `gen_ai.task.retry_count` | Contador | Detectar bucles de reintento excesivos (*Doom Loops*). |

---

## 3. Ejemplo de Instrumentación en Python

```python
import time
from typing import Callable, Any

class AgentTelemetry:
    """Colector de métricas de ejecución de herramientas y consumo de tokens."""

    def __init__(self) -> None:
        self.tool_latencies: dict[str, list[float]] = {}
        self.tool_errors: dict[str, int] = {}

    def record_tool_call(self, tool_name: str, duration_ms: float, success: bool) -> None:
        """Registra la duración y resultado de una llamada a herramienta."""
        if tool_name not in self.tool_latencies:
            self.tool_latencies[tool_name] = []
            self.tool_errors[tool_name] = 0

        self.tool_latencies[tool_name].append(duration_ms)
        if not success:
            self.tool_errors[tool_name] += 1
```
