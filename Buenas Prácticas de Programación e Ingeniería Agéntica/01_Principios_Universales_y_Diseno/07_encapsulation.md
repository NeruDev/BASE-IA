---
id: bp_57r2pv11f3bqpv38x7qb5r55n3
name: 07_encapsulation
title: "Encapsulación y Ocultamiento de Información"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/07_encapsulation.md
version: 1.1.0
category: universal_principles
tags: [encapsulation, information-hiding, oop, invariants, universal_principles]
description: "Encapsulación: protección de estado interno y exposición exclusiva de métodos validados."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 07 - Encapsulación y Ocultamiento de Información

## 1. Definición y Fundamento Teórico

Introducido formalmente por **David L. Parnas** en su célebre artículo *On the Criteria to Be Used in Decomposing Systems into Modules* (1972) y consolidado como pilar de la Programación Orientada a Objetos, el principio de **Encapsulación y Ocultamiento de Información** sostiene que:

> *"Un módulo o clase debe ocultar sus detalles internos de implementación y proteger su estado, exponiendo únicamente una interfaz pública mínima, controlada y validada."*

La encapsulación cumple dos propósitos complementarios:
1. **Protección de Invariantes:** Garantiza que el objeto nunca entre en un estado inválido o corrupto.
2. **Ocultamiento de Decisiones de Diseño:** Permite modificar la representación interna de los datos sin afectar el código que consume el módulo.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Corrupción de Estado:** Impide que módulos externos modifiquen variables internas eludiendo las reglas de validación.
- **Reducción del Acoplamiento:** Los consumidores dependen del contrato público, no de cómo se almacenan los datos en memoria o en disco.
- **Facilidad de Refactorización:** Permite optimizar algoritmos o cambiar tipos de datos internos con total seguridad de no romper clientes externos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Protección contra Mutaciones Indebidas de LLMs:** Los agentes de IA suelen acceder a propiedades privadas (`obj._saldo = 500` o modificar listas internas directamente) para "solucionar rápido" una tarea, saltándose validaciones y registros de auditoría.
- **Interfaces Autoexplicativas para Tools:** Clases con interfaces públicas claras permiten al agente deducir fácilmente las operaciones permitidas y sus contratos mediante *type hints*.
- **Invariantes Garantizados:** Asegura que, incluso si un agente genera parámetros inconsistentes, los métodos del objeto rechacen la operación de forma segura.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Estado Expuesto y Sin Invariantes)

```python
# Antipatrón: Acceso directo a datos que permite estados financieros inconsistentes
class CuentaBancaria:
    def __init__(self, titular: str, saldo_inicial: float):
        self.titular = titular
        self.saldo = saldo_inicial  # Atributo público sin control
        self.movimientos = []       # Lista mutable expuesta

# Cualquier módulo o agente puede corromper el estado sin validación:
cuenta = CuentaBancaria("Alice", 100.0)
cuenta.saldo = -5000.0  # ERROR: Saldo negativo sin validación ni registro de auditoría
cuenta.movimientos.append("Retiro de 5100") # ERROR: Historial inconsistente
```

### ✅ Código Correcto (Conforme a Encapsulación: Invariantes Protegidos)

```python
# src/domain/bank_account.py
from decimal import Decimal
from dataclasses import dataclass
from datetime import datetime, timezone

@dataclass(frozen=True)
class Transaccion:
    monto: Decimal
    tipo: str
    fecha: datetime

class CuentaBancaria:
    """Entidad bancaria con estado interno protegido e invariantes estrictos."""

    def __init__(self, titular: str, saldo_inicial: Decimal = Decimal("0.00")) -> None:
        if saldo_inicial < Decimal("0.00"):
            raise ValueError("El saldo inicial no puede ser negativo.")
        self._titular: str = titular
        self._saldo: Decimal = saldo_inicial
        self._movimientos: list[Transaccion] = []

    @property
    def saldo(self) -> Decimal:
        """Retorna el saldo actual en modo de solo lectura."""
        return self._saldo

    @property
    def titular(self) -> str:
        return self._titular

    def depositar(self, monto: Decimal) -> None:
        """Añade fondos a la cuenta validando que el monto sea positivo."""
        if monto <= Decimal("0.00"):
            raise ValueError(f"El monto a depositar debe ser estrictamente positivo: {monto}")

        self._saldo += monto
        self._movimientos.append(
            Transaccion(monto=monto, tipo="DEPOSITO", fecha=datetime.now(timezone.utc))
        )

    def retirar(self, monto: Decimal) -> None:
        """Retira fondos asegurando que existan fondos suficientes."""
        if monto <= Decimal("0.00"):
            raise ValueError(f"El monto a retirar debe ser estrictamente positivo: {monto}")
        if monto > self._saldo:
            raise ValueError(f"Fondos insuficientes. Saldo disponible: {self._saldo}, solicitado: {monto}")

        self._saldo -= monto
        self._movimientos.append(
            Transaccion(monto=monto, tipo="RETIRO", fecha=datetime.now(timezone.utc))
        )
```

## 5. Descripción Didáctica de los Cambios

1. **Protección del Estado Interno:** `_saldo` y `_movimientos` son protegidos mediante convención (`_`) y propiedades de solo lectura (`@property`).
2. **Cumplimiento de Invariantes:** Las operaciones de depósito y retiro validan montos no negativos y verifican la disponibilidad de fondos antes de alterar el estado.
3. **Auditoría Garantizada:** Cada modificación del saldo genera obligatoriamente un registro inmutable de transacción.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Estructuras de Datos Puras (DTOs y Value Objects):** En objetos que solo transfieren datos sin comportamiento (ej. cargas útiles de red o filas de base de datos), implementar getters/setters manuales agrega verbosidad innecesaria. Es preferible usar `@dataclass(frozen=True)` o modelos `Pydantic`.
- **Getters y Setters Triviales (*Anemic Domain*):** Crear un getter y un setter para cada atributo privado sin lógica de validación simplemente disfraza el acceso público y no aporta valor real de diseño.
- **Rendimiento en Procesamiento Numérico Masivo:** En cálculo vectorial intensivo (NumPy, PyTorch), el acceso a arrays directos en memoria es preferido por motivos de rendimiento de CPU/GPU.

## 7. Checklist de Verificación

- [ ] ¿Los atributos internos que definen la validez del estado están protegidos (`_variable`)?
- [ ] ¿El estado solo puede mutar a través de métodos de negocio que validan sus invariantes?
- [ ] ¿Las colecciones internas se retornan como tuplas/copias inmutables para evitar modificaciones directas externas?
- [ ] ¿Se evitó la creación de getters y setters indiscriminados sin propósito de validación?