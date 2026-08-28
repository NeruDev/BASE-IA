---
id: bp_5mt4yrhtt1bgbah12ts1jg7qf0
name: 04_agent_readable_code
title: "Código Diseñado para Inspección Agéntica (Agent-Readable Code)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/04_agent_readable_code.md
version: 1.1.0
category: agentic
tags: [agent-readable-code, explicit-code, low-complexity, readability, no-magic, universal_principles]
description: "Agent-Readable Code: código estructurado para mínima inferencia inductiva, linealidad y máxima comprensibilidad."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 04 - Código Diseñado para Inspección Agéntica (Agent-Readable Code)

## 1. Definición y Fundamento Teórico

Basada en los principios clásicos de **Legibilidad de Software (*Clean Code*)** y en la **Minimización de la Inferencia Inductiva** en modelos de atención (*Transformers*), la práctica de **Agent-Readable Code** postula:

> *"El código fuente debe estructurarse de manera explícita, lineal, modular y fuertemente tipada, manteniendo funciones de tamaño acotado (<30 líneas) y flujos de datos transparentes, erradicando la 'magia oculta' (metaprogramación dinámica, inyección de variables globales y decoradores que mutan firmas) para que cualquier LLM o revisor humano comprenda el comportamiento exacto de una función en una sola lectura sin ambigüedad."*

El código legible para IA favorece lo **Explícito sobre lo Implícito** y la **Composición sobre la Magia**.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reducción de Alucinaciones en Refactorizaciones:** Los agentes cometen errores graves cuando intentan modificar código que depende de variables mágicas inyectadas en runtime por metaprogramación.
- **Minimización de Saltos de Atención:** Permite al LLM inferir el comportamiento de una función leyendo solo ese bloque sin tener que buscar definiciones en 5 archivos indirectos.
- **Baja Complejidad Ciclomática:** Funciones lineales con pocas ramificaciones condicionales son más fáciles de probar y comprender.

## 3. Relevancia en Sistemas con IA Agéntica

- **Comprensión al Primer Turno:** El agente comprende la función en una sola llamada a `view_file` de 25 líneas, ahorrando tokens y reduciendo la latencia.
- **Facilidad de Generación de Tests:** Las funciones puras y lineales con dependencias explícitas se prueban con pruebas unitarias deterministas en segundos.
- **Mantenibilidad Híbrida Humano-IA:** Hace que el código sea transparente y fácil de auditar para los desarrolladores senior.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Metaprogramación Mágica y Estado Oculto)

```python
# Antipatrón: Magia dinámica indocumentada; indescifrable para agentes de IA y humanos
class MagicEntityAntipatron:
    def __init__(self, **kwargs):
        # ERROR: Metaprogramación dinámica con setattr; Mypy y el agente no saben qué atributos existen
        for k, v in kwargs.items():
            setattr(self, f"_dyn_{k}", v)

    def __getattr__(self, name):
        # ERROR: Búsqueda dinámica oculta que enmascara errores de tipado
        return self.__dict__.get(f"_dyn_{name}", None)
```

### ✅ Código Correcto (Conforme a Agent-Readable Code: Explícito, Lineal y Tipado)

```python
# src/domain/user_profile.py
from dataclasses import dataclass
from decimal import Decimal

@dataclass(frozen=True)
class UserProfile:
    """Entidad explícita, inmutable y directamente legible por agentes y Mypy."""
    user_id: str
    username: str
    credit_limit: Decimal

def calcular_limite_ajustado(
    profile: UserProfile,
    factor_ajuste: Decimal
) -> Decimal:
    """Calcula el nuevo límite crediticio de forma pura, lineal y determinista.

    Args:
        profile: Perfil del usuario con límite de crédito base.
        factor_ajuste: Factor multiplicador positivo.

    Returns:
        Decimal con el nuevo límite calculado con redondeo exacto.

    Raises:
        ValueError: Si el factor de ajuste es menor o igual a cero.
    """
    if factor_ajuste <= Decimal("0.00"):
        raise ValueError(f"El factor de ajuste debe ser positivo: {factor_ajuste}")

    limite_calculado = profile.credit_limit * factor_ajuste
    return limite_calculado.quantize(Decimal("0.01"))
```

## 5. Descripción Didáctica de los Cambios

1. **Atributos Explícitos:** `UserProfile` declara con claridad sus 3 atributos y sus tipos exactos.
2. **Flujo de Datos Lineal y Puro:** `calcular_limite_ajustado` recibe entradas, valida defensivamente y retorna el resultado sin efectos secundarios ocultos.
3. **Docstring Estructurado:** Describe parámetros, retorno y excepciones para que el LLM comprenda el contrato sin esfuerzo.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Frameworks con Decoradores Establecidos:** Usar `@app.get()` en FastAPI o `@pytest.fixture` en Pytest es estándar y bien comprendido por los LLMs; lo que se prohíbe es **crear frameworks caseros de metaprogramación indocumentada**.

## 7. Checklist de Verificación

- [ ] ¿Las funciones de negocio tienen menos de 30 líneas de código y baja complejidad ciclomática?
- [ ] ¿Todas las dependencias y parámetros se reciben explícitamente sin magia de `**kwargs` o `setattr`?
- [ ] ¿Las estructuras de datos son inmutables y declaran explícitamente todos sus atributos y tipos?
- [ ] ¿El flujo de ejecución es lineal y predecible sin efectos secundarios ocultos?