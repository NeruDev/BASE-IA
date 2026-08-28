---
id: spec_7jpm9w8sera5wassd8dckd14v4
name: 01_development_specification
title: "Especificación y Plantilla Maestra de DEVELOPMENT.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/01_development_specification.md
version: 1.0.0
category: templates
tags: [development, setup, environment, debugging, workflow]
description: "Especificación y plantilla de DEVELOPMENT.md (procedimientos técnicos locales y debug)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 01 - Especificación y Plantilla Maestra de DEVELOPMENT.md

## 1. Definición y Propósito del Archivo

### ¿Qué es DEVELOPMENT.md?

DEVELOPMENT.md es la guía técnica de operaciones locales para desarrolladores e ingenieros de software. Describe paso a paso cómo preparar el entorno de desarrollo, levantar servicios auxiliares, depurar y ejecutar scripts internos.

### ¿Por qué existe y qué problemas resuelve?

- **Aislamiento Operativo:** Separa los comandos detallados de desarrollo local del README.md (que debe mantenerse conciso y orientado al usuario).

- **Para Agentes de IA:** Provee la lista exacta de comandos de inicialización, endpoints locales de prueba y pasos de debugging para ejecutar diagnósticos autónomos.

## 2. Plantilla Maestra Canónica de DEVELOPMENT.md

# Guía de Desarrollo Local (DEVELOPMENT.md)

Este documento detalla los procedimientos para configurar, ejecutar y depurar el proyecto en entornos locales.

---

## 1. Preparación del Entorno

### Requisitos Previos

- Python 3.11+

- Git 2.40+

- Docker & Docker Compose (opcional para servicios)

### Inicialización Paso a Paso

```bash
# 1. Crear y activar entorno virtual
python3 -m venv .venv
source .venv/bin/activate

# 2. Instalar dependencias en modo editable con herramientas de desarrollo
pip install --upgrade pip
pip install -e ".[dev,test]"

# 3. Configurar pre-commit hooks
pre-commit install
```

## 2. Variables de Entorno Locales

Crear el archivo `.env` a partir de `.env.example`:

```bash
cp .env.example .env
```

| **Variable** | **Descripción** | **Valor por Defecto Local** |
|:---|:---|:---|
| LOG_LEVEL | Nivel de logging (DEBUG, INFO, WARNING) | DEBUG |
| ENV | Entorno de ejecución (development, test) | development |
| API_PORT | Puerto local del servidor | 8000 |

## 3. Ejecución y Depuración

```bash
# Ejecutar servidor de desarrollo con recarga en vivo
python -m src.paquete.main --reload

# Ejecutar script de prueba de agentes
python scripts/test_agent_pipeline.py --input data/sample.json
```