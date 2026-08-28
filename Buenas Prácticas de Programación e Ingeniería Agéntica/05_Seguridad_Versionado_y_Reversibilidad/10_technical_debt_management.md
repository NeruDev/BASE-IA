---
id: bp_5qtygnxczeamka7sete3a1xaez
name: 10_technical_debt_management
title: "Gestión y Control de Deuda Técnica"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/10_technical_debt_management.md
version: 1.1.0
category: standards
tags: [technical-debt, adr, architecture-decision-records, refactoring, code-health, universal_principles]
description: "Gestión de Deuda Técnica: registro, control mediante ADRs y pago planificado de compromisos técnicos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 10 - Gestión y Control de Deuda Técnica

## 1. Definición y Fundamento Teórico

Introducida por **Ward Cunningham** en 1992 (OOPSLA) como una metáfora financiera y formalizada mediante los **Registros de Decisiones Arquitectónicas (Architecture Decision Records - ADRs)** por **Michael Nygard**, la **Gestión de Deuda Técnica** establece:

> *"Asumir atajos temporales o compromisos de diseño para acelerar una entrega es una herramienta estratégica legítima, siempre y cuando la deuda sea formalmente registrada, cuantificada y pagada de forma planificada y periódica antes de que el pago de intereses (*lentitud de desarrollo, bugs e inestabilidad*) supere la capacidad operativa del equipo."*

El **Cuadrante de Deuda Técnica de Martin Fowler** clasifica la deuda en:
- **Prudente y Deliberada (Recomendada con ADR):** *"Sabemos que este atajo tiene limitaciones, lo documentamos y lo pagaremos en el sprint $N+1$ tras validar el MVP"*.
- **Imprudente e Inadvertida (Antipatrón Tóxico):** Código chapucero generado sin conciencia de diseño ni documentación.

## 2. Por Qué Existe y Problemas que Resuelve

- **Visibilidad Transparente de la Calidad Interna:** Transforma la deuda técnica invisible en tickets priorizables en el backlog junto a las características de negocio.
- **Prevención de la Bancarrota del Software:** Evita llegar al punto crítico donde cambiar una línea de código requiere semanas de trabajo y genera fallos en cascada.
- **Trazabilidad de Decisiones con ADRs:** Permite a futuros desarrolladores entender por qué se adoptó una solución temporal en lugar de asumir que fue un descuido.

## 3. Relevancia en Sistemas con IA Agéntica

- **Auditoría de Compromisos Generados por IA:** Los agentes de IA pueden optar por soluciones pragmáticas funcionales pero subóptimas a nivel de arquitectura. Exigir la creación de un ADR o issue formal asegura que el compromiso quede registrado.
- **Asignación de Capacidad a Subagentes Refactorizadores:** Permite delegar sprints de pago de deuda técnica exclusivamente a subagentes de mantenimiento que toman issues de refactorización y los resuelven con tests en verde.
- **Control de Complejidad Ciclomática:** Establece límites que impiden que los agentes acumulen capas de condicionales anidados sin refactorizar.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Deuda Técnica Invisible e Indocumentada)

```python
# Antipatrón: Comentario TODO abandonado sin issue, sin contexto ni plan de remediación
# Este comentario permanecerá en el código durante 4 años sin que nadie lo resuelva:
def sincronizar_inventario_antipatron(items: list):
    # TODO: arreglar esto después cuando tengamos base de datos real (hardcodeado por ahora)
    # FIXME: no maneja concurrencia ni reintentos
    for item in items:
        hacer_algo_fragil(item)
```

### ✅ Código Correcto (Conforme a Gestión de Deuda: Registro Formal ADR)

Archivo de Decisión Arquitectónica (`docs/adr/004-cache-en-memoria-temporal.md`):
```markdown
# ADR 004: Adopción Temporal de Caché en Memoria para Catálogo de Productos

## Estado
Aceptado (Deuda Técnica Planificada)

## Contexto
El lanzamiento de la campaña de ventas de verano exige soportar 5,000 req/s este viernes.
El clúster de Redis no estará aprovisionado por infraestructura hasta el 15 de septiembre.

## Decisión
Se implementa una caché local en memoria usando `cachetools.TTLCache(maxsize=10000, ttl=60)`
en el servicio de productos como solución temporal.

## Consecuencias e Intereses
- **Positivo:** Se cumple la fecha límite de la campaña con latencias inferiores a 5ms.
- **Deuda Asumida:** No soporta invalidación distribuida entre múltiples réplicas de contenedores.
- **Plan de Pago:** Issue #512 programado para migrar a Redis en el sprint 38 (Fecha límite: 25-Sept-2026).
```

Código con referencia al ADR (`src/catalog/cache.py`):
```python
# src/catalog/cache.py
from cachetools import TTLCache

# DEUDA TÉCNICA REGISTRADA: Ver ADR-004 (docs/adr/004-cache-en-memoria-temporal.md)
# Remedición planificada en Issue #512 para migración a Redis.
CATALOG_CACHE: TTLCache = TTLCache(maxsize=10_000, ttl=60)

def obtener_producto_con_cache_temporal(producto_id: str, fetcher_callable) -> dict:
    if producto_id in CATALOG_CACHE:
        return CATALOG_CACHE[producto_id]

    data = fetcher_callable(producto_id)
    CATALOG_CACHE[producto_id] = data
    return data
```

## 5. Descripción Didáctica de los Cambios

1. **Documentación Formal con ADR:** Se especifica el *contexto de negocio*, la *decisión técnica*, las *consecuencias* y la *fecha límite de pago*.
2. **Referencia Explícita en Código:** El archivo `src/catalog/cache.py` referencia el ADR-004 y el issue `#512`, evitando comentarios `TODO` huérfanos.
3. **Planificación en Backlog:** La deuda no es una sorpresa técnica, sino una tarea programada con asignación de recursos garantizada.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Dogmatismo de "Cero Deuda Técnica" (*Gold Plating*):** Exigir una arquitectura perfecta e inmaculada antes de lanzar cualquier funcionalidad puede llevar a la quiebra comercial por falta de velocidad de mercado.
- **Deuda No Asumida Formalmente:** Atajos que comprometen la seguridad, la integridad de los datos financieros o la privacidad de los usuarios **nunca son deuda técnica aceptable**; son negligencias inaceptables.
- **Sobrecarga de ADRs para Decisiones Triviales:** Redactar un ADR para elegir el nombre de una variable o instalar una librería menor agrega burocracia innecesaria.

## 7. Checklist de Verificación

- [ ] ¿Los compromisos y atajos técnicos temporales están documentados en un ADR o issue del backlog?
- [ ] ¿Se reserva un porcentaje fijo de capacidad (ej. 15-20%) en cada ciclo para el pago de deuda técnica?
- [ ] ¿Se eliminaron comentarios `TODO` o `FIXME` huérfanos sin ticket de seguimiento asociado?
- [ ] ¿Las métricas de cobertura de tests y complejidad ciclomática se monitorean para evitar la degradación estructural?