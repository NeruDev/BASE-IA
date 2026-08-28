---
id: bp_2n2wte2mhyamp8w1w657y7w68v
name: 01_context_engineering
title: "Ingeniería de Contexto para Agentes de IA (Context Engineering)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/01_context_engineering.md
version: 1.1.0
category: agentic
tags: [context-engineering, llm, prompt-engineering, agents, token-optimization, universal_principles]
description: "Context Engineering: diseño y curación de la información técnica inyectada al agente en cada paso."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 01 - Ingeniería de Contexto para Agentes de IA (Context Engineering)

## 1. Definición y Fundamento Teórico

Evolucionada a partir de los mecanismos de atención en la arquitectura Transformer (*Vaswani et al., 2017*) y los estudios de precisión atencional (*Liu et al., "Lost in the Middle", 2023*), la **Ingeniería de Contexto (Context Engineering)** es la disciplina que establece:

> *"La información inyectada en la ventana de contexto de un agente de IA debe diseñarse, seleccionarse, estructurarse y comprimirse estratégicamente en cada fase del bucle de razonamiento (ReAct / Plan-Execute), maximizando la densidad semántica de la señal (*Signal-to-Noise Ratio*) y eliminando el ruido que provoca alucinaciones o degradación atencional."*

A diferencia del simple "prompt engineering" (redactar instrucciones textuales), la ingeniería de contexto diseña **el entorno informacional completo**:
- **Contexto Estático:** Directivas operativas del proyecto (`AGENTS.md`), arquitectura y contratos de herramientas.
- **Contexto Dinámico:** Historial de ejecución de herramientas, resultados de tests, diffs de código y fragmentos de archivos relevantes recuperados bajo demanda.

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de Alucinaciones por Ruido:** Los LLMs inventan parámetros o librerías cuando reciben información dispersa o irrelevante.
- **Prevención de Pérdida de Atención (*Lost in the Middle*):** Asegura que las directivas críticas de seguridad y negocio no queden sepultadas bajo miles de líneas de logs.
- **Optimización de Costes Financieros y Latencia:** Reduce drásticamente el consumo de tokens de entrada y acelera el tiempo hasta el primer token (*TTFT*).

## 3. Relevancia en Sistemas con IA Agéntica

- **Determinismo en el Bucle Agéntico:** Proporciona al modelo exactamente las 5 variables y 2 firmas de funciones necesarias para resolver una tarea, evitando que explore a ciegas.
- **Poda Dinámica de Historial (*Context Pruning*):** Permite a los orquestadores limpiar salidas de herramientas excesivamente largas (ej. truncar una salida de terminal de 5,000 líneas a solo el stack trace relevante).
- **Curación de Ejemplos (*Few-Shot Selection*):** Inyecta ejemplos de código verificados que coinciden exactamente con la tarea que el agente debe resolver.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Context Stuffing con Inyección Masiva de Ruido)

```python
# Antipatrón: Inyecta todo el contenido del repositorio y logs crudos en el prompt
def invocar_agente_antipatron(user_query: str, repo_path: str):
    # ERROR: Carga 50,000 tokens de código no relacionado y 10,000 líneas de logs
    todo_el_codigo = leer_todos_los_archivos_del_repo(repo_path)
    logs_completos = leer_logs_crudos_del_servidor()
    
    prompt = f"""
    Eres un asistente. Aquí está TODO el código del sistema:
    {todo_el_codigo}
    Aquí están TODOS los logs:
    {logs_completos}
    Pregunta: {user_query}
    """
    # El LLM sufre degradación atencional, alucina y cuesta $0.50 por llamada
    return call_llm(prompt)
```

### ✅ Código Correcto (Conforme a Context Engineering: Curador de Contexto Tipado)

```python
# src/agent/context_curator.py
from dataclasses import dataclass
from typing import Sequence

@dataclass(frozen=True)
class CuratedAgentContext:
    system_rules: str
    target_interface_signature: str
    recent_error_snippet: str | None
    relevant_file_snippets: dict[str, str]

    def render_prompt(self, task_description: str) -> str:
        """Renderiza un prompt de alta densidad de señal y cero ruido."""
        bloques = [
            f"### DIRECTIVAS PRINCIPALES\n{self.system_rules.strip()}",
            f"### CONTRATO DE INTERFAZ\n{self.target_interface_signature.strip()}"
        ]
        
        if self.recent_error_snippet:
            bloques.append(f"### ERROR A RESOLVER (Últimas líneas)\n{self.recent_error_snippet.strip()}")

        for ruta, contenido in self.relevant_file_snippets.items():
            bloques.append(f"### ARCHIVO: `{ruta}`\n```python\n{contenido.strip()}\n```")

        bloques.append(f"### TAREA ASIGNADA\n{task_description.strip()}")
        return "\n\n".join(bloques)

def podar_salida_terminal(raw_output: str, max_lines: int = 15) -> str:
    """Conserva únicamente las últimas líneas relevantes de un log o stack trace."""
    lineas = raw_output.strip().splitlines()
    if len(lineas) <= max_lines:
        return raw_output
    return f"[... {len(lineas) - max_lines} líneas previas podadas por optimización de contexto ...]\n" + "\n".join(lineas[-max_lines:])
```

## 5. Descripción Didáctica de los Cambios

1. **Estructura Semántica Tipada:** `CuratedAgentContext` organiza la información en secciones limpias y aisladas (`DIRECTIVAS`, `CONTRATO`, `ERROR`).
2. **Poda de Logs (*Context Pruning*):** La función `podar_salida_terminal` reduce salidas gigantes a las últimas 15 líneas críticas del error.
3. **Cero Ruido:** Se inyectan únicamente los fragmentos de código estrictamente necesarios para la tarea, ahorrando hasta un 90% de tokens.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Poda Excesiva (*Over-pruning*):** Eliminar demasiado contexto puede ocultar la causa raíz de un bug sutil que ocurrió 50 líneas antes en el log; la poda debe ser inteligente y configurable.
- **Sobrecarga de Pre-procesamiento:** Implementar clasificadores pesados de machine learning para decidir qué contexto incluir puede añadir latencia al inicio del agente.

## 7. Checklist de Verificación

- [ ] ¿El contexto inyectado al agente contiene únicamente archivos e interfaces relevantes para la tarea?
- [ ] ¿Las salidas de terminal, logs y stack traces se podan para no saturar la ventana de tokens?
- [ ] ¿La información está estructurada con encabezados claros y delimitadores semánticos?
- [ ] ¿Se mide y monitorea el conteo de tokens de entrada por cada invocación del agente?