---
id: bp_1rz97983h5aw1rcem4zxspjvas
name: 06_bdd
title: "BDD: Behavior-Driven Development"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/06_bdd.md
version: 1.1.0
category: code_standards
tags: [bdd, behavior-driven-development, gherkin, given-when-then, testing, universal_principles]
description: "Behavior-Driven Development: especificación formal del comportamiento en escenarios Given-When-Then."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 06 - BDD: Behavior-Driven Development

## 1. Definición y Fundamento Teórico

Concebido por **Dan North** en 2006 como una evolución y refinamiento de TDD y popularizado por **Gojko Adzic** (*Specification by Example*), el **Desarrollo Guiado por Comportamiento (BDD)** establece que:

> *"El desarrollo y las pruebas de software deben guiarse por la especificación formal del comportamiento observable del sistema expresado en un lenguaje ubicuo compartido entre el negocio, los desarrolladores y los agentes automatizados."*

La estructura estándar se formula mediante la sintaxis **Gherkin (Given-When-Then)**:
- **Given (Dado):** Establece el contexto y las condiciones iniciales del sistema.
- **When (Cuando):** Describe la acción, evento o estímulo provocado por un actor o agente.
- **Then (Entonces):** Verifica los resultados observables esperados y los cambios de estado.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del Abismo de Comunicación:** Traduce las intenciones de los *stakeholders* de negocio en especificaciones ejecutables sin pérdida de significado técnico.
- **Pruebas Centradas en el Comportamiento (No en la Implementación):** Evita que las pruebas se rompan ante refactorizaciones internas que preservan el comportamiento externo.
- **Documentación Viva (*Living Documentation*):** Las especificaciones BDD actúan como manual de usuario y suite de pruebas automatizadas al mismo tiempo.

## 3. Relevancia en Sistemas con IA Agéntica

- **Ingeniería de Prompts Estructurada:** Instruir a un agente de IA utilizando el formato *Given-When-Then* reduce la ambigüedad y previene alucinaciones en la interpretación de requisitos.
- **Generación Automatizada de Casos de Prueba:** Los agentes pueden traducir historias de usuario en lenguaje natural a escenarios BDD ejecutables y generar sus correspondientes implementaciones (*step definitions*).
- **Validación de Criterios de Aceptación:** Provee un mecanismo formal para verificar si las tareas completadas por agentes cumplen con las expectativas del usuario.

## 4. Comparativa Didáctica de Código

### Escenario BDD en Gherkin (`features/refunds.feature`)

```gherkin
Feature: Política de Devoluciones de Productos

  Scenario: Devolución exitosa dentro del plazo legal de 30 días
    Given un cliente con una compra realizada hace 15 días
    And el producto se encuentra en estado "SELLADO"
    When el cliente solicita la devolución del dinero
    Then la solicitud es aprobada
    And se genera un reembolso por el monto total de la compra
```

### ✅ Implementación del Comportamiento en Python (`tests/test_refunds_bdd.py`)

```python
# src/domain/refunds.py (Lógica de Dominio)
from dataclasses import dataclass
from datetime import datetime, timezone, timedelta
from decimal import Decimal

@dataclass(frozen=True)
class Purchase:
    amount: Decimal
    purchase_date: datetime
    product_status: str

@dataclass(frozen=True)
class RefundResult:
    is_approved: bool
    refund_amount: Decimal

def procesar_solicitud_devolucion(purchase: Purchase, current_date: datetime) -> RefundResult:
    dias_transcurridos = (current_date - purchase.purchase_date).days
    if dias_transcurridos <= 30 and purchase.product_status == "SELLADO":
        return RefundResult(is_approved=True, refund_amount=purchase.amount)
    return RefundResult(is_approved=False, refund_amount=Decimal("0.00"))

# tests/test_refunds_bdd.py (Verificación del Escenario BDD)
def test_scenario_devolucion_exitosa_dentro_del_plazo():
    # GIVEN: un cliente con una compra realizada hace 15 días con producto SELLADO
    ahora = datetime.now(timezone.utc)
    fecha_compra = ahora - timedelta(days=15)
    compra = Purchase(amount=Decimal("150.00"), purchase_date=fecha_compra, product_status="SELLADO")

    # WHEN: el cliente solicita la devolución del dinero
    resultado = procesar_solicitud_devolucion(compra, current_date=ahora)

    # THEN: la solicitud es aprobada y se genera el reembolso total
    assert resultado.is_approved is True
    assert resultado.refund_amount == Decimal("150.00")
```

## 5. Descripción Didáctica de los Cambios

1. **Especificación en Lenguaje Ubicuo:** El archivo de comportamiento describe la regla de 30 días y producto sellado en términos que cualquier analista de negocio comprende.
2. **Implementación Directa del Comportamiento:** El test unitario mapea explícitamente los pasos *Given*, *When* y *Then* mediante código tipado y legible.
3. **Resistencia a Refactorizaciones:** Si la estructura interna de `procesar_solicitud_devolucion` cambia, la prueba seguirá verificando fielmente el comportamiento prometido.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobrecarga de Pegamento (*Glue Code Maintenance*):** Utilizar frameworks BDD pesados (como Cucumber o Behave) para funciones técnicas internas añade una capa de indirección innecesaria frente a un test directo con `pytest`.
- **No Apto para Lógica Algorítmica de Bajo Nivel:** Algoritmos de encriptación, drivers de red o parsing binario se benefician más de TDD unitario directo que de historias de usuario Given-When-Then.
- **Riesgo de Escenarios Técnicos Mal Redactados:** Escribir pasos que describen clicks en botones o llamadas a bases de datos (*"Given click en botón #submit"*) desvirtúa BDD transformándolo en scripting frágil de UI.

## 7. Checklist de Verificación

- [ ] ¿Los escenarios están redactados desde la perspectiva del comportamiento de negocio sin detalles técnicos de implementación?
- [ ] ¿Se utiliza la estructura formal *Given-When-Then* de forma coherente?
- [ ] ¿Los tests verifican resultados observables en lugar del estado interno privado de las clases?
- [ ] ¿Se reservó el uso de BDD para flujos de negocio y criterios de aceptación principales?