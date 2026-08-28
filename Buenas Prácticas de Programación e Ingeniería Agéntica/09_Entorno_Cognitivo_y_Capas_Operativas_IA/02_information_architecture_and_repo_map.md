---
id: bp_5n5yn1yfdpb62tst6nsckf5j81
name: 02_information_architecture_and_repo_map
title: "Arquitectura de Información y Mapa Semántico del Repositorio"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/02_information_architecture_and_repo_map.md
version: 1.1.0
category: architecture
tags: [information-architecture, repo-map, no-utils, domain-structure, discoverability, universal_principles]
description: "Information Architecture y REPO_MAP.md: mapa de navegación semántica y eliminación de carpetas cajón de sastre."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 02 - Arquitectura de Información y Mapa Semántico del Repositorio

## 1. Definición y Fundamento Teórico

Basada en los principios clásicos de la **Arquitectura de Información** (*Rosenfeld & Morville, 1998*) y en las taxonomías semánticas de software, esta práctica postula:

> *"La estructura de directorios y la nomenclatura de archivos del repositorio deben organizarse estrictamente en torno a dominios de negocio cohesivos y responsabilidades unívocas, erradicando los directorios 'cajón de sastre' (`utils/`, `misc/`, `common/`, `helpers/`) y proveyendo un mapa semántico centralizado (`docs/REPO_MAP.md`) que permita la navegación instantánea y sin fricción para humanos y agentes de IA."*

Un repositorio estructurado por dominios comunica su propósito arquitectónico a simple vista:

```text
 ❌ Antipatrón (Cajón de Sastre):            ✅ Arquitectura de Información por Dominio:
 src/                                        src/
 ├── utils/                                  ├── billing/ (Impuestos, facturación)
 │   ├── string_stuff.py                     ├── auth/    (Tokens JWT, permisos)
 │   ├── db_helper.py                        ├── catalog/ (Productos, categorías)
 │   └── misc_dates.py                       └── core/    (Configuración global inmutable)
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de los 'Basureros de Código' (`utils`):** Los directorios `utils/` acumulan cientos de funciones desordenadas con responsabilidades mezcladas y alto acoplamiento.
- **Navegación Intuitiva de Cero Búsqueda:** Desarrolladores y agentes saben exactamente en qué carpeta buscar un archivo sin necesidad de búsquedas recursivas.
- **Claridad de Dependencias:** Permite aplicar tests arquitectónicos para prohibir que un dominio importe indebidamente dependencias de otro.

## 3. Relevancia en Sistemas con IA Agéntica

- **Indexación Inmediata con `REPO_MAP.md`:** Proporciona al agente un mapa conceptual en formato tabular que se procesa en milisegundos (<100 tokens).
- **Prevención de Alucinaciones de Ubicación:** Impide que el agente cree un nuevo archivo `src/utils/my_helper.py` cuando la lógica pertenecía a `src/billing/tax.py`.
- **Alineación con Búsquedas Dirigidas:** Permite al modelo utilizar herramientas como `find_by_name` con filtros de directorio precisos.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Directorios 'Utils' Caóticos)

```text
src/
├── helpers/
│   ├── general.py          # Contiene: hashing de passwords, cálculo de IVA y formateo de fechas
│   └── misc.py             # Contiene: clientes HTTP, conexión SQLite y validadores de email
# RESULTADO: Cohesión nula, acoplamiento máximo y desorientación total para agentes de IA.
```

### ✅ Mapa Semántico Canónico (`docs/REPO_MAP.md`)

```markdown
# Mapa Semántico del Repositorio (docs/REPO_MAP.md)

Este documento es el mapa autoritativo de arquitectura de información del proyecto.

## 🗺️ Mapa de Dominios y Subsistemas

| Dominio / Módulo | Ruta de Código | Ruta de Tests | Responsabilidad Principal |
| :--- | :--- | :--- | :--- |
| **Facturación (Billing)** | `src/billing/` | `tests/unit/billing/` | Cálculo impositivo, recargos y emisión de facturas. |
| **Autenticación (Auth)** | `src/auth/` | `tests/unit/auth/` | Criptografía, hashing PBKDF2 y tokens JWT. |
| **Catálogo (Catalog)** | `src/catalog/` | `tests/unit/catalog/` | Gestión de productos, stock e inventario. |
| **Núcleo (Core)** | `src/core/` | `tests/unit/core/` | Configuración (`BaseSettings`), logging y telemetría. |

## 🚫 Reglas de Organización
1. **PROHIBIDO:** Crear carpetas llamadas `utils`, `helpers`, `misc` o `common`.
2. **REGLA DE UBICACIÓN:** Toda nueva función debe pertenecer a uno de los dominios existentes o motivar la creación de un nuevo dominio justificado.
```

## 5. Descripción Didáctica de los Cambios

1. **Eliminación de la Ambigüedad:** Cada módulo tiene una responsabilidad única y delimitada.
2. **Mapa Tabular Estandarizado:** `REPO_MAP.md` vincula código, tests y responsabilidades en una sola tabla de alta densidad.
3. **Regla de Prohibición Explícita:** Se prohíbe la creación de carpetas comodín que degraden la arquitectura.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobre-atomización (*Over-fragmentation*):** Crear 30 dominios con 1 solo archivo de 10 líneas cada uno genera sobrecarga de navegación; los dominios deben agrupar **unidades lógicas con tamaño sustancial**.

## 7. Checklist de Verificación

- [ ] ¿Se eliminaron del repositorio las carpetas `utils`, `helpers`, `misc` y `common`?
- [ ] ¿Existe un archivo `docs/REPO_MAP.md` que indexe todos los subsistemas y sus rutas?
- [ ] ¿Cada dominio de negocio cuenta con su carpeta de código y su carpeta espejo de tests?
- [ ] ¿El mapa semántico es conciso y está estructurado en formato tabular?