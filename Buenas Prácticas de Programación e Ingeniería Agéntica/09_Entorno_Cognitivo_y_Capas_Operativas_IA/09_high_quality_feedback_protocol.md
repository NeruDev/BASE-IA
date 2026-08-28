---
id: bp_0jz1v90e3gar98jkk9nx8zwgfg
name: 09_high_quality_feedback_protocol
title: "Protocolo de Feedback Estructurado de Alta Fidelidad"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/09_high_quality_feedback_protocol.md
version: 1.1.0
category: agentic
tags: [feedback-protocol, structured-feedback, expected-vs-actual, bug-reporting, high-fidelity, universal_principles]
description: "Protocolo de Feedback Estructurado: formato Expected vs Actual y captura de trazas exactas para resolución veloz."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 09 - Protocolo de Feedback Estructurado de Alta Fidelidad

## 1. Definición y Fundamento Teórico

Basado en los estándares internacionales de reporte de defectos (**IEEE 829 Standard for Software Test Documentation**) y en la **Ingeniería de Retroalimentación para LLMs**, este principio postula:

> *"Toda comunicación de errores, incidencias o correcciones entregada a un agente de IA (o generada por él) debe estructurarse de forma rigurosa bajo el formato canónico **Expected vs. Actual**, incluyendo los pasos exactos de reproducción, el comando de prueba y la traza de error completa, erradicando reportes vagos, incompletos o subjetivos."*

Un reporte de feedback de alta fidelidad contiene cuatro campos indispensables:
1. **Comportamiento Esperado (*Expected Behavior*):** El valor, estado o salida exacta que la especificación requiere.
2. **Comportamiento Observado (*Actual Behavior*):** El valor erróneo retornado en tiempo de ejecución.
3. **Comando de Reproducción (*Reproduction Step*):** La instrucción de terminal exacta y determinista para replicar el fallo.
4. **Contexto Afectado (*Target Context*):** Archivos y números de línea específicos vinculados al error.

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de las Adivinaciones de LLMs:** Evita que el agente gaste turnos intentando descifrar qué quiso decir el usuario con *"está roto"*.
- **Aceleración Radical del Triage:** Permite al modelo ubicar el fallo en el primer turno y formular una hipótesis de corrección inmediata.
- **Trazabilidad y Calidad de Issues:** Transforma los reportes de bugs en artefactos técnicos accionables tanto para humanos como para IA.

## 3. Relevancia en Sistemas con IA Agéntica

- **Comunicación Eficiente entre Subagentes:** Permite que un subagente de Testing envíe un reporte estructurado y quirúrgico al subagente Coder para su subsanación instantánea.
- **Reducción de Consumo de Tokens:** El agente no tiene que hacer preguntas aclaratorias de ida y vuelta.
- **Alineación con Testing Automático:** El bloque de feedback se traduce directamente en un nuevo caso de prueba en Pytest.

## 4. Comparativa Didáctica de Código

### ❌ Feedback Incorrecto (Antipatrón: Reporte Vago, Subjetivo e Inútil)

```text
# Antipatrón: Mensaje vago que desorienta al agente
Usuario: "Oye, el cálculo de facturas no funciona bien para usuarios VIP. Arréglalo por favor."
# PROBLEMAS:
# - ¿Qué significa "no funciona bien"?
# - ¿Qué monto se usó? ¿Qué error arrojó? ¿En qué archivo reside la lógica?
# El agente gasta 4 turnos buscando archivos y adivinando qué tasa de descuento aplicar.
```

### ✅ Feedback Correcto (Conforme al Protocolo Estructurado de Alta Fidelidad)

Plantilla de Feedback Estructurado (`.agent/feedback-template.md`):
```markdown
### 🐛 REPORTE DE INCIDENCIA TÉCNICA

#### 1. Descripción del Problema
Fallo en la aplicación de la tasa de descuento para clientes con rol VIP.

#### 2. Expected vs. Actual
- **Expected (Esperado):**
  Para un subtotal de `$100.00`, el total neto debe ser `$85.00` (descuento del 15% VIP).
- **Actual (Observado):**
  El sistema retorna `$90.00` (aplica erróneamente un descuento del 10%).

#### 3. Pasos de Reproducción Deterministas
Ejecutar el siguiente comando en la raíz del repositorio:
```bash
uv run pytest tests/unit/billing/test_discounts.py::test_calcular_descuento_vip_15_porciento
```

#### 4. Contexto y Archivos Identificados
- Archivo de implementación: `src/billing/discounts.py:L22`
- Archivo de pruebas: `tests/unit/billing/test_discounts.py:L45`

#### 5. Traza de Error (Stack Trace)
```text
FAILED tests/unit/billing/test_discounts.py::test_calcular_descuento_vip_15_porciento
AssertionError: assert Decimal('90.00') == Decimal('85.00')
+  where Decimal('90.00') = calcular_descuento_vip(Decimal('100.00'))
```
```

## 5. Descripción Didáctica de los Cambios

1. **Claridad Cuantitativa:** Se comparan números y tipos exactos (`Decimal('90.00')` vs. `Decimal('85.00')`).
2. **Comando Listo para Ejecución:** El agente puede copiar y ejecutar el comando exacto para reproducir el fallo de inmediato.
3. **Localización Directa:** Apunta con precisión al número de línea (`discounts.py:L22`), permitiendo un reemplazo quirúrgico en el primer intento.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Consultas Conceptuales Abiertas:** Cuando el usuario solicita una sesión de lluvia de ideas sobre arquitectura o diseño preliminar, exigir el formato *Expected vs Actual* es inapropiado; el protocolo aplica estrictamente a **reportes de bugs, tareas de corrección y revisiones de código**.

## 7. Checklist de Verificación

- [ ] ¿El feedback incluye las secciones explícitas *Expected Behavior* y *Actual Behavior*?
- [ ] ¿Se proporciona el comando de terminal exacto para reproducir la falla?
- [ ] ¿Se adjunta la traza de error completa o el mensaje de fallo del linter/compilador?
- [ ] ¿Se identifican las rutas de los archivos afectados con números de línea aproximados?