---
id: tmpl_wtwqhzgycesqt5kjdd27jrs7jh
name: sandbox_guide
title: "Guía de Sandboxing y Gestión de Blast Radius Controlado"
file_path: modules/sandbox/sandbox_guide.md
version: 2.0.0
category: guides
tags: [sandbox, blast-radius, isolation, safety, promotion-lifecycle, experimentation]
description: "Guía técnica para la gestión de entornos de experimentación con blast radius controlado y ciclo de vida de promoción a producción."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Guía de Sandboxing y Blast Radius Controlado (sandbox_guide.md)

Este documento define la **política de aislamiento, niveles de contención de riesgos y el ciclo de promoción de código** para experimentos y prototipos generados por humanos o agentes de IA.

---

## 1. Filosofía: Blast Radius Controlado

En lugar de asumir un aislamiento absoluto sin garantías de ejecución, el sistema implementa un modelo formal de **Blast Radius Controlado** graduado en 3 niveles de contención técnica y organizativa:

```mermaid
flowchart TD
    subgraph L1 ["Nivel 1: Aislamiento Organizativo (Default)"]
        A["Directorio sandbox/ en .gitignore"] --> B["src/ NUNCA importa desde sandbox/"]
    end

    subgraph L2 ["Nivel 2: Aislamiento en Control de Versiones (Intermedio)"]
        C["git worktree dedicado"] --> D["Rama efímera agent/scratch-*"]
    end

    subgraph L3 ["Nivel 3: Aislamiento de Entorno de Ejecución (Avanzado)"]
        E["Contenedor Docker efímero"] --> F["Subprocesos sin red + variables mockeadas"]
    end

    L1 -->|Escalamiento según riesgo| L2
    L2 -->|Escalamiento para código no confiable| L3
```

---

## 2. Los 3 Niveles de Aislamiento

1. **Nivel 1: Aislamiento Organizativo (Estándar para Prototipos Ligeros)**
   - El directorio `sandbox/` está excluido de Git mediante `.gitignore` (excepto su `README.md` y `.gitignore`).
   - `MUST_NOT`: Ningún módulo en `src/` o `tests/` puede importar código ubicado en `sandbox/`.
2. **Nivel 2: Aislamiento de Control de Versiones (Para Refactorizaciones Mayores)**
   - Uso de `git worktree` o ramas temporales (`agent/scratch-<id>`) para evitar ensuciar el árbol de trabajo principal.
   - Permite descartar o fusionar selectivamente los cambios experimentales.
3. **Nivel 3: Aislamiento de Entorno de Ejecución (Para Scripts No Confiables o Destructivos)**
   - Ejecución dentro de contenedores Docker efímeros sin privilegios (`--read-only`, `--network=none`).
   - Variables de entorno mockeadas para evitar conexión accidental a bases de datos de producción o consumo de créditos de APIs.

---

## 3. Protocolo de Promoción a Producción en 5 Pasos

Todo código originado en `sandbox/` que deba incorporarse a la base de código principal DEBE seguir este ciclo formal:

```mermaid
flowchart LR
    P1["1. Prototipar en sandbox/"] --> P2["2. Aislar & Tipar"]
    P2 --> P3["3. Mover a src/"]
    P3 --> P4["4. Crear Tests Unitarios"]
    P4 --> P5["5. Limpieza de sandbox/"]
```

1. **Paso 1 (Prototipado):** Desarrollar y verificar empíricamente la solución en `sandbox/`.
2. **Paso 2 (Aislamiento y Tipado):** Añadir anotaciones de tipo completas, docstrings y manejo de excepciones de dominio.
3. **Paso 3 (Migración a `src/`):** Mover el archivo o funciones al paquete canónico en `src/` respetando los límites de arquitectura.
4. **Paso 4 (Cobertura de Pruebas):** Escribir pruebas automatizadas en `tests/` que validen casos de éxito y de borde.
5. **Paso 5 (Limpieza):** Eliminar los archivos temporales de `sandbox/` para no dejar residuos.
