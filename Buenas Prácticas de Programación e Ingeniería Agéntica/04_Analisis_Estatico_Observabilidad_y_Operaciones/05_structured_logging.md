---
id: bp_7rq934dk28a5z8hddzsjn58zfa
name: 05_structured_logging
title: "Logging Estructurado en Formato JSON"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/05_structured_logging.md
version: 1.1.0
category: code_standards
tags: [structured-logging, json-logging, logs, observability, structlog, universal_principles]
description: "Logging Estructurado: emisión de eventos en formato JSON con pares clave-valor tipados para ingesta y análisis."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 05 - Logging Estructurado en Formato JSON

## 1. Definición y Fundamento Teórico

El **Logging Estructurado (Structured Logging)** es el estándar de ingeniería para la emisión y gestión de registros de auditoría y eventos operativos que postula:

> *"Los logs no deben emitirse como texto plano no estructurado o cadenas interpoladas arbitrarias; deben emitirse como documentos de datos estructurados (generalmente JSON Lines - ndjson) con pares clave-valor fuertemente tipados y normalizados."*

Cada entrada de log contiene un conjunto estandarizado de campos semánticos:
- `timestamp`: Marca temporal en formato ISO 8601 UTC (`2026-08-27T15:10:00Z`).
- `level`: Nivel canónico de severidad (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).
- `event` / `message`: Nombre semántico breve del evento en formato *snake_case* (ej. `payment_processed`).
- `context`: Atributos dinámicos del dominio (`user_id`, `order_id`, `trace_id`, `duration_ms`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Consultas y Agregaciones Indexadas Instantáneas:** Permite a motores como OpenSearch, Loki o BigQuery filtrar instantáneamente `WHERE level="ERROR" AND error_code="TIMEOUT" AND duration_ms > 1000` sin usar expresiones regulares frágiles.
- **Eliminación del Parsing Manual de Texto:** Suprime scripts complejos de expresiones regulares que se rompen cada vez que un desarrollador cambia una palabra en el mensaje de texto.
- **Normalización Multilingüe y Multi-Servicio:** Todos los microservicios y agentes del ecosistema emiten el mismo esquema JSON base.

## 3. Relevancia en Sistemas con IA Agéntica

- **Auditoría Automatizada por Subagentes:** Permite a agentes de diagnóstico e inspección técnica consultar logs estructurados mediante herramientas de base de datos o *tool calling* sin ambigüedad sintáctica.
- **Captura Precisa de Metadatos de LLM:** Registra de forma nativa parámetros críticos como modelo utilizado (`model="gemini-1.5-pro"`), tokens consumidos y llamadas a herramientas en campos JSON indexables.
- **Sanitización de Datos Sensibles (PII):** Los procesadores estructurados permiten filtrar o enmascarar automáticamente campos como `password`, `api_key` o `credit_card` antes de escribir en disco.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Texto Plano No Indexable con Interpolación)

```python
# Antipatrón: String interpolado en texto plano; imposible de consultar eficientemente en BigQuery/Loki
import logging

def cobrar_pedido_antipatron(user_id: str, order_id: str, monto: float):
    # ERROR: Mensaje arbitrario en texto plano, sin timestamp estructurado ni campos tipados
    logging.error(f"Fallo al cobrar {monto} al usuario {user_id} en la orden {order_id} por saldo insuficiente.")
```

### ✅ Código Correcto (Conforme a Logging Estructurado: JSON Formatter Nativo)

```python
# src/core/structured_logger.py
import json
import logging
import sys
from datetime import datetime, timezone
from typing import Any

class JsonFormatter(logging.Formatter):
    """Formateador que serializa registros de log a JSON Lines estandarizado."""
    def format(self, record: logging.LogRecord) -> str:
        log_entry: dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "event": record.getMessage(),
        }
        
        # Agrega atributos de contexto adicionales pasados en 'extra'
        if hasattr(record, "context") and isinstance(record.context, dict):
            log_entry.update(record.context)

        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_entry, ensure_ascii=False)

def obtener_logger_estructurado(nombre: str) -> logging.Logger:
    logger = logging.getLogger(nombre)
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(JsonFormatter())
        logger.addHandler(handler)
    return logger

# Uso en servicios del dominio:
logger = obtener_logger_estructurado("billing.service")

def cobrar_pedido_estructurado(user_id: str, order_id: str, monto: float) -> None:
    # Emisión con evento canónico y contexto tipado:
    logger.error(
        "payment_charge_failed",
        extra={
            "context": {
                "user_id": user_id,
                "order_id": order_id,
                "amount": monto,
                "error_code": "INSUFFICIENT_FUNDS",
                "attempt": 1
            }
        }
    )
```

## 5. Descripción Didáctica de los Cambios

1. **Serialización a JSON Lines:** Cada línea emitida es un objeto JSON autónomo parseable por cualquier colector de logs.
2. **Campos Estandarizados:** `timestamp` en UTC ISO 8601, severidad en mayúsculas y evento en *snake_case*.
3. **Contexto Desacoplado:** Variables de negocio (`user_id`, `amount`, `error_code`) viajan en el diccionario `context`, permitiendo indexación y agregación numérica directa.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Legibilidad para Humanos en Desarrollo Local:** El formato JSON puede ser denso para lectura manual rápida en consola local; la solución es configurar formato legible y coloreado en entornos de desarrollo local y JSON estricto en producción.
- **Fuga Accidental de Secretos (PII):** Si los desarrolladores o agentes pasan objetos completos en `context` sin filtrar, pueden emitirse tokens o datos personales sensibles; se deben implementar procesadores de ofuscación.
- **Sobrecarga de Serialización:** En bucles ultrarrápidos (>100,000 logs/seg), la serialización JSON en Python añade un costo de CPU medible; se deben usar librerías en C/Rust (como `orjson` o `structlog` optimizado).

## 7. Checklist de Verificación

- [ ] ¿Los logs se emiten en formato JSON estructurado con timestamps en UTC e ISO 8601?
- [ ] ¿Los eventos usan nombres semánticos breves y normalizados en lugar de frases arbitrarias?
- [ ] ¿Las variables de contexto se pasan como campos clave-valor en lugar de interpolarse en el string del mensaje?
- [ ] ¿Existe un mecanismo de filtrado automático para evitar la emisión de contraseñas o tokens (PII)?