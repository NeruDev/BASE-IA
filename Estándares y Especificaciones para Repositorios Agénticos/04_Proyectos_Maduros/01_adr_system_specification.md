---
id: spec_66rr2831zeb1f9gcgjacgf0p7t
name: 01_adr_system_specification
title: "Especificación y Plantilla Maestra de ADRs (Architecture Decision Records)"
file_path: Estándares y Especificaciones para Repositorios Agénticos/04_Proyectos_Maduros/01_adr_system_specification.md
version: 1.0.0
category: templates
tags: [adr, architecture-decision-records, governance, history, design-records]
description: "Especificación y plantilla de ADRs (docs/adr/ para decisiones de arquitectura)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 01 - Especificación y Plantilla Maestra de ADRs

## 1. Definición y Propósito del Archivo

### ¿Qué son los ADRs (docs/adr/)?

Los *Architecture Decision Records* son documentos inmutables que registran formalmente una decisión de diseño arquitectónico relevante, su justificación, el contexto histórico, las alternativas evaluadas y las consecuencias asumidas.

### ¿Por qué existe y qué problemas resuelve?

- **Memoria de Diseño:** Responde a la pregunta *"¿Por qué se construyó así?"* años después.

- **Para Agentes de IA:** Evita que los modelos sugieran refactorizaciones a tecnologías que ya fueron evaluadas y descartadas en el pasado.

## 2. Plantilla Maestra Canónica de un ADR

# ADR-0001: [Título Conciso de la Decisión]

- **Fecha:** YYYY-MM-DD

- **Estado:** [Propuesto | Aceptado | Reemplazado por ADR-XXXX | Obsoleto]

- **Decisores:** [Nombres de los arquitectos o equipo]

---

## Contexto y Declaración del Problema

[Descripción del problema técnico, requisitos y desafíos que motivan esta decisión].

---

## Decisión Adoptada

[Descripción clara de la solución elegida y justificación técnica].

---

## Alternativas Consideradas

1. **Alternativa A:** [Ventajas y por qué fue descartada].

2. **Alternativa B:** [Ventajas y por qué fue descartada].

---

## Consecuencias y Trade-offs

- **Positivas:** [Beneficios de rendimiento, modularidad o mantenibilidad].

- **Negativas / Costos:** [Complejidad adicional o dependencias asumidas].