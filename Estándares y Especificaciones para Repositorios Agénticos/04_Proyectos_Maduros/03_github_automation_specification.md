---
id: spec_3a94hkwberaje88z6nk39jk4dm
name: 03_github_automation_specification
title: "Especificación de Automatización de GitHub (.github/workflows, dependabot, templates)"
file_path: Estándares y Especificaciones para Repositorios Agénticos/04_Proyectos_Maduros/03_github_automation_specification.md
version: 1.0.0
category: templates
tags: [github-actions, ci-cd, dependabot, issue-templates, pr-templates, automation]
description: "Especificación de automatización de GitHub (Actions, dependabot, templates)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 03 - Especificación de Automatización de GitHub

## 1. Definición y Componentes de la Carpeta .github/

La carpeta .github/ centraliza los flujos de integración continua (CI), plantillas de interacción comunitaria y automatizaciones de mantenimiento de dependencias.

## 2. Componentes y Plantillas Estándar

### 2.1 Workflow de CI Principal (.github/workflows/ci.yml)

```yaml
name: CI Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-and-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - name: Install dependencies
        run: |
          pip install --upgrade pip
          pip install -e ".[dev,test]"
      - name: Run Linters
        run: |
          ruff check .
          black --check .
          mypy src/
      - name: Run Tests
        run: pytest --cov=src tests/
```

### 2.2 Actualización de Dependencias (.github/dependabot.yml)

```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

### 2.3 Plantilla de Pull Request (.github/PULL_REQUEST_TEMPLATE.md)

```markdown
## Descripción del Cambio

## Tipo de Cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Refactorización / Docs

## Checklist de Calidad
- [ ] Pruebas unitarias ejecutadas y aprobadas.
- [ ] Google Docstrings actualizados.
- [ ] Cero secretos o credenciales expuestas.
```