---
id: spec_0mx4af2anya3jt5ge93vwpp34r
name: 06_operations_specification
title: "Especificación y Plantilla Maestra de OPERATIONS.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/06_operations_specification.md
version: 1.0.0
category: templates
tags: [operations, deployment, environments, production-guardrails, monitoring]
description: "Especificación y plantilla de OPERATIONS.md (gestión de entornos y límites en producción)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 06 - Especificación y Plantilla Maestra de OPERATIONS.md

## 1. Definición y Propósito del Archivo

### ¿Qué es OPERATIONS.md?

OPERATIONS.md define los procedimientos operativos estándar para despliegues, monitoreo de salud, rollbacks, gestión de entornos (dev, staging, prod) y políticas de mantenimiento de infraestructura.

### ¿Por qué existe y qué problemas resuelve?

- **Estabilidad Operativa:** Estandariza la puesta en producción y planes de contingencia.

- **Límites de Seguridad para Agentes:** **Declara explícitamente qué operaciones están estrictamente prohibidas para agentes de IA en entornos productivos.**

## 2. Plantilla Maestra Canónica de OPERATIONS.md

# Guía de Operaciones e Infraestructura (OPERATIONS.md)

---

## 1. Entornos del Sistema

| Entorno | Propósito | Nivel de Acceso para Agentes |
|:---|:---|:---:|
| `development` | Desarrollo y testing local | ✅ Acceso completo de ejecución |
| `staging` | Pruebas de integración pre-producción | ⚠️ Solo lectura y tests automatizados |
| `production` | Entorno de usuarios finales | ⛔ **PROHIBIDO ACCESO DIRECTO** |

---

## 2. ⛔ Límites Inviolables para Agentes de IA en Producción

Los agentes autónomos **NO DEBEN BAJO NINGUNA CIRCUNSTANCIA:**

1. Ejecutar despliegues automáticos a producción sin aprobación humana explícita.

2. Modificar secretos o variables de entorno productivas.

3. Ejecutar migraciones de base de datos destructivas (`DROP TABLE`, `TRUNCATE`).

4. Eliminar recursos de infraestructura cloud.