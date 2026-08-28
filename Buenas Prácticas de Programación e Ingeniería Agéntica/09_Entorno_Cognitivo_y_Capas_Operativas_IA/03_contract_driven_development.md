---
id: bp_1dd3cmbz65b9ctdtznn2wsjk4k
name: 03_contract_driven_development
title: "Desarrollo Guiado por Contratos y Tipado Estricto"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/03_contract_driven_development.md
version: 1.1.0
category: agentic
tags: [contract-driven-development, design-by-contract, mypy-strict, pydantic, protocols, universal_principles]
description: "Contract-Driven Development: interfaces tipadas y contratos formales como razonador externo para agentes de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 03 - Desarrollo Guiado por Contratos y Tipado Estricto

## 1. Definición y Fundamento Teórico

Fundamentado en el paradigma de **Diseño por Contrato (*Design by Contract*)** formulado por **Bertrand Meyer** (1986) y en la **Teoría de Tipos Estáticos**, el **Desarrollo Guiado por Contratos (Contract-Driven Development - CDD)** postula:

> *"Antes de escribir cualquier línea de lógica algorítmica de implementación, deben declararse formalmente los contratos de interfaz, modelos de datos inmutables y firmas fuertemente tipadas (`typing.Protocol`, Pydantic v2, `@dataclass(frozen=True)`), siguiendo el ciclo estricto: $\text{Entrada} \rightarrow \text{Contrato / Tipos} \rightarrow \text{Implementación} \rightarrow \text{Tests}$."*

En sistemas agénticos, el compilador y analizador de tipos (**Mypy en modo estricto**) actúa como un **oráculo determinista y razonador externo** que guía la síntesis de código del LLM.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Errores de Runtime de Nulabilidad y Tipos:** Erradica bugs de `AttributeError: 'NoneType'`, `KeyError` y `TypeError` en producción.
- **Desacoplamiento Absoluto mediante Interfaces:** Permite cambiar la implementación de base de datos o APIs externas sin alterar la lógica de negocio.
- **Auto-corrección Guiada para Modelos de Lenguaje:** Mypy devuelve mensajes de error con número de línea exacto (`Argument 1 to "calcular" has incompatible type "float"; expected "Decimal"`), permitiendo al agente auto-corregirse en un solo turno.

## 3. Relevancia en Sistemas con IA Agéntica

- **Esquemas Infalibles para Tool Calling:** Los modelos Pydantic definen exactamente qué parámetros JSON espera el agente y con qué validaciones.
- **Inmunidad ante Alucinaciones de Firmas:** El agente no puede inventar parámetros que no estén definidos en el contrato de tipo.
- **Mockeo Determinista en Tests:** Los contratos basados en `Protocol` permiten crear mocks tipados instantáneos para pruebas unitarias.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Diccionarios Genéricos 'Dict' Sin Contrato)

```python
# Antipatrón: Sin contrato ni tipos; el agente asume claves arbitrarias que crashean en producción
def procesar_cobro_antipatron(payload: dict):
    # ¿Qué claves existen? ¿Qué tipos tienen? ¿Qué pasa si 'amount' viene como string?
    # ERROR EN RUNTIME si falta 'customer_id' o si 'amount' es None
    total = payload["amount"] * 1.16
    return {"status": "ok", "user": payload["customer_id"], "total": total}
```

### ✅ Código Correcto (Conforme a Contract-Driven Development: Protocol + Pydantic Inmutable)

Paso 1: Definición del Contrato y Modelo (`src/billing/contracts.py`):
```python
# src/billing/contracts.py
from decimal import Decimal
from typing import Protocol
from pydantic import BaseModel, Field, EmailStr

class PaymentRequest(BaseModel):
    """Contrato inmutable de entrada con validación estricta."""
    customer_email: EmailStr
    amount: Decimal = Field(gt=Decimal("0.00"), description="Monto estrictamente positivo")
    currency: str = Field(min_length=3, max_length=3, default="USD")

    model_config = {"frozen": True}

class PaymentReceipt(BaseModel):
    """Contrato inmutable de salida."""
    receipt_id: str
    total_charged: Decimal
    status: str

    model_config = {"frozen": True}

class PaymentProcessorGateway(Protocol):
    """Contrato formal abstracto de la pasarela de pagos."""
    def execute_charge(self, request: PaymentRequest) -> PaymentReceipt:
        ...
```

Paso 2: Implementación que cumple estrictamente el contrato (`src/billing/service.py`):
```python
# src/billing/service.py
from src.billing.contracts import PaymentRequest, PaymentReceipt, PaymentProcessorGateway

class BillingService:
    def __init__(self, gateway: PaymentProcessorGateway) -> None:
        self._gateway = gateway

    def charge_customer(self, request: PaymentRequest) -> PaymentReceipt:
        # Mypy y Pydantic garantizan que request.amount es Decimal válido > 0
        return self._gateway.execute_charge(request)
```

## 5. Descripción Didáctica de los Cambios

1. **Modelos Inmutables (`frozen=True`):** `PaymentRequest` y `PaymentReceipt` garantizan que los datos no sean mutados accidentalmente.
2. **Protocolo Tipado (`Protocol`):** `PaymentProcessorGateway` define la firma exacta requerida sin acoplarse a ninguna librería de terceros.
3. **Verificación Estática Mypy:** Cualquier discrepancia de tipo es detectada y rechazada por Mypy antes de la ejecución.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Prototipado Exploratorio Rápido:** En análisis de datos interactivos en notebooks donde la estructura de datos es desconocida de antemano, los esquemas estrictos pueden ralentizar la exploración inicial.

## 7. Checklist de Verificación

- [ ] ¿Los contratos de entrada y salida están definidos mediante modelos Pydantic o `@dataclass(frozen=True)`?
- [ ] ¿Las dependencias externas se abstraen mediante interfaces `typing.Protocol`?
- [ ] ¿El analizador estático `mypy --strict src/` pasa con cero errores de tipo?
- [ ] ¿Se prohibió el paso de diccionarios genéricos `dict[str, Any]` sin tipar en las interfaces del dominio?