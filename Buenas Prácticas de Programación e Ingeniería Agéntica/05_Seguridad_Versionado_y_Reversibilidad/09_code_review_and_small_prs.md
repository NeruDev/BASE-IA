---
id: bp_1bavjxysfdbtt83sc5118anfjf
name: 09_code_review_and_small_prs
title: "Revisión de Código y Pull Requests Acotados"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/09_code_review_and_small_prs.md
version: 1.1.0
category: standards
tags: [code-review, small-prs, pull-requests, human-in-the-loop, quality-assurance, universal_principles]
description: "Revisión de Código y PRs Acotados: revisiones rigurosas de diffs menores a 300 líneas para control de calidad."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 09 - Revisión de Código y Pull Requests Acotados

## 1. Definición y Fundamento Teórico

Respaldada por las directrices de ingeniería de **Google (Google Engineering Practices - Small CLs)** y los estudios empíricos de **SmartBear** y **Cisco Systems**, la práctica de **Revisión de Código y PRs Acotados** establece:

> *"Todo cambio introducido en la base de código debe someterse a revisión formal por pares (humanos o agentes auditores) y debe limitarse a un tamaño pequeño y enfocado (idealmente menos de 200 a 300 líneas de código modificado, excluyendo lockfiles), asegurando la máxima densidad de detección de defectos."*

El fundamento empírico se resume en la célebre **Ley de la Revisión de Código**:
> *"Un Pull Request de 10 líneas de cambio recibe 10 comentarios minuciosos; un Pull Request de 1,000 líneas recibe un 'Looks Good To Me (LGTM)' automático por fatiga cognitiva del revisor."*

## 2. Por Qué Existe y Problemas que Resuelve

- **Aumento Radical de la Calidad y Detección de Bugs:** La efectividad de detección de defectos cae en picado cuando los revisores analizan más de 400 líneas por sesión.
- **Tiempos de Aprobación Ultrarrápidos:** Un PR pequeño (<150 líneas) se revisa y fusiona en 15 minutos, evitando que las ramas queden estancadas durante días.
- **Reducción de Conflictos de Fusión:** Al integrarse rápidamente a la rama principal, se minimiza la divergencia de código.

## 3. Relevancia en Sistemas con IA Agéntica

- **Contención del Hinchazón de Código por LLMs:** Los agentes de IA son capaces de generar miles de líneas de código en segundos. Imponer un límite estricto de tamaño de PR obliga al agente a descomponer problemas complejos en entregas atómicas.
- **Supervisión Humana Efectiva (*Human-in-the-Loop*):** Permite a los ingenieros senior revisar con detalle cada diff generado por IA, detectando alucinaciones sutiles o atajos inseguros.
- **Auditoría Automatizada por Subagentes Revisores:** Facilita que subagentes especializados en seguridad o arquitectura realicen revisiones automatizadas enfocadas sin desbordar su ventana de contexto.

## 4. Comparativa Didáctica de Código

### ❌ Estructura de PR Incorrecta (Antipatrón: Pull Request Monstruo Inauditable)

```text
PR #405: "Refactorización general del sistema y módulo de pagos"
- 45 archivos modificados
- +2,450 líneas / -1,120 líneas
- Mezcla: actualización de dependencias, reescritura de autenticación, nuevo CSS y 4 endpoints.
RESULTADO: Nadie puede revisar este PR con rigor; se aprueba a ciegas con alto riesgo de bugs.
```

### ✅ Estructura de PR Correcta (Conforme al Estándar: PR Pequeño y Estructurado)

Plantilla de Pull Request (`.github/pull_request_template.md`):
```markdown
## 📌 Resumen del Cambio
Implementa el servicio de cálculo de recargos por mora en facturación conforme a la política tributaria 2026.

## 🔍 Detalles Técnicos
- Añade función pura `calcular_recargo_mora` en `src/billing/penalties.py`.
- Añade modelo inmutable de datos `PenaltySummary`.
- Cobertura de pruebas unitarias al 100% con 8 casos de prueba en `tests/unit/test_penalties.py`.

## 📊 Métricas del Diff
- **Archivos modificados:** 2 (`src/billing/penalties.py`, `tests/unit/test_penalties.py`)
- **Líneas añadidas/modificadas:** +68 líneas
- **Tests unitarios:** 8 PASADOS en 15ms (Pytest)

## 🔗 Referencias
Closes #204
```

## 5. Descripción Didáctica de los Cambios

1. **Tamaño Extremadamente Acotado:** Modifica únicamente 2 archivos y menos de 70 líneas de código.
2. **Autocontenido y Funcional:** Incluye tanto la lógica de negocio como su suite completa de pruebas unitarias.
3. **Revisión Rápida:** El revisor puede auditar la lógica matemática, tipos y casos límite en menos de 5 minutos con concentración total.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Fragmentación Artificial Rota (*Broken Micro-PRs*):** Dividir una feature en PRs tan pequeños que no pueden compilar o probarse por separado es un antipatrón; cada PR debe ser pequeño pero **funcionalmente completo y verificable**.
- **Refactorizaciones Automatizadas de Formato Masivo:** Cambios mecánicos generados por herramientas (ej. renombrado de paquete o formateo con Ruff) pueden superar las 300 líneas si son 100% deterministas y van aislados en su propio PR de tipo `chore`.
- **Generación de Lockfiles:** Modificaciones en `uv.lock` o `poetry.lock` que añaden muchas líneas de hashes no cuentan dentro del límite de código manual a revisar.

## 7. Checklist de Verificación

- [ ] ¿El Pull Request modifica menos de 300 líneas de código de lógica/producción?
- [ ] ¿El PR resuelve un único objetivo conceptual y está vinculado a un issue de seguimiento?
- [ ] ¿El PR incluye las pruebas unitarias que verifican los nuevos cambios?
- [ ] ¿La descripción del PR explica el *por qué* del cambio y los pasos de validación realizados?