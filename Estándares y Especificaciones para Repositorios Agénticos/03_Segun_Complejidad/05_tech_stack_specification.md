---
id: spec_2ykkdjfbvaakjvj0nhd90p3qct
name: 05_tech_stack_specification
title: "Especificación y Plantilla Maestra de TECH_STACK.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/05_tech_stack_specification.md
version: 1.0.0
category: templates
tags: [tech-stack, dependencies, frameworks, tools, versions, environment]
description: "Especificación y plantilla de TECH_STACK.md (tabla de lenguajes, frameworks y versiones)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 05 - Especificación y Plantilla Maestra de TECH_STACK.md

## 1. Definición y Propósito del Archivo

### ¿Qué es TECH_STACK.md?

TECH_STACK.md (o DEPENDENCIES.md) consolida en una sola tabla de referencia rápida todos los lenguajes, runtimes, frameworks, bases de datos, librerías centrales y herramientas de infraestructura que componen el proyecto.

### ¿Por qué existe y qué problemas resuelve?

- **Visión Tecnológica Centralizada:** Evita tener que inspeccionar múltiples archivos dispersos (pyproject.toml, package.json, Dockerfile, docker-compose.yml).

- **Ahorro de Contexto para Agentes de IA:** Permite al agente conocer las versiones exactas y stacks soportados en una sola lectura breve.

## 2. Plantilla Maestra Canónica de TECH_STACK.md

# Pila Tecnológica y Dependencias (TECH_STACK.md)

---

## Tecnologías Principales y Versiones

| Categoría | Tecnología / Framework | Versión Soportada | Propósito en el Repositorio |
|:---|:---|:---:|:---|
| **Lenguaje Base** | Python | `3.11+ / 3.12` | Runtime principal del sistema. |
| **Validación de Datos** | Pydantic v2 | `>= 2.7.0` | Esquemas fuertemente tipados y parseo. |
| **Testing & Cobertura** | Pytest / Pytest-cov | `>= 8.0.0` | Suite de pruebas unitarias y reportes. |
| **Linters & Formato** | Ruff / Black / Mypy | `Latest` | Análisis estático y verificación de tipos. |
| **Base de Datos** | PostgreSQL / SQLite | `16 / 3.45` | Persistencia relacional y tests locales. |
| **Diagramación** | Mermaid.js | `v10+` | Renderizado de topología y secuencias. |