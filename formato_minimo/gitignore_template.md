---
id: tmpl_01m1399p54fs7awtajtd1wgx8j
name: gitignore_template
title: "Plantilla Estándar y Patrón Maestro de .gitignore"
file_path: formato_minimo/gitignore_template.md
version: 2.0.0
category: templates
tags: [gitignore, template, master-pattern, security, secrets-prevention, agent-artifacts, hygiene]
description: "Plantilla patrón canónica de .gitignore para repositorios de propósito general con exclusión de secretos, cachés de lenguaje, artefactos de agentes de IA y buenas prácticas integradas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T22:16:00Z
updated_at: 2026-08-29T21:00:00Z
dependencies: [00_global_standards, 05_gitignore_specification]
related_specs: [01_readme_specification, 03_agents_specification]
schema_version: 1.0.0
---

# Patrón Maestro y Plantilla de .gitignore

Este documento define la **especificación canónica de exclusión de archivos, prevención de fuga de secretos e higiene del árbol de control de versiones (Git)** para desarrolladores y agentes autónomos de IA.

---

## 1. Función y Relevancia Crítica de .gitignore

El archivo `.gitignore` es la **primera línea de defensa de seguridad y limpieza estructural** del repositorio:

1. **Prevención de Fuga de Secretos (*Zero Secrets Leak*):** Bloquea de forma determinista la inclusión accidental de variables de entorno locales (`.env`), llaves privadas (`*.pem`, `id_rsa`), tokens y credenciales de servicios cloud.
2. **Higiene del Repositorio e Inmutabilidad de Diffs:** Evita que se introduzcan archivos binarios compilados (`__pycache__`, `.so`), reportes de cobertura efímeros o cachés de linters (`.ruff_cache`), manteniendo los diffs de commits atómicos y limpios.
3. **Aislamiento de Artefactos de Agentes de IA:** Impide que los directorios de trabajo de asistentes y extensiones de IA (`.cursor/`, `.claude/`, `.gemini/`, bitácoras de debug `agent_debug_traces/`) contaminen el historial de Git del proyecto.

---

## 2. Plantilla Canónica Lista para Instanciar (`.gitignore`)

<!-- ======================================================================= -->
<!-- A continuación se presenta el bloque de configuración .gitignore        -->
<!-- estandarizado con comentarios de Buenas Prácticas integradas.           -->
<!-- ======================================================================= -->

```gitignore
# =============================================================================
# 1. ENTORNOS VIRTUALES Y GESTIÓN DE DEPENDENCIAS
# BP: bp_0503_reproducible_builds_and_lockfiles
# Excluir paquetes y runtimes locales; los lockfiles (uv.lock) SÍ se versionan.
# =============================================================================
.venv/
venv/
ENV/
env/
wheels/
*.egg-info/
dist/
build/

# =============================================================================
# 2. SECRETOS, CREDENCIALES Y VARIABLES DE ENTORNO (SEGURIDAD CRÍTICA)
# BP: bp_0501_secret_management_and_no_hardcoded_credentials
# Prohibición absoluta de versionar credenciales; usar plantillas .env.example.
# =============================================================================
.env
.env.local
.env.*.local
*.pem
*.key
*.p12
*.crt
id_rsa
id_rsa.pub
id_ed25519
credentials.json
secrets.yaml
secrets.json
service_account.json

# =============================================================================
# 3. CACHÉS DE PYTHON, COMPILACIÓN Y ANÁLISIS ESTÁTICO
# BP: bp_0502_atomic_commits_and_clean_history
# Evitar colisiones de merge y ruido en artefactos generados automáticamente.
# =============================================================================
__pycache__/
*.py[cod]
*$py.class
*.so
.pytest_cache/
.coverage
htmlcov/
.mypy_cache/
.ruff_cache/
.hypothesis/

# =============================================================================
# 4. IDES, EDITORES Y SISTEMAS OPERATIVOS
# BP: bp_0113_convention_over_configuration
# Preservar configuraciones de equipo (.vscode/launch.json) e ignorar estados locales.
# =============================================================================
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# =============================================================================
# 5. ARTEFACTOS, CACHÉS Y LOGS DE AGENTES DE IA
# BP: bp_0910_worktree_isolation_and_parallel_exploration
# Aislamiento de sesiones de asistentes, agentes autónomos y scratchpads.
# =============================================================================
.cursor/
.claude/
.gemini/
*.tmp.agent
agent_debug_traces/
working_dir/artifacts/
sandbox/tmp/
scratch/

# =============================================================================
# 6. DATOS LOCALES, DATASETS PESADOS Y BASES DE DATOS TEMPORALES
# BP: bp_0703_high_signal_to_noise_ratio
# Prohibido almacenar binarios pesados o DBs locales en el árbol de Git.
# =============================================================================
data/raw/
data/processed/
*.sqlite3
*.db
*.parquet
downloads/
models/*.pt
models/*.onnx
```

---

## 3. Delimitación de Secciones y Explicación Técnica

| **Sección** | **Patrones Clave** | **Propósito para Humanos y Agentes** | **Riesgo si se Omite** |
|:---|:---|:---|:---|
| **1. Entornos Virtuales** | `.venv/`, `dist/`, `build/` | Excluir librerías de terceros y empaquetados reproducibles. | Repositorio sobredimensionado (cientos de MBs de dependencias). |
| **2. Secretos y Credenciales** | `.env`, `*.pem`, `credentials.json` | Evitar la fuga de claves privadas y tokens API a repositorios remotos. | **Vulnerabilidad Crítica de Seguridad** (compromiso de infraestructura). |
| **3. Cachés de Lenguaje y Linters** | `__pycache__/`, `.mypy_cache/` | Garantizar que solo el código fuente legible sea rastreado. | Conflictos de merge constantes e historial de Git corrupto. |
| **4. IDEs y Editores** | `.idea/`, `.vscode/*` (con excepciones) | Compartir configs estándar (`launch.json`) ignorando personalizaciones. | Fricción entre desarrolladores con diferentes editores. |
| **5. Artefactos de Agentes** | `.gemini/`, `.claude/`, `scratch/` | Aislar bitácoras y archivos temporales de ejecución autónoma. | Falsos positivos en diffs de PRs y ruido masivo en git status. |
| **6. Datos Locales y Modelos** | `*.sqlite3`, `*.parquet`, `models/` | Evitar el almacenamiento de archivos binarios pesados sin LFS. | Lentitud extrema en clones (`git clone`) y saturación de Git. |

---

## 4. Buenas Prácticas Agénticas Aplicadas a .gitignore

1. **Uso de `.env.example` como Contrato Público:**
   - `.env` DEBE estar en `.gitignore`.
   - `.env.example` NUNCA debe ignorarse; actúa como la especificación pública de las variables requeridas (con valores dummy o vacíos).
2. **Excepciones Selectivas con `!` (Whitelist Pattern):**
   - En lugar de ignorar todo `.vscode/`, se ignoran los archivos de estado local (`.vscode/*`) pero se preservan las recetas de debugging (`!.vscode/launch.json`) para que los agentes ejecuten tareas de diagnóstico deterministas.
3. **Preservación de Directorios Vacíos con `.gitkeep`:**
   - Si un directorio como `sandbox/` o `data/` debe existir en la estructura pero su contenido debe ignorarse, incluir un archivo `.gitkeep` y añadir la regla:
   ```gitignore
   sandbox/*
   !sandbox/.gitkeep
   ```

---

## 5. Guía de Límites y Fronteras Operativas de .gitignore

Para evitar errores comunes de exclusión o inclusión incorrecta, seguir la siguiente matriz de delimitación:

| **Tipo de Archivo / Recurso** | **¿Debe estar en .gitignore?** | **Justificación / Ubicación Correcta** |
|:---|:---:|:---|
| Archivos de credenciales reales (`.env`, `token.txt`) | ✅ **SÍ (Obligatorio)** | Nunca deben existir en el índice de Git. |
| Directorios de dependencias (`.venv/`, `node_modules/`) | ✅ **SÍ (Obligatorio)** | Se instalan bajo demanda vía `pyproject.toml` / `package.json`. |
| Cachés de linters y pruebas (`.ruff_cache/`, `.pytest_cache/`) | ✅ **SÍ (Obligatorio)** | Son efímeros y regenerados en cada ejecución. |
| Archivos de configuración de entorno plantilla (`.env.example`) | ❌ **NO (Debe versionarse)** | Es la referencia pública de configuración para agentes y CI/CD. |
| Archivos de bloqueo de dependencias (`uv.lock`, `poetry.lock`) | ❌ **NO (Debe versionarse)** | Garantiza builds reproducibles y deterministas. |
| Archivos de configuración del proyecto (`pyproject.toml`, `ruff.toml`) | ❌ **NO (Debe versionarse)** | Define la gobernanza y estándares del código. |
| Documentación y especificaciones (`README.md`, `AGENTS.md`) | ❌ **NO (Debe versionarse)** | Constituyen la base de conocimiento del repositorio. |

---

## 6. Comandos de Verificación y Diagnóstico para Agentes

Antes de realizar commits o tras modificar `.gitignore`, el agente debe verificar:

```bash
# 1. Comprobar por qué un archivo específico está siendo ignorado
git check-ignore -v .env
git check-ignore -v .venv/lib/python3.11/site-packages/

# 2. Verificar que ningún archivo rastreado previamente contenga secretos
git ls-files | grep -E "(\.env$|\.pem$|\.key$|credentials\.json)"

# 3. Limpiar archivos cacheados por error si fueron commiteados antes de añadir la regla
# (Usar con precaución y confirmación):
# git rm -r --cached .mypy_cache/
```
