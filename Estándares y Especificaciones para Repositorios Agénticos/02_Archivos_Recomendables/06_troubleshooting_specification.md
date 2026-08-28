---
id: spec_0j1w6r6r1xb0zrg7kdmjrnyvxh
name: 06_troubleshooting_specification
title: "Especificación y Plantilla Maestra de TROUBLESHOOTING.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/06_troubleshooting_specification.md
version: 1.0.0
category: templates
tags: [troubleshooting, debugging, common-issues, error-resolution, diagnostics]
description: "Especificación y plantilla de TROUBLESHOOTING.md (matriz de síntomas, causas y soluciones)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 06 - Especificación y Plantilla Maestra de TROUBLESHOOTING.md

## 1. Definición y Propósito del Archivo

### ¿Qué es TROUBLESHOOTING.md?

TROUBLESHOOTING.md es la guía de diagnóstico y resolución rápida de problemas técnicos, estructurada en matrices de síntomas, causas probables, comandos de validación y soluciones paso a paso.

### ¿Por qué existe y qué problemas resuelve?

- **Reducción de Tiempo de Bloqueo:** Facilita a cualquier desarrollador solucionar fallos comunes de entorno o dependencias.

- **Herramienta de Diagnóstico para Agentes:** Permite a los agentes autónomos consultar tablas estructuradas de síntomas y aplicar soluciones deterministas antes de detenerse o alucinar causas erróneas.

## 2. Plantilla Maestra Canónica de TROUBLESHOOTING.md

# Guía de Solución de Problemas (TROUBLESHOOTING.md)

Consulta esta guía ante errores comunes de instalación, ejecución o comportamiento anómalo del sistema.

---

## Matriz de Diagnóstico y Resolución Rápida

| Síntoma Observado | Causa Probable | Comando de Verificación | Solución Paso a Paso |
|:---|:---|:---|:---|
| `ModuleNotFoundError: No module named 'src'` | Paquete no instalado en modo editable | `python -c "import src"` | Ejecutar `pip install -e .` en la raíz del repositorio. |
| `ValidationError: Field required` | Falta variable de entorno requerida | `cat .env` | Copiar `.env.example` y definir los valores faltantes. |
| `PermissionError: Unauthorized Tool` | Herramienta invocada sin nivel de permiso adecuado | Revisar `AGENTS.md` | Solicitar confirmación humana o ajustar `tool_access_level`. |
| `pytest: command not found` | Entorno virtual inactivo o pytest no instalado | `which pytest` | Activar `.venv` y ejecutar `pip install -e ".[dev]"`. |

---

## Scripts de Diagnóstico Automático

Para verificar el estado completo del sistema:

```bash
python scripts/doctor.py --verbose
```