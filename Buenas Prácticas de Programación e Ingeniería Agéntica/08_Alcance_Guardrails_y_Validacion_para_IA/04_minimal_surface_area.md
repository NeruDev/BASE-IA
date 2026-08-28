---
id: bp_2s88rpn9sjatttse56d042ne0j
name: 04_minimal_surface_area
title: "Área de Superficie Mínima de Modificación"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/04_minimal_surface_area.md
version: 1.1.0
category: agentic
tags: [minimal-surface-area, change-containment, blast-radius, modularity, isolation, universal_principles]
description: "Superficie Mínima de Modificación: resolver problemas alterando el menor número posible de módulos y componentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 04 - Área de Superficie Mínima de Modificación

## 1. Definición y Fundamento Teórico

Basada en los principios de **Bajo Acoplamiento** y **Contención del Radio de Impacto (*Blast Radius Containment*)**, el principio de **Área de Superficie Mínima de Modificación** establece:

> *"Cualquier requerimiento, corrección de bug o nueva funcionalidad implementada por un agente de IA debe resolverse alterando el menor número posible de módulos, clases e interfaces (idealmente 1 o 2 archivos por tarea), evitando la dispersión innecesaria de cambios a lo largo del sistema."*

La meta es contener la mutación dentro de la frontera del dominio afectado, preservando la estabilidad del resto de la arquitectura.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de la Dispersión de Cambios (*Change Scatter*):** Evita que la solución a un bug puntual en facturación obligue a modificar modelos de usuarios, controladores de API y middleware de autenticación.
- **Minimización de Conflictos de Fusión:** Al tocar pocos archivos, se reduce prácticamente a cero la probabilidad de colisionar con ramas de otros desarrolladores.
- **Aislamiento de Errores:** Si la nueva lógica presenta un fallo, el diagnóstico es inmediato porque el cambio estuvo 100% contenido en un único módulo.

## 3. Relevancia en Sistemas con IA Agéntica

- **Enfoque Cognitivo para LLMs:** Obliga al agente a buscar soluciones elegantes y autocontenidas dentro del módulo existente en lugar de propagar cambios desordenados por 6 paquetes.
- **Preservación de Contratos Existentes:** Fomenta que el agente respete las firmas de métodos y modelos vigentes en lugar de alterar interfaces públicas de forma precipitada.
- **Eficiencia en PRs de Agentes:** Los PRs resultantes modifican de 1 a 3 archivos, permitiendo revisiones ágiles y aprobaciones inmediatas.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Dispersión Masiva de Cambios para un Fix Simple)

```text
# Tarea: Validar que los montos de facturación no sean negativos.
# ANTIPATRÓN: El agente dispersa la validación por todo el sistema:
1. Modifica `src/models/user.py` para agregar un validador de balance.
2. Modifica `src/api/routes.py` para agregar chequeos if/else manuales.
3. Modifica `src/billing/service.py` alterando la firma de 4 funciones.
4. Modifica `src/database/session.py` para interceptar transacciones.
RESULTADO: 4 módulos alterados y alto riesgo de regresiones colaterales.
```

### ✅ Flujo Correcto (Conforme a Superficie Mínima: Validación Autocontenida)

Modificación contenida exclusivamente en `src/billing/tax_calculator.py` y su test:
```python
# src/billing/tax_calculator.py
from decimal import Decimal

def calcular_iva(monto: Decimal) -> Decimal:
    """Calcula el IVA del 16% conteniendo la validación defensiva en el propio módulo."""
    # VALIDACIÓN AUTOCONTENIDA (No requiere alterar otros 4 archivos)
    if monto < Decimal("0.00"):
        raise ValueError(f"El monto no puede ser negativo: {monto}")

    return (monto * Decimal("0.16")).quantize(Decimal("0.01"))
```

```python
# tests/unit/billing/test_tax_calculator.py
import pytest
from decimal import Decimal
from src.billing.tax_calculator import calcular_iva

def test_calcular_iva_monto_negativo_lanza_excepcion():
    with pytest.raises(ValueError, match="El monto no puede ser negativo"):
        calcular_iva(Decimal("-10.00"))
```

## 5. Descripción Didáctica de los Cambios

1. **Superficie de Contacto Mínima:** El requerimiento se resolvió modificando exactamente 1 archivo de producción (`tax_calculator.py`) y 1 archivo de prueba (`test_tax_calculator.py`).
2. **Cero Impacto Colateral:** Ninguna interfaz externa, base de datos ni ruta de API fue alterada.
3. **Máxima Cohesión:** La regla de validación reside exactamente donde se realiza el cálculo.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Parches Chapuceros (*Monkey Patching*):** Forzar la superficie mínima no debe ser una excusa para meter lógica con fórceps en un lugar equivocado solo por no crear un archivo nuevo cuando la arquitectura lo exige limpiamente.
- **Refactorizaciones Estructurales:** Si una clase ha violado el principio de responsabilidad única y debe dividirse, la creación de nuevos archivos está justificada mediante un ADR.

## 7. Checklist de Verificación

- [ ] ¿La solución al problema se implementó modificando el menor número posible de archivos (idealmente 1-3)?
- [ ] ¿Se evitó modificar firmas de métodos o contratos públicos en módulos no relacionados?
- [ ] ¿La lógica añadida es altamente cohesiva y reside en el dominio correspondiente?
- [ ] ¿Se verificó que los módulos adyacentes no sufrieran cambios colaterales innecesarios?