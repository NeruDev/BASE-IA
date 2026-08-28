---
id: spec_7dm6vwvtrdayh8d2wpbcns36w4
name: 01_readme_specification
title: "Especificación y Plantilla Maestra de README.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/01_Archivos_Imprescindibles/01_readme_specification.md
version: 1.0.0
category: templates
tags: [readme, template, specification, documentation, onboarding]
description: "Especificación y plantilla de README.md (visión, quickstart reproducible y badges)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 01 - Especificación y Plantilla Maestra de README.md

Este documento define la estructura obligatoria, directrices de redacción y la plantilla canónica para el archivo README.md en repositorios agénticos.

## 1. Propósito y Audiencia Dual

El README.md es el punto de entrada primario del repositorio y debe ser comprensible y procesable simultáneamente por:

1.  **Desarrolladores Humanos:** Para comprender la visión, evaluar dependencias e iniciar el desarrollo en minutos.

2.  **Agentes de IA y LLMs:** Para extraer de forma determinista comandos de setup, arquitectura general, variables de entorno y reglas de ejecución sin requerir inferencias ambiguas.

## 2. Secciones Obligatorias y Especificación Técnica

| **N.º** | **Sección** | **Obligatoria** | **Propósito para Humanos** | **Propósito para Agentes de IA** |
|:---|:---|:--:|:---|:---|
| 1 | **Header & Badges** | Sí | Estado del build, versión, licencia. | Metadatos rápidos de compatibilidad y versión. |
| 2 | **Visión y Resumen Ejecutivo** | Sí | Comprender el problema y la solución. | Establecer el contexto semántico global del repositorio. |
| 3 | **Tabla de Contenidos** | Sí | Navegación rápida por hipervínculos. | Indexación de secciones para lectura selectiva. |
| 4 | **Características Clave** | Sí | Capacidades funcionales del sistema. | Mapeo de capacidades a casos de uso y herramientas. |
| 5 | **Requisitos y Compatibilidad** | Sí | Requisitos del sistema operativo y runtime. | Validación de entorno de ejecución previo a comandos. |
| 6 | **Inicio Rápido (Quickstart)** | Sí | Comandos reproducibles paso a paso. | Secuencia determinista de comandos de instalación/test. |
| 7 | **Estructura del Proyecto** | Sí | Mapa visual del código fuente y docs. | Resolución de rutas relativas y jerarquía modular. |
| 8 | **Configuración (.env)** | Sí | Lista de variables requeridas y secretas. | Identificación de credenciales requeridas. |
| 9 | **Uso y Ejemplos de Ejecución** | Sí | Ejemplos de código y CLI. | Generación de comandos y tests funcionales. |
| 10 | **Arquitectura y Enlaces** | Sí | Enlace a ARCHITECTURE.md y AGENTS.md. | Navegación hacia especificaciones profundas. |
| 11 | **Contribución y Calidad** | Sí | Guía de pull requests, tests y linters. | Normas de estilo para código generado. |
| 12 | **Licencia y Créditos** | Sí | Términos legales de uso. | Verificación de restricciones de licenciamiento. |

## 3. Plantilla Maestra Canónica de README.md

A continuación se presenta la plantilla oficial lista para ser instanciada en la raíz del repositorio:

# [Nombre del Proyecto]

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/usuario/repo/actions)

[![Python Version](https://img.shields.io/badge/python-3.11%20%7C%203.12-blue.svg)](https://www.python.org/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Code Style: Black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

[![Agent Ready](https://img.shields.io/badge/agent--ready-v1.0-purple.svg)](AGENTS.md)

> **[Lema o resumen de una sola frase que describe el propósito central del proyecto].**

---

## Tabla de Contenidos

- [Visión General](#visión-general)

- [Características Principales](#características-principales)

- [Requisitos del Sistema](#requisitos-del-sistema)

- [Inicio Rápido](#inicio-rápido)

- [1. Clonar el repositorio](#1-clonar-el-repositorio)

- [2. Configurar el entorno virtual](#2-configurar-el-entorno-virtual)

- [3. Instalar dependencias](#3-instalar-dependencias)

- [4. Variables de entorno](#4-variables-de-entorno)

- [Estructura del Repositorio](#estructura-del-repositorio)

- [Uso y Ejemplos](#uso-y-ejemplos)

- [Ejecución por Línea de Comandos (CLI)](#ejecución-por-línea-de-comandos-cli)

- [Integración en Código Python](#integración-en-código-python)

- [Arquitectura y Agentes](#arquitectura-y-agentes)

- [Pruebas y Calidad de Código](#pruebas-y-calidad-de-código)

- [Contribución](#contribución)

- [Licencia](#licencia)

---

## Visión General

[Descripción técnica de 2 a 3 párrafos explicando el problema que aborda el proyecto, la solución propuesta y los diferenciadores arquitectónicos].

---

## Características Principales

- ⚡ **Alto Rendimiento:** [Descripción de la capacidad técnica].

- 🤖 **Diseño Orientado a Agentes:** Contratos de operación explícitos definidos en [AGENTS.md](AGENTS.md).

- 📐 **Arquitectura Modular:** Separación clara entre capas de dominio, aplicación e infraestructura.

- 🛡️ **Validación Estricta:** Tipado estricto con Python `typing` y validación con Pydantic v2.

- 📊 **Trazabilidad Completa:** Logs estructurados y soporte nativo para métricas.

---

## Requisitos del Sistema

- **Runtime:** Python `>= 3.11` (recomendado `3.11.x` o `3.12.x`).

- **Gestor de Paquetes:** `uv`, `poetry` o `pip`.

- **Sistema Operativo:** Linux (Ubuntu 22.04+), macOS (Apple Silicon / Intel), Windows con WSL2.

---

## Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/nombre-repositorio.git
cd nombre-repositorio
```

### 2. Configurar el entorno virtual

```bash
python3 -m venv .venv
source .venv/bin/activate # En Windows: .venv\Scripts\activate
```

### 3. Instalar dependencias

```bash
pip install --upgrade pip
pip install -e ".[dev]"
```

### 4. Variables de entorno

Copiar el archivo de plantilla y configurar las credenciales correspondientes:

```bash
cp .env.example .env
```

## Estructura del Repositorio

```yaml
estructura_repositorio:
  README.md: "Documento principal del repositorio"
  ARCHITECTURE.md: "Topología técnica y flujos Mermaid"
  AGENTS.md: "Contrato operativo y guardrails de IA"
  CONTRIBUTING.md: "Guía de contribución"
  LICENSE: "Licencia MIT"
  .env.example: "Variables de entorno requeridas"
  pyproject.toml: "Metadatos del proyecto y dependencias"
  src:
    paquete_principal:
      __init__.py: "Inicializador del paquete"
      core: "Entidades de dominio y lógica pura"
      services: "Casos de uso y orquestación"
      adapters: "Conectores externos y APIs"
  tests: "Suite de pruebas unitarias y e2e"
```

## Uso y Ejemplos

### Ejecución por Línea de Comandos (CLI)

```bash
# Ejecutar pipeline principal
python -m paquete_principal.cli --input data/ejemplo.json --output results/
```

### Integración en Código Python

```python
from paquete_principal.core import MotorPrincipal

# Inicializar motor con configuración predeterminada
motor = MotorPrincipal()
resultado = motor.procesar({"clave": "valor"})
print(resultado)
```

## Arquitectura y Agentes

Para obtener detalles profundos sobre el diseño del sistema y los contratos de ejecución autónoma:

- 🏛️ Consulta la [Especificación de Arquitectura](ARCHITECTURE.md).
- 🤖 Consulta el [Contrato Operativo de Agentes](AGENTS.md).
- 📋 Consulta los [Estándares de Docstrings y Tipado](docs/03_docstrings_and_code_standards.md).

## Pruebas y Calidad de Código

Ejecutar la suite de pruebas unitarias y linters automáticos:

```bash
# Ejecutar pruebas con pytest y cobertura
pytest --cov=src tests/

# Formateo y linting estricto
ruff check src tests/
black --check src tests/
mypy src/
```

## Contribución

Por favor, revisa las directrices de contribución en [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar un Pull Request. Todos los cambios deben incluir tests unitarios asociados y respetar los estándares de docstrings.

## Licencia

Distribuido bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más información.

---

## 4. Checklist de Validación para Agentes Generadores

Antes de finalizar la creación o actualización de un `README.md`, el agente debe verificar:

- [ ] No contiene placeholders sin resolver (ej. `[TODO]`, `[INSERT HERE]`).

- [ ] Todos los enlaces relativos apuntan a archivos existentes en el repositorio.

- [ ] Los comandos bash son sintácticamente válidos y reproducibles.

- [ ] La versión de Python y dependencias coinciden con `pyproject.toml`.

- [ ] El árbol de directorios refleja con precisión la estructura real.