---
id: spec_7kas5hygmgb5tb0jsp5yxbs93q
name: 03_changelog_specification
title: "Especificación y Plantilla Maestra de CHANGELOG.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/02_Archivos_Recomendables/03_changelog_specification.md
version: 1.0.0
category: templates
tags: [changelog, keep-a-changelog, semver, release-notes, history]
description: "Especificación y plantilla de CHANGELOG.md (Keep a Changelog 1.1.0 y SemVer 2.0.0)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 03 - Especificación y Plantilla Maestra de CHANGELOG.md

## 1. Definición y Propósito del Archivo

### ¿Qué es CHANGELOG.md?

CHANGELOG.md es el registro histórico cronológico de cambios notables introducidos en cada versión del proyecto, organizado bajo el estándar *Keep a Changelog* y Versionado Semántico (SemVer).

### ¿Por qué existe y qué problemas resuelve?

- **Memoria Histórica para Agentes:** Permite a un agente de IA comprender qué características han cambiado recientemente, qué métodos están obsoletos (Deprecated) y qué bugs han sido corregidos.

- **Regla de Síntesis:** Evita que el agente registre cada renombre menor de variable y enfoca los registros en cambios de valor arquitectónico y funcional.

## 2. Plantilla Maestra Canónica de CHANGELOG.md

# Registro de Cambios (CHANGELOG.md)

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [Unreleased]

### Added

- Soporte para streaming de telemetría en tiempo real en `src/core/telemetry.py`.

### Changed

- Refactorización del orquestador de agentes para permitir ejecución paralela de subagentes.

### Fixed

- Corrección en el parseo de YAML frontmatter cuando contiene caracteres escapados.

---

## [1.0.0] - 2026-08-26

### Added

- Lanzamiento inicial del framework de repositorios agénticos.

- Módulos base de arquitectura hexagonal y validación de tipos Pydantic.

- Suite de especificaciones y contratos operativos para agentes de IA.