---
id: spec_01m1339xhmfw9tkx7j2x9bzkh9
name: 07_debugging_specification
title: "Especificación y Plantilla Maestra de DEBUGGING.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/07_debugging_specification.md
version: 1.0.0
category: templates
tags: [debugging, debug-protocol, troubleshooting, vscode-launch, pdb, interactive-debug]
description: "Especificación y plantilla maestra para el archivo DEBUGGING.md, estableciendo protocolos de depuración interactiva y no interactiva, breakpoints y diagnóstico."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:00:00Z
updated_at: 2026-08-27T16:00:00Z
schema_version: 1.0.0
---

# 07 - Especificación y Plantilla Maestra de DEBUGGING.md

Este documento establece la especificación técnica, protocolos y plantilla maestra para el archivo `DEBUGGING.md`, ubicado en la raíz o en `docs/development/DEBUGGING.md`.

---

## 1. Propósito y Delimitación frente a TROUBLESHOOTING.md

Es fundamental delimitar la responsabilidad de ambos documentos:

| **Documento** | **Naturaleza** | **Propósito Central** | **Audiencia / Uso Típico** |
|:---|:---|:---|:---|
| **`TROUBLESHOOTING.md`** | **Reactivo / Matriz de Errores** | Diagnosticar síntomas conocidos, códigos de error y soluciones directas. | Desarrollador o agente buscando solucionar un error específico ya catalogado. |
| **`DEBUGGING.md`** | **Activo / Procedimental** | Guía paso a paso para inspeccionar el estado en runtime, adjuntar depuradores y aislar fallas complejas. | Desarrollador o agente que debe investigar un bug desconocido mediante instrumentación. |

---

## 2. Protocolos de Depuración para Agentes y Desarrolladores

1. **Modo No Interactivo para Agentes:** Los agentes no pueden interactuar con un prompt interactivo de `pdb`. Deben utilizar flags de logging detallado (`LOG_LEVEL=DEBUG`), trazas JSON o scripts de prueba reproducibles (`repro_script.py`).
2. **Depuración Interactiva para Humanos:** Configuraciones de depuración listas para usar en editores (`.vscode/launch.json`).
3. **Aislamiento de Sesión:** Toda sesión de debug debe ejecutarse en entornos virtuales aislados o contenedores de prueba para evitar mutaciones de estado persistente.

---

## 3. Plantilla Maestra Canónica de `DEBUGGING.md`

```markdown
# Protocolos y Guía de Depuración (DEBUGGING.md)

Este documento describe los procedimientos para inspeccionar, depurar y perfilar el comportamiento en tiempo de ejecución de los componentes del sistema.

---

## 1. Configuración de Depuración Rápida

### 1.1 Variables de Entorno para Diagnóstico
Para activar el logging verboso e inspección de payloads:

```bash
export LOG_LEVEL=DEBUG
export AGENT_DEBUG_MODE=true
export DUMP_RAW_PAYLOADS=true
```

### 1.2 Ejecución de Pruebas en Modo Verboso con Salida Inmediata
```bash
pytest -vv -s --tb=short tests/unit/test_modulo_especifico.py
```

---

## 2. Depuración Interactiva con Python (`debugpy` / `pdb`)

### 2.1 Puntos de Interrupción en Código Local
Insertar el breakpoint nativo en el punto de sospecha:
```python
breakpoint()  # Invoca pdb o debugpy según la configuración
```

### 2.2 Configuración de VS Code (`.vscode/launch.json`)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Depurar Test Actual",
      "type": "debugpy",
      "request": "launch",
      "module": "pytest",
      "args": ["${file}", "-vv", "-s"],
      "console": "integratedTerminal"
    }
  ]
}
```

---

## 3. Protocolo de Diagnóstico para Agentes de IA

Si eres un agente de IA investigando un bug desconocido:
1. **Crear un script de reproducción mínima:** Guardar en `scripts/repro_issue.py` reproduciendo la falla con el menor número de líneas posible.
2. **Ejecutar con trazas completas:** Ejecutar el repro script redirigiendo stdout y stderr a un log inspeccionable.
3. **Analizar la causa raíz:** Identificar la invariante rota o la precondición fallida.
4. **Limpieza posterior:** Eliminar cualquier script temporal o llamada a `breakpoint()` antes de finalizar la tarea.
```

---

## 4. Checklist de Limpieza Post-Debug

- [ ] Se eliminaron todas las sentencias `breakpoint()`, `import pdb; pdb.set_trace()` o `print()` de depuración.
- [ ] Las variables de entorno de debug volvieron a sus valores estándar.
- [ ] No se commitearon scripts temporales en directorios productivos.
