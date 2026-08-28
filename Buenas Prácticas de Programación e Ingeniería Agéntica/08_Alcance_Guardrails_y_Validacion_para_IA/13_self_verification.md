---
id: bp_1v1ffrahhnbcks19zpj70qnzdx
name: 13_self_verification
title: "Auto-Verificación y Revisión de Diff (Self-Verification)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/13_self_verification.md
version: 1.1.0
category: agentic
tags: [self-verification, git-diff, code-hygiene, clean-up, debug-removal, universal_principles]
description: "Auto-Verificación del Diff: inspección del propio git diff antes de concluir para descartar líneas espurias."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 13 - Auto-Verificación y Revisión de Diff (Self-Verification)

## 1. Definición y Fundamento Teórico

Basada en la disciplina de **Auto-Revisión por Pares (*Self-Code Review*)** y en la **Introspección Reflexiva**, la práctica de **Auto-Verificación y Revisión de Diff** establece:

> *"Antes de declarar una tarea como finalizada o abrir un Pull Request, el agente de IA debe ejecutar obligatoriamente una auto-inspección de su propio `git diff` y `git status`, verificando línea por línea que no existan modificaciones accidentales, archivos temporales residuales, formateos espurios ni instrucciones de depuración (`print`, `debugger`, `breakpoint`) olvidadas en el código de producción."*

Esta práctica actúa como el **filtro final de higiene técnica** antes de entregar el trabajo al revisor humano.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Residuos de Depuración (*Debug Pollution*):** Evita que `print("DEBUG:", variable)` o `import pdb` se filtren al entorno productivo.
- **Detección de Modificaciones Accidentales:** Identifica si el agente tocó sin querer líneas no relacionadas debido a conflictos de herramientas.
- **Limpieza de Archivos Temporales:** Asegura que scripts de prueba efímeros (`scratch.py`, `.tmp`) sean eliminados antes del commit.

## 3. Relevancia en Sistemas con IA Agéntica

- **Higiene en Pipelines Autónomos:** Garantiza que los Pull Requests generados por agentes sean impecables y estén listos para revisión inmediata.
- **Reducción de Fatiga del Revisor Humano:** El revisor no tiene que señalar *"por favor borra el print de la línea 45"*.
- **Control de Calidad Interno de Ciclo Cerrado:** Fomenta la capacidad reflexiva del modelo sobre su propia salida de trabajo.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Entrega Sin Auto-Revisión de Diff)

```python
# Diff generado por un agente descuidado que no ejecutó auto-verificación:
# src/billing/tax.py
def calcular_iva(monto: Decimal) -> Decimal:
    print(f"DEBUG: monto recibido = {monto}") # RESIDUO DE DEPURACIÓN OLVIDADO
    resultado = monto * Decimal("0.16")
    # import pdb; pdb.set_trace()           # LÍNEA PELIGROSA COMENTADA A MEDIAS
    return resultado
# Además dejó un archivo `test_prueba_temporal.py` sin borrar en la raíz.
```

### ✅ Flujo Correcto (Conforme a Auto-Verificación: Inspección y Limpieza)

Protocolo de Cierre del Agente:
```text
Paso 1: Agente ejecuta `git status` y `git diff`:
        Detecta:
        - `print(f"DEBUG:...")` en src/billing/tax.py (Línea 12)
        - Archivo residual `test_prueba_temporal.py` no rastreado en raíz.

Paso 2: Agente limpia activamente los residuos:
        - Elimina la línea de debug en `src/billing/tax.py`.
        - Borra el archivo temporal `test_prueba_temporal.py`.

Paso 3: Agente re-ejecuta `git diff` para verificar la limpieza absoluta:
        Salida de git diff:
        +++ b/src/billing/tax.py
        @@ -10,3 +10,3 @@ def calcular_iva(monto: Decimal) -> Decimal:
        -    return (monto * Decimal("0.15")).quantize(Decimal("0.01"))
        +    return (monto * Decimal("0.16")).quantize(Decimal("0.01"))

Paso 4: El agente procede a entregar la solución 100% limpia.
```

## 5. Descripción Didáctica de los Cambios

1. **Auto-Corrección Previa a la Entrega:** El agente identificó y eliminó sus propios residuos antes de que un humano viera el código.
2. **Diff Quirúrgico y Canónico:** El diff final contiene única y exclusivamente el cambio funcional solicitado (+1 / -1 línea).
3. **Cero Archivos Huérfanos:** El repositorio se mantiene libre de archivos basura no rastreados.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Instrucciones Explícitas de Telemetría:** Si la tarea solicitada por el usuario fue específicamente *"añadir logs de monitoreo en el servicio"*, los logs estructurados legítimos forman parte de la solución y no deben confundirse con prints de depuración temporales.

## 7. Checklist de Verificación

- [ ] ¿El agente ejecutó `git diff` para inspeccionar todas las líneas modificadas antes de dar por cerrada la tarea?
- [ ] ¿Se eliminaron todos los `print()` de depuración, breakpoints o comentarios temporales?
- [ ] ¿Se eliminaron los archivos temporales (`.tmp`, `.scratch`, `test_temp.py`) creados durante el desarrollo?
- [ ] ¿El diff final contiene únicamente los cambios estrictamente relacionados con el requerimiento?