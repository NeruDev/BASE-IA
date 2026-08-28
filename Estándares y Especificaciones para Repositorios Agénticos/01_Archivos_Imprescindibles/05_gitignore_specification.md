---
id: spec_3047ysxadnavp9691094bzkr0s
name: 05_gitignore_specification
title: "Especificación y Plantilla Maestra de .gitignore"
file_path: Estándares y Especificaciones para Repositorios Agénticos/01_Archivos_Imprescindibles/05_gitignore_specification.md
version: 1.0.0
category: templates
tags: [gitignore, git, security, environment, artifacts]
description: "Especificación y plantilla de .gitignore (patrones de exclusión y prevención de secretos)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 05 - Especificación y Plantilla Maestra de .gitignore

## 1. Definición y Propósito del Archivo

### ¿Qué es .gitignore?

.gitignore es el archivo de configuración declarativo que especifica qué patrones de archivos y directorios no deben ser rastreados ni almacenados en el árbol de control de versiones de Git.

### ¿Por qué existe y qué problemas resuelve?

- **Seguridad Crítica:** Previene la fuga accidental de secretos, variables de entorno (.env), llaves SSH y tokens API.

- **Higiene del Repositorio:** Evita que se commiteen artefactos de compilación (__pycache__, .so), entornos virtuales (.venv/), logs temporales y cachés de herramientas de IA (.cursor/, .claude/, temporales de agentes).

## 2. Plantilla Maestra Canónica de .gitignore

```gitignore
# ==========================================
# Entornos Virtuales y Dependencias
# ==========================================
.venv/
venv/
ENV/
env/
wheels/
*.egg-info/
dist/
build/

# ==========================================
# Secretos y Variables de Entorno (CRÍTICO)
# ==========================================
.env
.env.local
.env.*.local
*.pem
*.key
*.p12
id_rsa
credentials.json
secrets.yaml

# ==========================================
# Cachés de Python y Compilación
# ==========================================
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.coverage
htmlcov/
.mypy_cache/
.ruff_cache/

# ==========================================
# IDEs y Editores
# ==========================================
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
.idea/
*.swp
*.swo

# ==========================================
# Artefactos y Cachés de Agentes de IA
# ==========================================
.cursor/
.claude/
.gemini/
*.tmp.agent
agent_debug_traces/
downloads/
working_dir/artifacts/
```