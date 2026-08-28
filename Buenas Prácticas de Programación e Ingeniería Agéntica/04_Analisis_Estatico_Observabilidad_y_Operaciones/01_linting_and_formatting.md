---
id: bp_0w7av0wps1bgj94ypvkd9yz6kj
name: 01_linting_and_formatting
title: "Linting y Formateo Automático de Código"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/01_linting_and_formatting.md
version: 1.1.0
category: code_standards
tags: [linting, formatting, ruff, black, code-quality, ast, universal_principles]
description: "Linting y Formateo: estandarización automática de código y prevención de fallas estáticas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 01 - Linting y Formateo Automático de Código

## 1. Definición y Fundamento Teórico

Originado con la creación de la herramienta `lint` por **Stephen C. Johnson** en Bell Labs (1978) y evolucionado mediante formateadores canónicos basados en AST como **Ruff**, **Black** y **Prettier**, el principio de **Linting y Formateo Automático** establece:

> *"El estilo, la estructura sintáctica y la higiene visual del código deben verificarse y corregirse de forma 100% automatizada y determinista, eliminando el error humano y suprimiendo debates cosméticos en las revisiones de código."*

Se compone de dos herramientas complementarias:
- **Linter:** Analiza el código sin ejecutarlo para detectar construcciones sospechosas, variables no utilizadas, importaciones desordenadas, violaciones de estándares idiomáticos y malas prácticas.
- **Formateador Canónico:** Reorganiza visualmente el código (longitud de línea, comillas, espaciado, saltos de línea) aplicando una representación canónica unificada.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Debates de Estilo (*Bikeshedding*):** Los ingenieros y revisores se concentran exclusivamente en la lógica de negocio y arquitectura.
- **Diffs Mínimos y Limpios en Git:** El formateo canónico asegura que los cambios en Git reflejen únicamente modificaciones reales de lógica, evitando conflictos por reordenamiento de espacios.
- **Detección Preventiva de Errores Comunes:** Identifica variables no declaradas, sombras de nombres (*variable shadowing*) y mutabilidad en argumentos por defecto antes de la ejecución.

## 3. Relevancia en Sistemas con IA Agéntica

- **Estandarización de la Salida de LLMs:** Los modelos de lenguaje varían sutilmente en estilo, formato y espaciado. Aplicar un formateador automático estandariza la salida del agente antes de integrarla al repositorio.
- **Ahorro de Tokens en Contexto y Revisión:** Diffs limpios y consistentes reducen el consumo de tokens en las llamadas a herramientas y facilitan la revisión automática por subagentes auditores.
- **Corrección Autónoma Rápida:** Linters modernos como `ruff` permiten al agente ejecutar `ruff check --fix` para subsanar automáticamente el 90% de las anomalías sintácticas en milisegundos.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Desorden Sintáctico, Imports sin Uso y Mutabilidad en Default)

```python
# Antipatrón: Imports desordenados, variables no utilizadas y mutable default argument
import os, sys
from datetime import * # ERROR: Wildcard import
import json

def registrar_evento(evento, tags = []): # ERROR: Mutable default argument peligroso
    unused_var = 123                     # ERROR: Variable muerta
    tags.append(evento)
    print ( "Evento registrado:" ,evento ) # Espaciado errático y comillas inconsistentes
    return tags
```

### ✅ Código Correcto (Conforme a Linting y Formateo: Ruff / Pyproject Estructurado)

Configuración en `pyproject.toml`:
```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",   # Errores de estilo (pycodestyle)
    "F",   # Errores lógicos (pyflakes)
    "I",   # Orden de importaciones (isort)
    "B",   # Detección de bugs comunes (flake8-bugbear)
    "UP",  # Modernización de sintaxis (pyupgrade)
]
```

Código formateado e higienizado (`src/events/logger.py`):
```python
# src/events/logger.py
from datetime import datetime, timezone

def registrar_evento(evento: str, tags: list[str] | None = None) -> list[str]:
    """Registra un evento agregando la lista de etiquetas de forma segura."""
    lista_tags = tags if tags is not None else []
    lista_tags.append(evento)
    
    timestamp = datetime.now(timezone.utc).isoformat()
    print(f"[{timestamp}] Evento registrado: {evento}")
    return lista_tags
```

## 5. Descripción Didáctica de los Cambios

1. **Eliminación de Mutable Default Argument:** Se sustituyó `tags = []` por `tags: list[str] | None = None`, erradicando el bug clásico de persistencia no deseada entre llamadas.
2. **Higiene de Importaciones:** Se suprimieron imports no utilizados (`os`, `sys`, `json`) y se reemplazó el comodín `import *` por una importación puntual.
3. **Formateo Determinista:** Espaciado y comillas normalizados automáticamente según el estándar PEP 8 / Ruff.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Reglas Excesivamente Pedantes:** Habilitar cientos de reglas de linter sin discernimiento (como forzar docstrings en funciones privadas triviales) genera fatiga de desarrollo sin aportar valor real.
- **Conflictos Masivos en Adopción Inicial:** Aplicar un formateador a un proyecto heredado gigante de 500,000 líneas en un solo commit puede ensuciar el `git blame` histórico; debe realizarse configurando `.git-blame-ignore-revs`.
- **Linter no Reemplaza al Sistema de Tipos:** Los linters comprueban sintaxis y convenciones, pero no sustituyen el análisis profundo de contratos de tipos (tarea de Mypy).

## 7. Checklist de Verificación

- [ ] ¿Existe un archivo de configuración centralizado (`pyproject.toml` / `.ruff.toml`) con las reglas de linting del proyecto?
- [ ] ¿El formateo y linting se ejecutan automáticamente en los hooks de pre-commit y en el CI?
- [ ] ¿Se eliminaron imports comodín (`from module import *`) y variables no utilizadas?
- [ ] ¿El agente de IA ejecuta `ruff check --fix` y `ruff format` tras generar o editar código?