---
id: tmpl_bzm81dfgjda0q4vb6exmxxtz72
name: adr_index_template
title: "Índice de Registros de Decisiones de Arquitectura (ADRs)"
file_path: modules/adr/adr_index_template.md
version: 2.0.0
category: templates
tags: [adr, index, architecture-decisions, history, governance]
description: "Índice cronológico y catálogo estructurado de Decisiones de Arquitectura del repositorio."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Catálogo e Índice de Decisiones de Arquitectura (ADRs)

Este documento registra el historial cronológico y el estado actual de todas las decisiones arquitectónicas tomadas en el proyecto.

---

## 1. Matriz de Decisiones Registradas

| Número | Fecha | Título de la Decisión | Estado | Módulo Principal |
|:---:|:---:|:---|:---:|:---|
| **[ADR-001](file:///docs/adr/0001_seleccion_arquitectura.md)** | `2026-08-29` | Adopción de Arquitectura Modular y Desacoplada | `Aceptado` | Core / Arquitectura |
| **[ADR-002](file:///docs/adr/0002_estrategia_persistencia.md)** | `2026-08-29` | Estrategia de Persistencia y Aislamiento de Puertos | `Aceptado` | Adaptadores / DB |

---

## 2. Convenciones para Nuevos Registros

1. Numeración correlativa con cuatro dígitos (`0001_nombre_descriptivo.md`).
2. Utilizar siempre la plantilla base [`adr_template.md`](file:///modules/adr/adr_template.md).
3. Registrar de inmediato la nueva entrada en esta tabla tras la aprobación del cambio.
