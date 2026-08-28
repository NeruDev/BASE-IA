---
id: bp_3z0q0emd3bbtqrt1db401qdmyp
name: 07_agent_discoverability
title: "Descubribilidad para Agentes (Agent Discoverability)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/07_agent_discoverability.md
version: 1.1.0
category: agentic
tags: [agent-discoverability, navigation, predictable-structure, index, information-architecture, universal_principles]
description: "Discoverability: estructuras predecibles e índices semánticos para navegación autónoma y veloz de agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 07 - Descubribilidad para Agentes (Agent Discoverability)

## 1. Definición y Fundamento Teórico

Originada en los principios de la **Arquitectura de Información** y en el diseño de **Sistemas Autodescriptivos**, la **Descubribilidad para Agentes (Agent Discoverability)** establece:

> *"La organización de directorios, la nomenclatura de archivos y los índices de documentación de un repositorio deben diseñarse de manera predecible, semántica y estructurada, permitiendo que un agente de IA localice cualquier módulo, interfaz, contrato o prueba asociada en segundos sin necesidad de realizar búsquedas aleatorias o recursivas ciegas."*

Los tres pilares de la descubribilidad para agentes son:
1. **Estructura Espejo 1:1 (*Mirror Structure*):** Cada archivo en `src/dominio/archivo.py` tiene su archivo de prueba exacto en `tests/unit/dominio/test_archivo.py`.
2. **Índice Semántico Maestro (`docs/INDEX.md`):** Mapa tabular que relaciona dominios de negocio con sus rutas de código correspondientes.
3. **Nomenclatura Explícita y Canónica:** Nombres que comunican inequívocamente la responsabilidad del módulo (prohibiendo nombres genéricos como `utils.py` o `helpers.py`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Búsquedas Ciegas:** Evita que el agente ejecute 8 llamadas consecutivas a `list_dir` o `find_by_name` para encontrar dónde está definida una clase.
- **Localización Inmediata de Tests:** El agente sabe exactamente dónde crear o modificar la prueba unitaria sin tener que explorar toda la carpeta `tests/`.
- **Aceleración del Razonamiento Agéntico:** Permite al agente saltar directamente al archivo objetivo en el primer turno de ejecución.

## 3. Relevancia en Sistemas con IA Agéntica

- **Ahorro de Tool Calls y Tokens:** Cada llamada a una herramienta de exploración consume tiempo y tokens. La descubribilidad predecible reduce a cero las búsquedas exploratorias.
- **Autonomía en Tareas Desatendidas:** Permite a agentes que corren en pipelines de CI ubicarse de forma instantánea en cualquier repositorio nuevo.
- **Facilidad de Integración para Subagentes:** Subagentes especializados pueden recibir rutas directas inferidas sin margen de error.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Desorganización y Nombres Opacos)

```text
# Antipatrón: Estructura caótica e impredecible
src/
├── utils_final2.py       # ¿Qué contiene? Imposible de deducir
├── stuff.py              # Nombre inexpresivo
└── logic/
    └── code.py
tests/
└── test_everything.py    # Un solo archivo gigante con 200 tests desordenados
# RESULTADO: El agente de IA pierde 4 turnos buscando dónde implementar un nuevo endpoint.
```

### ✅ Estructura Correcta (Conforme a Descubribilidad: Espejo 1:1 + Índice Semántico)

Estructura del proyecto:
```text
repo/
├── docs/
│   └── INDEX.md                            # Índice maestro de descubrimiento
├── src/
│   └── billing/
│       ├── __init__.py
│       ├── models.py                       # Entidades y esquemas de datos
│       └── tax_calculator.py               # Lógica de cálculo impositivo
└── tests/
    └── unit/
        └── billing/
            ├── test_models.py              # Espejo exacto de src/billing/models.py
            └── test_tax_calculator.py      # Espejo exacto de src/billing/tax_calculator.py
```

Índice Maestro (`docs/INDEX.md`):
```markdown
# Índice de Descubrimiento para Agentes (docs/INDEX.md)

| Dominio | Código Fuente (`src/`) | Pruebas Unitarias (`tests/`) | Responsabilidad |
| :--- | :--- | :--- | :--- |
| **Cálculo de Impuestos** | `src/billing/tax_calculator.py` | `tests/unit/billing/test_tax_calculator.py` | Reglas de IVA y retenciones |
| **Modelos de Factura** | `src/billing/models.py` | `tests/unit/billing/test_models.py` | Esquemas Pydantic inmutables |
| **Auth & Tokens** | `src/auth/tokens.py` | `tests/unit/auth/test_tokens.py` | Generación y validación JWT |
```

## 5. Descripción Didáctica de los Cambios

1. **Correspondencia Espejo 1:1:** Si el agente modifica `src/billing/tax_calculator.py`, sabe sin buscar que sus pruebas residen en `tests/unit/billing/test_tax_calculator.py`.
2. **Índice Tabular Directo:** `docs/INDEX.md` permite resolver la ruta en una sola lectura.
3. **Nombres Semánticos:** Se eliminaron nombres opacos (`stuff.py`, `utils.py`) en favor de identificadores de responsabilidad única.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Profundidad de Anidamiento Excesiva:** Crear carpetas de 6 niveles (`src/a/b/c/d/e/service.py`) genera fricción en la consola y paths excesivamente largos en Windows (`MAX_PATH`).
- **Mantenimiento del Índice en Repositorios Dinámicos:** Si el equipo crea archivos constantemente pero olvida actualizar `INDEX.md`, se genera desincronización; se recomienda un script de verificación en CI que valide que todo módulo en `src/` tenga entrada en `INDEX.md`.

## 7. Checklist de Verificación

- [ ] ¿Existe una estructura espejo 1:1 entre los archivos de `src/` y los de `tests/unit/`?
- [ ] ¿Existe un archivo `docs/INDEX.md` que mapea módulos de código con sus responsabilidades?
- [ ] ¿Se eliminaron nombres de archivo genéricos u opacos (`utils.py`, `helpers.py`, `misc.py`)?
- [ ] ¿Un agente de IA puede deducir la ruta de un test a partir de la ruta del archivo de producción sin realizar búsquedas?