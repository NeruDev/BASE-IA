---
id: bp_5bpwtz6tr5ax5tac9c8vjhghs4
name: 07_reproducibility
title: "Reproducibilidad de Entornos y Builds"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/07_reproducibility.md
version: 1.1.0
category: code_standards
tags: [reproducibility, lockfiles, docker, uv, poetry, determinism, universal_principles]
description: "Reproducibilidad: fijación determinista de dependencias con lockfiles criptográficos y contenedores."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 07 - Reproducibilidad de Entornos y Builds

## 1. Definición y Fundamento Teórico

Fundamentada en los principios de la **Computación Determinista**, los estándares **OCI de Contenedores** y los gestores de paquetes basados en grafos de dependencias resueltos (**UV**, **Poetry**, **Cargo**, **Nix**), la **Reproducibilidad de Entornos** establece:

> *"Un sistema de software debe ser capaz de reconstruir de manera 100% idéntica y determinista su entorno de ejecución, compilación y árbol completo de dependencias (con hashes criptográficos inmutables) en cualquier máquina local, servidor de CI o sandbox de agente, erradicando por completo el 'Dependency Drift'."*

Los dos pilares de la reproducibilidad son:
1. **Lockfiles Autoritativos (`uv.lock` / `poetry.lock`):** Fijan no solo las dependencias directas, sino todas las dependencias transitivas con sus hashes SHA-256 exactos.
2. **Entornos Aislados Contenerizados (Docker):** Garantizan que las librerías del sistema operativo (C runtime, OpenSSL, drivers) sean idénticas sin importar el host.

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación del *"En mi máquina sí funcionaba"*:** Asegura que el código se comporte de manera exactamente igual en local, en CI y en producción.
- **Inmunidad ante Breaking Changes de Dependencias Transitivas:** Evita que la actualización sorpresiva de una sub-dependencia menor rompa el despliegue del proyecto.
- **Onboarding Inmediato:** Permite a un nuevo miembro del equipo o a un agente levantar el entorno completo con un solo comando determinista.

## 3. Relevancia en Sistemas con IA Agéntica

- **Estabilidad en Sandboxes Agénticos:** Los agentes de IA ejecutan código y tests en contenedores efímeros. Un lockfile estricto evita que el agente falle por diferencias de versiones en librerías subyacentes.
- **Determinismo en la Evaluación de Agentes:** Garantiza que los benchmarks y pruebas de calidad de los modelos de lenguaje midan la capacidad del agente y no discrepancias en el entorno.
- **Seguridad en la Cadena de Suministro (*Supply Chain Security*):** Los hashes criptográficos previenen ataques de inyección de paquetes maliciosos sustitutos en PyPI.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Requirements Abiertos sin Lockfile)

```text
# requirements.txt (Antipatrón: Dependencias sin versión o con rangos abiertos)
fastapi
pydantic>=2.0.0
requests
pytest

# PELIGRO: Si se ejecuta 'pip install -r requirements.txt' hoy y dentro de 3 semanas:
# 1. Se instalarán versiones menores distintas con posibles breaking changes.
# 2. Las dependencias transitivas no están controladas ni tienen hashes verificados.
```

### ✅ Código Correcto (Conforme a Reproducibilidad: Pyproject + Lockfile Criptográfico)

Definición formal en `pyproject.toml`:
```toml
[project]
name = "enterprise-agent-core"
version = "1.0.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi==0.115.0",
    "pydantic==2.9.2",
    "pydantic-settings==2.5.2",
    "structlog==24.4.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

Generación y uso del lockfile determinista:
```bash
# Genera uv.lock con hashes SHA-256 inmutables de todo el árbol transitivo:
uv lock

# Instalación exacta y determinista (utilizada por CI y agentes):
uv sync --frozen --no-dev
```

Contenedor Reproducible (`Dockerfile` Multi-Stage):
```dockerfile
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app
COPY pyproject.toml uv.lock ./
# Instalación inmutable verificando hashes
RUN pip install uv && uv sync --frozen --no-dev

FROM python:3.11-slim-bookworm AS runtime
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY src/ /app/src/

ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["python", "-m", "src.main"]
```

## 5. Descripción Didáctica de los Cambios

1. **Fijación Estricta de Dependencias:** El archivo `uv.lock` bloquea las versiones exactas y los hashes de integridad SHA-256 de todas las librerías directas e indirectas.
2. **Instalación Frozen en CI:** El comando `uv sync --frozen` prohíbe actualizar paquetes si el lockfile no fue explícitamente modificado en Git.
3. **Contenedor Multi-Stage:** El `Dockerfile` genera una imagen ligera, inmutable y reproducible basada en una distribución Debian específica (`bookworm`).

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Obsolescencia de Dependencias (*Dependency Staleness*):** Un lockfile estricto puede perpetuar vulnerabilidades de seguridad si no se cuenta con herramientas automatizadas de actualización (Dependabot, Renovate).
- **Sobrecarga en Scripts Utilitarios de 10 Líneas:** Para un script de un solo archivo que solo usa la librería estándar de Python, configurar lockfiles y Docker es innecesario.
- **Dependencias con Binarios Específicos de SO:** Librerías con extensiones nativas en C/C++ (ej. CUDA, drivers de base de datos propietarios) pueden requerir configuraciones de compilación adicionales por plataforma.

## 7. Checklist de Verificación

- [ ] ¿El repositorio incluye un archivo de bloqueo (`uv.lock` / `poetry.lock`) bajo control de versiones en Git?
- [ ] ¿Los pipelines de CI utilizan comandos de instalación congelada (`uv sync --frozen` / `pip sync`)?
- [ ] ¿La versión de Python está explícitamente fijada tanto en `pyproject.toml` como en el `.python-version` y `Dockerfile`?
- [ ] ¿Se cuenta con un escáner automático de dependencias (Dependabot / Renovate) para actualizar vulnerabilidades?