---
id: spec_01m133cfy1e5w95gfcj2dn5qsv
name: 12_gitmodules_specification
title: "Especificación y Gestión Segura de Submódulos Git (.gitmodules)"
file_path: Estándares y Especificaciones para Repositorios Agénticos/03_Segun_Complejidad/12_gitmodules_specification.md
version: 1.0.0
category: templates
tags: [gitmodules, submodules, multi-repo, git, dependencies, agent-safety]
description: "Especificación técnica para la gestión segura de submódulos Git en arquitecturas multi-repositorio y delimitación de guardrails para agentes autónomos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:00:00Z
updated_at: 2026-08-27T16:00:00Z
schema_version: 1.0.0
---

# 12 - Especificación y Gestión Segura de Submódulos Git (.gitmodules)

Este documento establece los estándares técnicos, el formato canónico y los guardrails de seguridad para el uso de **Submódulos Git (`.gitmodules`)** en repositorios operados por agentes de Inteligencia Artificial.

---

## 1. Casos de Uso Válidos y Riesgos de Corrupción por Agentes

Los submódulos Git permiten anidar repositorios externos (ej. esquemas compartidos, librerías comunes de dominio o SDKs de clientes) dentro de un repositorio principal.

### ⛔ Riesgos Críticos para Agentes de IA:
1. **Punteros Desacoplados (*Detached HEAD*):** Los agentes pueden realizar cambios locales dentro del submódulo sin haber creado una rama remota, perdiendo el trabajo al ejecutar un `git submodule update`.
2. **Commits Fantasma:** Confirmar un puntero SHA en el repositorio principal antes de que el commit exista en el remoto del submódulo, rompiendo los clones de CI/CD para el resto del equipo.
3. **Clonación Incompleta:** Fallos al ejecutar tests porque las carpetas de submódulos quedan vacías tras un clone superficial.

---

## 2. Guardrails Inviolables para Agentes Autónomos

1. ⛔ **Prohibido realizar commits directos dentro de directorios de submódulos** de forma autónoma a menos que la tarea esté explícitamente parametrizada para ello.
2. ✅ **Inicialización Obligatoria:** Todo script o pipeline de validación debe garantizar `git submodule update --init --recursive` antes de compilar o testear.
3. ✅ **URLs Relativas o HTTPS Estándar:** Las rutas remotas en `.gitmodules` deben ser URLs HTTPS públicas o rutas relativas del mismo servidor Git para evitar fallos de autenticación SSH en runners de CI.

---

## 3. Plantilla Canónica de `.gitmodules`

```ini
# =============================================================================
# DEFINICIÓN CANÓNICA DE SUBMÓDULOS DEL REPOSITORIO
# =============================================================================

[submodule "libs/shared-schemas"]
    path = libs/shared-schemas
    url = https://github.com/organizacion/shared-schemas.git
    branch = main
    shallow = true

[submodule "vendor/agentic-runtime"]
    path = vendor/agentic-runtime
    url = https://github.com/organizacion/agentic-runtime.git
    branch = release/v1
    shallow = true
```

---

## 4. Comandos Permitidos y Protocolo de Inicialización

```bash
# 1. Clonar repositorio incluyendo submódulos automáticamente
git clone --recurse-submodules https://github.com/org/repo.git

# 2. Inicializar submódulos en un repositorio ya clonado
git submodule update --init --recursive

# 3. Actualizar punteros de submódulos al último commit de su rama remota
git submodule update --remote --merge
```
