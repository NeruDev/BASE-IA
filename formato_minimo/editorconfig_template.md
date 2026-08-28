---
id: tmpl_01m139myzmez6ads4q5ye17sfx
name: editorconfig_template
title: "Plantilla Estándar y Patrón Maestro de .editorconfig"
file_path: formato_minimo/editorconfig_template.md
version: 1.0.0
category: templates
tags: [editorconfig, template, master-pattern, formatting, encoding, line-endings, whitespace, agent-hygiene]
description: "Plantilla patrón canónica de .editorconfig para repositorios de propósito general con estandarización de codificación UTF-8, saltos LF, indentación y buenas prácticas integradas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T22:20:00Z
updated_at: 2026-08-27T22:20:00Z
dependencies: [00_global_standards, 07_editorconfig_specification]
related_specs: [01_readme_specification, 03_agents_specification, 05_gitignore_specification]
schema_version: 1.0.0
---

# Patrón Maestro y Plantilla de .editorconfig

Este documento define la **especificación canónica de formato de texto plano, codificación de caracteres, saltos de línea e indentación** para desarrolladores humanos, entornos IDE y agentes autónomos de IA.

---

## 1. Función y Relevancia en Repositorios Agénticos

El archivo `.editorconfig` actúa como el **estabilizador de formato a nivel de sistema operativo y editor**:

1. **Eliminación de *Diff Pollution*:** Garantiza que los agentes de IA y los desarrolladores en Windows, macOS o Linux generen archivos con finales de línea `LF` y codificación `UTF-8` estricta sin BOM, previniendo diffs espurios de cientos de líneas provocados por conversiones `CRLF`.
2. **Consistencia de Sangría por Tipo de Archivo:** Define automáticamente 4 espacios para Python/Backend y 2 espacios para YAML/JSON/Markdown, eliminando ambigüedades durante la edición quirúrgica de código con LLMs.
3. **Limpieza Automática de Espacios Residuales:** Fuerza la eliminación de espacios en blanco al final de línea (`trim_trailing_whitespace = true`) e inserción de salto final (`insert_final_newline = true`).

---

## 2. Plantilla Canónica Lista para Instanciar (`.editorconfig`)

<!-- ======================================================================= -->
<!-- Bloque de configuración .editorconfig con comentarios de BP integrados. -->
<!-- ======================================================================= -->

```ini
# =============================================================================
# CONFIGURACIÓN MAESTRA DE EDITORCONFIG
# BP: bp_0113_convention_over_configuration
# Marca este archivo como la raíz del árbol jerárquico del repositorio.
# =============================================================================
root = true

# =============================================================================
# 1. REGLAS GLOBALES POR DEFECTO PARA TODOS LOS ARCHIVOS
# BP: bp_0904_agent_readable_code & bp_0502_atomic_commits_and_clean_history
# UTF-8 estricto, finales de línea LF e indentación de 4 espacios.
# =============================================================================
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4
max_line_length = 120

# =============================================================================
# 2. ARCHIVOS DE CONFIGURACIÓN Y DATOS ESTRUCTURADOS (YAML, JSON, TOML)
# BP: bp_0601_documentation_as_code
# Indentación canónica de 2 espacios sin tabuladores.
# =============================================================================
[*.{yml,yaml,json,jsonc,toml}]
indent_size = 2
indent_style = space

# =============================================================================
# 3. DOCUMENTACIÓN MARKDOWN (.md)
# BP: bp_0607_facts_rules_and_procedures_separation
# Preservar 2 espacios de sangría; trim_trailing_whitespace deshabilitado si
# se emplean dos espacios al final de línea para saltos forzados de Markdown.
# =============================================================================
[*.md]
indent_size = 2
indent_style = space
trim_trailing_whitespace = false
max_line_length = off

# =============================================================================
# 4. SCRIPTS DE AUTOMATIZACIÓN Y HERRAMIENTAS SHELL (.sh, .bash)
# BP: bp_0801_operational_boundaries_and_blast_radius
# Finales LF obligatorios para evitar errores de interpretación en Linux.
# =============================================================================
[*.{sh,bash}]
indent_size = 2
indent_style = space
end_of_line = lf

# =============================================================================
# 5. MAKEFILES Y ARCHIVOS DE COMPILACIÓN BASADOS EN TABULADORES
# BP: bp_0603_runbooks_and_operational_documentation
# Los Makefiles requieren sintaxis de tabuladores reales para los targets.
# =============================================================================
[Makefile]
indent_style = tab
indent_size = 4

[*.mk]
indent_style = tab
indent_size = 4
```

---

## 3. Delimitación de Secciones y Explicación Técnica

| **Sección** | **Patrón de Archivo** | **Propósito para Humanos y Agentes** | **Riesgo si se Omite** |
|:---|:---|:---|:---|
| **Global `[*]`** | Todos los archivos | Establece UTF-8, finales `LF` y sangría base de 4 espacios. | Commits con finales mixtos CRLF/LF que corrompen pipelines de CI. |
| **Configuraciones** | `*.{yml,yaml,json,toml}` | Normaliza sangría de 2 espacios requerida por parsers estrictos. | Errores de parseo en YAML o GitHub Actions por sangría incorrecta. |
| **Documentación** | `*.md` | Permite estructuración de listas a 2 espacios y saltos de línea. | Diffs que alteran párrafos Markdown y rompen renderizado GFM. |
| **Shell Scripts** | `*.{sh,bash}` | Fuerza saltos `LF` críticos para ejecución en contenedores Linux. | Error `: command not found` al ejecutar scripts en Linux/Docker. |
| **Makefiles** | `Makefile`, `*.mk` | Exige caracteres `TAB` obligatorios para comandos de recetas Make. | Error `Makefile: *** missing separator. Stop.` al ejecutar `make`. |

---

## 4. Buenas Prácticas Agénticas Aplicadas a .editorconfig

1. **Sinergia con `.gitattributes` y Linters:**
   - `.editorconfig` normaliza la escritura en el editor/agente.
   - `.gitattributes` normaliza la persistencia en el repositorio Git.
   - `ruff` / `black` validan y corrigen la sintaxis de código en CI/CD.
2. **Invarianza de Salto de Línea en Windows:**
   - Para agentes que corren en entornos Windows (PowerShell), la regla `end_of_line = lf` asegura que cualquier nuevo archivo creado mantenga la compatibilidad con servidores Linux y CI sin intervención manual.
3. **Protección de Makefiles:**
   - La regla explícita `indent_style = tab` previene que un agente reemplace tabuladores por espacios al editar un `Makefile`, lo cual rompería inmediatamente la automatización de compilación.

---

## 5. Guía de Límites y Fronteras Operativas de .editorconfig

Para evitar confusiones sobre la responsabilidad de cada herramienta, seguir la siguiente matriz:

| **Responsabilidad / Tarea** | **¿Corresponde a .editorconfig?** | **Herramienta / Ubicación Correcta** |
|:---|:---:|:---|
| Codificación de caracteres (`UTF-8`), saltos `LF` e indentación básica | ✅ **SÍ** | `.editorconfig`. |
| Reglas de sangría diferenciadas por extensión (`.py` vs `.yaml` vs `.md`) | ✅ **SÍ** | `.editorconfig`. |
| Normalización de finales de línea en el índice de Git | ❌ **NO** | `.gitattributes` (`* text=auto eol=lf`). |
| Reglas de estilo de código avanzadas (orden de imports, nombres) | ❌ **NO** | `ruff.toml` / `pyproject.toml`. |
| Verificación estricta de tipos estáticos | ❌ **NO** | `mypy.ini` o `pyproject.toml` (`[tool.mypy]`). |
| Exclusión de archivos y carpetas del control de versiones | ❌ **NO** | `.gitignore`. |

---

## 6. Comandos de Verificación para Agentes

Para comprobar la conformidad de archivos con las directivas de `.editorconfig`:

```bash
# 1. Verificar conformidad de archivos con editorconfig-checker (si está instalado)
ec src/ tests/ docs/

# 2. Verificar que los archivos creados tengan saltos de línea LF (sin retornos )
file src/**/*.py
```
