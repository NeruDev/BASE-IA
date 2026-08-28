---
id: bp_3rtfvjhjydbnqsw7dtp38yf5pk
name: 03_design_by_contract
title: "Diseño por Contrato (Design by Contract - DbC)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/03_design_by_contract.md
version: 1.1.0
category: code_standards
tags: [design-by-contract, dbc, preconditions, postconditions, invariants, bertrand-meyer, universal_principles]
description: "Diseño por Contrato: especificación formal de precondiciones, postcondiciones e invariantes de clase."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 03 - Diseño por Contrato (Design by Contract - DbC)

## 1. Definición y Fundamento Teórico

Creado por **Bertrand Meyer** en 1986 durante el desarrollo del lenguaje Eiffel y formalizado en su obra *Object-Oriented Software Construction* (1988), el **Diseño por Contrato (DbC)** concibe la colaboración entre módulos de software como un contrato legal formal compuesto por tres cláusulas:

1. **Precondiciones (*Requires*):** Requisitos y obligaciones que el llamador (*cliente*) debe garantizar antes de invocar la operación. Si se viola una precondición, la culpa es exclusivamente del cliente.
2. **Postcondiciones (*Ensures*):** Garantías y propiedades que el método (*proveedor*) se compromete a entregar al finalizar su ejecución si las precondiciones fueron satisfechas. Si se viola una postcondición, la culpa es del proveedor.
3. **Invariantes de Clase (*Invariants*):** Condiciones de integridad que deben mantenerse verdaderas durante toda la vida útil del objeto (en reposo, antes y después de cualquier método público).

## 2. Por Qué Existe y Problemas que Resuelve

- **Atribución Clara de Responsabilidades:** Elimina la ambigüedad sobre quién debe verificar qué (evita que tanto el llamador como el llamado dupliquen los mismos chequeos defensivos).
- **Documentación Ejecutable y Formal:** Los contratos son verificables programáticamente mediante aserciones o herramientas de análisis estático/dinámico.
- **Detección Inmediata de Bugs de Lógica:** Las violaciones de postcondición revelan fallos internos en los algoritmos en el momento exacto en que ocurren.

## 3. Relevancia en Sistemas con IA Agéntica

- **Delimitación Rigurosa para Tools de Agentes:** Permite a los agentes de IA entender inequívocamente qué argumentos son válidos para una herramienta (precondición) y qué resultado garantiza la herramienta (postcondición).
- **Diferenciación de Errores en Razonamiento Agéntico:** Si el agente envía argumentos erróneos, la violación de precondición le indica que debe corregir su prompt o llamada; si falla la postcondición, el agente sabe que la herramienta externa tuvo un error interno.
- **Prevención de Estados Corruptos en Subagentes:** Los invariantes impiden que un agente deje un objeto o sesión en un estado semánticamente inválido.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Sin Contratos ni Invariantes Formales)

```python
# Antipatrón: No define precondiciones, postcondiciones ni preserva invariantes
class CuentaBancaria:
    def __init__(self, saldo: float):
        self.saldo = saldo

    def retirar(self, monto: float):
        # ERROR: No valida monto negativo (Precondición violada silenciosamente)
        # ERROR: Permite sobregiro no autorizado corrompiendo el invariante (saldo >= 0)
        self.saldo -= monto
        # ERROR: No garantiza que el saldo resultante sea exactamente el esperado (Postcondición)
        return self.saldo
```

### ✅ Código Correcto (Conforme a Diseño por Contrato: Pre, Post e Invariantes)

```python
# src/domain/bank_account.py
from decimal import Decimal

class CuentaBancariaContrato:
    """Entidad bancaria regida estrictamente por principios de Diseño por Contrato."""

    def __init__(self, saldo_inicial: Decimal = Decimal("0.00")) -> None:
        # PRECONDICIÓN del constructor
        if saldo_inicial < Decimal("0.00"):
            raise ValueError("Precondición violada: El saldo inicial no puede ser negativo.")
        self._saldo: Decimal = saldo_inicial
        self._verificar_invariante()

    def _verificar_invariante(self) -> None:
        """INVARIANTE DE CLASE: El saldo nunca debe ser inferior a cero."""
        assert self._saldo >= Decimal("0.00"), f"Invariante violado: Saldo negativo detectado ({self._saldo})"

    @property
    def saldo(self) -> Decimal:
        return self._saldo

    def retirar(self, monto: Decimal) -> Decimal:
        """Ejecuta un retiro bajo contrato formal.

        Precondiciones:
            - monto > 0
            - monto <= saldo disponible

        Postcondiciones:
            - nuevo_saldo == saldo_anterior - monto

        Invariantes:
            - saldo >= 0
        """
        # 1. PRECONDICIONES (Obligación del cliente)
        if monto <= Decimal("0.00"):
            raise ValueError(f"Precondición violada: El monto a retirar debe ser estrictamente positivo ({monto}).")
        if monto > self._saldo:
            raise ValueError(f"Precondición violada: Fondos insuficientes (Saldo: {self._saldo}, Solicitado: {monto}).")

        saldo_previo = self._saldo

        # 2. OPERACIÓN
        self._saldo -= monto

        # 3. POSTCONDICIÓN (Obligación del método)
        assert self._saldo == saldo_previo - monto, "Postcondición violada: Error en el cálculo de deducción de saldo."

        # 4. VERIFICACIÓN DEL INVARIANTE
        self._verificar_invariante()

        return self._saldo
```

## 5. Descripción Didáctica de los Cambios

1. **Precondición Explícita:** Se rechazan inmediatamente montos negativos o superiores al saldo disponible con mensajes descriptivos.
2. **Postcondición Verificada:** Se comprueba formalmente que el nuevo saldo corresponda exactamente a la resta matemática (`_saldo == saldo_previo - monto`).
3. **Invariante de Clase:** El método `_verificar_invariante` asegura que la cuenta jamás quede en estado de sobregiro inconsistente tras cualquier mutación.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **DbC vs. Validación Defensiva en Fronteras:** DbC asume que dentro del sistema los módulos cooperan bajo contratos. Para datos no confiables de usuarios externos o LLMs en crudo, se requiere **validación defensiva previa** (ej. Pydantic) antes de entrar al núcleo DbC.
- **Sobrecarga de Rendimiento en Invariantes Complejas:** Si un invariante requiere recorrer un árbol de 100,000 nodos en cada llamada de método, el chequeo dinámico en producción puede degradar el rendimiento (suele desactivarse en producción manteniendo las precondiciones activas).
- **Verbosidad en Funciones Triviales:** Añadir contratos formales con pre/postcondiciones a una función de suma de dos enteros añade ruido innecesario.

## 7. Checklist de Verificación

- [ ] ¿Están documentadas y verificadas las precondiciones que el llamador debe cumplir?
- [ ] ¿Se garantizan las postcondiciones que el método promete entregar tras su ejecución?
- [ ] ¿La clase mantiene un invariante de integridad que se verifica en cada estado observable?
- [ ] ¿Se distingue claramente entre la validación de entrada externa (defensiva) y los contratos internos de diseño (DbC)?