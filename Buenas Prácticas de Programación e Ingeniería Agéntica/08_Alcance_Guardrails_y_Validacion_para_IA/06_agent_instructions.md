---
id: bp_22mmj7e917a9mbxvkb268stqyn
name: 06_agent_instructions
title: "Instrucciones Estructuradas para Agentes"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/06_agent_instructions.md
version: 1.1.0
category: agentic
tags: [agent-instructions, imperative-prompting, deterministic-rules, agents-md, prompt-engineering, universal_principles]
description: "Instrucciones para Agentes: directivas imperativas, accionables, binarias y deterministas en AGENTS.md."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 06 - Instrucciones Estructuradas para Agentes

## 1. Definición y Fundamento Teórico

Basada en la teoría de **Gramáticas Imperativas** y en los principios de **Ingeniería de Instrucciones Deterministas para LLMs**, esta práctica establece:

> *"Todas las directivas técnicas y operativas dirigidas a agentes de IA deben redactarse utilizando un lenguaje imperativo, estructurado, unívoco y directamente verificable, estructurado en reglas binarias (Obligatorio / Prohibido / Verificación), erradicando sugerencias optativas, prosa pasiva o declaraciones ambiguas que los modelos suelen ignorar."*

Los modelos de lenguaje no responden eficazmente a sugerencias amables; requieren **órdenes operativas formales con condiciones de activación y consecuencias claras**.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Ambigüedad Interpretativa:** Erradica el fenómeno donde el agente "asume" o "interpreta" libremente una recomendación ambigua.
- **Aumento Radical de Adherencia a Estándares:** Directivas imperativas estructuradas alcanzan más del 95% de cumplimiento en benchmarks de generación de código frente a menos del 50% en directivas pasivas.
- **Facilidad de Auditoría:** Permite comprobar de forma binaria si el agente cumplió o violó cada regla del contrato.

## 3. Relevancia en Sistemas con IA Agéntica

- **Determinismo en `AGENTS.md`:** Convierte el archivo de instrucciones en un manual de operaciones ejecutable y preciso.
- **Reducción de Alucinaciones Operativas:** Instrucciones claras sobre qué comandos ejecutar evitan que el modelo intente flags de terminal inexistentes.
- **Compatibilidad Transversal:** Funciona de manera idéntica en modelos de Anthropic, Google, OpenAI o modelos locales (Llama / Mistral).

## 4. Comparativa Didáctica de Código

### ❌ Redacción Incorrecta (Antipatrón: Prosa Pasiva, Sugerencias Vagas y Opcionales)

```markdown
<!-- Antipatrón: Directivas redactadas en tono sugerente y pasivo que el LLM ignora -->
# Recomendaciones de Código
Sería deseable que intentes escribir código lo más limpio posible.
Si tienes tiempo y te parece adecuado, nos gustaría que añadieras algunas anotaciones
de tipo en las funciones principales. Por favor, ten en cuenta que no nos gusta mucho
cuando se usan comandos raros de shell o librerías que no conocemos bien.
<!-- RESULTADO: El agente no añade tipos, no corre tests y usa comandos arbitrarios -->
```

### ✅ Redacción Correcta (Conforme a Instrucciones Estructuradas: Gramática Imperativa)

```markdown
# Directivas Operativas Obligatorias (AGENTS.md)

## 1. Sistema de Tipos (Mypy Strict)
- **OBLIGATORIO:** Todas las funciones públicas deben declarar tipos explícitos en parámetros y retorno (`def f(x: int) -> str:`).
- **OBLIGATORIO:** Usar `T | None` para valores opcionales con chequeo explícito de nulabilidad (`if x is None:`).
- **PROHIBIDO:** Usar `Any` arbitrario en el código de producción.
- **VERIFICACIÓN:** Ejecutar `mypy --strict src/` (debe retornar 0 errores).

## 2. Higiene de Código y Formato (Ruff)
- **OBLIGATORIO:** Ejecutar `ruff check --fix` y `ruff format` tras cualquier edición.
- **PROHIBIDO:** Dejar importaciones no utilizadas (`F401`) o imports comodín (`from module import *`).
- **PROHIBIDO:** Mutabilidad en argumentos por defecto (`def f(tags=[])` -> RECHAZADO).

## 3. Entrega y Cierre de Tarea
- **OBLIGATORIO:** Ejecutar `pytest tests/unit/` antes de declarar la tarea como finalizada.
- **OBLIGATORIO:** Mostrar la salida del terminal de los tests pasando en el mensaje final.
```

## 5. Descripción Didáctica de los Cambios

1. **Categorías Binarias Explicitas:** Clasificación en `OBLIGATORIO`, `PROHIBIDO` y `VERIFICACIÓN`.
2. **Sintaxis Imperativa y Directa:** Verbos en infinitivo o imperativo directo (*"Ejecutar"*, *"Usar"*, *"Prohibido"*).
3. **Comandos de Verificación Exactos:** Cada sección incluye el comando determinista para validar el cumplimiento de la regla.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Instrucciones Contradictorias Acumuladas:** Acumular 50 reglas que se contradicen entre sí (ej. *"escribe código ultra-conciso"* vs. *"añade docstrings de 20 líneas en cada función"*) provoca que el modelo entre en bucle o ignore ambas; **las directivas deben ser coherentes y priorizadas**.
- **Sobre-especificación Rígida de Algoritmos:** No es necesario dictar cada línea de código; especifica las *restricciones, contratos y pruebas*, permitiendo al LLM sintetizar la lógica algorítmica.

## 7. Checklist de Verificación

- [ ] ¿Las directivas están redactadas en lenguaje imperativo y directo (Obligatorio / Prohibido)?
- [ ] ¿Se eliminaron frases pasivas o ambiguas (*"sería bueno si..."*, *"en lo posible..."*)?
- [ ] ¿Cada bloque de directivas incluye un comando de verificación programática?
- [ ] ¿Se verificó que no existan directivas contradictorias en el documento?