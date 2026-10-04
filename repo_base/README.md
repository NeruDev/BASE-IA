---
id: doc_01m44g0zphee3bmyg1n11yaf68
name: readme
title: "Repositorio base universal"
file_path: README.md
category: guides
tags: [readme, plantilla, inicio-rapido]
description: "Qué es esta plantilla, cómo instanciarla en un proyecto nuevo y qué pregunta responde cada documento."
status: active
updated_at: 2026-10-04T22:30:00Z
---

# Repositorio base universal

Plantilla agnóstica del lenguaje para proyectos de un único desarrollador asistido por agentes de IA. Aplica *Documentation-as-Code*: cada documento tiene una cabecera verificable, los enlaces se comprueban, las decisiones quedan registradas y todo se valida con un solo comando.

## Inicio rápido

Requisito: Git para Windows (aporta `sh`). Los linters son opcionales; su instalación está en [CONTRIBUTING.md](CONTRIBUTING.md).

1. Copiar la plantilla en la carpeta del proyecto e inicializar git: `git init -b main`.
2. Activar el hook pre-commit: `git config core.hooksPath .githooks` (o la tarea de VS Code *hooks: activar*).
3. Opcional: configurar las bases teóricas externas copiando `config/external-bases.example` a `config/external-bases.local` y completando la ruta, o definiendo la variable de entorno `EXTERNAL_BASES_DIR`. Las reglas de uso están en [AGENTS.md](AGENTS.md).
4. Ejecutar la autoevaluación: `sh scripts/check.sh` (o la tarea *check: completo*). Debe terminar con código 0.
5. Adaptar al proyecto: elegir licencia y añadir `LICENSE`, reescribir este README y registrar el stack elegido en un ADR nuevo.

## Mapa de documentación

| Documento | Pregunta que responde |
| --- | --- |
| [README.md](README.md) | ¿Qué es y cómo empiezo? |
| [AGENTS.md](AGENTS.md) | ¿Cómo debe trabajar un agente de IA aquí? Es la fuente única de reglas. |
| [ARCHITECTURE.md](ARCHITECTURE.md) | ¿Cómo está organizado el repositorio y cómo funciona la autoevaluación? |
| [CONTRIBUTING.md](CONTRIBUTING.md) | ¿Cómo hago un cambio, un documento nuevo o un ADR? |
| [docs/adr/](docs/adr/README.md) | ¿Por qué se decidió así? |
| [.github/instructions/](.github/instructions/) | Reglas por tipo de archivo para GitHub Copilot. |
| [CLAUDE.md](CLAUDE.md), [.github/copilot-instructions.md](.github/copilot-instructions.md) | Adaptadores que solo apuntan a AGENTS.md. |
