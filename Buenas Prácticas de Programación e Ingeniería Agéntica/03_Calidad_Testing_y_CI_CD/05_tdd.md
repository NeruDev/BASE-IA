---
id: bp_49d5cwvvykbdxvhhzaawg61sn5
name: 05_tdd
title: "TDD: Test-Driven Development"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/05_tdd.md
version: 1.1.0
category: code_standards
tags: [tdd, test-driven-development, red-green-refactor, agile, testing, universal_principles]
description: "Test-Driven Development: ciclo Red-Green-Refactor para desarrollo guiado por pruebas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 05 - TDD: Test-Driven Development

## 1. Definición y Fundamento Teórico

Formalizado por **Kent Beck** en su obra clásica *Test-Driven Development: By Example* (2002) como uno de los núcleos metodológicos de *Extreme Programming (XP)*, el **Desarrollo Guiado por Pruebas (TDD)** postula que:

> *"Ninguna línea de código de producción debe escribirse a menos que sea para hacer pasar una prueba unitaria automatizada que ha fallado previamente."*

El flujo de trabajo sigue estrictamente el ciclo iterativo **Red-Green-Refactor**:
1. 🔴 **Red (Rojo):** Escribir una prueba unitaria enfocada en un requerimiento específico y ejecutarla para verificar que **falla** (comprobando que la prueba es válida y no da un falso positivo).
2. 🟢 **Green (Verde):** Escribir la solución más simple y directa posible que haga pasar la prueba (incluso si es rudimentaria).
3. 🔵 **Refactor (Refactorizar):** Limpiar el código, eliminar duplicación, mejorar nombres y estructurar el diseño, manteniendo todas las pruebas en verde en cada paso.

## 2. Por Qué Existe y Problemas que Resuelve

- **Diseño Emergente Guiado por la Usabilidad:** Al escribir el test primero, el desarrollador diseña la API desde la perspectiva del consumidor, produciendo interfaces más limpias y desacopladas.
- **Cobertura de Código Real del 100% en Lógica Nueva:** Garantiza que no exista código muerto o caminos no probados en las nuevas funcionalidades.
- **Confianza Absoluta para Refactorizar:** Una suite creada con TDD permite reestructurar el sistema en cualquier momento con la certeza de que cualquier regresión se detectará al instante.

## 3. Relevancia en Sistemas con IA Agéntica

- **Criterio de Parada Objetivo y Determinista para LLMs:** Los agentes de IA tienden a "declarar victoria" de forma prematura. Si se opera bajo TDD, el agente tiene una meta verificable inmutable: el código solo está terminado cuando el test pasa con código de retorno 0.
- **Prevención de Alucinaciones en Especificaciones:** Escribir el test primero fuerza al agente a consolidar las firmas de función, tipos de entrada y valores de retorno antes de generar la lógica interna.
- **Bucle de Auto-Corrección Eficiente:** Si el test falla en el paso Rojo o Verde, el stack trace exacto alimenta el siguiente turno de razonamiento del agente, guiando la corrección precisa.

## 4. Comparativa Didáctica de Código

### El Ciclo TDD Paso a Paso

#### 🔴 Paso 1: Red (Escribir la prueba que falla primero)

```python
# tests/test_shipping.py
import pytest
from decimal import Decimal
# from src.shipping import calcular_costo_envio (Aún no existe)

def test_calcular_costo_envio_gratis_para_pedidos_mayores_a_100():
    # TEST RED: Falla inmediatamente con ImportError o AssertionError
    from src.shipping import calcular_costo_envio
    costo = calcular_costo_envio(monto_pedido=Decimal("150.00"), distancia_km=10)
    assert costo == Decimal("0.00")
```

#### 🟢 Paso 2: Green (Escribir la implementación mínima para pasar)

```python
# src/shipping.py
from decimal import Decimal

def calcular_costo_envio(monto_pedido: Decimal, distancia_km: int) -> Decimal:
    # Solución mínima que satisface el test:
    if monto_pedido >= Decimal("100.00"):
        return Decimal("0.00")
    return Decimal("10.00")  # Valor básico para pruebas iniciales
```

#### 🔵 Paso 3: Refactor (Limpiar el diseño preservando el test en verde)

```python
# src/shipping.py (Refactorizado con constantes, validaciones y docstrings)
from decimal import Decimal

UMBRAL_ENVIO_GRATIS = Decimal("100.00")
TARIFA_BASE_ENVIO = Decimal("10.00")
COSTO_POR_KM_EXTRA = Decimal("0.50")

def calcular_costo_envio(monto_pedido: Decimal, distancia_km: int) -> Decimal:
    """Calcula el costo de flete aplicando política de envío gratuito sobre umbral."""
    if monto_pedido < Decimal("0.00") or distancia_km < 0:
        raise ValueError("El monto del pedido y la distancia deben ser no negativos.")

    if monto_pedido >= UMBRAL_ENVIO_GRATIS:
        return Decimal("0.00")

    return TARIFA_BASE_ENVIO + (Decimal(distancia_km) * COSTO_POR_KM_EXTRA)
```

## 5. Descripción Didáctica de los Cambios

1. **Red Inicial:** Se definió la expectativa del cliente (`monto >= 100 -> costo == 0`) antes de escribir código de negocio.
2. **Green Inmediato:** Se implementó el condicional indispensable para pasar la prueba unitaria en milisegundos.
3. **Refactorización Segura:** Se incorporaron validaciones defensivas, constantes nombradas y tarifas por kilómetro sin romper el test original.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Spikes de Investigación y PoCs Desconocidos:** Cuando no se comprende cómo funciona una librería externa o un algoritmo experimental, forzar TDD puede bloquear la creatividad; en esos casos se realiza un *Spike* de código exploratorio y luego se reescribe con TDD.
- **Diseño Visual e Interfaces Gráficas Cambiantes:** Diseñar la estética de un frontend mediante TDD es ineficiente; es preferible usar herramientas visuales interactivas y aplicar TDD al ViewModel o capa lógica.
- **Dogmatismo en Código Trivial:** Escribir tests previos para getters/setters o mapeos directos obvios añade sobrecarga sin mitigar riesgos reales.

## 7. Checklist de Verificación

- [ ] ¿Se escribió y ejecutó la prueba unitaria antes de comenzar el código de producción?
- [ ] ¿Se verificó que la prueba fallara inicialmente por la razón correcta (fase Red)?
- [ ] ¿Se implementó la solución más sencilla posible para pasar la prueba (fase Green)?
- [ ] ¿Se realizó una refactorización de limpieza garantizando que todos los tests continúen en verde?