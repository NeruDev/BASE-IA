---
id: bp_7rx5w5ydn3bcgb1vy5dtc8145w
name: 15_protected_files_and_boundaries
title: "Archivos Protegidos y Fronteras de Código Generado"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/15_protected_files_and_boundaries.md
version: 1.1.0
category: agentic
tags: [protected-files, generated-code, protobuf, openapi-generator, immutability, universal_principles]
description: "Archivos Protegidos y Código Generado: marcado estricto de solo lectura para evitar ediciones efímeras."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 15 - Archivos Protegidos y Fronteras de Código Generado

## 1. Definición y Fundamento Teórico

Basada en los principios de diseño de **Compiladores y Generadores de Código (Protobuf, gRPC, OpenAPI Generator, Prisma)**, esta práctica establece:

> *"El repositorio debe delimitar con absoluta claridad la frontera entre el código fuente editable manualmente y los artefactos generados automáticamente por herramientas o compiladores, protegiendo estos últimos bajo marcas explícitas de solo lectura (`# CODE GENERATED - DO NOT EDIT`) y guiando a los agentes de IA a modificar el archivo fuente primario (*Single Source of Truth*) en lugar del artefacto compilado."*

Cualquier edición manual sobre un archivo generado se considera efímera y un error de diseño, ya que será destruida en la siguiente ejecución del generador.

```text
 [Archivo Fuente Primario: schema.proto] ──(Compilador: protoc)──► [Código Generado: user_pb2.py]
                   ▲                                                               ▲
                   │ (EDITABLE POR AGENTE)                                         │ (SOLO LECTURA)
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Pérdida Silenciosa de Cambios:** Evita que horas de trabajo de un agente desaparezcan la próxima vez que el CI ejecute el comando de generación de código.
- **Mantenimiento de la Fuente Canónica:** Asegura que los esquemas `.proto`, `.yaml` o `.graphql` permanezcan como la única verdad autoritativa.
- **Claridad para Herramientas de IA:** Indica al LLM exactamente qué comando de compilación debe ejecutar tras modificar la definición base.

## 3. Relevancia en Sistemas con IA Agéntica

- **Direccionamiento Correcto de Modificaciones:** Los agentes suelen buscar el archivo donde está la clase en Python (`user_pb2.py`) e intentar editarlo. La protección de frontera redirige al agente a `schemas/user.proto`.
- **Automatización de Regeneración:** Documentar el comando de generación (`buf generate` / `uv run alembic revision --autogenerate`) permite al agente compilar los artefactos de forma autónoma.
- **Reducción de Diffs Basura:** Evita que el agente comitee modificaciones menores manuales que luego divergen de la salida oficial del compilador.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: El Agente Edita el Archivo Generado Directamente)

```python
# Archivo: src/generated/billing_pb2.py
# ANTIPATRÓN: El agente edita manualmente este archivo para agregar el campo 'tax_id':
class Invoice(object):
    def __init__(self):
        self.tax_id = "" # MODIFICACIÓN MANUAL PELIGROSA
# CONSECUENCIA: En el pipeline de CI se ejecuta 'protoc billing.proto',
# sobrescribiendo billing_pb2.py y borrando la modificación del agente.
```

### ✅ Flujo Correcto (Conforme a Fronteras de Código Generado)

Encabezado de Protección en Archivo Generado (`src/generated/billing_pb2.py`):
```python
# ----------------------------------------------------------------------------------
# 🛑 ARCHIVO GENERADO AUTOMÁTICAMENTE - PROHIBIDO EDITAR MANUALMENTE
# Fuente Canónica: schemas/billing.proto
# Comando de Regeneración: uv run python -m grpc_tools.protoc -I schemas/ ...
# ----------------------------------------------------------------------------------
```

Directiva en `AGENTS.md`:
```markdown
## ⚙️ Código Generado y Compilado
- **PROHIBIDO EDITAR DIRECTAMENTE:** La carpeta `src/generated/*` contiene código generado.
- **FLUJO OBLIGATORIO:**
  1. Modificar la definición de esquema en `schemas/<dominio>.proto`.
  2. Ejecutar la compilación determinista:
     ```bash
     uv run python scripts/generate_protos.py
     ```
  3. Ejecutar la validación completa.
```

## 5. Descripción Didáctica de los Cambios

1. **Encabezado Desalentador:** El archivo generado contiene una advertencia en mayúsculas visible para el agente en el primer token que lee.
2. **Instrucción de Redirección:** Se documenta la ruta del archivo fuente primario y el comando exacto para compilarlo.
3. **Flujo Causal Correcto:** El agente modifica la fuente `.proto` y ejecuta el script de compilación para actualizar el artefacto de forma reproducible.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Repositorios Sin Generadores de Código:** En proyectos que no utilizan Protobuf, GraphQL Code Generator ni generadores de clientes OpenAPI, esta regla no añade restricciones.

## 7. Checklist de Verificación

- [ ] ¿Los directorios y archivos de código generado están claramente identificados (`src/generated/`)?
- [ ] ¿Los archivos generados incluyen encabezados explícitos advirtiendo que no deben editarse a mano?
- [ ] ¿`AGENTS.md` documenta el script canónico para regenerar los artefactos a partir de los esquemas fuente?
- [ ] ¿El pipeline de CI valida que los archivos generados comiteados coincidan exactamente con la compilación limpia del esquema?