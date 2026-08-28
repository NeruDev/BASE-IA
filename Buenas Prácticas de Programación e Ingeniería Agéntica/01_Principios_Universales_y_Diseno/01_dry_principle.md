---
id: bp_4jhc4rkem1bvaamp134a8mhvne
name: 01_dry_principle
title: "Principio DRY: Don't Repeat Yourself"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/01_dry_principle.md
version: 1.1.0
category: universal_principles
tags: [dry, modularity, abstraction, single-source-of-truth, maintenance]
description: "Don't Repeat Yourself: centralización de lógica autoritativa y límites ante duplicación coincidente."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 01 - Principio DRY: Don't Repeat Yourself

## 1. Definición y Fundamento Teórico

Formulado originalmente por Andy Hunt y Dave Thomas en *The Pragmatic Programmer* (1999), el principio **DRY (Don't Repeat Yourself)** establece que:

> *"Cada pieza de conocimiento o lógica de negocio debe tener una representación única, inequívoca y autoritativa dentro de un sistema."*

**Aclaración fundamental:** DRY no se refiere únicamente a evitar líneas de código textual o sintácticamente idénticas. Su objetivo es la **duplicación de conocimiento**. Dos bloques de código pueden parecer idénticos hoy, pero si cambian por razones de negocio distintas, no representan la misma pieza de conocimiento.

## 2. Por Qué Existe y Problemas que Resuelve

- **Inconsistencia y Desincronización:** Cuando una regla de negocio se replica en varios módulos, modificarla en uno sin actualizar los demás produce comportamientos contradictorios y bugs silenciosos.
- **Sobrecarga de Mantenimiento:** Multiplica el costo de desarrollo, refactorización y cobertura de pruebas unitarias.
- **Aumento de la Deuda Técnica:** La dispersión de lógica dificulta la auditoría y el entendimiento global del comportamiento del software.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prevención de Fragmentación por Agentes:** Los LLMs y agentes autónomos tienden a generar utilidades *inline* aisladas en cada tarea cuando carecen de visibilidad global del repositorio o cuando operan con ventanas de contexto acotadas.
- **Eficiencia de Contexto:** Centralizar funciones y constantes permite al agente importar interfaces consolidadas en lugar de re-razonar y re-generar implementaciones divergentes.
- **Garantía de Reglas Críticas:** Asegura que políticas transversales (seguridad, validación de tokens, esquemas de persistencia) no sean recreadas con discrepancias por subagentes en paralelo.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Duplicación de Conocimiento)

```python
# modulo_ventas.py
def calcular_total_venta(monto_base: float, tasa_iva: float = 0.16) -> float:
    # ERROR: Lógica tributaria calculada de forma inline
    # ERROR: Si la tasa cambia o se requiere redondeo bancario, este módulo quedará desfasado
    impuesto = monto_base * tasa_iva
    return monto_base + impuesto

# modulo_facturacion.py
def emitir_factura(monto_base: float) -> dict[str, float]:
    # ERROR: Duplica el cálculo de IVA hardcodeando 1.16
    # ERROR: No valida montos negativos ni maneja precisión decimal (IEEE 754)
    total = monto_base * 1.16
    return {"base": monto_base, "total": total}
```

### ✅ Código Correcto (Conforme a Estándar: Centralizado y Preciso)

```python
# src/core/finance.py
from decimal import Decimal, ROUND_HALF_UP

# MEJORA: Constante centralizada y autoritativa (Single Source of Truth)
TASA_IVA_STANDARD = Decimal("0.16")

def calcular_monto_con_impuesto(
    monto_base: Decimal,
    tasa: Decimal = TASA_IVA_STANDARD
) -> Decimal:
    """Calcula el total con impuesto de forma precisa y centralizada.

    Args:
        monto_base: Cantidad monetaria base no negativa.
        tasa: Tasa impositiva aplicable (por defecto 0.16).

    Returns:
        Decimal redondeado a 2 posiciones decimales.

    Raises:
        ValueError: Si monto_base o tasa son negativos.
    """
    # MEJORA: Validación temprana de precondiciones
    if monto_base < Decimal("0") or tasa < Decimal("0"):
        raise ValueError("El monto base y la tasa impositiva deben ser no negativos.")

    # MEJORA: Uso de Decimal para evitar imprecisiones de punto flotante
    total = monto_base * (Decimal("1") + tasa)
    return total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
```

## 5. Descripción Didáctica de los Cambios

1. **Centralización de la Regla de Negocio:** Se eliminaron los cálculos dispersos en `modulo_ventas.py` y `modulo_facturacion.py`, consolidando la fórmula en `src/core/finance.py`.
2. **Tipado y Precisión Numérica:** Se reemplazó `float` por `Decimal` con redondeo explícito (`ROUND_HALF_UP`) para evitar inconsistencias de redondeo financiero.
3. **Validación Defensiva:** Se implementó una precondición explícita que impide procesar montos o tasas negativas.
4. **Documentación:** Se incorporó docstring con tipos de entrada/salida y excepciones esperadas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

Aplicar DRY de forma ciega o prematura genera problemas severos en el diseño:

- **Duplicación Accidental vs. Duplicación de Conocimiento:** Dos procesos que hoy calculan un valor de manera idéntica pueden pertenecer a dominios conceptualmente diferentes. Unificarlos genera un acoplamiento artificial que obligará a meter condicionales (*flags*) cuando sus requerimientos diverjan.
- **Abstracción Prematura (*The Wrong Abstraction*):** Como formuló Sandi Metz: *"La duplicación es mucho más barata que la abstracción equivocada"*. Es preferible tolerar duplicación temporal hasta que el patrón emerja con claridad (Regla de Tres / *Rule of Three*).
- **Límites de Microservicios y Bounded Contexts:** Compartir librerías de código interno para forzar DRY entre servicios independientes crea acoplamiento en despliegues y versiones. En arquitecturas distribuidas, la autonomía del servicio prevalece sobre la reutilización de código.
- **Código de Pruebas (DAMP sobre DRY):** En suites de testing, se prefiere **DAMP** (*Descriptive And Meaningful Phrases*) sobre DRY estricto, para que cada test sea autocontenido y legible sin obligar al desarrollador o agente a navegar por múltiples fixtures anidadas.

## 7. Checklist de Verificación

- [ ] ¿Existe un único punto de verdad para esta regla de negocio o cálculo?
- [ ] ¿Los módulos cliente importan la función centralizada en lugar de reimplementarla?
- [ ] ¿La abstracción creada representa un único concepto de negocio y no una coincidencia sintáctica?
- [ ] ¿Se evaluó si la unificación generará acoplamiento entre dominios no relacionados?