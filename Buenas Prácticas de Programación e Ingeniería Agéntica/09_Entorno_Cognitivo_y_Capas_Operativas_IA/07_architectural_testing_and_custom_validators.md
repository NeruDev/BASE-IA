---
id: bp_5s2dqq3zveanssn8d4cej76jav
name: 07_architectural_testing_and_custom_validators
title: "Tests Arquitectónicos y Validadores a Medida"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/07_architectural_testing_and_custom_validators.md
version: 1.1.0
category: agentic
tags: [architectural-testing, pytest-archon, ast-validators, clean-architecture, dependency-rules, universal_principles]
description: "Tests Arquitectónicos: validación automatizada de capas de importación con pytest-archon y analizadores AST."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 07 - Tests Arquitectónicos y Validadores a Medida

## 1. Definición y Fundamento Teórico

Basada en el paradigma de **Pruebas de Arquitectura de Software (*ArchUnit / pytest-archon*)** y en el análisis estático de dependencias mediante el **Árbol de Sintaxis Abstracta (AST)**, esta práctica postula:

> *"Las reglas de diseño, separación de capas y restricciones de dependencia del sistema (ej. Arquitectura Limpia / Hexagonal) deben formalizarse como pruebas automatizadas ejecutables en la suite de Pytest, garantizando que ningún cambio generado por humanos o agentes de IA viole los límites arquitectónicos ni introduzca acoplamientos prohibidos."*

A diferencia de los linters cosméticos, los tests arquitectónicos auditan el **grafo de dependencias de módulos**:
- El núcleo de Dominio (`src/domain/`) **NUNCA** debe importar de Infraestructura (`src/infrastructure/`).
- Los Controladores de API (`src/api/`) **NUNCA** deben consultar directamente la base de datos sin pasar por los Casos de Uso.
- No deben existir **dependencias cíclicas** entre subsistemas.

```text
 ┌──────────────────────┐         (Import Prohibido por Arch Test)
 │  src/domain/         │ ◄───────────────────────────────┐
 └──────────┬───────────┘                                 │
            ▲                                             │
            │ (Permitido)                        [ 🛑 VIOLACIÓN ]
            │                                             │
 ┌──────────┴───────────┐                                 │
 │  src/infrastructure/ │ ────────────────────────────────┘
 └──────────────────────┘
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de la Erosión Arquitectónica:** Evita que con el paso del tiempo la arquitectura limpia se degrade en un "Gran Lodo de Dependencias" (*Big Ball of Mud*).
- **Control de Calidad para Código de IA:** Los LLMs tienden a importar libremente librerías de infraestructura en el dominio para "ahorrar líneas de código".
- **Verificación Determinista en CI:** Transforma las guías de arquitectura abstractas en aserciones ejecutables de código.

## 3. Relevancia en Sistemas con IA Agéntica

- **Guardrail Arquitectónico Indestructible:** Si el agente intenta acoplar una entidad de dominio a SQLAlchemy o Redis, el test arquitectónico falla con un mensaje preciso.
- **Educación Dinámica del Modelo:** La salida de error (`"Domain layer must not import infrastructure"`) indica al agente exactamente cómo desacoplar la lógica usando `typing.Protocol` o Inyección de Dependencias.
- **Auditoría Continua sin Burocracia:** Permite a los arquitectos descansar sabiendo que las fronteras del sistema están custodiadas por código.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: El Agente Importa Infraestructura en el Dominio)

```python
# Archivo: src/domain/account.py (Debería ser lógica pura de negocio)
# ANTIPATRÓN: El agente importa directamente el cliente de base de datos e infraestructura:
from src.infrastructure.database import ejecutar_query_sql # ACOPLAMIENTO PROHIBIDO

class CuentaUsuario:
    def debitar(self, monto: float):
        # ERROR ARQUITECTÓNICO: Lógica de persistencia física mezclada en la entidad de dominio
        ejecutar_query_sql(f"UPDATE cuentas SET balance = balance - {monto}")
```

### ✅ Test Arquitectónico Automatizado (`tests/arch/test_architecture.py`)

```python
# tests/arch/test_architecture.py
import pytest
from pytest_archon import archrule

def test_domain_layer_isolation():
    """Garantiza que la capa de dominio sea 100% pura y no dependa de infraestructura."""
    (
        archrule("DomainIsolation")
        .match("src.domain.*")
        .should_not_import("src.infrastructure.*")
        .should_not_import("src.api.*")
        .should_not_import("sqlalchemy.*")
        .should_not_import("redis.*")
    ).check()

def test_no_cyclic_dependencies():
    """Garantiza que no existan ciclos de importación entre paquetes."""
    archrule("NoCyclicDependencies").match("src.*").should_not_import_cyclic().check()
```

Salida de error didáctica cuando el agente comete una violación:
```text
FAILED tests/arch/test_architecture.py::test_domain_layer_isolation
Rule 'DomainIsolation' violated:
  Module 'src.domain.account' imports 'src.infrastructure.database'
  -> Domain layer must remain pure and free from infrastructure dependencies.
```

## 5. Descripción Didáctica de los Cambios

1. **Aserción de Aislamiento:** `pytest-archon` analiza las importaciones del AST y prohíbe explícitamente que `src.domain.*` importe de `src.infrastructure.*`.
2. **Detección de Ciclos:** `should_not_import_cyclic()` previene dependencias circulares que rompen la modularidad.
3. **Mensaje Accionable:** La salida del test guía al agente a desacoplar el acceso a datos mediante una interfaz `Protocol`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sistemas Legacy con Alto Acoplamiento Previo:** En proyectos antiguos con miles de violaciones históricas, activar reglas globales puede bloquear todo el desarrollo; se deben configurar reglas con excepciones acotadas (*allow-lists*) y sanearlas de forma progresiva.

## 7. Checklist de Verificación

- [ ] ¿Existen tests arquitectónicos automatizados en la carpeta `tests/arch/`?
- [ ] ¿Se verifica que el núcleo de dominio no importe módulos de infraestructura ni frameworks web?
- [ ] ¿Se audita la ausencia de importaciones cíclicas en todo el proyecto?
- [ ] ¿Los tests arquitectónicos se ejecutan en cada corrida de `python scripts/validate.py`?