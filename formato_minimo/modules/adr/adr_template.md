---
id: tmpl_6z28q658012xcyvry46pg94fe2
name: adr_template
title: "Plantilla de Registro de Decisión de Arquitectura (ADR)"
file_path: modules/adr/adr_template.md
version: 2.0.0
category: templates
tags: [adr, architecture-decision-record, madr, rfc, decisions, governance]
description: "Plantilla estandarizada basada en MADR para registrar decisiones arquitectónicas y técnicas significativas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# ADR-[NUM]: [Título Breve y Descriptivo de la Decisión]

- **Fecha:** YYYY-MM-DD
- **Estado:** Propuesto | Aceptado | Rechazado | Deprecado | Superado por [ADR-XXX]
- **Autores / Decisores:** [Nombres o Roles]
- **Módulos Afectados:** [Módulo o Capa]

---

## 1. Contexto y Planteamiento del Problema

Describir la necesidad técnica, las fuerzas en conflicto y las restricciones que motivan esta decisión.

---

## 2. Decisión Tomada

Declarar de forma clara y explícita la alternativa seleccionada y cómo se implementará.

> **Decisión:** [Detalle técnico de la opción elegida].

---

## 3. Consecuencias y Trade-offs

### Consecuencias Positivas (Beneficios)
- Beneficio 1 (ej. mayor desacoplamiento, mejor rendimiento).
- Beneficio 2 (ej. facilidad de testing).

### Consecuencias Negativas (Costos y Desventajas)
- Costo 1 (ej. ligera complejidad adicional en el setup).
- Costo 2 (ej. curva de aprendizaje para nuevos desarrolladores).

---

## 4. Alternativas Descartadas

| Alternativa Evaluada | Razón Principal de Descarte |
|:---|:---|
| **Opción A** | No escalaba adecuadamente con el volumen esperado. |
| **Opción B** | Introducía un acoplamiento excesivo a una librería de terceros. |
