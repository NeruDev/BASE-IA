---
id: bp_6q2kz1t8n5a3xv71fnj5r620cg
name: 02_architecture_decision_records
title: "Registros de Decisiones de Arquitectura (ADRs)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/02_architecture_decision_records.md
version: 1.1.0
category: architecture
tags: [adr, architecture-decision-records, nygard, architectural-governance, memory, universal_principles]
description: "ADRs: preservación del contexto histórico y consecuencias de decisiones técnicas clave en docs/adr/."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 02 - Registros de Decisiones de Arquitectura (ADRs)

## 1. Definición y Fundamento Teórico

Introducidos formalmente por **Michael Nygard** en su ensayo *Documenting Architecture Decisions* (2011) y consolidados bajo el estándar **MADR (Markdown Architectural Decision Records)**, los **ADRs** son documentos de texto inmutables que establecen:

> *"Cada decisión arquitectónica significativa, no trivial o difícil de revertir debe quedar registrada en un documento breve y fechado, capturando el contexto de negocio, las alternativas descartadas, la justificación de la elección y las consecuencias positivas y negativas asociadas."*

La estructura estándar de un ADR comprende:
- **Título y Numeración:** `0003-adopcion-de-postgresql-con-pgvector.md`
- **Estado:** `Propuesto (Proposed)`, `Aceptado (Accepted)`, `Reemplazado (Superseded por ADR-XXX)`, `Deprecado (Deprecated)`.
- **Contexto:** El problema técnico o necesidad de negocio que motiva la decisión.
- **Decisión:** La solución técnica adoptada de forma explícita.
- **Consecuencias:** Beneficios obtenidos y compromisos asumidos (*trade-offs*).

## 2. Por Qué Existe y Problemas que Resuelve

- **Preservación de la Memoria Organizacional:** Evita debates circulares repetitivos (*"¿Por qué usamos FastAPI en lugar de Django?"*).
- **Comprensión del 'Por Qué' Detrás del Código:** Permite a nuevos ingenieros entender por qué se diseñó una solución atípica sin asumir que fue un error.
- **Evolución Ordenada de la Arquitectura:** Los ADRs nunca se editan retrospectivamente para falsear la historia; si una decisión cambia, se publica un nuevo ADR que *reemplaza* (*supersedes*) al anterior.

## 3. Relevancia en Sistemas con IA Agéntica

- **Protección contra Refactorizaciones Destructivas de LLMs:** Los agentes de IA tienden a "corregir" patrones deliberados si desconocen el contexto histórico (ej. intentar reemplazar un almacén relacional por NoSQL ignorando restricciones de cumplimiento normativo).
- **Fuente de Contexto Autoritativo para Agentes:** Al inyectar el catálogo de ADRs en el contexto del agente, el modelo respeta los estándares arquitectónicos consensuados por el equipo.
- **Generación Asistida de Decisiones:** Los agentes pueden colaborar con arquitectos redactando el borrador inicial de un ADR tras evaluar benchmarks de diferentes librerías.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Decisión Crítica en Chat Efímero Indocumentada)

```text
# Antipatrón: Decisión tomada en un canal de Slack privado en 2024
"Oigan, usemos SQLite para almacenar las sesiones de los agentes para salir rápido a producción."
# 2 años después: El equipo creció, el canal de Slack se archivó y nadie sabe por qué
# el sistema no escala a múltiples servidores. Un nuevo agente intenta reescribir todo a ciegas.
```

### ✅ Documento ADR Correcto (`docs/adr/0003-adopcion-de-postgresql-con-pgvector.md`)

```markdown
# 3. Adopción de PostgreSQL con pgvector para Memoria Semántica

Fecha: 2026-08-27
Estado: Aceptado

## Contexto
El sistema de agentes autónomos requiere almacenar y buscar embeddings vectoriales de 1536 dimensiones
para la recuperación de contexto semántico (RAG).
Se evaluaron tres alternativas:
1. Base de datos vectorial dedicada (Pinecone / Qdrant).
2. Base de datos relacional existente con extensión vectorial (PostgreSQL + pgvector).
3. Motor en memoria local (FAISS).

## Decisión
Adoptamos **PostgreSQL 16 con la extensión pgvector**.
- Permite almacenar los datos relacionales de usuarios, transacciones y embeddings en la misma base de datos.
- Soporta transacciones ACID unificadas (evita inconsistencias entre metadatos y vectores).
- Reduce la complejidad operativa al no requerir un cluster adicional en la nube.

## Consecuencias
### Positivas
- Simplificación de backups unificados y menor coste de infraestructura.
- Consultas híbridas SQL + Búsqueda por similitud coseno en una sola sentencia.

### Negativas / Compromisos Asumidos
- Rendimiento de indexación HNSW ligeramente inferior a motores dedicados en colecciones >50M vectores.
- Requiere monitorizar el consumo de memoria RAM del proceso PostgreSQL.
```

## 5. Descripción Didáctica de los Cambios

1. **Inmutabilidad y Contexto:** El ADR documenta formalmente las 3 alternativas evaluadas y las razones de negocio para descartar Pinecone y FAISS.
2. **Registro de Compromisos:** Queda explícito que se priorizó la consistencia ACID sobre el rendimiento ultra-extremo de indexación.
3. **Guía para Agentes y Humanos:** Cualquier agente de IA que lea este ADR comprenderá que no debe sugerir un cambio a Pinecone sin justificar un volumen superior a 50 millones de vectores.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Micro-decisiones Triviales (*ADR Overload*):** Escribir un ADR para elegir el nombre de una variable, instalar una librería de testing menor o cambiar el color de un botón genera burocracia innecesaria.
- **ADRs Obsoletos No Mantenidos:** Si una decisión cambia pero no se publica el ADR sucesor (`Superseded by ADR-008`), se genera confusión histórica.
- **Falta de Discusión Previa:** Un ADR no debe ser una imposición unilateral sin revisión previa por pares mediante Pull Request.

## 7. Checklist de Verificación

- [ ] ¿Las decisiones técnicas estructurales y de alto impacto están registradas en `docs/adr/`?
- [ ] ¿Cada ADR incluye la fecha, estado, contexto, alternativas consideradas y consecuencias?
- [ ] ¿Los ADRs modificados se marcan formalmente como `Superseded` en lugar de borrar el archivo original?
- [ ] ¿El catálogo de ADRs se encuentra en texto plano Markdown accesible para desarrolladores y agentes de IA?