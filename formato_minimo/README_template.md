---
id: tmpl_01m13915xwemz8qkc7d08950b8
name: readme_template
title: "Plantilla Estándar y Patrón Maestro de README.md"
file_path: formato_minimo/README.md
version: 2.0.0
category: templates
tags: [readme, template, master-pattern, documentation, onboarding, progressive-disclosure, agent-first]
description: "Plantilla patrón canónica de README.md para repositorios de propósito general con descripción de secciones, límites de contexto y buenas prácticas agénticas integradas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T22:10:00Z
updated_at: 2026-08-29T21:00:00Z
dependencies: [00_global_standards, 01_readme_specification]
related_specs: [02_architecture_specification, 03_agents_specification]
schema_version: 1.0.0
---

<!-- ======================================================================= -->
<!-- SECCIÓN 1: HEADER, BADGES Y LEMA PRINCIPAL                              -->
<!-- BP RECOMENDADA: bp_0703_high_signal_to_noise_ratio                      -->
<!-- Los badges proporcionan metadatos compactos de alta señal (estado del   -->
<!-- build, versión de runtime, licencia) procesables de inmediato por LLMs. -->
<!-- LÍMITES: Máximo 4 a 6 badges esenciales. Evitar insignias decorativas. -->
<!-- ======================================================================= -->

# [Nombre del Proyecto / Módulo]

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/usuario/repo/actions)
[![Python Version](https://img.shields.io/badge/python-3.10%20%7C%203.11%20%7C%203.12-blue.svg)](https://www.python.org/)
[![Type Checked: mypy](https://img.shields.io/badge/type--checking-mypy--strict-informational.svg)](https://mypy.readthedocs.io/)
[![Code Style: Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Agent Ready](https://img.shields.io/badge/agent--ready-v1.0-purple.svg)](AGENTS.md)

> **[Lema o propuesta de valor central en 1 sola frase clara y contundente].**

---

<!-- ======================================================================= -->
<!-- SECCIÓN 2: TABLA DE CONTENIDOS (INDEXACIÓN Y NAVEGACIÓN)                -->
<!-- BP RECOMENDADA: bp_0702_progressive_disclosure                          -->
<!-- Permite navegación por saltos semánticos. Un agente puede inspeccionar  -->
<!-- la tabla para extraer únicamente la sección requerida sin sobrecarga.   -->
<!-- ======================================================================= -->

## Tabla de Contenidos

- [Visión General](#visin-general)
- [Características Principales](#caractersticas-principales)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Inicio Rápido (Quickstart)](#inicio-rpido-quickstart)
  - [1. Clonar el repositorio](#1-clonar-el-repositorio)
  - [2. Configurar el entorno virtual](#2-configurar-el-entorno-virtual)
  - [3. Instalar dependencias](#3-instalar-dependencias)
  - [4. Variables de entorno](#4-variables-de-entorno)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Uso y Ejemplos](#uso-y-ejemplos)
  - [Ejecución por Línea de Comandos (CLI)](#ejecucin-por-lnea-de-comandos-cli)
  - [Integración en Código Python](#integracin-en-cdigo-python)
- [Arquitectura y Contratos de Agente](#arquitectura-y-contratos-de-agente)
- [Pruebas y Calidad de Código (DoD)](#pruebas-y-calidad-de-cdigo-dod)
- [Contribución](#contribucin)
- [Licencia](#licencia)

---

<!-- ======================================================================= -->
<!-- SECCIÓN 3: VISIÓN GENERAL Y RESUMEN EJECUTIVO                           -->
<!-- BP RECOMENDADA: bp_0607_facts_rules_and_procedures_separation           -->
<!-- Definir Hechos Ontológicos del dominio: qué problema resuelve, para     -->
<!-- quién está diseñado y por qué existe esta solución.                     -->
<!-- LÍMITES: 2 a 3 párrafos de alto nivel. NO incluir detalles de bajo      -->
<!-- nivel ni diagramas de secuencia internos (eso pertenece a ARCHITECTURE).-->
<!-- ======================================================================= -->

## Visión General

[Párrafo 1: Descripción del problema específico que aborda este repositorio, contexto de dominio y limitaciones de los enfoques existentes].

[Párrafo 2: Explicación de la solución propuesta por el sistema, componentes centrales y propuesta técnica diferenciadora].

[Párrafo 3: Audiencia objetivo, casos de uso principales e impacto esperado en el flujo de trabajo de desarrolladores o agentes de IA].

---

<!-- ======================================================================= -->
<!-- SECCIÓN 4: CARACTERÍSTICAS PRINCIPALES                                  -->
<!-- BP RECOMENDADA: bp_0913_concrete_examples_and_reference_implementations  -->
<!-- Enumerar capacidades técnicas comprobables y medibles con viñetas.     -->
<!-- LÍMITES: Lista de 4 a 6 características clave concisas.                 -->
<!-- ======================================================================= -->

## Características Principales

- ⚡ **[Capacidad 1 / Rendimiento]:** [Descripción concisa del atributo funcional o métrica técnica].
- 🤖 **Diseño Orientado a Agentes (*Agent-First*):** Contrato operativo explícito y permisos definidos en [AGENTS.md](AGENTS.md).
- 📐 **Arquitectura Modular & Tipado Estricto:** Código validado en modo estricto (`mypy --strict`) con contratos explícitos.
- 🛡️ **Validación Determinista:** Modelado de datos en fronteras de E/S con esquemas Pydantic v2 / Dataclasses inmutables.
- 📊 **Observabilidad & Trazabilidad:** Soporte de logging estructurado, telemetría y diagnósticos reproducibles.

---

<!-- ======================================================================= -->
<!-- SECCIÓN 5: REQUISITOS Y COMPATIBILIDAD                                  -->
<!-- BP RECOMENDADA: bp_0113_convention_over_configuration                   -->
<!-- Declarar explícitamente versiones de runtime, herramientas y OS para    -->
<!-- evitar errores de entorno durante la ejecución autónoma de agentes.     -->
<!-- ======================================================================= -->

## Requisitos del Sistema

- **Runtime de Ejecución:** Python `>= 3.10` (recomendado `3.11.x` o `3.12.x`).
- **Gestor de Paquetes:** `pip`, `uv` o `poetry` compatible con `pyproject.toml` (PEP 517/621).
- **Sistemas Operativos Compatibles:** Linux (Ubuntu 22.04+), macOS (Apple Silicon / Intel), Windows (PowerShell 7+ / WSL2).
- **Herramientas de Diagnóstico:** `pytest >= 8.0`, `ruff >= 0.3`, `mypy >= 1.9`.

---

<!-- ======================================================================= -->
<!-- SECCIÓN 6: INICIO RÁPIDO (QUICKSTART REPRODUCIBLE)                      -->
<!-- BP RECOMENDADA: bp_0601_documentation_as_code & bp_0603_runbooks        -->
<!-- Secuencia de pasos determinista, copiable y testeable en CI/CD.         -->
<!-- LÍMITES: Comandos directos sin bifurcaciones complejas. Si hay          -->
<!-- configuraciones avanzadas, mover a docs/SETUP.md.                       -->
<!-- ======================================================================= -->

## Inicio Rápido (Quickstart)

### 1. Clonar el repositorio
```bash
git clone https://github.com/usuario/nombre-repositorio.git
cd nombre-repositorio
```

### 2. Configurar el entorno virtual
```bash
python -m venv .venv

# En Linux/macOS:
source .venv/bin/activate

# En Windows (PowerShell):
.venv\Scripts\Activate.ps1
```

### 3. Instalar dependencias
```bash
pip install --upgrade pip
pip install -e ".[dev]"
```

### 4. Variables de entorno
Copiar la plantilla de configuración e ingresar las variables requeridas:
```bash
cp .env.example .env
```

---

<!-- ======================================================================= -->
<!-- SECCIÓN 7: ESTRUCTURA DEL REPOSITORIO (REPO MAP EN YAML)                -->
<!-- BP RECOMENDADA: bp_0902_information_architecture_and_repo_map           -->
<!-- Representar el árbol en formato YAML con responsabilidades de 1 línea   -->
<!-- por componente. PROHIBIDO el uso de árboles o hilos ASCII.             -->
<!-- ======================================================================= -->

## Estructura del Repositorio

```yaml
estructura_repositorio:
  README.md: "Punto de entrada principal, visión y quickstart del proyecto"
  AGENTS.md: "Contrato operativo, matriz de permisos y guardrails de IA"
  ARCHITECTURE.md: "Topología técnica profunda y diagramas de flujo Mermaid"
  CONTRIBUTING.md: "Normas de contribución, ciclo de PRs y convenciones de commits"
  LICENSE: "Licencia de código abierto (MIT / Apache-2.0)"
  pyproject.toml: "Configuración canónica del paquete, linters y dependencias"
  .env.example: "Plantilla de variables de entorno requeridas sin secretos"
  sandbox/: "Directorio exclusivo para pruebas throwaway y scripts temporales"
  src/:
    paquete_principal:
      __init__.py: "Exposición de la API pública del paquete"
      core/: "Lógica de negocio pura, entidades y modelos de dominio"
      services/: "Casos de uso, orquestación y flujos de aplicación"
      adapters/: "Conectores externos, clientes de API y persistencia"
  tests/:
    unit/: "Pruebas unitarias aisladas de ejecución rápida"
    integration/: "Pruebas de integración y contratos de frontera"
```

---

<!-- ======================================================================= -->
<!-- SECCIÓN 8: USO Y EJEMPLOS CONCRETOS                                     -->
<!-- BP RECOMENDADA: bp_0913_concrete_examples_and_reference_implementations  -->
<!-- Proporcionar ejemplos funcionales mínimos y auto-contenidos.            -->
<!-- LÍMITES: Ejemplos esenciales. Guías exhaustivas van en docs/EXAMPLES.md.-->
<!-- ======================================================================= -->

## Uso y Ejemplos

### Ejecución por Línea de Comandos (CLI)
```bash
# Ejecutar módulo con argumentos estándar
python -m paquete_principal.cli --input data/sample.json --output results/
```

### Integración en Código Python
```python
from paquete_principal.core import MotorPrincipal, ConfiguracionMotor

# 1. Inicializar configuración inmutable
config = ConfiguracionMotor(timeout_segundos=30, modo_estricto=True)

# 2. Instanciar servicio y procesar payload
motor = MotorPrincipal(config=config)
resultado = motor.ejecutar({"item_id": "item_123", "accion": "procesar"})

print(f"Resultado: {resultado}")
```

---

<!-- ======================================================================= -->
<!-- SECCIÓN 9: ARQUITECTURA Y CONTRATOS DE AGENTE                           -->
<!-- BP RECOMENDADA: bp_0702_progressive_disclosure & bp_0709_doc_as_interface-->
<!-- Enlazar hacia especificaciones profundas para evitar saturar el README. -->
<!-- ======================================================================= -->

## Arquitectura y Contratos de Agente

Para profundizar en el diseño del sistema y los protocolos de desarrollo autónomo:

- 🏛️ **Arquitectura del Sistema:** Consulta [ARCHITECTURE.md](ARCHITECTURE.md) para ver diagramas Mermaid de flujo y topología de capas.
- 🤖 **Contrato Operativo de IA:** Consulta [AGENTS.md](AGENTS.md) para revisar la jerarquía de instrucciones, permisos y políticas de fallo.
- 📋 **Guía de Estilo y Metadatos:** Consulta [`formato_minimo/frontmatter_yaml.md`](frontmatter_yaml.md) y [`formato_minimo/id_standards_guide.md`](id_standards_guide.md).

---

<!-- ======================================================================= -->
<!-- SECCIÓN 10: PRUEBAS Y CALIDAD DE CÓDIGO (DEFINITION OF DONE)            -->
<!-- BP RECOMENDADA: bp_0313_acceptance_criteria_and_definition_of_done       -->
<!-- Comandos directos de una sola línea para validar la suite en CI/local.  -->
<!-- ======================================================================= -->

## Pruebas y Calidad de Código (DoD)

Antes de realizar commits o proponer cambios, verificar que el proyecto pase todos los controles:

```bash
# 1. Ejecutar suite de pruebas unitarias
pytest tests/unit/ -vv -s

# 2. Verificación estricta de tipos estáticos
mypy --strict src/

# 3. Linter y análisis estático rápido
ruff check src/ tests/

# 4. Verificación de formato de código
ruff format --check src/ tests/
```

---

<!-- ======================================================================= -->
<!-- SECCIÓN 11: CONTRIBUCIÓN Y GOBERNANZA                                   -->
<!-- ======================================================================= -->

## Contribución

Agradecemos las contribuciones al proyecto. Por favor, consulta [CONTRIBUTING.md](CONTRIBUTING.md) para conocer las pautas sobre ramas, mensajes de commit convencionales (`feat:`, `fix:`) y el proceso de revisión de Pull Requests.

---

<!-- ======================================================================= -->
<!-- SECCIÓN 12: LICENCIA                                                    -->
<!-- ======================================================================= -->

## Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para conocer los términos legales y de distribución.

---

<!-- ======================================================================= -->
<!-- GUÍA DE LÍMITES Y FRONTERAS OPERATIVAS DEL README.md                    -->
<!-- ======================================================================= -->

## Guía de Límites y Fronteras Operativas del README.md

Para mantener el archivo README.md con alta densidad de señal y evitar que se convierta en un volcado excesivo de tokens (*Context Rot*), seguir la siguiente matriz de delimitación:

| **Contenido / Información** | **¿Debe estar en README.md?** | **Ubicación Correcta Designada** |
|:---|:---:|:---|
| Visión general, valor y lema del proyecto | ✅ **SÍ** | `README.md` (Secciones 1 y 3). |
| Pasos esenciales y reproducibles de Quickstart | ✅ **SÍ** | `README.md` (Sección 6). |
| Árbol de componentes de alto nivel (formato YAML) | ✅ **SÍ** | `README.md` (Sección 7). |
| Comandos de test y linter de una sola línea | ✅ **SÍ** | `README.md` (Sección 10). |
| Topología profunda de subsistemas y diagramas Mermaid extensos | ❌ **NO** | `ARCHITECTURE.md`. |
| Reglas de comportamiento de agentes, permisos y sandbox | ❌ **NO** | `AGENTS.md`. |
| Especificación detallada de endpoints de API o SDK | ❌ **NO** | `docs/API.md` o docstrings inline. |
| Valores reales de claves API, tokens o contraseñas | ❌ **NO (Prohibido)** | Cargar exclusivamente vía `.env`. |
| Bitácoras de sesión, diarios de trabajo o marcas temporales | ❌ **NO** | `PROGRESS.md` o `MEMORY.md`. |
| Procedimientos complejos de troubleshooting y runbooks de fallos | ❌ **NO** | `docs/RUNBOOKS.md` o `DEBUGGING.md`. |
