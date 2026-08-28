---
id: bp_01m13428crennafgsevdh4hjd0
name: 07_facts_rules_and_procedures_separation
title: "Separación Estricta de Hechos, Reglas y Procedimientos en la Documentación"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/07_facts_rules_and_procedures_separation.md
version: 1.0.0
category: standards
tags: [knowledge-management, cognitive-architecture, documentation-triad, facts-rules-procedures, disambiguation]
description: "Marco teórico y metodológico para categorizar toda la documentación técnica en tres dimensiones semánticas (Hechos, Reglas y Procedimientos), eliminando la ambigüedad en LLMs."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T16:30:00Z
updated_at: 2026-08-27T16:30:00Z
schema_version: 1.0.0
---

# 07 - Separación de Hechos, Reglas y Procedimientos

La ambigüedad en el razonamiento de los modelos de lenguaje ocurre con frecuencia cuando un documento mezcla simultáneamente descripciones de la arquitectura, restricciones de seguridad y comandos de ejecución. La **Tríada Cognitiva** clasifica la información en tres dimensiones epistemológicas puras.

---

## 1. La Tríada Cognitiva de la Documentación

```mermaid
graph TD
    subgraph Triada_Cognitiva ["Clasificación Epistemológica de la Documentación"]
        H["A. HECHOS (Ontología)<br/>¿Cómo está construido el sistema?<br/>• ARCHITECTURE.md<br/>• DOMAIN.md<br/>• TECH_STACK.md"]
        R["B. REGLAS (Restricciones)<br/>¿Qué está estrictamente prohibido?<br/>• AGENTS.md<br/>• SECURITY.md<br/>• STYLE_GUIDE.md"]
        P["C. PROCEDIMIENTOS (Algoritmos)<br/>¿Cómo se ejecuta paso a paso?<br/>• DEVELOPMENT.md<br/>• TESTING.md<br/>• TROUBLESHOOTING.md"]
    end
```

---

## 2. Matriz de Clasificación de Documentos

| **Dimensión** | **Naturaleza Semántica** | **Archivos Canónicos** | **Efecto en el Razonamiento del Agente** |
|:---|:---|:---|:---|
| **Hechos** | Descriptivo / Estático | `ARCHITECTURE.md`, `DOMAIN.md` | Proporciona el mapa mental del sistema y sus entidades. |
| **Reglas** | Normativo / Invariante | `AGENTS.md`, `SECURITY.md` | Actúa como guardrail inviolable que frena acciones no autorizadas. |
| **Procedimientos** | Prescriptivo / Dinámico | `DEVELOPMENT.md`, `TESTING.md` | Proporciona la secuencia algorítmica de comandos a ejecutar. |
