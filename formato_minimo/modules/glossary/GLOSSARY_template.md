---
id: tmpl_7ydsz3m2axg4p33mtscktztagf
name: glossary_template
title: "Plantilla de Glosario Ontológico y Anclaje Semántico de Dominio"
file_path: modules/glossary/GLOSSARY_template.md
version: 2.0.0
category: templates
tags: [glossary, domain, ubiquitous-language, ddd, ontology, semantic-anchoring, invariants]
description: "Plantilla de glosario focalizada en la desambiguación semántica, entidades de dominio propias e invariantes del proyecto."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-29T21:00:00Z
updated_at: 2026-08-29T21:00:00Z
schema_version: 1.0.0
---

# Glosario Ontológico y Lenguaje Ubicuo (GLOSSARY.md)

Este documento constituye el **anclaje semántico y diccionario de lenguaje ubicuo** del proyecto. Su objetivo exclusivo es prevenir la deriva conceptual y alucinaciones de modelos de lenguaje sobre términos propios del negocio.

> [!NOTE]
> **Criterio de Inclusión:** Este glosario NO debe contener definiciones de términos genéricos de la industria (tales como *API, JSON, HTTP, REST o CRUD*). Contiene únicamente:
> 1. Entidades propias del dominio de este repositorio.
> 2. Conceptos con significado específico o polisémico dentro del proyecto.
> 3. Invariantes y límites operativos del negocio.

---

## 1. Entidades Propias del Dominio

| Entidad / Término | Definición Canónica en este Repositorio | Atributos Clave / Invariantes |
|:---|:---|:---|
| **[EntidadEjemplo]** | Representa la unidad fundamental de procesamiento en el sistema (ej. `Expediente`, `Tenant`, `Slot`, `SessionDevice`). | Debe poseer siempre un identificador único inmutable y estado válido. |
| **[TransaccionDominio]** | Operación atómica de negocio que muta el estado de una entidad tras validar precondiciones. | No puede ejecutarse si el balance o estado es incompatible. |

---

## 2. Términos Polisémicos y Desambiguación

| Término | Significado Común en la Industria | **Significado Estricto en este Repositorio** |
|:---|:---|:---|
| **`Session`** | Sesión web HTTP de navegador | Instancia activa de conexión agéntica en memoria con cuota de tokens asignada. |
| **`Profile`** | Perfil de usuario o cuenta | Manifiesto declarativo de composición arquitectónica de módulos. |
| **`Sandbox`** | Entorno virtual de pruebas | Directorio aislado con blast radius controlado para prototipado rápido. |

---

## 3. Invariantes del Negocio (Guardrails de Dominio)

Reglas inmutables del dominio que el agente de IA `MUST` respetar en toda implementación:

1. **Invariante de Identidad:** Toda entidad persistida debe generarse con un ID determinista e indexable (TypeID o UUIDv7).
2. **Invariante de Estado:** Ninguna entidad puede transicionar a un estado terminal sin pasar por la fase de validación de invariantes.
3. **Invariante de Aislamiento:** Los datos pertenecientes a un contexto o cliente no pueden compartirse ni filtrarse entre peticiones concurrentes.
