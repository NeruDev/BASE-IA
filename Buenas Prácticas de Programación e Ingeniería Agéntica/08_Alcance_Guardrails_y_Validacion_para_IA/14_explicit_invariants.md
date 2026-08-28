---
id: bp_7jyfvby5r5bpt8de2kem2826m7
name: 14_explicit_invariants
title: "Invariantes Explícitos del Sistema"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/14_explicit_invariants.md
version: 1.1.0
category: agentic
tags: [explicit-invariants, domain-driven-design, ddd, business-rules, domain-md, universal_principles]
description: "Invariantes Explícitos: reglas de negocio inmutables documentadas en DOMAIN.md y protegidas en código."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 14 - Invariantes Explícitos del Sistema

## 1. Definición y Fundamento Teórico

Originado en el **Diseño por Contrato (*Design by Contract*)** formulado por **Bertrand Meyer** (1986) y consolidado en el **Diseño Guiado por el Dominio (DDD)** por **Eric Evans**, el principio de **Invariantes Explícitos** establece:

> *"Todas las reglas de negocio fundamentales y condiciones lógicas que deben mantenerse estrictamente verdaderas en todo estado válido del sistema deben declararse de forma explícita en la documentación (`DOMAIN.md`) y protegerse mediante validaciones inviolables en el código, impidiendo que cualquier mutación sitúe al sistema en un estado inconsistente o corrupto."*

Un invariante representa una verdad matemática del negocio que no puede violarse bajo ninguna circunstancia.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Violaciones de Reglas Invisibles:** Los agentes de IA no poseen sentido común humano sobre las sutilezas del negocio; si la regla no está escrita, la violarán tarde o temprano.
- **Protección de la Integridad Transaccional:** Impide la creación de cuentas con balances negativos, órdenes sin cliente o transacciones duplicadas.
- **Auto-Defensa del Modelo de Dominio:** Los agregados y entidades rechazan cualquier operación inválida en el momento exacto en que se intenta ejecutar.

## 3. Relevancia en Sistemas con IA Agéntica

- **Ground Truth para LLMs en `DOMAIN.md`:** Proporciona un catálogo conciso de reglas inmutables que el modelo consulta para validar la coherencia de sus propuestas.
- **Alineación con Testing Basado en Propiedades (*Property-Based Testing*):** Permite escribir suites con `Hypothesis` que verifican que ningún cambio del agente rompa los invariantes.
- **Prevención de Alucinaciones de Dominio:** Evita que el agente invente estados imposibles (ej. transicionar una orden de `CANCELLED` a `SHIPPED`).

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Invariante Implícito No Protegido)

```python
# Antipatrón: La regla "el balance nunca puede ser negativo" es un supuesto implícito no protegido
class CuentaUsuarioAntipatron:
    def __init__(self, balance: float):
        self.balance = balance

    def retirar(self, cantidad: float):
        # ERROR: No verifica si cantidad > balance; permite saldos negativos por descuido del agente
        self.balance -= cantidad
```

### ✅ Código Correcto (Conforme a Invariantes Explícitos: DOMAIN.md + Protección Inmutable)

Documentación en `docs/DOMAIN.md`:
```markdown
# Invariantes del Dominio Financiero (docs/DOMAIN.md)

1. **INV-01 (No Negatividad de Balance):** El saldo de una cuenta estándar nunca puede ser inferior a $0.00. Cualquier intento de sobregiro debe abortar con `InvariantViolationError`.
2. **INV-02 (Transiciones de Orden):** Una orden en estado `FINALIZADA` o `CANCELADA` es inmutable y no admite modificaciones posteriores.
```

Código con protección dura del invariante (`src/domain/account.py`):
```python
# src/domain/account.py
from decimal import Decimal

class DomainInvariantError(Exception):
    """Excepción lanzada cuando se intenta violar un invariante de negocio explícito."""
    pass

class CuentaUsuario:
    """Entidad de dominio que encapsula y defiende sus invariantes de negocio."""

    def __init__(self, usuario_id: str, balance_inicial: Decimal) -> None:
        if balance_inicial < Decimal("0.00"):
            raise DomainInvariantError(f"[INV-01] El balance inicial no puede ser negativo: {balance_inicial}")
        self._usuario_id = usuario_id
        self._balance = balance_inicial

    @property
    def balance(self) -> Decimal:
        return self._balance

    def debitar(self, monto: Decimal) -> None:
        """Aplica un débito preservando estrictamente el invariante INV-01."""
        if monto <= Decimal("0.00"):
            raise ValueError(f"El monto a debitar debe ser positivo: {monto}")

        # DEFENSA DEL INVARIANTE:
        if self._balance - monto < Decimal("0.00"):
            raise DomainInvariantError(
                f"[INV-01] Saldo insuficiente. Balance actual: {self._balance}, Débito solicitado: {monto}"
            )

        self._balance -= monto
```

## 5. Descripción Didáctica de los Cambios

1. **Documentación Formal:** El invariante `INV-01` está registrado en `docs/DOMAIN.md` como referencia autoritativa.
2. **Encapsulamiento Defensivo:** La clase `CuentaUsuario` protege su balance interno y rechaza débitos que violen la no-negatividad.
3. **Excepción Explícita:** Se utiliza `DomainInvariantError` para comunicar con exactitud qué regla de negocio fue protegida.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Confundir Invariantes con Reglas de UI Efímeras:** Las reglas visuales (ej. *"el botón debe ser azul si el usuario es VIP"*) no son invariantes de dominio; **los invariantes son verdades lógicas e inmutables del núcleo de negocio**.

## 7. Checklist de Verificación

- [ ] ¿Los invariantes críticos de negocio están formalmente documentados y numerados en `docs/DOMAIN.md`?
- [ ] ¿Las entidades de dominio protegen sus invariantes lanzando excepciones ante estados inconsistentes?
- [ ] ¿Existen pruebas automatizadas específicas que intenten violar los invariantes para comprobar que son rechazados?
- [ ] ¿El agente de IA consulta `DOMAIN.md` al diseñar flujos transaccionales?