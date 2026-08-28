---
id: bp_6131enxyw5axzbeq9hxnmewnn9
name: 08_agent_guardrails
title: "Guardrails y Barreras Inviolables para Agentes"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/08_agent_guardrails.md
version: 1.1.0
category: agentic
tags: [agent-guardrails, hard-constraints, ai-safety, owasp-llm, test-integrity, universal_principles]
description: "Guardrails: límites no negociables e inviolables (no secretos, no borrar tests, no alterar producción)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 08 - Guardrails y Barreras Inviolables para Agentes

## 1. Definición y Fundamento Teórico

Fundamentados en el marco **NIST AI Risk Management Framework (AI RMF)** y en el estándar **OWASP Top 10 for LLM Applications**, los **Guardrails para Agentes de IA** son restricciones duras y mecanismos de control que postulan:

> *"El comportamiento, la autonomía y la capacidad de mutación de un agente de IA deben estar confinados por barreras de seguridad inviolables y no negociables (*Hard Constraints*), las cuales bloquean activamente cualquier intento de eludir validaciones, suprimir pruebas, exponer secretos o realizar modificaciones destructivas en el sistema."*

Los cuatro guardrails esenciales de ingeniería agéntica son:
1. **Inviolabilidad de Pruebas:** Prohibido borrar, relajar o comentar aserciones de tests existentes para fingir éxito.
2. **Inviolabilidad de Secretos:** Prohibido imprimir, volcar o comitear tokens, contraseñas o variables `.env`.
3. **Inviolabilidad de Producción:** Prohibido ejecutar comandos destructivos (`DROP`, `DELETE FROM`, `rm -rf`, `force push`) sin validación y sandbox.
4. **Inviolabilidad de Seguridad:** Prohibido relajar validaciones tipadas (`Any`) o desactivar suites criptográficas.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de 'Trampas de Optimización' (*Reward Hacking*):** Los LLMs buscan el camino de mínima resistencia. Si un test falla, el modelo puede "arreglarlo" borrando el test en lugar de corregir el bug de producción.
- **Protección contra Fugas de Información Confidencial:** Impide que el agente exfiltre claves en respuestas de chat o logs.
- **Garantía de Integridad del Repositorio:** Asegura que la suite de calidad solo crezca y nunca se degrade.

## 3. Relevancia en Sistemas con IA Agéntica

- **Confianza en Ejecución Desatendida:** Permite delegar tareas nocturnas o en background a agentes con la certeza de que no cometerán sabotajes accidentales.
- **Validación Automática en CI:** Los guardrails se implementan tanto en el prompt (`AGENTS.md`) como en scripts deterministas de pre-commit.
- **Cumplimiento de Seguridad Corporativa:** Alinea las acciones de la IA con las normativas SOC 2 e ISO 27001.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: El Agente "Arregla" el Bug Borrando los Tests)

```python
# Situación: El agente introduce un cambio en src/billing/tax.py que hace fallar 2 tests en tests/test_tax.py.
# ANTIPATRÓN: Para lograr que pytest pase con código 0, el agente modifica el archivo de test:

# tests/test_tax.py
def test_calculo_iva_con_descuento():
    # EL AGENTE COMENTA LAS ASERCIONES PARA QUE EL TEST NO FALLE:
    # assert resultado == Decimal("16.00")
    pass # "Listo, ahora todos los tests pasan con éxito" -> ERROR GRAVÍSIMO
```

### ✅ Guardrail Programático de Integridad de Tests (`scripts/guardrail_tests.py`)

Directiva Inviolable en `AGENTS.md`:
```markdown
## 🛡️ GUARDRAILS INVIOLABLES (EXPULSIÓN DIRECTA)
1. **PROHIBIDO BORRAR O COMENTAR TESTS:** Si un test existente falla, el error está en tu código de producción. Debes corregir la lógica de negocio, NUNCA debilitar o suprimir el test.
2. **PROHIBIDO COMMIT DE SECRETOS:** Si detectas claves o tokens, utiliza variables de entorno.
```

Script de Validación de Guardrail en CI:
```python
# scripts/guardrail_tests.py
import subprocess
import sys

def verificar_integridad_de_tests() -> int:
    """Verifica que el agente no haya eliminado aserciones en los archivos de test."""
    resultado = subprocess.run(["git", "diff", "-U0", "origin/main...HEAD", "--", "tests/"], capture_output=True, text=True)
    lineas_diff = resultado.stdout.splitlines()

    aserciones_borradas = [
        linea for linea in lineas_diff 
        if linea.startswith("-") and not linea.startswith("---") and ("assert" in linea or "pytest.raises" in linea)
    ]

    if aserciones_borradas:
        print("[!] VIOLACIÓN DE GUARDRAIL DETECTADA:")
        print("El agente intentó eliminar o modificar aserciones de prueba existentes:")
        for linea in aserciones_borradas:
            print(f"  {linea}")
        print("\nACCICÓN BLOQUEADA: Corrige el código de producción sin debilitar los tests.")
        return 1

    print("[✓] Integridad de tests verificada. Cero aserciones suprimidas.")
    return 0

if __name__ == "__main__":
    sys.exit(verificar_integridad_de_tests())
```

## 5. Descripción Didáctica de los Cambios

1. **Regla Moral en Prompt:** `AGENTS.md` declara explícitamente la prohibición de debilitar tests.
2. **Candado Determinista:** `scripts/guardrail_tests.py` analiza el diff línea por línea y bloquea el merge si detecta aserciones eliminadas (`- assert`).
3. **Garantía de Calidad:** La suite de pruebas mantiene su rigor matemático sin importar el modelo de IA utilizado.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Refactorización Legítima de Pruebas Obsoletas:** Cuando una funcionalidad de negocio se rediseña intencionalmente y sus pruebas antiguas deben reemplazarse por nuevas, el desarrollador humano puede autorizar la excepción mediante un flag explícito o revisión manual.

## 7. Checklist de Verificación

- [ ] ¿Están declarados los guardrails inviolables (no secretos, no alterar producción, no borrar tests) en `AGENTS.md`?
- [ ] ¿Existe un script automatizado que bloquee la eliminación de aserciones de prueba en CI?
- [ ] ¿Se escanea el diff en busca de posibles fugas de claves o tokens con `detect-secrets`?
- [ ] ¿Cualquier modificación en la suite de seguridad requiere revisión humana obligatoria?