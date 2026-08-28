---
id: bp_3jgvyd94s5aaf8f09bdd31gt6v
name: 11_defensive_programming
title: "Programación Defensiva"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/11_defensive_programming.md
version: 1.1.0
category: universal_principles
tags: [defensive-programming, validation, pydantic, security, boundary, universal_principles]
description: "Programación defensiva: validación estricta de esquemas de datos externos con Pydantic."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 11 - Programación Defensiva

## 1. Definición y Fundamento Teórico

La **Programación Defensiva** es una disciplina de diseño de software derivada de la ingeniería de confiabilidad y seguridad que establece:

> *"El software debe anticipar proactivamente condiciones anómalas, entradas malformadas y fallos de servicios externos, verificando de forma estricta todos los datos en las fronteras del sistema para evitar que contaminen el núcleo operativo."*

Se basa en el principio de **cero confianza en las fronteras (*Zero Trust Boundaries*)**: ningún dato proveniente de un usuario humano, una API de terceros, una base de datos externa o un modelo de lenguaje debe asumirse correcto o seguro sin previa validación y coerción de esquema.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Vulnerabilidades de Seguridad:** Mitiga riesgos de inyección (SQL, Prompt Injection, XSS) y corrupción de memoria o estados.
- **Resiliencia ante Cambios en APIs Externas:** Protege la aplicación frente a roturas de contrato o campos eliminados inesperadamente por proveedores externos.
- **Conversión de Datos No Confiables en Modelos Fuertes:** Transforma cadenas de texto o payloads no tipados en objetos inmutables y tipados con garantías de validez.

## 3. Relevancia en Sistemas con IA Agéntica

- **Contención del No-Determinismo de los LLMs:** Las respuestas generadas por modelos de lenguaje (JSON outputs, argumentos de tool calling) son probabilísticas y pueden omitir campos obligatorios, alterar formatos de fecha o mezclar tipos (ej. retornar `"100"` como string en vez de número).
- **Validación Automática de Esquemas con Pydantic:** La programación defensiva es el cortafuegos que valida y coerciona la salida de los agentes antes de ejecutar operaciones en bases de datos o servicios de pago.
- **Prevención de Inyecciones Indirectas de Prompt:** Sanitiza y valida las entradas procesadas por agentes autónomos desde fuentes web no confiables.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Confianza Ciega en Payloads Externos/LLM)

```python
# Antipatrón: Asume que el JSON generado por el LLM o API externa siempre es perfecto
import json

def procesar_respuesta_agente(raw_json: str) -> dict:
    data = json.loads(raw_json)
    
    # CRASH POTENCIAL: KeyError si 'user' o 'actions' no existen
    # ERROR DE TIPO: Si 'user_id' es un string en lugar de int
    # SEGURIDAD: Sin validación de rango ni límites de longitud
    user_id = data["user"]["id"]
    accion_principal = data["actions"][0]["type"]
    puntuacion = data["score"] * 100  # TypeError si score es None o string

    return {"user_id": user_id, "action": accion_principal, "score": puntuacion}
```

### ✅ Código Correcto (Conforme a Programación Defensiva: Validación Estricta con Pydantic)

```python
# src/schemas/agent_payload.py
from pydantic import BaseModel, Field, ValidationError, field_validator
from typing import Literal

class AgentAction(BaseModel):
    type: Literal["SEND_EMAIL", "GENERATE_REPORT", "UPDATE_RECORD"]
    priority: int = Field(ge=1, le=5, default=3)

class AgentResponseSchema(BaseModel):
    user_id: int = Field(gt=0, description="Identificador único positivo del usuario.")
    actions: list[AgentAction] = Field(min_length=1, description="Debe contener al menos una acción.")
    score: float = Field(ge=0.0, le=1.0, description="Puntuación normalizada entre 0.0 y 1.0.")

def procesar_respuesta_agente_defensiva(raw_json: str) -> AgentResponseSchema:
    """Parsea y valida estrictamente el JSON generado por un agente de IA.

    Args:
        raw_json: Cadena con el payload JSON a validar.

    Returns:
        Instancia validada y fuertemente tipada de AgentResponseSchema.

    Raises:
        ValueError: Si el JSON es inválido o no cumple con el esquema requerido.
    """
    try:
        return AgentResponseSchema.model_validate_json(raw_json)
    except ValidationError as exc:
        # Falla defensiva reportando con precisión qué campo violó el contrato
        raise ValueError(f"Payload de agente no conforme con el esquema: {exc.errors()}") from exc
```

## 5. Descripción Didáctica de los Cambios

1. **Esquema Autoritativo con Pydantic:** Se modeló la estructura esperada definiendo tipos, rangos numéricos (`ge=0.0, le=1.0`), valores permitidos (`Literal`) y longitudes mínimas.
2. **Coerción y Validación Automática:** `model_validate_json` verifica simultáneamente la sintaxis JSON y el cumplimiento de las restricciones semánticas.
3. **Manejo Seguro de Excepciones:** Se captura `ValidationError` y se traduce en una excepción controlada con detalles precisos de las violaciones de contrato.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobre-defensa en el Núcleo Interno (*Trust Zone*):** Validar defensivamente con Pydantic o múltiples `if` dentro de funciones privadas de bajo nivel donde todos los llamadores son de confianza degrada el rendimiento e infla el código innecesariamente. La regla es: **Sé defensivo en las fronteras (I/O, APIs, LLMs) y asertivo en el núcleo interno**.
- **Ocultamiento de Fallos con Fallbacks Excesivos:** Devolver valores por defecto "mágicos" ante datos malformados puede enmascarar errores de integración graves en lugar de corregir la causa raíz.
- **Sobrecarga de CPU en Procesamiento de Streams de Alta Frecuencia:** En pipelines de telemetría de millones de eventos por segundo, la validación exhaustiva de cada campo debe balancearse mediante muestreo o esquemas binarios eficientes (Protobuf/Avro).

## 7. Checklist de Verificación

- [ ] ¿Todas las entradas provenientes de APIs externas, LLMs, formularios o archivos son validadas en la frontera con un esquema estricto (ej. Pydantic)?
- [ ] ¿Se definieron límites explícitos para rangos numéricos, tamaños de listas y longitudes de cadenas?
- [ ] ¿La validación defensiva se concentra en las capas de entrada/salida y no se duplica innecesariamente en funciones privadas internas?
- [ ] ¿Los fallos de validación producen mensajes claros que detallan el campo erróneo y la regla infringida?