---
id: bp_01m13428cqe2sbsp2tqqxk63gc
name: 12_debuggable_by_design
title: "Debuggable by Design: Arquitectura Introspectiva y Transparencia Operativa"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/12_debuggable_by_design.md
version: 1.0.0
category: architecture
tags: [debuggable-by-design, observability, transparency, pure-functions, introspection, clean-architecture]
description: "Principios y patrones de diseño para construir sistemas cuya arquitectura interna sea intrínsecamente transparente, auditable y fácil de depurar."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 12 - Debuggable by Design (Diseñado para el Diagnóstico)

El principio **Debuggable by Design** establece que la capacidad de depurar, inspeccionar y auditar un sistema no debe ser un añadido posterior, sino un **requisito arquitectónico de primer nivel** integrado en la estructura de código y datos.

---

## 1. Pilares de un Sistema Introspectivo

1. **Aislamiento de Lógica Pura (Funciones Puras):** Si una función de cálculo depende de variables globales ocultas o I/O no declarado, reproducir un fallo requiere reconstruir todo el entorno. Las funciones puras son reproducibles al 100% con un simple doctest.
2. **Inyección Explícita de Dependencias:** Pasar clientes HTTP, conexiones a bases de datos y APIs como argumentos tipados en lugar de instanciarlos dentro de las clases.
3. **Trazabilidad por IDs de Correlación:** Cada solicitud, tarea de agente o evento debe transportar un `task_id` o `trace_id` que vincule logs, llamadas a herramientas y salidas de error.
4. **Modos de Inspección en Runtime (*Dry-Run*):** Herramientas de mutación que permitan un flag `--dry-run` para simular acciones sin alterar el estado real.

---

## 2. Comparativa de Código

### ❌ Anti-Patrón: Caja Negra con Efectos Secundarios Ocultos
```python
# Modifica estado global y hace I/O implícito imposible de depurar
def process_orders():
    global CURRENT_STATE
    data = db.query("SELECT * FROM orders") # I/O oculto
    for d in data:
        CURRENT_STATE.append(d)
```

### ✅ Patrón Conforme: Función Pura y Testable
```python
from typing import Sequence
from pydantic import BaseModel

class Order(BaseModel):
    id: str
    amount: float

def calculate_order_totals(orders: Sequence[Order]) -> float:
    """Calcula el monto total acumulado de una secuencia de órdenes de forma pura.

    Args:
        orders: Secuencia inmutable de órdenes.

    Returns:
        Suma total de los montos de las órdenes.
    """
    return sum(order.amount for order in orders)
```
