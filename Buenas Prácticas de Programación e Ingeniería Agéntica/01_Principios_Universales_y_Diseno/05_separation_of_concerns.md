---
id: bp_52a31wshr5ajmv482cscafc39w
name: 05_separation_of_concerns
title: "Separación de Responsabilidades (Separation of Concerns - SoC)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/05_separation_of_concerns.md
version: 1.1.0
category: universal_principles
tags: [soc, architecture, layers, clean-architecture, universal_principles]
description: "Separación de responsabilidades: aislamiento del Dominio puro de la capa Web y Persistencia."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 05 - Separación de Responsabilidades (Separation of Concerns - SoC)

## 1. Definición y Fundamento Teórico

Formulado por el pionero de las ciencias de la computación **Edsger W. Dijkstra** en su ensayo *On the role of scientific thought* (1974), el principio de **Separación de Responsabilidades (SoC)** establece:

> *"Dividir un problema en aspectos o partes lógicamente diferenciadas, de modo que cada parte se concentre exclusivamente en resolver una preocupación particular del sistema sin verse contaminada por las demás."*

En la arquitectura de software moderna, SoC se materializa típicamente en la división por capas:
- **Capa de Dominio:** Reglas de negocio puras e invariantes, independientes de la tecnología.
- **Capa de Aplicación:** Casos de uso y orquestación del flujo.
- **Capa de Infraestructura:** Acceso a bases de datos, APIs externas, sistemas de archivos y mensajería.
- **Capa de Presentación / Interfaz:** Controladores HTTP, CLI o interfaces de usuario.

## 2. Por Qué Existe y Problemas que Resuelve

- **Aislamiento de Cambios:** Modificar el motor de base de datos o el framework web no debe requerir alterar las reglas de negocio de la empresa.
- **Testabilidad de Lógica Pura:** Permite probar algoritmos críticos en memoria en milisegundos sin levantar servidores, bases de datos o mocks de red complejos.
- **Paralelización del Desarrollo:** Permite a diferentes desarrolladores o subagentes trabajar en la interfaz, la persistencia y las reglas de negocio de forma concurrente sin conflictos de fusión (*merge conflicts*).

## 3. Relevancia en Sistemas con IA Agéntica

- **Modularización del Razonamiento Agéntico:** Los agentes de IA generan código con mayor precisión y menos alucinaciones cuando su tarea se delimita a una sola preocupación (ej. "escribe la función matemática pura de descuento" vs. "escribe el endpoint HTTP con SQL y validaciones").
- **Aislamiento de Prompts y Tools:** Las herramientas (*tools*) expuestas a los agentes deben separar la lógica de ejecución del formateo de salida para evitar que errores de serialización bloqueen el motor del agente.
- **Reducción de Ambigüedad:** El agente no tiene que lidiar con detalles de I/O cuando razona sobre reglas de dominio.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Mezcla de Presentación, Negocio y Persistencia)

```python
# Antipatrón: Un controlador web que mezcla parsing HTTP, queries SQL y lógica de negocio
from fastapi import FastAPI, HTTPException
import sqlite3

app = FastAPI()

@app.post("/solicitudes-credito")
def solicitar_credito(payload: dict):
    # PREOCUPACIÓN 1: Parsing y validación básica de entrada
    ingreso = payload.get("ingreso_mensual", 0)
    deuda = payload.get("deuda_actual", 0)
    user_id = payload.get("user_id")

    # PREOCUPACIÓN 2: Lógica de negocio (Cálculo de riesgo financiero)
    ratio_endeudamiento = deuda / ingreso if ingreso > 0 else 1.0
    if ratio_endeudamiento > 0.40:
        return {"aprobado": False, "motivo": "Capacidad de pago insuficiente"}

    # PREOCUPACIÓN 3: Persistencia directa en base de datos
    conn = sqlite3.connect("creditos.db")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO solicitudes (user_id, aprobado) VALUES (?, ?)", (user_id, True))
    conn.commit()
    conn.close()

    # PREOCUPACIÓN 4: Formateo de respuesta HTTP
    return {"aprobado": True, "limite_credito": ingreso * 3}
```

### ✅ Código Correcto (Conforme a SoC: Dominio Aislado y Orquestación Limpia)

```python
# src/domain/credit_rules.py (Lógica Pura de Dominio - Sin dependencias externas)
from dataclasses import dataclass

@dataclass(frozen=True)
class EvaluacionCredito:
    aprobado: bool
    limite_otorgado: float
    motivo: str | None = None

def evaluar_capacidad_crediticia(ingreso_mensual: float, deuda_actual: float) -> EvaluacionCredito:
    """Evalúa la elegibilidad de crédito basada en el ratio de endeudamiento."""
    if ingreso_mensual <= 0:
        return EvaluacionCredito(aprobado=False, limite_otorgado=0.0, motivo="Ingreso mensual debe ser mayor a 0.")

    ratio = deuda_actual / ingreso_mensual
    if ratio > 0.40:
        return EvaluacionCredito(aprobado=False, limite_otorgado=0.0, motivo="Ratio de deuda superior al 40%.")

    return EvaluacionCredito(aprobado=True, limite_otorgado=ingreso_mensual * 3.0)
```

## 5. Descripción Didáctica de los Cambios

1. **Aislamiento del Dominio:** `evaluar_capacidad_crediticia` es una función pura, determinista y comprobable con tests unitarios instantáneos, sin requerir FastAPI ni SQLite.
2. **Desacoplamiento de I/O:** La base de datos y la capa HTTP se gestionan en sus propios módulos dedicados, permitiendo cambiar el framework web o la persistencia sin tocar las reglas financieras.
3. **Claridad Estructural:** Cada archivo y función tiene un único propósito delimitado y comprensible.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Hiper-fragmentación (*Shotgun Surgery*):** Separar en demasiadas capas micro-componentes triviales puede obligar a modificar 8 archivos para cambiar un campo en un formulario básico. Las cosas que cambian juntas por la misma razón deben permanecer cercanas (*Colocation*).
- **Prototipado Rápido y Scripts de Análisis:** En scripts exploratorios de ciencia de datos o pipelines de un solo uso, forzar una arquitectura en capas añade fricción innecesaria.
- **Penalización de Rendimiento por Serialización:** En sistemas de latencia ultra baja, transformar datos entre múltiples modelos de dominio, DTOs y capas de persistencia puede generar un costo de memoria y CPU apreciable.

## 7. Checklist de Verificación

- [ ] ¿La lógica de negocio pura está libre de librerías de frameworks web (FastAPI, Flask) o de bases de datos (SQL, ORMs)?
- [ ] ¿Es posible testear la regla de negocio central sin iniciar servicios de red ni bases de datos?
- [ ] ¿Cada módulo o capa responde a una preocupación claramente diferenciada (Dominio, Persistencia, Presentación)?
- [ ] ¿Se evitó la fragmentación excesiva en componentes que siempre evolucionan juntos?