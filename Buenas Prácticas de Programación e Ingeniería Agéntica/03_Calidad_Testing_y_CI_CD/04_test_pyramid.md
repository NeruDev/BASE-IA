---
id: bp_38k9nzhkcfbwa8x64b4f9fbvbp
name: 04_test_pyramid
title: "La Pirámide de Pruebas (Test Pyramid)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/04_test_pyramid.md
version: 1.1.0
category: code_standards
tags: [test-pyramid, unit-testing, integration-testing, e2e, testing-strategy, universal_principles]
description: "Pirámide de Pruebas: base amplia de tests unitarios ultrarrápidos, integración equilibrada y mínimos tests E2E."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 04 - La Pirámide de Pruebas (Test Pyramid)

## 1. Definición y Fundamento Teórico

Introducida por **Mike Cohn** en *Succeeding with Agile* (2009) y popularizada por **Martin Fowler**, la **Pirámide de Pruebas** es una guía estratégica que establece la distribución óptima de los tipos de pruebas automatizadas en un sistema de software:

```text
       / \
      / E2E \       <-- Cúspide: Pocos tests E2E / UI (Lentos, costosos, frágiles: ~5-10%)
     /-------\
    / Integr. \     <-- Capa Media: Tests de Integración / Componente (~15-20%)
   /-----------\
  /  Unitarias  \   <-- Base: Masiva cantidad de Tests Unitarios (<50ms, aislados: ~70-80%)
 /---------------\
```

El principio busca evitar a toda costa el **Antipatrón del Cono de Helado (*Ice Cream Cone / Inverted Pyramid*)**, donde una base escasa de pruebas unitarias sostiene una capa hipertrofiada y frágil de pruebas E2E manuales o de interfaz que tardan horas en ejecutarse.

## 2. Por Qué Existe y Problemas que Resuelve

- **Velocidad de Retroalimentación (*Fast Feedback Loop*):** Los tests unitarios se ejecutan en milisegundos, permitiendo al desarrollador verificar cambios continuamente durante la codificación.
- **Localización Precisa de Fallos:** Si un test unitario falla, señala exactamente la línea y función rota; si un test E2E falla, puede deberse a la base de datos, la red, el navegador o la lógica de negocio.
- **Reducción de Costos de Mantenimiento:** Las pruebas unitarias son deterministas y resistentes a cambios visuales, mientras que las suites E2E pesadas sufren de intermitencia (*Flaky Tests*).

## 3. Relevancia en Sistemas con IA Agéntica

- **Ciclos Rápidos de Auto-Corrección:** En el bucle de razonamiento de un agente (ReAct / Agentic Coding), el modelo requiere validar sus ediciones en menos de 2 segundos. Tests unitarios rápidos permiten al agente iterar y reparar errores en tiempo real.
- **Eficiencia Computacional:** Evita que el agente consuma minutos de inferencia y recursos de servidor esperando la inicialización de navegadores o contenedores pesados.
- **Aislamiento de Diagnóstico:** Permite al agente discernir si su cambio rompió una regla pura de dominio o si se trata de un problema de infraestructura externa.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Cono de Helado / Test E2E Frágil para Lógica Pura)

```python
# Antipatrón: Probar un cálculo de descuento financiero levantando un navegador Selenium
# Tarda 35 segundos, requiere Chrome instalado y falla si la UI cambia un botón
from selenium import webdriver
from selenium.webdriver.common.by import By

def test_calculo_descuento_e2e_fragil():
    driver = webdriver.Chrome()
    driver.get("http://localhost:8000/cart")
    driver.find_element(By.ID, "coupon_input").send_keys("VERANO10")
    driver.find_element(By.ID, "apply_btn").click()
    total_text = driver.find_element(By.ID, "total_price").text
    assert total_text == "$90.00"  # Frágil: si el botón cambia de ID o la red parpadea, falla
    driver.quit()
```

### ✅ Código Correcto (Conforme a la Pirámide: Test Unitario Aislado en Memoria)

```python
# src/domain/discounts.py (Lógica Pura de Dominio)
from decimal import Decimal

def aplicar_descuento_porcentual(monto_base: Decimal, porcentaje: Decimal) -> Decimal:
    """Calcula el monto neto tras aplicar un porcentaje de descuento."""
    if monto_base < Decimal("0.00"):
        raise ValueError(f"Monto base no puede ser negativo: {monto_base}")
    if not (Decimal("0.00") <= porcentaje <= Decimal("1.00")):
        raise ValueError(f"Porcentaje de descuento fuera de rango [0, 1]: {porcentaje}")

    descuento = monto_base * porcentaje
    return monto_base - descuento

# tests/unit/test_discounts.py (Test Unitario Puro: Ejecución en <1ms en pytest)
import pytest
from decimal import Decimal

@pytest.mark.parametrize("base, porcentaje, esperado", [
    (Decimal("100.00"), Decimal("0.10"), Decimal("90.00")),
    (Decimal("50.00"), Decimal("0.00"), Decimal("50.00")),
    (Decimal("200.00"), Decimal("0.50"), Decimal("100.00")),
    (Decimal("100.00"), Decimal("1.00"), Decimal("0.00")),
])
def test_aplicar_descuento_porcentual_casos_validos(base, porcentaje, esperado):
    resultado = aplicar_descuento_porcentual(base, porcentaje)
    assert resultado == esperado

def test_aplicar_descuento_porcentual_rechaza_negativos():
    with pytest.raises(ValueError, match="no puede ser negativo"):
        aplicar_descuento_porcentual(Decimal("-10.00"), Decimal("0.10"))
```

## 5. Descripción Didáctica de los Cambios

1. **Aislamiento en Memoria:** El test unitario evalúa la función matemática directamente con `pytest` sin navegadores, sockets ni servidores HTTP.
2. **Cobertura Exhaustiva de Casos Límite:** Mediante `@pytest.mark.parametrize`, se verifican múltiples escenarios (0%, 50%, 100%, valores inválidos) en menos de 5 milisegundos.
3. **Distribución Piramidal:** La lógica de cálculo queda cubierta al 100% en la base unitaria; la capa E2E se reserva para un único test de humo que valide que el endpoint responde.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **El Trofeo de Pruebas (*Testing Trophy*):** En aplicaciones web modernas con lógica de negocio delegada a servicios integrados (BFFs, GraphQL, lambdas intermediarias), las **pruebas de integración** con base de datos en memoria (SQLite/testcontainers) pueden ofrecer un mejor retorno de inversión (ROI) que obsesionarse con tests unitarios hiper-aislados con mocks.
- **Herramientas de Integración Exclusivas:** Para drivers de hardware o clientes de APIs de terceros donde casi no existe lógica pura, la base de la pirámide naturalmente se desplaza hacia pruebas de integración y contratos.
- **Falsa Seguridad de Tests Unitarios Aislados:** 100 tests unitarios en verde no garantizan que los componentes interactúen correctamente entre sí si no existen pruebas de integración que los unan.

## 7. Checklist de Verificación

- [ ] ¿La suite de pruebas unitarias se ejecuta en menos de 10 segundos en local?
- [ ] ¿Los tests unitarios están libres de dependencias de red, sockets y bases de datos reales?
- [ ] ¿La gran mayoría (~70-80%) de los casos límite y ramas de decisión se cubren a nivel unitario?
- [ ] ¿Las pruebas E2E se reservan exclusivamente para los caminos críticos (*Happy Paths*) del negocio?