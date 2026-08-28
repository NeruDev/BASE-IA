---
id: bp_0ad8awaar7bwvabk9y77j6rz65
name: 07_inversion_of_control
title: "Inversión de Control (Inversion of Control - IoC)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/07_inversion_of_control.md
version: 1.1.0
category: architecture
tags: [inversion-of-control, ioc, hollywood-principle, frameworks, plugins, universal_principles]
description: "Inversión de Control: delegación del ciclo de vida y control de ejecución a frameworks y motores de agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 07 - Inversión de Control (Inversion of Control - IoC)

## 1. Definición y Fundamento Teórico

Popularizado bajo el conocido **"Principio de Hollywood" (*Don't call us, we'll call you*)** y formalizado por **Ralph Johnson** y **Brian Foote** (1988), el principio de **Inversión de Control (IoC)** establece:

> *"En una arquitectura de software tradicional, el código del desarrollador controla el flujo del programa y llama a librerías de utilidad. En IoC, el control se invierte: un framework o motor central orquesta el ciclo de vida global y llama al código del desarrollador en puntos de extensión específicos (*hooks*, *callbacks*, *plugins*)."*

**Relación fundamental:** IoC es un concepto arquitectónico amplio. Patrones como *Dependency Injection (DI)*, *Template Method*, *Observer*, *Middlewares* y *Plugin Systems* son implementaciones concretas de IoC.

## 2. Por Qué Existe y Problemas que Resuelve

- **Estandarización del Ciclo de Vida:** Centraliza políticas críticas (manejo de errores globales, auditoría, telemetría, reintentos) en un solo motor orquestador.
- **Extensibilidad sin Modificación:** Permite añadir nuevos comportamientos y herramientas simplemente registrando plugins o manejadores sin alterar el núcleo del motor.
- **Reutilización Arquitectónica:** El esqueleto de control de flujo se escribe una sola vez y se reutiliza a través de múltiples proyectos o módulos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Motores y Runtimes de Agentes:** Los frameworks agénticos modernos (LangGraph, CrewAI, AutoGen, runtimes de agentes) funcionan enteramente mediante IoC: el motor orquesta el bucle de razonamiento (ReAct, gestión de contexto, límites de tokens) y despacha la ejecución a las herramientas (*tools*) registradas por el usuario.
- **Inyección de Guardrails y Observabilidad:** Permite insertar capas de seguridad (*safety filters* y *cost monitors*) antes y después de cada llamada al LLM mediante hooks automáticos del framework.
- **Composición Dinámica de Habilidades (*Skills*):** Los subagentes pueden extender sus capacidades en tiempo de ejecución acoplando nuevos plugins al orquestador central.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Control Imperativo Monolítico sin Puntos de Extensión)

```python
# Antipatrón: El script controla rígidamente cada paso; imposible añadir hooks de logging o métricas
import time

def ejecutar_pipeline_agente_rigido(tarea: str):
    print("Iniciando tarea...")
    # Código acoplado y secuencial fijo
    time.sleep(0.5)
    resultado = f"Procesado: {tarea}"
    print(f"Resultado final: {resultado}")
    # Si queremos añadir validación de seguridad o cálculo de latencia,
    # debemos modificar directamente este archivo rompiendo el principio OCP.
```

### ✅ Código Correcto (Conforme a IoC: Orquestador con Ciclo de Vida y Hooks)

```python
# src/engine/orchestrator.py
from typing import Callable, Protocol
from dataclasses import dataclass
import time

@dataclass(frozen=True)
class ExecutionContext:
    task: str
    duration_seconds: float
    output: str

class ExecutionHook(Protocol):
    """Contrato para interceptar el ciclo de vida del agente."""
    def on_complete(self, context: ExecutionContext) -> None:
        ...

class AgentExecutionEngine:
    """Motor central que orquesta el ciclo de vida (IoC)."""
    def __init__(self) -> None:
        self._hooks: list[ExecutionHook] = []

    def register_hook(self, hook: ExecutionHook) -> None:
        self._hooks.append(hook)

    def run(self, task: str, task_executor: Callable[[str], str]) -> str:
        # El motor controla el inicio, medición de tiempo y notificación
        start_time = time.perf_counter()
        output = task_executor(task)
        elapsed = time.perf_counter() - start_time

        context = ExecutionContext(task=task, duration_seconds=elapsed, output=output)
        for hook in self._hooks:
            hook.on_complete(context)

        return output

# Plugins/Hooks del Desarrollador (El framework los llama: "Don't call us, we'll call you")
class MetricsLoggerHook:
    def on_complete(self, context: ExecutionContext) -> None:
        print(f"[METRIC] Tarea '{context.task}' ejecutada en {context.duration_seconds:.4f}s")
```

## 5. Descripción Didáctica de los Cambios

1. **Inversión del Control de Ejecución:** `AgentExecutionEngine` gobierna el flujo de inicio, cronometraje y notificación; el desarrollador solo suministra la lógica de la tarea y los hooks.
2. **Extensibilidad Abierta (OCP):** Nuevos observadores (telemetría, persistencia, filtros de seguridad) se integran mediante `register_hook` sin tocar el motor.
3. **Desacoplamiento Operativo:** La tarea en sí desconoce por completo la existencia de los hooks de métricas o auditoría.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Pérdida de Transparencia Secuencial (*Framework Mystery*):** Seguir el flujo exacto de ejecución paso a paso en depuración se vuelve más complejo cuando existen decenas de interceptores y middlewares activos.
- **Acoplamiento al Ciclo de Vida del Framework (*Vendor Lock-in*):** Adaptar el código a la estructura de un framework específico puede dificultar migrar a otro motor agéntico en el futuro.
- **Sobrecarga en Tareas Aisladas Simples:** Para funciones utilitarias o scripts lineales de 10 líneas, montar un contenedor IoC con hooks representa una complejidad innecesaria.

## 7. Checklist de Verificación

- [ ] ¿El motor central gestiona el ciclo de vida transversal (medición, reintentos, auditoría) de forma unificada?
- [ ] ¿Es posible registrar plugins, herramientas o hooks adicionales sin modificar el código fuente del motor?
- [ ] ¿Los contratos de extensión (`Protocol` / callbacks) están claramente delimitados y tipados?
- [ ] ¿Se evitó el exceso de indirección cuando una simple llamada secuencial directa es suficiente?