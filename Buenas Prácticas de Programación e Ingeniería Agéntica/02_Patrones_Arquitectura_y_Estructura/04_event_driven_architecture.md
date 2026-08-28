---
id: bp_3d7bkfrkkxavtr8qd9bnv05012
name: 04_event_driven_architecture
title: "Arquitectura Orientada a Eventos (Event-Driven Architecture - EDA)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/04_event_driven_architecture.md
version: 1.1.0
category: architecture
tags: [event-driven, eda, asynchronous, multi-agent, reactive, universal_principles]
description: "Arquitectura Orientada a Eventos: desacoplamiento temporal y espacial mediante eventos inmutables."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 04 - Arquitectura Orientada a Eventos (Event-Driven Architecture - EDA)

## 1. Definición y Fundamento Teórico

La **Arquitectura Orientada a Eventos (EDA)** es un patrón de diseño y arquitectura de sistemas en el cual la interacción entre componentes se produce exclusivamente a través de la producción, propagación y consumo reactivo de **Eventos**:

> *"Un Evento es un registro inmutable que certifica un hecho relevante que ya ha ocurrido en el pasado dentro del dominio del sistema (ej. `OrderPlacedEvent`, `AgentTaskCompletedEvent`)."*

EDA proporciona un desacoplamiento en tres dimensiones fundamentales:
- **Desacoplamiento Espacial:** Los productores no conocen la identidad, número ni ubicación de los consumidores.
- **Desacoplamiento Temporal:** Productores y consumidores no necesitan ejecutarse de forma simultánea.
- **Desacoplamiento de Flujo:** El productor no se bloquea esperando que los consumidores procesen el evento.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Llamadas Bloqueantes en Cascada:** Evita que la lentitud o caída de un servicio secundario (ej. envío de correos) bloquee o aborte la transacción principal de negocio.
- **Escalabilidad Horizontal Autónoma:** Permite escalar los consumidores de eventos pesados de manera independiente al servicio de entrada.
- **Facilidad de Extensibilidad:** Añadir un nuevo suscriptor o funcionalidad no requiere modificar el código del emisor.

## 3. Relevancia en Sistemas con IA Agéntica

- **Orquestación Multi-Agente Asíncrona:** Permite que un enjambre de subagentes especializados (investigador, programador, auditor de seguridad) reaccione en tiempo real a los eventos generados por otros agentes sin acoplamiento punto a punto.
- **Trazabilidad y Auditoría de Razonamiento:** Cada evento emitido por un agente queda registrado con su *timestamp* e identificador de correlación, facilitando la observabilidad y reproducción de trayectorias agénticas.
- **Resiliencia ante Tareas de Larga Duración:** Permite que los agentes procesen tareas pesadas en segundo plano y notifiquen su finalización mediante eventos sin bloquear la interfaz de usuario.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Acoplamiento Síncrono Bloqueante en Cascada)

```python
# Antipatrón: El servicio de pagos invoca directamente a todos los módulos secundarios de forma bloqueante
class OrderCheckoutService:
    def __init__(self, payment_gateway, inventory_api, email_api, analytics_api):
        self.payment = payment_gateway
        self.inventory = inventory_api
        self.email = email_api
        self.analytics = analytics_api

    def checkout(self, order_id: str, amount: float, user_email: str) -> None:
        # Si la API de analytics o de correo falla o tarda 5 segundos, la compra se arruina
        self.payment.charge(order_id, amount)
        self.inventory.reserve(order_id)
        self.email.send_confirmation(user_email, order_id)   # BLOQUEANTE
        self.analytics.track_sale(order_id, amount)          # BLOQUEANTE
```

### ✅ Código Correcto (Conforme a EDA: Bus de Eventos Desacoplado y Tipado)

```python
# src/core/events.py
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Callable, Any

@dataclass(frozen=True)
class DomainEvent:
    occurred_at: datetime

@dataclass(frozen=True)
class OrderPaidEvent(DomainEvent):
    order_id: str
    amount: float
    user_email: str

class EventBus:
    """Bus de eventos liviano con suscripciones fuertemente tipadas."""
    def __init__(self) -> None:
        self._subscribers: dict[type, list[Callable[[Any], None]]] = {}

    def subscribe(self, event_type: type, handler: Callable[[Any], None]) -> None:
        if event_type not in self._subscribers:
            self._subscribers[event_type] = []
        self._subscribers[event_type].append(handler)

    def publish(self, event: DomainEvent) -> None:
        handlers = self._subscribers.get(type(event), [])
        for handler in handlers:
            handler(event)

# src/services/checkout.py
class OrderCheckoutService:
    def __init__(self, event_bus: EventBus) -> None:
        self._event_bus = event_bus

    def checkout(self, order_id: str, amount: float, user_email: str) -> None:
        # Procesa el pago central...
        # Emite el hecho consumado al bus de eventos
        event = OrderPaidEvent(
            occurred_at=datetime.now(timezone.utc),
            order_id=order_id,
            amount=amount,
            user_email=user_email
        )
        self._event_bus.publish(event)
```

## 5. Descripción Didáctica de los Cambios

1. **Inmutabilidad del Evento:** `OrderPaidEvent` es un registro inmutable (`@dataclass(frozen=True)`) que describe un hecho pasado con su marca temporal UTC.
2. **Desacoplamiento Total del Productor:** `OrderCheckoutService` solo conoce al `EventBus` y al evento; desconoce cuántos módulos o agentes escucharán la noticia.
3. **Extensibilidad Inmediata:** Se pueden añadir suscriptores de analítica, notificaciones o agentes de recomendación sin tocar una sola línea de `OrderCheckoutService`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Complejidad de Depuración y Trazabilidad:** Al no existir un flujo secuencial directo en código, rastrear el camino de un evento requiere herramientas de *Distributed Tracing* (OpenTelemetry, Correlation IDs).
- **Consistencia Eventual (*Eventual Consistency*):** Los suscriptores procesan los datos con cierto desfase temporal; no es adecuado para operaciones que exigen consistencia transaccional inmediata ACID en la misma base de datos.
- **Spaghetti de Eventos y Ciclos Infinitos:** En sistemas sin control de arquitectura, un evento puede disparar un manejador que emite otro evento que vuelve a disparar al primero en un bucle recursivo destructivo.

## 7. Checklist de Verificación

- [ ] ¿Los eventos representan hechos en tiempo pasado (`OrderPaid`, `AgentFinished`) y son completamente inmutables?
- [ ] ¿Los emisores de eventos desconocen la existencia y número de suscriptores?
- [ ] ¿Cada evento contiene marcas temporales (`timestamp`) e identificadores de correlación (*trace/correlation ID*)?
- [ ] ¿Se cuenta con mecanismos para prevenir bucles de retroalimentación de eventos y gestionar la consistencia eventual?