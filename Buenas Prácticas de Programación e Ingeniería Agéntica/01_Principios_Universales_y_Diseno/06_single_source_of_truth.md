---
id: bp_4s8eapm6gfbprb7gemcxbzg7bs
name: 06_single_source_of_truth
title: "Fuente Única de Verdad (Single Source of Truth - SSOT)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/06_single_source_of_truth.md
version: 1.1.0
category: universal_principles
tags: [ssot, single-source-of-truth, data-integrity, configuration, universal_principles]
description: "Fuente única de verdad: unificación de constantes, configuraciones, esquemas y estados."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 06 - Fuente Única de Verdad (Single Source of Truth - SSOT)

## 1. Definición y Fundamento Teórico

El principio de **Fuente Única de Verdad (Single Source of Truth - SSOT)** es una práctica fundamental de la arquitectura de información y la ingeniería de software que establece:

> *"Cada elemento de dato, regla de configuración, esquema o estado de un sistema debe tener un único punto de definición oficial, inequívoco y autoritativo."*

Cualquier otra parte del sistema que requiera acceder a dicho dato debe **referenciarlo** o **derivar de él**, evitando réplicas manuales o definiciones independientes concurrentes.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Desincronización de Estados:** Previene que un módulo considere un estado válido mientras otro lo rechaza debido a discrepancias en strings o constantes duplicadas.
- **Mantenimiento Ágil y Seguro:** Cambiar una configuración, versión de API o catálogo de valores se realiza en un solo lugar y se propaga automáticamente a todo el sistema.
- **Integridad de Datos:** Asegura que las validaciones en frontend, backend y base de datos compartan la misma definición semántica.

## 3. Relevancia en Sistemas con IA Agéntica

- **Coherencia en la Generación de Código:** Los agentes de IA generan errores comunes al inventar variantes de strings o constantes cuando no encuentran un enum o esquema autoritativo centralizado (ej. usar `"PAID"`, `"paid"` o `"PAGADO"` indistintamente).
- **Sincronización de Configuración:** Previene discrepancias entre archivos de entorno (`.env`), manifiestos de agentes (`AGENTS.md` o `pyproject.toml`) y código fuente.
- **Interoperabilidad entre Herramientas:** Las herramientas (*tools*) que comparten definiciones autoritativas permiten a múltiples subagentes colaborar sin corromper el estado global.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Múltiples Definiciones Dispersas de Estados)

```python
# modulo_pedidos.py
def crear_pedido(datos: dict):
    # ERROR: Estado como string arbitrario hardcodeado
    return {"id": 101, "status": "PENDIENTE_PAGO"}

# modulo_pagos.py
def procesar_pago(pedido: dict):
    # ERROR: Desincronización - espera 'PENDING' en inglés
    if pedido.get("status") != "PENDING":
        raise ValueError("El pedido no está listo para pago.")
    pedido["status"] = "PAGADO"

# modulo_envios.py
def despachar_pedido(pedido: dict):
    # ERROR: Otra discrepancia tipográfica
    if pedido.get("status") != "pagado":
        raise ValueError("Pedido no pagado.")
```

### ✅ Código Correcto (Conforme a SSOT: Enum Centralizado Autoritativo)

```python
# src/domain/enums.py (Única Fuente de Verdad para Estados de Pedidos)
from enum import StrEnum

class OrderStatus(StrEnum):
    """Catálogo autoritativo de estados del ciclo de vida de un pedido."""
    PENDIENTE_PAGO = "PENDIENTE_PAGO"
    PAGADO = "PAGADO"
    EN_PREPARACION = "EN_PREPARACION"
    ENVIADO = "ENVIADO"
    ENTREGADO = "ENTREGADO"
    CANCELADO = "CANCELADO"

# src/services/payments.py
from src.domain.enums import OrderStatus

def procesar_pago(pedido_id: int, estado_actual: OrderStatus) -> OrderStatus:
    """Procesa el pago asegurando la transición de estado válida."""
    if estado_actual != OrderStatus.PENDIENTE_PAGO:
        raise ValueError(f"Estado inválido para procesar pago: {estado_actual}")

    # Lógica de cobro exitoso...
    return OrderStatus.PAGADO
```

## 5. Descripción Didáctica de los Cambios

1. **Centralización con Tipado Fuerte:** Se definió `OrderStatus` usando `StrEnum` en un módulo de dominio central, eliminando cadenas sueltas (*magic strings*).
2. **Consistencia Global:** Todos los servicios (pedidos, pagos, envíos) importan el mismo catálogo; un cambio en un estado es verificado por el sistema de tipos estático (*mypy* / IDE).
3. **Validación Automática:** Los agentes de IA reciben soporte explícito de autocompletado y validación de tipos, eliminando alucinaciones sintácticas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Desnormalización y Caché para Rendimiento:** En bases de datos analíticas (OLAP) o lecturas de alta concurrencia (Redis, CDNs), a menudo se duplican datos calculados para evitar joins pesados. Aquí se gestiona la **consistencia eventual** manteniendo el origen primario como SSOT.
- **Autonomía en Arquitecturas Orientadas a Eventos:** En sistemas distribuidos con *Event Sourcing*, cada microservicio mantiene su propia proyección de lectura optimizada (*Read Model*) derivada del stream de eventos original.
- **Acoplamiento de Esquemas Externos:** Compartir un único modelo interno con clientes externos acopla el dominio a cambios de terceros. Es preferible mapear DTOs en las fronteras del sistema.

## 7. Checklist de Verificación

- [ ] ¿Los estados, roles y categorías clave están definidos en un Enum o modelo centralizado?
- [ ] ¿Las variables de configuración y credenciales se leen desde un único módulo de configuración tipado (ej. `pydantic-settings`)?
- [ ] ¿Se eliminaron cadenas mágicas (*magic strings*) y números mágicos repetidos a lo largo del código?
- [ ] ¿Si existen datos cacheados o desnormalizados, se definió con claridad cuál es la fuente autoritativa original?