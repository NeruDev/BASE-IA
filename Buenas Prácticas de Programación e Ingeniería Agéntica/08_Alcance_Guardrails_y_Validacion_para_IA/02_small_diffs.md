---
id: bp_39bdp56bwrb39rtmscqy6nq6er
name: 02_small_diffs
title: "Preferencia por Diffs Pequeños (Small Diffs)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/02_small_diffs.md
version: 1.1.0
category: agentic
tags: [small-diffs, surgical-edits, git-diff, code-review, safety, universal_principles]
description: "Diffs Pequeños: modificaciones quirúrgicas y acotadas que facilitan la auditoría humana y reducen regresiones."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 02 - Preferencia por Diffs Pequeños (Small Diffs)

## 1. Definición y Fundamento Teórico

Respaldada por las guías de ingeniería de **Google (Google Engineering Practices - Small Changes)** y los principios de edición quirúrgica de código, la **Preferencia por Diffs Pequeños** establece:

> *"Todo cambio introducido por un agente de IA debe consistir en la modificación mínima indispensable y altamente focalizada (idealmente diffs menores a 50-150 líneas netas), prohibiendo taxativamente la reescritura total de archivos o reformateos cosméticos no relacionados con la tarea asignada."*

Esta práctica prohíbe el uso de "sobrescrituras completas" cuando una edición de pocas líneas es suficiente, garantizando que el historial de Git refleje únicamente la intención semántica del cambio.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Regresiones Fantasma (*Ghost Regressions*):** Reescribir un archivo completo de 400 líneas para cambiar una sola condición lógica suele introducir errores accidentales en las otras 395 líneas.
- **Auditoría Humana Instantánea:** Un diff de 10 líneas se revisa y valida en 30 segundos en GitHub/GitLab.
- **Preservación del `git blame`:** Mantiene la autoría histórica y el contexto de las líneas que no requerían alteración.

## 3. Relevancia en Sistemas con IA Agéntica

- **Uso de Herramientas Quirúrgicas (`replace_file_content`):** Obliga al agente a identificar el bloque exacto (`StartLine` a `EndLine`) y reemplazar solo el fragmento necesario en lugar de emitir un nuevo archivo entero.
- **Ahorro de Tokens de Generación:** Generar un diff de 15 líneas consume una fracción de los tokens que requeriría regenerar un archivo completo de 500 líneas.
- **Detección Rápida de Alucinaciones:** Cualquier cambio espurio o no solicitado resalta de inmediato en el diff.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Sobrescritura Completa Destructiva)

```python
# Antipatrón: El agente sobrescribe src/billing/discounts.py (350 líneas) entero
# para cambiar solo la tasa de descuento de 0.10 a 0.15.
# CONSECUENCIAS NEGATIVAS:
# 1. Borra comentarios y docstrings que no comprendió.
# 2. Reformatea imports arbitrariamente.
# 3. Genera un git diff de +350 / -350 líneas imposible de auditar con rigor.
```

### ✅ Flujo Correcto (Conforme a Small Diffs: Reemplazo Quirúrgico)

Llamada a herramienta quirúrgica (`replace_file_content`):
```text
TargetFile: src/billing/discounts.py
StartLine: 24
EndLine: 28
TargetContent:
    # Descuento estándar anterior
    tasa_descuento = Decimal("0.10")
    return subtotal * (Decimal("1.00") - tasa_descuento)

ReplacementContent:
    # Nueva tasa de descuento conforme a política 2026 (Issue #104)
    tasa_descuento = Decimal("0.15")
    return subtotal * (Decimal("1.00") - tasa_descuento)
```

Diff resultante en Git (`git diff`):
```diff
--- a/src/billing/discounts.py
+++ b/src/billing/discounts.py
@@ -24,3 +24,3 @@ def aplicar_descuento(subtotal: Decimal) -> Decimal:
-    # Descuento estándar anterior
-    tasa_descuento = Decimal("0.10")
+    # Nueva tasa de descuento conforme a política 2026 (Issue #104)
+    tasa_descuento = Decimal("0.15")
     return subtotal * (Decimal("1.00") - tasa_descuento)
```

## 5. Descripción Didáctica de los Cambios

1. **Edición Quirúrgica Pura:** Se modificaron exactamente 2 líneas y se eliminaron 2 líneas.
2. **Preservación Total del Entorno:** Las 346 líneas restantes del archivo quedaron intactas con su formato, comentarios y autoría histórica original.
3. **Diff Auto-explicativo:** El revisor puede comprobar en 5 segundos que el cambio cumple estrictamente con el objetivo asignado.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Creación de Nuevos Módulos Desde Cero:** Al crear un nuevo archivo, el diff contendrá la totalidad del nuevo código, pero el módulo en sí debe diseñarse con bajo acoplamiento y tamaño conciso (<200 líneas).
- **Refactorizaciones Mayores Justificadas:** Cambios arquitectónicos estructurales planificados en un ADR pueden generar diffs mayores, pero deben descomponerse en una secuencia de PRs pequeños.

## 7. Checklist de Verificación

- [ ] ¿El diff modifica únicamente las líneas estrictamente necesarias para resolver la tarea?
- [ ] ¿Se utilizaron herramientas de reemplazo puntual (`replace_file_content`) en lugar de sobrescribir archivos enteros?
- [ ] ¿Se preservaron los comentarios, docstrings y formato del resto del archivo?
- [ ] ¿El diff total de la tarea es menor a 150 líneas modificadas?