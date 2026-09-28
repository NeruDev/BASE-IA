---
id: tmpl_7s43hp1drgp5y3nza90nkdnqam
name: readme_core
title: "Plantilla Estándar y Estructura Base de README.md"
file_path: core/README_core.md
version: 2.0.0
category: templates
tags: [readme, core, onboarding, progressive-disclosure, navigation, starter]
description: "Plantilla base de README.md para repositorios agénticos universales con divulgación progresiva y navegación indexada."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Nombre del Proyecto / Repositorio

> Resumen ejecutivo en una o dos líneas que defina con claridad la propuesta de valor y el propósito central del sistema.

---

## 1. Propósito y Visión General

Explicación concisa del problema que resuelve este proyecto, su público objetivo y sus objetivos técnicos principales.

- **Objetivo Primario:** Describir la meta fundamental.
- **Enfoque de Diseño:** Principios clave (simplicidad, seguridad, modularidad, rendimiento).

---

## 2. Inicio Rápido (Quickstart)

Guía determinista de tres pasos para poner en marcha el entorno local:

### 2.1 Requisitos Previos
- Especificar dependencias del entorno o herramientas base (ej. Python 3.11+, Node.js 20+, GCC/Clang, CMake, etc.).

### 2.2 Instalación
```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd <nombre-del-repositorio>

# 2. Configurar entorno y dependencias
<comando-de-instalacion>
```

### 2.3 Ejecución y Verificación
```bash
# 3. Ejecutar la aplicación o suite de pruebas
<comando-de-ejecucion-o-test>
```

---

## 3. Mapa de Navegación Documental (Progressive Disclosure)

Para minimizar el consumo de tokens y facilitar la navegación tanto a humanos como a agentes de IA:

| Documento | Rol Principal | Nivel de Detalle |
|:---|:---|:---:|
| [`AGENTS.md`](file:///AGENTS.md) | Constitución operativa, guardrails y directivas de ejecución. | Alta prioridad para Agentes |
| [`ARCHITECTURE.md`](file:///ARCHITECTURE.md) | Topología técnica, capas, flujo de datos y diagramas. | Técnico / Arquitectura |
| [`GLOSSARY.md`](file:///GLOSSARY.md) | Términos clave del dominio, entidades e invariantes. | Semántico / Dominio |
| [`repo_manifest.jsonc`](file:///repo_manifest.jsonc) | Manifiesto de composición declarativa del repositorio. | Declarativo / Máquina |

---

## 4. Estándares de Contribución y Calidad

1. **Contrato de Agentes:** Todo agente autónomo o asistente de código DEBE acatar las directivas de [`AGENTS.md`](file:///AGENTS.md).
2. **Control de Calidad:** Ningún cambio debe introducir advertencias de linters, vulnerabilidades de seguridad ni pruebas rotas.
3. **Commits Atómicos:** Usar mensajes de commit semánticos y cambios independientes y verificables.
