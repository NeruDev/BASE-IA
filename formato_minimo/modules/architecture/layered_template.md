---
id: tmpl_f9q7vr8rfjxrbz2hq861b6hzyz
name: layered_template
title: "Plantilla de Arquitectura en Capas Clásicas (N-Tier / Layered)"
file_path: modules/architecture/layered_template.md
version: 2.0.0
category: templates
tags: [architecture, layered, n-tier, web, fullstack, components, models, controllers]
description: "Patrón arquitectónico en capas tradicionales para aplicaciones web estándar, APIs monolíticas y clientes frontend."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Arquitectura en Capas Tradicionales (ARCHITECTURE.md)

Este documento define la **organización en capas, separación de responsabilidades y flujo de control** del sistema.

---

## 1. Topología del Sistema en Capas

El sistema se estructura en capas horizontales donde cada nivel consume únicamente los servicios del nivel inferior inmediato:

```mermaid
flowchart TD
    subgraph Capa_Presentacion ["1. Capa de Presentación / UI / Controladores"]
        UI["Componentes de Vista / Páginas / Routers"]
        Controllers["Controladores y Manejadores de Petición"]
    end

    subgraph Capa_Negocio ["2. Capa de Lógica de Negocio / Servicios"]
        Services["Servicios de Negocio / Validadores"]
        Models["Modelos de Dominio y Tipos"]
    end

    subgraph Capa_Datos ["3. Capa de Acceso a Datos / Persistencia"]
        Repositories["Repositorios / Clientes de API / ORM"]
        Storage[(Base de Datos / Storage Local / Cache)]
    end

    UI --> Controllers
    Controllers --> Services
    Services --> Models
    Services --> Repositories
    Repositories --> Storage
```

---

## 2. Delimitación de Capas y Responsabilidades

| **Capa** | **Directorio Físico** | **Responsabilidad** | **Reglas de Acceso** |
|:---|:---|:---|:---|
| **Presentación** | `src/presentation/` o `src/views/` | Renderizado visual, captura de eventos de usuario y enrutamiento. | Solo invoca servicios de la capa de negocio. `MUST_NOT` consultar BD directamente. |
| **Lógica de Negocio** | `src/services/` o `src/business/` | Reglas operativas, validaciones de datos y transformación. | Depende de modelos y repositorios de datos. |
| **Acceso a Datos** | `src/repositories/` o `src/data/` | Consultas a bases de datos, consumo de APIs externas y almacenamiento. | Provee abstracciones para que la capa de negocio no lidie con detalles de conexión. |

---

## 3. Manejo de Estado y Flujo Unidireccional

1. Los componentes de vista emiten acciones o eventos.
2. Los controladores validan los parámetros y delegan a la capa de servicios.
3. Los servicios ejecutan la lógica, mutan el estado y persisten mediante los repositorios.
4. La respuesta enriquecida retorna de forma determinista a la capa de presentación.
