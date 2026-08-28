---
id: bp_52vw6zxxzybmgty5kj35xwd8n2
name: 07_regression_testing
title: "Pruebas de Regresión Automatizadas"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/07_regression_testing.md
version: 1.1.0
category: code_standards
tags: [regression-testing, automated-tests, bug-fix, quality-assurance, universal_principles]
description: "Pruebas de Regresión: blindaje automatizado contra fallos introducidos por agentes y refactorizaciones."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 07 - Pruebas de Regresión Automatizadas

## 1. Definición y Fundamento Teórico

Pilar central del Aseguramiento de Calidad (*QA*) y la Integración Continua, las **Pruebas de Regresión Automatizadas** constituyen la práctica de ingeniería que establece:

> *"Cada vez que el software se modifica para incorporar una nueva característica, corregir un defecto o realizar una refactorización, debe re-ejecutarse automáticamente un conjunto integral de pruebas para confirmar que las funcionalidades preexistentes no han sufrido alteraciones indeseadas ni degradación de rendimiento."*

La máxima metodológica de esta disciplina es la **Regla Bug-to-Test (*Defect-to-Test Principle*)**:
> *"Ningún defecto debe corregirse sin antes haber escrito una prueba de regresión automatizada que reproduzca el fallo y que permanezca para siempre en la suite de pruebas del proyecto."*

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de la Reaparición de Bugs Históricos:** Evita que un error corregido hace meses vuelva a manifestarse tras una refactorización posterior.
- **Seguridad en Entornos de Despliegue Frecuente:** Proporciona la certeza necesaria para desplegar a producción múltiples veces al día sin temor a efectos colaterales ocultos.
- **Reducción del Costo de Verificación:** Automatiza miles de comprobaciones que manualmente tomarían semanas de trabajo repetitivo.

## 3. Relevancia en Sistemas con IA Agéntica

- **Blindaje contra Efectos Secundarios de LLMs:** Los agentes de IA pueden resolver exitosamente la tarea asignada pero romper inadvertidamente dependencias sutiles en otros módulos. Una suite de regresión sólida intercepta estas roturas al instante.
- **Validación Automática de PRs Agénticas:** Permite a los sistemas de orquestación multi-agente aceptar o rechazar parches de forma 100% determinista sin intervención humana.
- **Generación de Pruebas de Regresión por Agentes:** Ante un reporte de bug, el primer paso instruido al agente debe ser escribir el test que reproduce el fallo antes de tocar el código fuente.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Corrección de Bug sin Test de Regresión)

```python
# Bug Report: "Los usuarios con timezone UTC-5 pierden acceso 5 horas antes de que venza su suscripción"
# ANTIPATRÓN: El desarrollador o agente parchó la función directamente sin crear un test que blinde el caso.
# En el futuro, otra refactorización volverá a romper este caso límite silenciosamente.
def esta_suscripcion_activa_sin_test(fecha_vencimiento_iso: str) -> bool:
    # Parche rápido susceptible a futuras regresiones
    return True
```

### ✅ Código Correcto (Conforme a Regresión: Test Blindado + Fix Estructurado)

```python
# tests/test_regression_subscription.py
import pytest
from datetime import datetime, timezone, timedelta
from src.domain.subscriptions import verificar_acceso_suscripcion

# TEST DE REGRESIÓN: Captura formalmente el escenario que originó el defecto
@pytest.mark.parametrize("offset_horas, esperado", [
    (-5, True),   # Cliente en UTC-5 (América/Bogotá / NY)
    (0, True),    # Cliente en UTC
    (+9, True),   # Cliente en UTC+9 (Tokio)
])
def test_regression_acceso_suscripcion_con_diferentes_zonas_horarias(offset_horas, esperado):
    """Regresión Bug #1042: Verificar que el cálculo considere zonas horarias con offset."""
    tz_cliente = timezone(timedelta(hours=offset_horas))
    ahora_cliente = datetime.now(tz_cliente)
    vence_en_una_hora = ahora_cliente + timedelta(hours=1)

    # Debe permitir acceso sin importar la zona horaria del cliente
    resultado = verificar_acceso_suscripcion(fecha_vencimiento=vence_en_una_hora, fecha_actual=ahora_cliente)
    assert resultado is esperado

# src/domain/subscriptions.py (Implementación robusta normalizada a UTC)
def verificar_acceso_suscripcion(fecha_vencimiento: datetime, fecha_actual: datetime) -> bool:
    """Verifica el estado de acceso normalizando ambas marcas temporales a UTC."""
    vencimiento_utc = fecha_vencimiento.astimezone(timezone.utc)
    actual_utc = fecha_actual.astimezone(timezone.utc)
    return actual_utc < vencimiento_utc
```

## 5. Descripción Didáctica de los Cambios

1. **Blindaje con Prueba de Regresión:** `test_regression_acceso_suscripcion_con_diferentes_zonas_horarias` reproduce el caso exacto del bug con zonas horarias diversas (`UTC-5`, `UTC`, `UTC+9`).
2. **Normalización Defensiva:** La implementación normaliza a `timezone.utc`, asegurando consistencia matemática universal.
3. **Protección Permanente:** El test queda integrado en la suite general de CI; si un agente futuro intenta modificar este método, el test fallará inmediatamente si la lógica de zonas horarias se ve comprometida.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobrecarga de Tiempo de Ejecución (*Test Suite Bloat*):** Acumular miles de pruebas pesadas sin optimización puede hacer que la suite tarde horas. Es indispensable categorizar en **Smoke Regression** (rápida para PRs) y **Full Regression** (nocturna).
- **Pruebas de Regresión Obsoletas:** Mantener tests que validan comportamientos o flujos de negocio que ya fueron explícitamente reemplazados introduce fricción y falsos negativos.
- **Falsa Confianza con Tests Superficiales:** Tener miles de pruebas que solo verifican códigos HTTP 200 sin aserciones profundas de datos crea una ilusión de cobertura sin protección real.

## 7. Checklist de Verificación

- [ ] ¿Cada corrección de bug incluye una prueba de regresión automatizada que reproduce el problema?
- [ ] ¿La suite de regresión se ejecuta automáticamente en cada commit o Pull Request?
- [ ] ¿Los tests de regresión están categorizados para optimizar los tiempos de ejecución en CI?
- [ ] ¿Se eliminan o actualizan periódicamente las pruebas de regresión asociadas a características deprecadas?