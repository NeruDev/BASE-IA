---
id: bp_45h9e4s77caqvt7ktcad8css7j
name: 09_cohesion_and_coupling
title: "Alta Cohesión y Bajo Acoplamiento"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/09_cohesion_and_coupling.md
version: 1.1.0
category: universal_principles
tags: [cohesion, coupling, architecture, modularity, universal_principles]
description: "Alta cohesión interna y bajo acoplamiento entre componentes independientes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 09 - Alta Cohesión y Bajo Acoplamiento

## 1. Definición y Fundamento Teórico

Introducidos por **Larry Constantine** y **Edward Yourdon** en su obra clásica *Structured Design* (1979), los conceptos de **Cohesión** y **Acoplamiento** son las dos métricas cualitativas fundamentales del diseño de software:

- **Cohesión:** Grado en que los elementos internos de un módulo (funciones, métodos, datos) pertenecen juntos y cooperan estrechamente para cumplir un único propósito funcional bien definido. **(Meta: Alta Cohesión)**.
- **Acoplamiento:** Grado de interdependencia, conocimiento íntimo y conexión directa entre dos o más módulos independientes. **(Meta: Bajo Acoplamiento)**.

> *"La regla de oro del diseño de sistemas es buscar la máxima cohesión dentro de cada módulo y el mínimo acoplamiento entre módulos distintos."*

## 2. Por Qué Existe y Problemas que Resuelve

- **Aislamiento del Impacto de Cambios:** En sistemas desacoplados, modificar la implementación interna de un componente no provoca fallos imprevistos (*efectos secundarios*) en el resto de la aplicación.
- **Facilidad de Comprensión:** Un módulo altamente cohesivo se lee y razona como una unidad lógica completa y congruente.
- **Reutilización Real:** Los componentes con bajo acoplamiento pueden extraerse y utilizarse en otros contextos sin arrastrar un árbol masivo de dependencias.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prevención de Fallos en Cascada por Refactorización de LLMs:** Si los módulos están fuertemente acoplados, cuando un agente de IA modifica una firma de función o esquema, genera errores en cadena en módulos distantes que escapan a su ventana de verificación.
- **Enfoque de Razonamiento Agéntico:** La alta cohesión permite al modelo entender completamente la lógica de un dominio leyendo un solo archivo conciso.
- **Facilidad de Generación de Tests por Agentes:** Los módulos con bajo acoplamiento facilitan que un subagente escriba pruebas unitarias sin lidiar con inicializaciones complejas de dependencias cruzadas.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Baja Cohesión y Alto Acoplamiento)

```python
# Antipatrón: Baja cohesión (mezcla pagos, PDF y emails) y Alto acoplamiento (accede a variables globales de otro módulo)
import smtplib
import global_config  # Alto acoplamiento a estado global mutable

class GodOrderProcessor:
    def process_and_notify(self, order_data: dict):
        # 1. Lógica de Cobro
        card = order_data["card_number"]
        if not card.startswith("4"):
            raise ValueError("Solo tarjetas Visa.")

        # 2. Generación de Factura (Baja cohesión - no pertenece al flujo de pago)
        pdf_bytes = f"FACTURA PARA: {order_data['client_name']}".encode()

        # 3. Envío de Correo con acoplamiento directo a variables globales
        server = smtplib.SMTP(global_config.SMTP_HOST)
        server.sendmail("sales@app.com", order_data["email"], pdf_bytes)
        server.quit()
```

### ✅ Código Correcto (Conforme a Alta Cohesión y Bajo Acoplamiento)

```python
# src/billing/payment_processor.py (Alta Cohesión: Solo procesamiento de cobros)
from dataclasses import dataclass

@dataclass(frozen=True)
class PaymentResult:
    transaction_id: str
    is_success: bool

class CreditCardPaymentProcessor:
    """Responsabilidad única: Validar y ejecutar pagos con tarjeta."""
    def charge(self, card_number: str, amount: float) -> PaymentResult:
        if not card_number.startswith("4"):
            raise ValueError("Número de tarjeta inválido.")
        # Simulación de transacción procesada
        return PaymentResult(transaction_id="tx_12345", is_success=True)

# src/notifications/mailer.py (Alta Cohesión: Solo entrega de mensajes)
from typing import Protocol

class MessageSender(Protocol):
    def send(self, recipient: str, subject: str, body: bytes) -> None:
        ...

# src/orders/order_service.py (Bajo Acoplamiento: Orquesta mediante contratos)
class OrderService:
    def __init__(
        self,
        payment_processor: CreditCardPaymentProcessor,
        mailer: MessageSender
    ) -> None:
        self._payment_processor = payment_processor
        self._mailer = mailer

    def checkout(self, customer_email: str, card_number: str, amount: float) -> None:
        payment = self._payment_processor.charge(card_number, amount)
        if payment.is_success:
            self._mailer.send(customer_email, "Confirmación de Compra", b"Pago exitoso")
```

## 5. Descripción Didáctica de los Cambios

1. **Separación Cohesiva:** El procesamiento de cobro (`CreditCardPaymentProcessor`) y el envío de notificaciones (`MessageSender`) residen en módulos independientes dedicados a sus respectivas áreas.
2. **Desacoplamiento mediante Inyección:** `OrderService` recibe sus dependencias por constructor a través de interfaces (`Protocol`), eliminando referencias a variables globales o implementaciones rígidas de red.
3. **Resistencia a Cambios:** Si la infraestructura de correo migra de SMTP a una API REST (ej. SendGrid), `OrderService` y `CreditCardPaymentProcessor` permanecen intactos.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **La Ilusión del Acoplamiento Cero:** El acoplamiento cero no existe en un sistema funcional; los componentes deben colaborar. El objetivo es acoplar a **contratos abstractos estables**, no eliminar toda comunicación.
- **Exceso de Indirección (*Event Spaghetti*):** Reemplazar llamadas directas simples por buses de eventos asíncronos y mediadores innecesarios solo para "desacoplar" puede hacer imposible seguir el flujo del programa en depuración.
- **Rendimiento en Micro-componentes Internos:** Entre clases privadas dentro del mismo módulo cerrado, un acoplamiento controlado es natural y aceptable en aras de la simplicidad.

## 7. Checklist de Verificación

- [ ] ¿Cada clase y función realiza un conjunto de operaciones estrechamente conectadas temáticamente?
- [ ] ¿Los módulos se comunican mediante parámetros e interfaces claras en lugar de acceder a variables globales compartidas?
- [ ] ¿Es posible modificar la lógica interna de un módulo sin necesidad de editar los módulos que lo importan?
- [ ] ¿Se evitó el uso de buses de eventos o mediadores complejos para interacciones lineales simples?