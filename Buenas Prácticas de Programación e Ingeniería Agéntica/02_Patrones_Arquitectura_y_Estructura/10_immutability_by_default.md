---
id: bp_115fzg2x0gaenvnprh0fhrrvfv
name: 10_immutability_by_default
title: "Inmutabilidad por Defecto (Immutability by Default)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/10_immutability_by_default.md
version: 1.1.0
category: architecture
tags: [immutability, functional-programming, concurrency, value-objects, thread-safety, universal_principles]
description: "Inmutabilidad por defecto: estructuras de datos inmutables y funciones puras para concurrencia segura."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 10 - Inmutabilidad por Defecto (Immutability by Default)

## 1. Definición y Fundamento Teórico

Originado en el paradigma de la **Programación Funcional** (Haskell, Clojure - **Rich Hickey**) e integrado en la ingeniería de sistemas modernos y *Domain-Driven Design (Value Objects)*, el principio de **Inmutabilidad por Defecto** establece:

> *"Todas las estructuras de datos, objetos, estados de sesión y eventos deben diseñarse como inmutables por defecto. Ningún objeto debe modificar su estado interno tras su creación; cualquier transformación debe generar una nueva instancia con los cambios aplicados, preservando el estado original."*

La inmutabilidad transforma las operaciones de modificación de estado de **mutaciones en memoria (*in-place mutations*)** a **funciones puras de transición de estado ($S_{n+1} = f(S_n)$)**.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Condiciones de Carrera (*Race Conditions*):** En entornos multihilo o asíncronos, los datos inmutables pueden compartirse entre múltiples procesos sin necesidad de bloqueos (*locks* o *mutexes*).
- **Eliminación de Efectos Secundarios Ocultos:** Una función que recibe un objeto inmutable garantiza al llamador que no alterará sus datos subyacentes.
- **Historial y Depuración Reversible (*Time-Travel Debugging*):** Al no sobrescribir estados previos, es trivial implementar funcionalidades de deshacer (*undo*), auditoría o reproducción exacta de ejecuciones.

## 3. Relevancia en Sistemas con IA Agéntica

- **Seguridad en Ejecución Multi-Agente Concurrente:** Cuando múltiples subagentes analizan o procesan simultáneamente el estado de una conversación o tarea, la inmutabilidad previene que un subagente corrompa el contexto que otro subagente está leyendo en paralelo.
- **Trazabilidad de Razonamiento y Pasos de Agentes:** Permite registrar cada iteración del bucle ReAct como una instantánea inmutable del contexto del agente, facilitando la evaluación de calidad y detección de alucinaciones.
- **Consistencia en Herramientas de IA:** Garantiza que las herramientas invocadas por los LLMs no muten estructuras compartidas inadvertidamente.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Mutación In-Place y Estado Compartido Mutable)

```python
# Antipatrón: Estado mutable compartido que genera condiciones de carrera y efectos secundarios
class AgentSharedState:
    def __init__(self):
        self.context_history = []  # Lista mutable propensa a corrupción
        self.total_tokens = 0

def subagent_researcher(state: AgentSharedState, new_item: str):
    # Mutación in-place sin control:
    state.context_history.append(f"Investigación: {new_item}")
    state.total_tokens += 150

def subagent_writer(state: AgentSharedState, new_item: str):
    # Si ambos subagentes corren concurrentemente en asyncio, el estado puede corromperse
    state.context_history.append(f"Redacción: {new_item}")
    state.total_tokens += 200
```

### ✅ Código Correcto (Conforme a Inmutabilidad: Dataclasses Frozen y Transición Pura)

```python
# src/domain/agent_state.py
from dataclasses import dataclass, replace

@dataclass(frozen=True)
class AgentState:
    """Estado inmutable del agente: garantizado thread-safe y sin efectos secundarios."""
    context_history: tuple[str, ...] = ()
    total_tokens: int = 0

    def append_message(self, message: str, tokens_used: int) -> "AgentState":
        """Retorna una NUEVA instancia con la transición aplicada sin mutar la actual."""
        if tokens_used < 0:
            raise ValueError("Los tokens consumidos deben ser no negativos.")

        new_history = self.context_history + (message,)
        return replace(
            self,
            context_history=new_history,
            total_tokens=self.total_tokens + tokens_used
        )

# Uso determinista y seguro en orquestación de agentes:
estado_inicial = AgentState()
estado_tras_investigacion = estado_inicial.append_message("Datos de mercado analizados.", 120)
estado_tras_redaccion = estado_tras_investigacion.append_message("Borrador de reporte listo.", 250)

# Verificación de inmutabilidad:
assert len(estado_inicial.context_history) == 0          # El estado inicial permanece intacto
assert len(estado_tras_investigacion.context_history) == 1
assert len(estado_tras_redaccion.context_history) == 2
```

## 5. Descripción Didáctica de los Cambios

1. **Estructura Inmutable:** `@dataclass(frozen=True)` e historial basado en `tuple` en lugar de `list` impiden cualquier intento de mutación directa (`estado.total_tokens = 10` lanzará `FrozenInstanceError`).
2. **Transición Pura de Estado:** El método `append_message` produce una nueva instancia utilizando `dataclasses.replace`, preservando intacto el estado anterior.
3. **Concurrencia Segura:** Múltiples subagentes pueden consultar `estado_tras_investigacion` en hilos o tareas asíncronas simultáneas sin riesgo de interferencia mutua.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Procesamiento Numérico y Gráfico de Alto Rendimiento:** En algoritmos de machine learning (PyTorch, TensorFlow, OpenCV) o procesamiento masivo de arrays (NumPy), mutar buffers de memoria directamente (*in-place*) es indispensable para evitar saturar la memoria RAM y el recolector de basura (*Garbage Collector*).
- **Sobrecarga de Asignación en Bucles Intensivos:** Si un bucle ejecuta 10 millones de iteraciones por segundo creando nuevos objetos en cada ciclo, el costo de CPU de crear y destruir instancias puede ser inaceptable.
- **Estructuras Profundamente Anidadas:** Modificar un campo en un árbol de 6 niveles de profundidad inmutable puede requerir copiar todos los nodos del camino (*cloning path*), a menos que se utilicen estructuras de datos persistentes (*Trie-based Persistent Data Structures* / *Lenses*).

## 7. Checklist de Verificación

- [ ] ¿Las entidades de valor (*Value Objects*), mensajes y eventos están configurados como inmutables (`@dataclass(frozen=True)` o `tuple`)?
- [ ] ¿Las operaciones que transforman datos retornan nuevas instancias en lugar de modificar el objeto recibido?
- [ ] ¿Se eliminaron variables globales mutables compartidas entre hilos o corrutinas asíncronas?
- [ ] ¿Se evaluó el impacto de rendimiento en secciones con procesamiento intensivo de datos numéricos o streaming de alta frecuencia?