---
id: spec_03dx3sh98pavk8ye5cz4cgf33t
name: 08_faq_specification
title: "Especificación y Plantilla Maestra de FAQ.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/08_faq_specification.md
version: 1.0.0
category: templates
tags: [faq, questions, answers, troubleshooting, onboarding]
description: "Especificación y plantilla de FAQ.md (preguntas frecuentes técnicas y autoayuda)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 08 - Especificación y Plantilla Maestra de FAQ.md

## 1. Definición y Propósito del Archivo

### ¿Qué es FAQ.md?

FAQ.md agrupa las preguntas frecuentes de instalación, diseño conceptual y uso general, proporcionando respuestas directas y concisas.

### ¿Por qué existe y qué problemas resuelve?

- **Autoservicio Rápido:** Resuelve dudas recurrentes sin saturar los canales de soporte.

- **Para Agentes de IA:** Permite responder preguntas de usuarios consultando una base curada de respuestas verificadas.

## 2. Plantilla Maestra Canónica de FAQ.md

# Preguntas Frecuentes (FAQ.md)

---

## Preguntas Generales

### ¿Por qué se utiliza arquitectura hexagonal?

Para aislar completamente las reglas de negocio del dominio de las dependencias externas (bases de datos, APIs de LLMs), permitiendo pruebas unitarias deterministas en memoria.

### ¿Cómo añado una nueva herramienta para agentes?

1. Define el contrato tipado en `src/paquete/agents/tools/`.

2. Actualiza la matriz de permisos en [AGENTS.md](AGENTS.md).

3. Añade la prueba unitaria correspondiente en `tests/unit/`.