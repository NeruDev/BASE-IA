---
id: spec_4jxrjatwh7bx9adn34fc5bsrnx
name: 02_architecture_specification
title: "Especificación y Plantilla Maestra de ARCHITECTURE.md"
file_path: Estándares y Especificaciones para Repositorios Agénticos/01_Archivos_Imprescindibles/02_architecture_specification.md
version: 1.0.0
category: architecture
tags: [architecture, mermaid, design, system-topology, state-management]
description: "Especificación y plantilla de ARCHITECTURE.md (topología hexagonal y diagramas Mermaid)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:00:00Z
schema_version: 1.0.0
---

# 02 - Especificación y Plantilla Maestra de ARCHITECTURE.md

Este documento define la estructura técnica, estándares de diagramación y plantilla canónica para el archivo ARCHITECTURE.md en repositorios preparados para agentes de IA.

## 1. Función de ARCHITECTURE.md para Agentes y Humanos

El archivo ARCHITECTURE.md provee la **representación mental de alto nivel** del sistema:

- **Para Humanos:** Facilita la comprensión de límites de módulos, flujos de datos y decisiones técnicas históricas.

- **Para Agentes de IA:** Provee las restricciones estructurales y delimitaciones de capas para evitar violaciones de arquitectura (ej. importar infraestructura en el dominio puro) y guiar la generación de código contextualmente correcto.

## 2. Principios de Diseño Arquitectónico

1.  **Arquitectura Hexagonal (Puertos y Adaptadores):**

    - **Domain Core:** Modelos puros de datos, reglas de negocio e invariantes. No depende de ningún framework ni I/O.

    - **Application / Service Layer:** Orquestación de casos de uso, coordinación de pipelines y contratos de servicios.

    - **Infrastructure / Adapters:** Implementaciones concretas de I/O (bases de datos, APIs de LLMs, sistema de archivos, clientes HTTP).

    - **Agent Interface:** Capa de abstracción donde los agentes interactúan mediante herramientas (tools) y llamadas a funciones estructuradas.

2.  **Inmutabilidad y Estado Explícito:** Las transiciones de estado deben ser deterministas y serializables en JSON/Pydantic.

3.  **Diagramas Autocontenidos:** Todo flujo crítico debe representarse en sintaxis nativa de **Mermaid.js** para permitir renderizado web y parsing textual directo por LLMs.

## 3. Plantilla Maestra Canónica de ARCHITECTURE.md

# Arquitectura del Sistema

Este documento describe la topología del sistema, las fronteras modulares, los modelos de datos, la gestión de estado y los flujos de interacción entre componentes y agentes de IA.

---

## 1. Topología del Sistema y Capas

El sistema sigue una Arquitectura Limpia/Hexagonal estructurada en cuatro capas concéntricas con regla de dependencia hacia el interior:

```mermaid
graph TD
    subgraph Capa_Externa ["Capa de Interfaz y Adaptadores (Infrastructure / I/O)"]
        CLI["CLI / Terminal"]
        API["REST / GraphQL API"]
        AgentRuntime["AI Agent Runtime / Tools"]
        DB[(Base de Datos / Storage)]
        LLM["Proveedores LLM (Gemini/OpenAI)"]
    end

    subgraph Capa_Aplicacion ["Capa de Aplicación (Use Cases & Workflows)"]
        Orquestador["Orquestador de Tareas"]
        PipelineService["Pipeline & Validation Service"]
        ContextManager["Context & Session Manager"]
    end

    subgraph Capa_Dominio ["Capa de Dominio Puro (Core Domain & Invariants)"]
        Entidades["Entidades y Value Objects"]
        ReglasNegocio["Políticas y Reglas de Negocio"]
        Schemas["Esquemas de Datos Pydantic"]
    end

    CLI --> Orquestador
    API --> Orquestador
    AgentRuntime --> Orquestador

    Orquestador --> PipelineService
    Orquestador --> ContextManager

    PipelineService --> Entidades
    PipelineService --> ReglasNegocio
    PipelineService --> Schemas

    PipelineService -.-> DB
    PipelineService -.-> LLM
```

## 2. Delimitación de Capas y Responsabilidades

| **Capa** | **Directorio** | **Responsabilidad** | **Restricciones de Dependencia** |
|:---|:---|:---|:---|
| **Dominio** | src/paquete/core/ | Lógica de negocio pura, entidades, validaciones semánticas. | **Cero dependencias externas.** Prohibido importar I/O, frameworks o APIs. |
| **Aplicación** | src/paquete/services/ | Orquestación de flujos de trabajo, casos de uso y pipelines. | Solo depende del Dominio e interfaces abstractas. |
| **Infraestructura** | src/paquete/adapters/ | Implementación de conectores externos, DBs, clientes HTTP y LLMs. | Implementa los puertos definidos en Aplicación/Dominio. |
| **Agentes e Interfaz** | src/paquete/agents/ | Definición de herramientas (tools), prompts estructurados y schemas. | Consume la capa de Aplicación a través de contratos tipados. |

## 3. Flujo de Ejecución y Secuencia de Datos

El siguiente diagrama de secuencia ilustra el flujo de una invocación de tarea agéntica con validación y manejo de estado:

```mermaid
sequenceDiagram
    autonumber
    actor Usuario as Usuario / Cliente
    participant Agent as AI Agent Controller
    participant Orch as Orquestador de Servicios
    participant Domain as Capa de Dominio
    participant Store as Persistencia / DB

    Usuario->>Agent: Envía solicitud / prompt
    Agent->>Orch: Valida y traduce a comando tipado
    activate Orch
    Orch->>Domain: Aplica reglas de negocio y validación de esquema
    alt Datos Inválidos
        Domain-->>Orch: Retorna ValidationError estructurado
        Orch-->>Agent: Retorna Error Payload con sugerencia
        Agent-->>Usuario: Solicita clarificación o reintenta con parámetros corregidos
    else Datos Válidos
        Domain-->>Orch: Retorna Entidad de Dominio Confirmada
        Orch->>Store: Persiste estado / ejecuta mutación
        Store-->>Orch: Confirmación de persistencia
        Orch-->>Agent: Retorna resultado tipado (Success Payload)
        deactivate Orch
        Agent-->>Usuario: Entrega respuesta contextualizada y verificada
    end
```

## 4. Gestión de Estado y Ciclo de Vida

El estado de ejecución de cualquier proceso o sesión agéntica se modela como una máquina de estados finita determinista:

```mermaid
stateDiagram-v2
    [*] --> PENDIENTE: Tarea recibida
    PENDIENTE --> EN_ANALISIS: Agente descompone instrucciones
    EN_ANALISIS --> VALIDANDO_CONTEXTO: Verificación de dependencias
    VALIDANDO_CONTEXTO --> BLOQUEADO_AMBIGUEDAD: Información faltante
    BLOQUEADO_AMBIGUEDAD --> EN_ANALISIS: Usuario provee clarificación
    VALIDANDO_CONTEXTO --> EJECUTANDO: Precondiciones cumplidas
    EJECUTANDO --> EN_VALIDACION: Ejecución de herramientas completada
    EN_VALIDACION --> COMPLETADO: Tests y verificaciones pasan
    EN_VALIDACION --> FALLIDO: Error no recuperable
    EN_VALIDACION --> EJECUTANDO: Reintento con fallback
    COMPLETADO --> [*]
    FALLIDO --> [*]
```

### Reglas de Invarianza de Estado:

1. **Transiciones Atómicas:** Ningún estado puede persistirse de forma parcial.
2. **Serialización Segura:** Todo snapshot de estado debe ser convertible a JSON sin pérdida de tipos.
3. **Auditoría:** Cada transición emite un evento de log estructurado con timestamp, transition_id y agent_id.

## 5. Registro de Decisiones de Arquitectura (ADR)

Las decisiones de diseño significativas se documentan bajo el formato **ADR** en docs/adr/.

### Plantilla de ADR:

```markdown
# ADR-001: [Título de la Decisión Arquitectónica]

- **Fecha:** YYYY-MM-DD
- **Estado:** [Propuesto | Aceptado | Reemplazado | Obsoleto]
- **Contexto:** [Descripción del problema o necesidad técnica].
- **Decisión:** [Solución elegida y justificación].
- **Consecuencias:**
  - Positivas: [Beneficios obtenidos].
  - Negativas / Trade-offs: [Costos o limitaciones asumidas].
```

## 6. Sincronización y Mantenimiento

- Cualquier cambio en la estructura de paquetes debe reflejarse en los diagramas Mermaid de este documento.

- Si se añaden nuevas herramientas para agentes, actualizar la capa Agent Interface y [AGENTS.md](AGENTS.md).

---

## 4. Reglas de Validación de Diagramas Mermaid para Agentes

Al generar o editar `ARCHITECTURE.md`:

1. Validar que la sintaxis de Mermaid sea compatible con el parser de GitHub (`graph TD`, `sequenceDiagram`, `stateDiagram-v2`).

2. No usar caracteres especiales o espacios sin comillas dobles en los identificadores de nodos.

3. Siempre incluir numeración automática en diagramas de secuencia (`autonumber`).