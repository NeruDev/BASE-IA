---
id: bp_76vckgmn0sa3wvwett61bf6fgg
name: 10_fail_fast
title: "Principio Fail Fast"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/10_fail_fast.md
version: 1.1.0
category: universal_principles
tags: [fail-fast, error-handling, validation, reliability, universal_principles]
description: "Fail Fast: validación temprana de precondiciones y excepciones descriptivas inmediatas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 10 - Principio Fail Fast

## 1. Definición y Fundamento Teórico

Conceptualizado originalmente por **Jim Gray** en el estudio de sistemas tolerantes a fallos y formalizado en la ingeniería de software por **Martin Fowler** y **John Shore** (*Fail Fast*, IEEE Software, 2004), el principio **Fail Fast** postula que:

> *"Cualquier condición de error, violación de precondición o estado inconsistente debe interrumpir la ejecución de forma inmediata y explícita en el punto más cercano a su origen, en lugar de continuar operando con datos corruptos."*

Fail Fast contrasta diametralmente con el "antipatrón de tolerancia silenciosa", donde el software traga errores o retorna valores nulos que terminan provocando fallos misteriosos y difíciles de depurar tiempo después.

## 2. Por Qué Existe y Problemas que Resuelve

- **Diagnóstico Preciso y Rápido:** El stack trace apunta con exactitud a la causa raíz inmediata en lugar de señalar un síntoma derivado varios niveles de llamada después.
- **Prevención de la Corrupción de Datos:** Evita persistir registros corruptos o incompletos en bases de datos o almacenamiento persistente.
- **Reducción del Tiempo de Depuración:** Los desarrolladores y sistemas automatizados detectan el error en el momento exacto en que se desvía del contrato esperado.

## 3. Relevancia en Sistemas con IA Agéntica

- **Bucle de Retroalimentación y Auto-corrección:** En arquitecturas de agentes autónomos (como ReAct o tool calling), un fallo rápido con una excepción descriptiva permite al LLM entender inmediatamente qué argumento fue inválido y corregir su invocación en el siguiente paso de razonamiento.
- **Supresión de Respuestas Silenciosas Engañosas:** Si una herramienta devuelve `None` o `{}` silenciosamente ante un fallo, el agente de IA asumirá falsamente que la acción fue exitosa y procederá a alucinar sobre resultados inexistentes.
- **Seguridad en la Ejecución de Herramientas:** Detiene la ejecución antes de ejecutar comandos destructivos o llamadas a APIs con parámetros erróneos.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Ocultamiento Silencioso de Errores)

```python
# Antipatrón: Retorna None y traga excepciones, postergando el fallo inevitable
def calcular_balance_promedio(cuentas: list[dict]) -> float | None:
    try:
        # Si cuentas está vacío o contiene datos malformados:
        total = sum(c["balance"] for c in cuentas)
        return total / len(cuentas)
    except Exception:
        # ERROR: Traga la excepción silenciosamente retornando None
        return None

# Código cliente distante:
resultado = calcular_balance_promedio([])
# 50 líneas más tarde en otro archivo...
impuesto = resultado * 0.10  # CRASH MISTERIOSO: TypeError: unsupported operand type(s) for *: 'NoneType' and 'float'
```

### ✅ Código Correcto (Conforme a Fail Fast: Cláusulas de Guarda Tempranas)

```python
# src/finance/balance.py
from dataclasses import dataclass
from decimal import Decimal

@dataclass(frozen=True)
class Cuenta:
    id: str
    balance: Decimal

def calcular_balance_promedio(cuentas: list[Cuenta]) -> Decimal:
    """Calcula el balance promedio de una lista de cuentas.

    Args:
        cuentas: Lista no vacía de instancias de Cuenta.

    Returns:
        Decimal con el promedio exacto de balance.

    Raises:
        ValueError: Si la lista de cuentas está vacía.
    """
    # CLÁUSULA DE GUARDA: Falla de inmediato en el origen
    if not cuentas:
        raise ValueError("No es posible calcular el balance promedio de una lista de cuentas vacía.")

    total = sum((c.balance for c in cuentas), start=Decimal("0.00"))
    return total / Decimal(len(cuentas))
```

## 5. Descripción Didáctica de los Cambios

1. **Cláusula de Guarda Inmediata (*Guard Clause*):** Si la lista recibida está vacía, se lanza inmediatamente un `ValueError` descriptivo antes de intentar divisiones o iteraciones.
2. **Eliminación del Bloque `except Exception: pass`:** No se tragan errores inesperados; cualquier anomalía detiene la ejecución inmediatamente con su stack trace completo.
3. **Tipado Estricto:** Se reemplazó la lista de diccionarios genéricos por una colección de objetos tipados `Cuenta`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Procesamiento Batch Masivo y Pipelines ETL:** Si un lote de 1 millón de registros contiene 3 filas corruptas, detener todo el pipeline de 4 horas en el registro 900,000 es costoso. La estrategia correcta es registrar los registros fallidos en una cola de mensajes no procesados (*Dead Letter Queue - DLQ*) y continuar con los registros válidos.
- **Sistemas de Misión Crítica y Alta Disponibilidad:** En servidores web o servicios de mensajería en vivo, un error en una petición individual debe abortar esa petición aislada (*Fail Fast local*), pero jamás derribar el proceso principal del servidor.
- **Interfaces de Usuario (UI/UX):** Un fallo en un widget secundario no debe cerrar la aplicación entera del usuario; se utilizan *Error Boundaries* para degradar la vista de forma elegante.

## 7. Checklist de Verificación

- [ ] ¿Las funciones validan precondiciones y argumentos al inicio mediante cláusulas de guarda?
- [ ] ¿Se eliminaron bloques `try/except` que capturan excepciones genéricas (`pass` o retorno de `None`) sin manejar el error?
- [ ] ¿Las excepciones lanzadas son específicas (`ValueError`, `KeyError`, excepciones de dominio) y contienen mensajes diagnósticos claros?
- [ ] ¿En herramientas de agentes de IA, los errores devuelven retroalimentación estructurada para permitir la auto-corrección inmediata?