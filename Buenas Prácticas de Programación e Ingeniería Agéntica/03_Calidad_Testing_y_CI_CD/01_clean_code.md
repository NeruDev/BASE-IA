---
id: bp_35rdqtkebrby7vtddf6jcw49c9
name: 01_clean_code
title: "Código Limpio (Clean Code)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/01_clean_code.md
version: 1.1.0
category: code_standards
tags: [clean-code, readability, refactoring, code-quality, universal_principles]
description: "Código Limpio: legibilidad inmediata, funciones pequeñas, nombres con intención y abstracción coherente."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 01 - Código Limpio (Clean Code)

## 1. Definición y Fundamento Teórico

Sintetizado por **Robert C. Martin ("Uncle Bob")** en su obra clásica *Clean Code: A Handbook of Agile Software Craftsmanship* (2008), el principio de **Código Limpio** establece que:

> *"El código limpio es aquel que ha sido escrito con tal claridad, sencillez y franqueza que cualquier desarrollador puede leerlo, comprender su intención y mantenerlo sin esfuerzo mental excesivo. Se lee como prosa bien redactada."*

Los pilares fundamentales del código limpio incluyen:
- **Nombres con Intención Explicita:** Nombres de variables, clases y funciones que revelan el *por qué existe*, *qué hace* y *cómo se usa*.
- **Funciones Pequeñas y de Un Solo Propósito:** Cada función debe hacer una sola cosa y hacerla bien (*Single Level of Abstraction Principle - SLAP*).
- **Auto-documentación:** El código debe ser tan claro que los comentarios solo sean necesarios para justificar decisiones de negocio atípicas, no para explicar código confuso.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reducción de la Carga Cognitiva:** La proporción entre tiempo de lectura y tiempo de escritura de código supera el 10:1. El código legible multiplica la productividad del equipo.
- **Minimización de Errores Ocultos:** El código enredado (*code smells*) enmascara bugs y condiciones de carrera que pasan inadvertidos en revisiones superficiales.
- **Facilidad de Refactorización:** Funciones concisas y desacopladas son fáciles de reorganizar sin temor a romper comportamientos no relacionados.

## 3. Relevancia en Sistemas con IA Agéntica

- **Reducción de Alucinaciones en Agentes de IA:** Los LLMs razonan de forma mucho más certera cuando analizan código limpio con nombres explícitos; nombres crípticos (`x`, `tmp`, `f_val`) inducen a los agentes a inferir tipos o propósitos erróneos.
- **Eficiencia de la Ventana de Contexto:** El código sin duplicaciones, funciones gigantescas ni comentarios obsoletos reduce drásticamente el uso de tokens por consulta.
- **Generación Predecible de Cambios:** Un agente guiado por estándares de código limpio produce parches consistentes que encajan armónicamente en el estilo del repositorio.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Nombres Opacos, Flags Booleanos y Mezcla de Niveles)

```python
# Antipatrón: Nombres inexpresivos, flag booleano que altera el comportamiento y números mágicos
def proc(u, flag=False):
    # ERROR: ¿Qué es u? ¿Qué significa flag?
    r = []
    for x in u:
        # Número mágico 86400 (segundos en un día)
        if x.get("s", 0) > 86400:
            if flag:
                # Modifica datos y calcula al mismo tiempo
                v = x["b"] * 0.90  # ¿Descuento del 10%?
                r.append(v)
            else:
                r.append(x["b"])
    return r
```

### ✅ Código Correcto (Conforme a Clean Code: Nombres Expresivos, Tipado y Funciones Descriptivas)

```python
# src/billing/discounts.py
from dataclasses import dataclass
from decimal import Decimal

# Constantes explícitas eliminan números mágicos
SEGUNDOS_EN_UN_DIA = 86_400
FACTOR_DESCUENTO_CLIENTE_ANTIGUO = Decimal("0.90")

@dataclass(frozen=True)
class CuentaSuscripcion:
    id: str
    segundos_activa: int
    balance_mensual: Decimal

def calcular_balances_con_descuento_antiguedad(
    cuentas: list[CuentaSuscripcion],
    aplicar_descuento: bool = False
) -> list[Decimal]:
    """Calcula los balances mensuales aplicables para cuentas con más de 24h de actividad.

    Args:
        cuentas: Lista de suscripciones a evaluar.
        aplicar_descuento: Si es True, aplica el 10% de descuento por antigüedad.

    Returns:
        Lista de balances mensuales finales en Decimal.
    """
    cuentas_elegibles = [c for c in cuentas if c.segundos_activa > SEGUNDOS_EN_UN_DIA]

    if not aplicar_descuento:
        return [c.balance_mensual for c in cuentas_elegibles]

    return [c.balance_mensual * FACTOR_DESCUENTO_CLIENTE_ANTIGUO for c in cuentas_elegibles]
```

## 5. Descripción Didáctica de los Cambios

1. **Nombres Significativos:** Se reemplazaron nombres opacos (`proc`, `u`, `flag`, `r`, `b`) por identificadores transparentes (`CuentaSuscripcion`, `cuentas_elegibles`, `balance_mensual`).
2. **Eliminación de Números Mágicos:** `86400` y `0.90` fueron promovidos a constantes descriptivas nombradas.
3. **Tipado Fuerte y Precisión:** Uso de `dataclass` inmutable y `Decimal` para garantizar integridad en cálculos financieros.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Micro-fragmentación Excesiva (*Function Proliferation*):** Dividir una función lineal y clara de 15 líneas en 7 micro-funciones de 2 líneas que solo se llaman una vez añade saltos visuales y sobrecarga mental sin beneficio real.
- **Rendimiento Extremo en Bucles Críticos:** En algoritmos de cómputo intensivo o procesamiento de imágenes a nivel de píxel, la extracción excesiva de funciones pequeñas puede tener impacto por la sobrecarga de *call-stack* (en lenguajes interpretados).
- **Dogmatismo de Cero Comentarios:** Aunque el código debe ser auto-documentado, los comentarios que explican el *porqué de una decisión de negocio compleja* o un *workaround ante un bug de un vendor externo* son indispensables y valiosos.

## 7. Checklist de Verificación

- [ ] ¿Los nombres de funciones y variables expresan con claridad su propósito sin necesidad de adivinar?
- [ ] ¿Cada función opera en un único nivel de abstracción y tiene una responsabilidad acotada?
- [ ] ¿Se eliminaron números mágicos y cadenas de texto hardcodeadas en favor de constantes nombradas?
- [ ] ¿El código carece de comentarios que simplemente repiten lo que el código ya dice de forma evidente?