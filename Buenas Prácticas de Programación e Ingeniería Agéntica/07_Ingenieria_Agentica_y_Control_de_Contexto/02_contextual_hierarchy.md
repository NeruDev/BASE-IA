---
id: bp_7k20s66hdab0m8xee2cgfvkvn0
name: 02_contextual_hierarchy
title: "Jerarquía Contextual de Instrucciones"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/02_contextual_hierarchy.md
version: 1.1.0
category: agentic
tags: [contextual-hierarchy, scoping, cascading-rules, agents-md, modularity, universal_principles]
description: "Jerarquía Contextual: reglas globales en raíz y directivas locales especializadas por subdirectorio."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 02 - Jerarquía Contextual de Instrucciones

## 1. Definición y Fundamento Teórico

Basada en los principios de **Scoping Léxico** y **Cascada de Configuración Jerárquica** (similar a la resolución de directivas en Git o CSS), la **Jerarquía Contextual de Instrucciones** establece:

> *"Las directivas operativas para agentes de IA deben distribuirse en niveles jerárquicos de especificidad creciente, donde la raíz del repositorio define las reglas universales inmutables y los subdirectorios especializados añaden o refinan directivas locales, impidiendo la contaminación cruzada de contexto entre tecnologías distintas."*

La jerarquía canónica se divide en:
1. **Nivel 1 (Global / Raíz `AGENTS.md`):** Políticas organizacionales universales (Conventional Commits, ramas cortas, linters, seguridad y límites de PRs).
2. **Nivel 2 (Dominio / Directorio `src/<modulo>/AGENTS.md`):** Estándares del stack técnico local (ej. FastAPI + Pydantic en backend vs. React + Tailwind en frontend).
3. **Nivel 3 (Sesión / Tarea):** Instrucciones efímeras pasadas por el usuario o issue específico.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Contaminación Cruzada:** Evita que un agente que modifica componentes visuales de frontend aplique reglas de diseño de bases de datos relacionales.
- **Reducción de Reglas Contradictorias:** Centraliza lo común en la raíz y especializa lo particular en su propia carpeta.
- **Mantenimiento Descentralizado:** Los equipos especializados pueden actualizar las directivas de su dominio sin tocar el archivo de directivas globales del repositorio.

## 3. Relevancia en Sistemas con IA Agéntica

- **Enrutamiento Preciso de Subagentes:** Un subagente enfocado en Backend solo carga el `AGENTS.md` de la raíz y el de `src/api/`, ahorrando tokens y maximizando la adherencia a sus frameworks.
- **Sobreescritura Segura de Reglas Locales:** Permite relajar o endurecer directivas puntuales (ej. permitir librerías de mocks adicionales solo en `tests/`).
- **Coherencia en Monorepos:** Permite gobernar monorepos con múltiples lenguajes (Go, Python, TypeScript) bajo un único marco armonizado.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Archivo Único Monolítico Caótico)

```markdown
<!-- Antipatrón: AGENTS.md en raíz de 1,200 líneas con reglas mezcladas -->
# REGLAS DEL PROYECTO
- En Python usar siempre Type Hints y Mypy.
- En TypeScript usar interfaces y no types.
- En React usar React Hooks y nunca class components.
- En Docker no correr como root.
- En Backend usar async/await con SQLAlchemy 2.0.
- En el microservicio de Go usar structs y punteros explícitos.
<!-- ERROR: Cuando el agente edita un script de Python, el 70% de las instrucciones son ruido irrelevante -->
```

### ✅ Estructura Correcta (Conforme a Jerarquía Contextual: Cascada Modular)

Estructura de archivos:
```text
monorepo/
├── AGENTS.md                   # Nivel 1: Reglas Universales (Git, CI, Seguridad)
├── backend/
│   ├── AGENTS.md               # Nivel 2: Reglas de Python / FastAPI / SQLAlchemy
│   └── src/
└── frontend/
    ├── AGENTS.md               # Nivel 2: Reglas de TypeScript / React / Vitest
    └── src/
```

Directivas Globales (`monorepo/AGENTS.md`):
```markdown
# Directivas Universales del Monorepo

- **Control de Versiones:** Commits en formato Conventional Commits (`feat:`, `fix:`).
- **Seguridad:** Prohibido commitear tokens o secretos; usar siempre variables de entorno.
- **Tamaño de PRs:** Menos de 250 líneas modificadas por PR.
- **Verificación Local:** Todo cambio debe pasar su suite de validación antes de abrir PR.
```

Directivas de Backend (`monorepo/backend/AGENTS.md`):
```markdown
# Directivas de Backend (Python)

- **Framework:** FastAPI 0.115+ con Python 3.11+.
- **Tipado:** Tipado estricto verificado con `mypy --strict`.
- **Formateo:** Ejecutar `ruff check --fix` y `ruff format` tras cualquier edición.
- **Modelos:** Pydantic v2 para validación de schemas de entrada/salida.
```

## 5. Descripción Didáctica de los Cambios

1. **Desacoplamiento Tecnológico:** Las reglas de backend y frontend no interfieren entre sí.
2. **Carga Contextual Dirigida:** El agente de backend solo recibe las directivas universales y las específicas de Python.
3. **Escalabilidad del Repositorio:** Añadir un nuevo servicio (ej. `analytics/`) solo requiere crear su respectivo `analytics/AGENTS.md`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Jerarquías Hiper-Profundas (*Nesting Hell*):** Crear archivos de reglas en 5 niveles anidados (`src/a/b/c/d/AGENTS.md`) dificulta saber qué directiva prevalece; se recomienda un máximo de **2 niveles (Raíz y Dominio)**.
- **Proyectos Monolíticos Pequeños de un Solo Lenguaje:** Para un paquete simple de 5 archivos, un único `AGENTS.md` en la raíz es suficiente.

## 7. Checklist de Verificación

- [ ] ¿El archivo `AGENTS.md` de la raíz contiene exclusivamente reglas transversales (Git, CI, Seguridad)?
- [ ] ¿Los subsistemas con tecnologías distintas tienen su propio archivo de directivas local?
- [ ] ¿Las reglas locales refinan o especializan las globales sin contradecir las políticas de seguridad?
- [ ] ¿La jerarquía de contexto no supera los 2 niveles de profundidad para evitar confusiones de precedencia?