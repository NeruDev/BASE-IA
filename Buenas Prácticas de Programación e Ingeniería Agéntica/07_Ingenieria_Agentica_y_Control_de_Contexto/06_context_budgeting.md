---
id: bp_79wwgdarkcaja9vmxvqndxshca
name: 06_context_budgeting
title: "Gestión del Presupuesto de Contexto y Límite de Tokens"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/07_Ingenieria_Agentica_y_Control_de_Contexto/06_context_budgeting.md
version: 1.1.0
category: agentic
tags: [context-budgeting, token-limits, context-window, efficiency, 32kib-limit, universal_principles]
description: "Presupuesto de Contexto: gestión del límite de tokens (~32 KiB) para optimizar atención y coste."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:25:00Z
schema_version: 1.0.0
---

# 06 - Gestión del Presupuesto de Contexto y Límite de Tokens

## 1. Definición y Fundamento Teórico

Fundamentada en las restricciones de capacidad de la ventana de contexto de los **Modelos de Lenguaje** y en los límites prácticos de inyección de instrucciones en herramientas de desarrollo (ej. el límite canónico de **~32 KiB** en sistemas como GitHub Copilot, OpenAI Codex y Cursor), la **Gestión del Presupuesto de Contexto** postula:

> *"La ventana de contexto de un agente de IA debe administrarse como un recurso escaso y costoso, manteniendo los archivos de instrucciones iniciales (`AGENTS.md`) por debajo del límite estricto de ~32 KiB (<4,000 tokens) para reservar la máxima capacidad atencional al razonamiento (*thoughts*), la memoria de herramientas y la generación de código."*

Cada token inyectado en el prompt de sistema tiene un costo computacional y financiero recurrente en cada turno de la conversación.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Truncamiento Silencioso:** Muchas herramientas truncan silenciosamente los archivos de directivas si superan los 32 KiB, haciendo que las reglas críticas del final del archivo sean ignoradas.
- **Reducción de Latencia (*Time-To-First-Token*):** Menor cantidad de tokens de entrada acelera el tiempo de respuesta del LLM.
- **Maximización del Espacio de Trabajo:** Deja espacio libre para diffs grandes, respuestas de APIs y resultados de tests.

## 3. Relevancia en Sistemas con IA Agéntica

- **Alta Densidad Informativa:** Obliga a redactar directivas directas, concisas y estructuradas en tablas y viñetas en lugar de párrafos narrativos redundantes.
- **Eficiencia en Bucles de Múltiples Turnos (*Multi-Turn Conversations*):** Si el prompt base consume 30k tokens, en 10 turnos de ReAct el agente consumirá 300k tokens solo en contexto estático. Reducirlo a 2k tokens reduce el coste en un 93%.
- **Control de Presupuesto Financiero:** Permite a organizaciones a gran escala controlar la factura mensual de APIs de modelos de lenguaje.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Directivas Verbosas e Infladas >80 KiB)

```markdown
<!-- Antipatrón: AGENTS.md inflado con explicaciones redundantes y código duplicado -->
# MANUAL DE INSTRUCCIONES PARA AGENTES DE INTELIGENCIA ARTIFICIAL (85 KiB)

En este proyecto tenemos una filosofía muy particular sobre cómo escribir código en Python.
Nos gusta mucho la legibilidad y por eso creemos firmemente que todos los desarrolladores
deben intentar usar siempre que sea posible las funciones de la librería estándar...
(40 párrafos explicando la historia de Python y copiando 300 líneas de código de ejemplo).
<!-- RESULTADO: Se superan los 32 KiB; las herramientas truncan el archivo y el LLM se satura -->
```

### ✅ Estructura Correcta (Conforme a Presupuesto de Contexto: <15 KiB de Alta Densidad)

```markdown
# Directivas Operativas (AGENTS.md - 3.2 KiB / 650 Tokens)

## 🛠️ Stack y Herramientas Canónicas
| Herramienta | Comando Obligatorio | Propósito |
| :--- | :--- | :--- |
| **Gestor** | `uv sync --frozen` | Sincronización determinista de dependencias |
| **Linter** | `ruff check --fix` | Corrección estática y formato canónico |
| **Tipos** | `mypy --strict src/` | Verificación formal de tipos |
| **Tests** | `pytest tests/unit/` | Validación de suite unitaria |

## 📐 Convenciones Críticas
- **Tipado:** Tipado estricto obligatorio en todas las firmas públicas (`T | None`).
- **Seguridad:** Prohibido `eval()`, `shell=True` o secretos hardcodeados.
- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`).
- **PRs:** Diffs < 200 líneas.

## 📚 Enlaces a Especificaciones (Carga Bajo Demanda)
- Arquitectura: [`docs/architecture.md`](docs/architecture.md)
- Facturación: [`docs/billing/README.md`](docs/billing/README.md)
```

## 5. Descripción Didáctica de los Cambios

1. **Uso de Tablas y Listas:** La información se presenta de forma compacta y directamente procesable por el LLM.
2. **Eliminación de Prosa de Relleno:** Se suprimen introducciones filosóficas innecesarias.
3. **Punteros a Documentación Externa:** Los detalles profundos residen en `docs/` y se cargan solo si el agente los necesita.
4. **Cumplimiento del Límite de 32 KiB:** El archivo ocupa solo 3.2 KiB (~650 tokens), dejando el 95% de la ventana disponible.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobre-compresión Críptica (*Over-compression*):** Comprimir el texto con acrónimos ininteligibles o eliminar instrucciones de seguridad esenciales por ahorrar 20 tokens es un antipatrón peligroso; la claridad semántica prevalece sobre el ahorro extremo.
- **Modelos de Contexto Masivo (1M+ Tokens):** Aunque modelos como Gemini 1.5 Pro admiten millones de tokens, mantener el prompt de sistema compacto sigue siendo una buena práctica para reducir latencia y costes.

## 7. Checklist de Verificación

- [ ] ¿El archivo `AGENTS.md` pesa menos de 32 KiB (idealmente <15 KiB / <3,000 tokens)?
- [ ] ¿La información se presenta en formato estructurado (tablas de comandos, viñetas)?
- [ ] ¿Se eliminaron explicaciones narrativas de relleno o tutoriales extensos del prompt de sistema?
- [ ] ¿Los detalles de dominio residen en archivos complementarios enlazados bajo demanda?