---
id: spec_0vzaj596kfacdrre228s3dkxmm
name: 07_editorconfig_specification
title: "Especificación y Plantilla Maestra de .editorconfig"
file_path: Estándares y Especificaciones para Repositorios Agénticos/01_Archivos_Imprescindibles/07_editorconfig_specification.md
version: 1.0.0
category: templates
tags: [editorconfig, formatting, indents, encoding, line-endings]
description: "Especificación y plantilla de .editorconfig (indentación y finales de línea)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 07 - Especificación y Plantilla Maestra de .editorconfig

## 1. Definición y Propósito del Archivo

### ¿Qué es .editorconfig?

.editorconfig es un archivo de configuración universal multiplataforma que estandariza las reglas básicas de formato de texto (codificación, sangría, saltos de línea y eliminación de espacios en blanco) en todos los editores e IDEs.

### ¿Por qué existe y qué problemas resuelve?

- **Evita Guerras de Formato:** Impide discrepancias entre desarrolladores en Linux, macOS y Windows.

- **Para Agentes de IA:** Garantiza que los archivos generados o modificados por agentes mantengan exactamente la codificación UTF-8, saltos LF e indentación de 4 espacios (Python) o 2 espacios (Markdown/YAML), evitando diffs ruidosos en Git.

## 2. Plantilla Maestra Canónica de .editorconfig

```ini
# Configuración global EditorConfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{yml,yaml,json,toml}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false
indent_size = 2

[Makefile]
indent_style = tab
```