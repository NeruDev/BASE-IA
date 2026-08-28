---
id: spec_288ktgvx69avhr8n798yt888cn
name: 04_style_guide_specification
title: "Especificación y Plantilla Maestra de STYLE_GUIDE.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/04_style_guide_specification.md
version: 1.0.0
category: templates
tags: [style-guide, conventions, code-style, linting, imports, formatting]
description: "Especificación y plantilla de STYLE_GUIDE.md (convenciones de código y logging)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 04 - Especificación y Plantilla Maestra de STYLE_GUIDE.md

## 1. Definición y Propósito del Archivo

### ¿Qué es STYLE_GUIDE.md?

STYLE_GUIDE.md complementa a los formateadores automáticos (black/ruff) definiendo convenciones semánticas profundas: orden de imports, estructura de clases, políticas de logging y manejo defensivo de memoria.

### ¿Por qué existe y qué problemas resuelve?

- **Cohesión Estilística:** Mantiene el código uniforme a lo largo del tiempo.

- **Para Agentes de IA:** Evita el uso de anti-patrones como print() en producción, imports circulares o captura genérica silenciosa de excepciones (except: pass).

## 2. Plantilla Maestra Canónica de STYLE_GUIDE.md

# Guía de Estilo y Convenciones de Código (STYLE_GUIDE.md)

---

## 1. Convenciones de Nomenclatura

| Elemento | Convención | Ejemplo |
|:---|:---|:---|
| Módulos y Paquetes | `snake_case` | `data_loader.py` |
| Clases y Modelos Pydantic | `PascalCase` | `AgentExecutionPipeline` |
| Funciones y Métodos | `snake_case` | `validar_esquema_payload()` |
| Constantes Globales | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_ATTEMPTS` |
| Variables Privadas / Protegidas | `_snake_case` | `_instancia_singleton` |

---

## 2. Orden y Agrupación de Imports

```python
# 1. Librería estándar de Python
import os
import sys
from typing import Any

# 2. Dependencias externas de terceros
from pydantic import BaseModel, Field
import pytest

# 3. Módulos internos del proyecto
from src.paquete.core import EntidadBase
```

## 3. Políticas de Logging y Salida

- ⛔ **PROHIBIDO:** Usar `print()` en código de producción.
- ✅ **OBLIGATORIO:** Usar el logger estructurado del sistema:

```python
import logging

logger = logging.getLogger(__name__)
logger.info("Pipeline completado exitosamente", extra={"task_id": task_id})
```