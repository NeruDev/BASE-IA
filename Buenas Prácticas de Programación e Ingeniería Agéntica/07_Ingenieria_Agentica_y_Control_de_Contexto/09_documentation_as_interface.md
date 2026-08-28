---
id: bp_01m1343cyvfk9sqz1c9k7fem8z
name: 09_documentation_as_interface
title: "Documentation as Interface: La Documentación como Plano de Control Ejecutable"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/09_documentation_as_interface.md
version: 1.0.0
category: agentic
tags: [documentation-as-interface, control-plane, agent-governance, executable-specs, deterministic-commands]
description: "Estudio del paradigma donde la documentación deja de ser texto pasivo y se convierte en una interfaz operativa activa y ejecutable para agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 09 - Documentation as Interface (La Documentación como Interfaz Operativa)

En la ingeniería de software tradicional, la documentación es un artefacto pasivo redactado para humanos. En el paradigma **Agentic Software Engineering**, la documentación es el **plano de control primario y la interfaz de usuario de los agentes de IA**.

---

## 1. De Prosa Pasiva a Contrato Operacional

```mermaid
flowchart LR
    subgraph Docs_Pasivas ["Documentación Tradicional (Pasiva)"]
        P1["Prosa narrativa ambigua"] --> P2["Incertidumbre en LLM"]
        P2 --> P3["❌ Acciones impredecibles y desalineación"]
    end

    subgraph Docs_Interfaz ["Documentation as Interface (Activa)"]
        I1["Comandos exactos + Invariantes"] --> I2["Contrato determinista"]
        I2 --> I3["✅ Invocación precisa y verificación automática"]
    end
```

---

## 2. Principios de Redacción de Documentación como Interfaz

1. **Directivas Imperativas y Unívocas:** En lugar de *"sería deseable que el desarrollador use ruff"*, escribir *"OBLIGATORIO: Ejecutar `ruff check --fix src/` antes de cada commit"*.
2. **Vinculación con Herramientas Ejecutables:** Todo procedimiento debe incluir el comando exacto de CLI y el código de salida esperado (`exit code 0`).
3. **Contratos de Entrada y Salida Explícitos:** Especificar esquemas JSON / Pydantic para los intercambios de datos entre subagentes.
