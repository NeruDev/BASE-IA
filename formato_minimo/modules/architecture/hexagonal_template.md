---
id: tmpl_b2zh2rpzshnqdgxhqyhj3ygrv6
name: hexagonal_template
title: "Plantilla de Arquitectura Hexagonal (Puertos y Adaptadores)"
file_path: modules/architecture/hexagonal_template.md
version: 2.0.0
category: templates
tags: [architecture, hexagonal, ports-and-adapters, ddd, domain, services, adapters, mermaid]
description: "Patrón arquitectónico de Puertos y Adaptadores para servicios backend, APIs y microservicios con aislamiento estricto de dominio."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Arquitectura Hexagonal: Puertos y Adaptadores (ARCHITECTURE.md)

Este documento define la **topología técnica, límites de capas, puertos, adaptadores e invariantes de dependencia** para este repositorio.

---

## 1. Topología del Sistema y Capas Concéntricas

El sistema implementa una **Arquitectura Hexagonal (Puertos y Adaptadores)** desacoplada en cuatro capas concéntricas con regla de dependencia unidireccional estricta hacia el núcleo:

```mermaid
graph TD
    subgraph Capa_Externa ["1. Capa de Infraestructura & Adaptadores (I/O, Drivers, APIs)"]
        CLI["CLI / Terminal"]
        API["API REST / GraphQL / Webhooks"]
        AgentRuntime["AI Agent Controller / MCP Tools"]
        DB[(Persistencia / DB / Cache)]
        LLM["Proveedores LLM / Clientes Externos"]
    end

    subgraph Capa_Aplicacion ["2. Capa de Aplicación (Servicios, Casos de Uso & Orquestación)"]
        Orquestador["Orquestador de Tareas"]
        PipelineService["Application Services"]
        ContextManager["Session & State Manager"]
    end

    subgraph Capa_Dominio ["3. Capa de Dominio Puro (Core Domain, Entidades & Reglas)"]
        Entidades["Entidades y Value Objects"]
        ReglasNegocio["Políticas y Reglas de Negocio"]
        Contratos["Puertos e Interfaces Abstractas"]
    end

    CLI --> Orquestador
    API --> Orquestador
    AgentRuntime --> Orquestador

    Orquestador --> PipelineService
    Orquestador --> ContextManager

    PipelineService --> Entidades
    PipelineService --> ReglasNegocio
    PipelineService --> Contratos

    PipelineService -.-> DB
    PipelineService -.-> LLM
```

> [!IMPORTANT]
> **Regla de Dependencia Unidireccional (`MUST_NOT`):** La capa de Dominio (`core/` o `domain/`) NUNCA debe importar librerías de infraestructura, frameworks web, clientes de bases de datos o servicios externos de E/S. Las dependencias externas se invierten mediante interfaces abstractas (Puertos).

---

## 2. Delimitación de Capas y Responsabilidades

| **Capa Arquitectónica** | **Directorio Físico Sugerido** | **Responsabilidad Principal** | **Reglas de Dependencia e Importación** |
|:---|:---|:---|:---|
| **Dominio Puro (*Core/Domain*)** | `src/<paquete>/core/` o `src/<paquete>/domain/` | Entidades puras, Value Objects, reglas de negocio e interfaces de puertos. | `MUST_NOT` importar frameworks, DBs, requests, o librerías de E/S. |
| **Aplicación (*Services/Use Cases*)** | `src/<paquete>/services/` o `src/<paquete>/application/` | Casos de uso, orquestación de flujos, transacciones y coordinación. | Solo depende de `core/` y de interfaces/puertos abstractos. |
| **Infraestructura (*Adapters/Infra*)** | `src/<paquete>/adapters/` o `src/<paquete>/infra/` | Implementación concreta de puertos: clientes de DB, APIs externas, filesystem, LLMs. | Implementa interfaces de `core/`. No contiene reglas de negocio. |
| **Puntos de Entrada (*Entrypoints/Agents*)** | `src/<paquete>/entrypoints/` o `src/<paquete>/api/` | Routers HTTP, controladores CLI, herramientas MCP y consumidores de eventos. | Consume `services/` mediante DTOs tipados. Prohibido saltar directo a DB. |

---

## 3. Máquina de Estados y Ciclo de Vida del Dominio

Para entidades con ciclos de vida complejos, modelar las transiciones mediante máquinas de estado finito (FSM):

```mermaid
stateDiagram-v2
    [*] --> Creado : Inicializar
    Creado --> EnProceso : Iniciar Tarea
    EnProceso --> EnRevision : Completar Tarea
    EnRevision --> Aprobado : Validar Criterios
    EnRevision --> EnProceso : Rechazar con Observaciones
    Aprobado --> [*] : Archivar
```

---

## 4. Registro de Decisiones de Arquitectura (ADR)

Toda modificación estructural significativa debe formalizarse mediante un registro de decisión en `docs/adr/`.
Consulte [`docs/adr/index.md`](file:///docs/adr/index.md) para el catálogo de decisiones históricas.
