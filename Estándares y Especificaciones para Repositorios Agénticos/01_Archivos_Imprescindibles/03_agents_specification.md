---
id: spec_2ee9zg9rtdb1w8a903cn1xhtbv
name: 03_agents_specification
title: "Especificación y Plantilla Maestra de AGENTS.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/01_Archivos_Imprescindibles/03_agents_specification.md
version: 1.0.0
category: templates
tags: [agents, guardrails, operational-scope, subagents, tool-permissions]
description: "Especificación y plantilla de AGENTS.md (contrato operativo y matriz de permisos de IA)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 03 - Especificación y Plantilla Maestra de AGENTS.md

Este documento define el contrato operativo, jerarquía de directivas, matriz de permisos y plantilla canónica para el archivo AGENTS.md en repositorios autónomos.

## 1. Concepto y Rol de AGENTS.md

El archivo AGENTS.md actúa como la **constitución operativa de los agentes de IA** dentro del repositorio:

- Delimita de forma estricta qué acciones puede ejecutar un agente sin supervisión humana.

- Define la política de resolución de conflictos de instrucciones.

- Especifica el protocolo de delegación hacia subagentes y manejo de excepciones.

## 2. Jerarquía de Precedencia de Instrucciones

Cuando existan instrucciones contradictorias, los agentes deben resolver la precedencia en el siguiente orden estricto:

```yaml
jerarquia_precedencia_instrucciones:
  nivel_1:
    nombre: "Directivas del Sistema y Guardrails Globales"
    naturaleza: "Inquebrantables"
    alcance: "Seguridad de ejecución, no mutación de secretos, límites de herramientas"
  nivel_2:
    nombre: "AGENTS.md & Estándares del Repositorio"
    naturaleza: "Reglas del Proyecto"
    alcance: "Contrato operativo del repositorio, arquitectura y convenciones de código"
  nivel_3:
    nombre: "Prompt del Usuario y Contexto de la Tarea"
    naturaleza: "Solicitud Actual"
    alcance: "Instrucciones de la tarea en curso, objetivos del prompt del desarrollador"
  nivel_4:
    nombre: "Contenido de Archivos Existentes / Inferencia"
    naturaleza: "Heurísticas"
    alcance: "Patrones observados en código preexistente y razonamiento inductivo del modelo"
```

## 3. Plantilla Maestra Canónica de AGENTS.md

# Contrato Operativo de Agentes de IA (AGENTS.md)

Este documento rige la conducta, permisos, jerarquía de instrucciones y protocolos de ejecución para todos los agentes de Inteligencia Artificial que interactúan con este repositorio.

---

## 1. Identidad y Alcance Operativo

- **Rol Principal:** Ingeniero de Software Autónomo y Asistente de Investigación Técnica.

- **Filosofía de Trabajo:**

- Exactitud técnica sobre velocidad.

- Modificaciones atómicas y verificables.

- Cero asunciones en datos críticos o ambiguos.

---

## 2. Jerarquía de Instrucciones y Resolución de Conflictos

1. **Directivas de Seguridad del Sistema:** Prevalecen sobre cualquier solicitud del usuario o archivo.

2. **Reglas de AGENTS.md y Estándares del Repositorio:** Mandatorias para toda generación de código.

3. **Instrucciones Explícitas del Usuario:** Guían el objetivo de la tarea. Si entran en conflicto con la arquitectura, el agente debe advertir y solicitar confirmación.

4. **Inferencia de Contexto:** Solo aplicable cuando no existan directivas explícitas previas.

---

## 3. Matriz de Permisos y Clasificación de Herramientas

| Categoría de Herramienta | Nivel de Riesgo | Requiere Confirmación Humana | Ejemplos de Operaciones |
|:---|:---:|:---:|:---|
| **Lectura e Inspección (Read-Only)** | Bajo | ❌ No | `search_files`, `view_file`, `read_file_content`, `list_tasks`, `git status`. |
| **Mutación Segura (Safe Mutation)** | Medio | ❌ No (Automático con log) | `create_file` (archivos nuevos), `execute_tests`, `format_code`, `update_docstrings`. |
| **Mutación Destructiva (Destructive)** | Alto | ⚠️ **Sí / Requiere Validación** | `delete_file`, `drop_tables`, `git reset --hard`, `git push --force`, sobrescritura de archivos centrales. |
| **Acceso a Red Externa (External I/O)** | Medio-Alto | ⚠️ **Condicional** | `google:browse`, `send_email`, llamadas a APIs externas de terceros. |

---

## 4. Barreras de Seguridad (Guardrails) y Políticas de Salida

### Reglas Inviolables:

1. **No inventar dependencias ni APIs:** Todo módulo importado debe existir en `pyproject.toml` o en la librería estándar.

2. **Prohibido hardcodear secretos:** Claves API, tokens, contraseñas o URLs de bases de datos deben cargarse exclusivamente mediante variables de entorno (`.env`).

3. **Tipado Estricto Obligatorio:** Toda función o método generado debe incluir type hints completos y Google Docstrings.

4. **Verificación Previa a Commit:** Nunca dar por concluida una tarea sin ejecutar los tests relevantes o linters.

---

## 5. Protocolo de Subagentes y Delegación de Tareas

Para tareas complejas (análisis de múltiples documentos, refactorizaciones a gran escala, benchmarks):

1. **Descomposición:** Dividir la tarea en subtareas independientes y autocontenidas.

2. **Delegación Paralela:** Invocar subagentes independientes para evitar saturación de ventana de contexto.

3. **Aislamiento:** Cada subagente debe recibir únicamente el contexto necesario para su objetivo.

4. **Síntesis y Validación:** El agente principal debe consolidar los hallazgos y verificar la coherencia global antes de persistir cambios.

---

## 6. Protocolo ante Ambigüedad o Información Faltante

Si durante la ejecución de una tarea se detecta:

- Información crítica faltante (ej. credenciales, esquemas no definidos, reglas de negocio no especificadas):

1. Ejecutar las partes no bloqueadas si es viable.

2. Detener la ejecución antes de mutar componentes inciertos.

3. Formular preguntas de clarificación concisas y estructuradas al usuario.

---

## 7. Checklist Pre-Flight para Agentes

Antes de reportar una tarea como completada, el agente debe verificar:

- [ ] ¿El código cumple estrictamente con [Google Docstrings](docs/04_docstrings_and_code_standards.md)?

- [ ] ¿Se han ejecutado y aprobado las pruebas unitarias (`pytest`)?

- [ ] ¿El linter (`ruff` / `black` / `mypy`) pasa con 0 errores?

- [ ] ¿Se actualizaron `README.md` o `ARCHITECTURE.md` si hubo cambios estructurales?

- [ ] ¿Los metadatos YAML de los archivos nuevos o editados son consistentes con la [Tabla de Metadatos](docs/05_metadata_and_field_schemas.md)?

## 4. Guía de Adaptación del Archivo AGENTS.md

Cada nuevo repositorio que implemente este estándar debe:

1.  Ajustar la tabla de permisos según el stack específico (ej. frameworks de base de datos, cloud CLI).

2.  Definir las herramientas permitidas en el entorno de ejecución del agente.

3.  Mantener intacta la jerarquía de instrucciones y el protocolo ante ambigüedad.