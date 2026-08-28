---
id: tmpl_5nfpbeqpsmasaa6ss4p1g9sf7n
name: frontmatter_yaml
title: Plantilla Estándar de Metadatos YAML Frontmatter
file_path: frontmatter_yaml.md
version: 1.1.0
category: metadata
tags: [metadata, yaml, frontmatter, schema, agentic, standards, template, typeid]
description: Plantilla canónica y directrices para metadatos YAML Frontmatter en documentos Markdown para repositorios agénticos.
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T14:00:00Z
updated_at: 2026-08-27T14:20:00Z
schema_version: 1.0.0
---

# Plantilla Estándar de Metadatos YAML Frontmatter (Agent-First)

Este documento establece la **plantilla canónica**, la estructura de campos, las reglas de validación y los criterios de saneamiento/migración de metadatos **YAML Frontmatter** para todos los archivos Markdown (`.md`) del repositorio.

---

## 1. Propósito y Filosofía (Agent-First Metadata)

El encabezado **YAML Frontmatter** es el punto de entrada primario para sistemas agénticos y modelos de lenguaje (LLMs). Permite a los agentes autónomos:

1. **Descubrimiento e Indexación Instantánea:** Conocer la identidad única (`id`), propósito, ruta y palabras clave de un archivo sin gastar tokens leyendo todo el cuerpo.
2. **Control de Flujo y Permisos:** Determinar si un archivo es ejecutable, de solo lectura, o requiere herramientas específicas.
3. **Resolución de Dependencias:** Construir grafos de lectura contextual y evitar alucinaciones.

---

## 2. Requisitos Mínimos Obligatorios

Todo archivo `.md` del repositorio debe contener **como mínimo** los siguientes campos en su Frontmatter:

| **Campo** | **Tipo** | **Requerido** | **Formato / Regla** | **Propósito** |
|:---|:---:|:---:|:---|:---|
| `id` | string | **Sí** | `^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$` | Identificador único global e inmutable en formato **TypeID** (ej. `bp_...`, `spec_...`, `doc_...`). |
| `name` | string | **Sí** | `^[a-z0-9_]{3,64}$` | Identificador unívoco del archivo en snake_case (coincidente con el basename). |
| `title` | string | **Sí** | 5 a 120 caracteres | Título legible para humanos y cabeceras de reportes. |
| `file_path` | string | **Sí** | Ruta POSIX relativa (ej. `docs/01_file.md`) | Ubicación canónica del archivo desde la raíz del repositorio. |
| `version` | string | **Sí** | SemVer 2.0.0 (`^\d+\.\d+\.\d+$`) | Control de compatibilidad e historial de cambios. |
| `category` | enum | **Sí** | Uno de los valores taxonómicos válidos | Clasificación semántica para filtrado de contexto. |
| `tags` | list[string] | **Sí** | Lista de 1 a 10 strings en minúsculas | Palabras clave para indexación y búsqueda vectorial. |
| `description` | string | **Sí** | 10 a 300 caracteres | Resumen corto del contenido y utilidad del documento. |
| `owner` | string | **Sí** | Nombre de equipo, rol o correo | Responsable técnico para escalamiento o autoría. |
| `status` | enum | **Sí** | `draft` | `active` | `deprecated` | `archived` | Estado del ciclo de vida del documento. |
| `created_at` | string | **Sí** | ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ssZ`) | Marca de tiempo de creación original. |
| `updated_at` | string | **Sí** | ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ssZ`) | Marca de tiempo de última actualización. |
| `schema_version` | string | **Sí** | SemVer (`1.0.0`) | Versión de la especificación de metadatos aplicada. |

---

## 3. Tabla Exhaustiva de Campos (Esquema Completo)

| **Campo** | **Tipo** | **Obligatorio** | **Valores Permitidos / Validación** | **Descripción / Utilidad Agéntica** |
|:---|:---:|:---:|:---|:---|
| `id` | string | **Sí** | `^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$` | Identificador único global e inmutable en formato TypeID. |
| `name` | string | **Sí** | `^[a-z0-9_]{3,64}$` | Identificador legible en snake_case. |
| `title` | string | **Sí** | 5 a 120 caracteres | Título legible del documento. |
| `file_path` | string | **Sí** | Ruta relativa con `/` (POSIX) | Ruta exacta del archivo dentro del repositorio. |
| `version` | string | **Sí** | `^\d+\.\d+\.\d+$` (ej. `1.0.0`) | Versión semántica del documento. |
| `category` | enum | **Sí** | `standards`, `architecture`, `agentic`, `code_standards`, `metadata`, `errors`, `templates`, `guides`, `universal_principles` | Categoría taxonómica global. |
| `domain` | string | No | Subdominio funcional (ej. `core`, `ml`, `qa`, `devops`) | Delimitación del contexto de aplicación. |
| `tags` | list[str] | **Sí** | 1 a 10 strings en minúsculas sin espacios | Palabras clave para búsqueda semántica. |
| `description` | string | **Sí** | 10 a 300 caracteres | Descripción corta de alto nivel. |
| `author` | string | No | Nombre del creador original | Atribución de autoría. |
| `owner` | string | **Sí** | Equipo responsable o rol | Propietario del documento. |
| `maintainers` | list[str] | No | Lista de nombres o correos | Lista de mantenedores actuales. |
| `status` | enum | **Sí** | `draft`, `active`, `deprecated`, `archived` | Estado operativo (agentes solo aplican `active`). |
| `created_at` | string | **Sí** | ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ssZ`) | Marca de tiempo de creación. |
| `updated_at` | string | **Sí** | ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ssZ`) | Marca de tiempo de modificación. |
| `license` | string | No | Identificador SPDX (ej. `MIT`, `Apache-2.0`) | Licencia del documento/módulo. |
| `agent_visibility` | enum | No | `public`, `internal`, `restricted` (default: `public`) | Nivel de visibilidad para agentes. |
| `tool_access_level`| enum | No | `read_only`, `safe_mutation`, `full_access` (default: `safe_mutation`) | Nivel de permisos de herramientas requerido. |
| `execution_mode` | enum | No | `sync`, `async`, `batch`, `event_driven` | Modo de ejecución del script o módulo. |
| `priority` | integer | No | 1 (baja) a 5 (crítica). Por defecto `3`. | Prioridad en colas de trabajo agénticas. |
| `timeout_seconds` | integer | No | Entero positivo >= 1 | Límite de tiempo para tareas autónomas. |
| `dependencies` | list[str] | No | Lista de nombres (`name`) de dependencias | Documentos requeridos para lectura previa. |
| `parent_doc` | string | No | Nombre del documento padre | Documento jerárquico superior. |
| `related_specs` | list[str] | No | Lista de nombres de especificaciones | Especificaciones relacionadas para lectura cruzada. |
| `entrypoint` | string | No | Ruta relativa al archivo ejecutable | Punto de entrada si el archivo describe un script. |
| `schema_version` | string | **Sí** | `^\d+\.\d+\.\d+$` (ej. `1.0.0`) | Versión de este esquema de metadatos. |

---

## 4. Reglas de Saneamiento, Ordenación y Depuración

Al aplicar esta plantilla a archivos existentes que poseen metadatos mal formateados o incompletos, se deben seguir estrictamente las siguientes reglas:

### 4.1 Reglas de Formato y Sintaxis
1. **Delimitadores Obligatorios:** El bloque Frontmatter DEBE iniciar en la línea 1 del archivo con `---` y finalizar con `---` antes del cuerpo Markdown.
2. **Eliminar Escapes Residuales:**
   - Eliminar barras invertidas al final de las líneas (`` -> borrado).
   - Desescapar corchetes en listas (`[` -> `[`, `]` -> `]`).
3. **Prohibición de Metadatos en Títulos:** Nunca incrustar pares clave-valor en encabezados Markdown (ej. `## name: ...`). Deben extraerse y colocarse en el bloque YAML superior.
4. **Espaciado e Indentación:** Usar 2 espacios exactos para indentación. Prohibido el uso de tabuladores (`\t`).
5. **Formato de Listas:** Usar la notación en línea `[tag1, tag2, tag3]` o listas con guiones `- tag1`.

### 4.2 Reglas de Ordenación Canónica
Los campos del Frontmatter deben organizarse siempre en el siguiente orden secuencial:
1. `id`
2. `name`
3. `title`
4. `file_path`
5. `version`
6. `category`
7. `domain` *(si aplica)*
8. `tags`
9. `description`
10. `author` *(si aplica)*
11. `owner`
12. `maintainers` *(si aplica)*
13. `status`
14. `created_at`
15. `updated_at`
16. `license` *(si aplica)*
17. `agent_visibility` *(si aplica)*
18. `tool_access_level` *(si aplica)*
19. `execution_mode` *(si aplica)*
20. `priority` *(si aplica)*
21. `timeout_seconds` *(si aplica)*
22. `dependencies` *(si aplica)*
23. `parent_doc` *(si aplica)*
24. `related_specs` *(si aplica)*
25. `entrypoint` *(si aplica)*
26. `schema_version`

### 4.3 Reglas de Depuración (Eliminación vs Conservación)
- **Conservar y Reordenar:** Si un campo existente coincide o puede mapearse a uno del esquema oficial (`name`, `title`, `category`, `tags`, `owner`, `status`, `created_at`, `updated_at`), normalizar su valor y reordenarlo.
- **Eliminar:** Si un archivo contiene campos no contemplados en el estándar, ruidosos o redundantes (por ejemplo: `target_scope`, `level`, o parámetros arbitrarios no definidos en el esquema), deben ser eliminados de inmediato.
- **Completar Faltantes:** Si faltan campos obligatorios (`id`, `file_path`, `description`, `schema_version`), deducirlos y generarlos conforme al estándar.

---

## 5. Plantillas Listas para Uso

### 5.1 Plantilla Básica / Mínima (Recomendada para Documentación General)

```yaml
---
id: doc_01h455vb4pex5v7cb50153dnq9
name: nombre_del_documento
title: "Título Descriptivo del Documento"
file_path: ruta/relativa/al/archivo.md
version: 1.0.0
category: standards
tags: [palabra_clave1, palabra_clave2, palabra_clave3]
description: "Descripción concisa del contenido y propósito del documento (10-300 caracteres)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T14:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---
```

### 5.2 Plantilla Completa / Extendida (Para Módulos de Código o Tareas de Agentes)

```yaml
---
id: task_01j7w2b8k4z0v9m1x2c3d4e5f6
name: agent_task_executor
title: "Ejecutor Autónomo de Tareas y Herramientas"
file_path: src/agents/task_executor.md
version: 1.2.0
category: agentic
domain: core_runtime
tags: [agent, runner, tools, execution, automation]
description: "Especificación técnica y runtime para la orquestación y ejecución determinista de herramientas agénticas."
author: AI Engineering Guild
owner: AI Architecture Team
maintainers: [lead-dev@example.com]
status: active
created_at: 2026-08-27T14:00:00Z
updated_at: 2026-08-27T14:00:00Z
license: MIT
agent_visibility: public
tool_access_level: safe_mutation
execution_mode: async
priority: 4
timeout_seconds: 300
dependencies: [00_global_standards, 03_agents_specification]
parent_doc: 00_global_standards
related_specs: [02_architecture_specification]
entrypoint: src/agents/runner.py
schema_version: 1.0.0
---
```

---

## 6. Esquema de Validación Formal (JSON Schema Draft-07)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AgenticFrontmatterSchema",
  "type": "object",
  "required": [
    "id",
    "name",
    "title",
    "file_path",
    "version",
    "category",
    "tags",
    "description",
    "owner",
    "status",
    "created_at",
    "updated_at",
    "schema_version"
  ],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$"
    },
    "name": {
      "type": "string",
      "pattern": "^[a-z0-9_]{3,64}$"
    },
    "title": {
      "type": "string",
      "minLength": 5,
      "maxLength": 120
    },
    "file_path": {
      "type": "string",
      "pattern": "^[a-zA-Z0-9_\\-\\./ ]+\\.md$"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "category": {
      "type": "string",
      "enum": [
        "standards",
        "architecture",
        "agentic",
        "code_standards",
        "metadata",
        "errors",
        "templates",
        "guides",
        "universal_principles"
      ]
    },
    "domain": {
      "type": "string"
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "maxItems": 10
    },
    "description": {
      "type": "string",
      "minLength": 10,
      "maxLength": 300
    },
    "author": {
      "type": "string"
    },
    "owner": {
      "type": "string"
    },
    "maintainers": {
      "type": "array",
      "items": { "type": "string" }
    },
    "status": {
      "type": "string",
      "enum": ["draft", "active", "deprecated", "archived"]
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "license": {
      "type": "string"
    },
    "agent_visibility": {
      "type": "string",
      "enum": ["public", "internal", "restricted"],
      "default": "public"
    },
    "tool_access_level": {
      "type": "string",
      "enum": ["read_only", "safe_mutation", "full_access"],
      "default": "safe_mutation"
    },
    "execution_mode": {
      "type": "string",
      "enum": ["sync", "async", "batch", "event_driven"]
    },
    "priority": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5,
      "default": 3
    },
    "timeout_seconds": {
      "type": "integer",
      "minimum": 1
    },
    "dependencies": {
      "type": "array",
      "items": { "type": "string" }
    },
    "parent_doc": {
      "type": "string"
    },
    "related_specs": {
      "type": "array",
      "items": { "type": "string" }
    },
    "entrypoint": {
      "type": "string"
    },
    "schema_version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    }
  },
  "additionalProperties": false
}
```

---

## 7. Referencia Cruzada y Guía de Identificadores Únicos (IDs)

Para la especificación exhaustiva sobre la convención de nombres para el campo `id`, prefijos tipados (**TypeID**), **UUIDv7** (RFC 9562), **ULID** y códigos de error/ADRs, consultar el documento maestro:

- **[`id_standards_guide.md`](id_standards_guide.md)** en la raíz del repositorio.