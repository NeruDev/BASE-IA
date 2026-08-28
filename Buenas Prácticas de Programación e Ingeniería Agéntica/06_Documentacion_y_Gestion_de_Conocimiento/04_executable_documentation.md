---
id: bp_139b8fh0mbbyvrsjjjhgexbfvw
name: 04_executable_documentation
title: "Documentación Ejecutable y Verificable"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/04_executable_documentation.md
version: 1.1.0
category: standards
tags: [executable-documentation, doctest, pytest, literate-programming, verification, universal_principles]
description: "Documentación Ejecutable: ejemplos y fragmentos de código testeados automáticamente en CI mediante doctests."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 04 - Documentación Ejecutable y Verificable

## 1. Definición y Fundamento Teórico

Inspirada en el paradigma de **Literate Programming** formulado por **Donald Knuth** (1984) y consolidada en Python mediante el módulo **`doctest`** (*Tim Peters*, 1999) y extensiones como `pytest-codeblocks`, la **Documentación Ejecutable** postula:

> *"Todo ejemplo de código, fragmento interactivo o comando presente en la documentación técnica (docstrings, READMEs y guías en `docs/`) debe ser tratado como un caso de prueba ejecutable verificado automáticamente por el pipeline de CI, erradicando ejemplos rotos o desincronizados."*

Esta disciplina elimina el dilema entre *probar el código* y *documentar el código*, unificando ambos propósitos en un único artefacto verificable.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de Ejemplos Rotos:** Garantiza que los tutoriales y fragmentos de código copiados por usuarios y desarrolladores funcionen a la primera.
- **Prevención de la Obsolescencia de Docstrings:** Si una firma de función o valor de retorno cambia, los doctests fallan en el CI, obligando a actualizar la documentación de inmediato.
- **Verificación Ligera y de Cero Configuración:** Permite probar funciones puras y utilitarios directamente dentro de su propio bloque de documentación.

## 3. Relevancia en Sistemas con IA Agéntica

- **Aprendizaje Libre de Alucinaciones para LLMs:** Los agentes de IA aprenden a invocar APIs y librerías internas leyendo los ejemplos de la documentación. Si los ejemplos están rotos, el agente generará código defectuoso.
- **Validación Automática de Documentación Generada por Agentes:** Permite verificar que los ejemplos de uso redactados por subagentes técnicos sean sintáctica y semánticamente correctos.
- **Inyección de Ejemplos Verificados en Prompts (*Few-Shot Examples*):** Asegura que los ejemplos inyectados en los prompts de los agentes sean 100% operativos y libres de bugs.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Docstring con Ejemplo Roto e Inservible)

```python
# Antipatrón: El ejemplo en la documentación está desfasado y roto
def calcular_descuento_vip(monto: float) -> float:
    """Calcula el descuento aplicable.

    Ejemplo de uso:
        >>> calcular_descuento_vip(100.0)
        90.0  # ERROR: En realidad la función devuelve 85.0 y espera Decimal, no float.
              # Nadie prueba este docstring en CI, confundiendo a desarrolladores y agentes.
    """
    return monto * 0.85
```

### ✅ Código Correcto (Conforme a Documentación Ejecutable: Doctest Verificado en CI)

```python
# src/finance/discounts.py
from decimal import Decimal

def calcular_descuento_vip(monto: Decimal) -> Decimal:
    """Calcula el total neto aplicando un descuento VIP del 15% con redondeo exacto.

    Ejemplos de uso ejecutables (validados automáticamente por pytest):
        >>> from decimal import Decimal
        >>> calcular_descuento_vip(Decimal("100.00"))
        Decimal('85.00')

        >>> calcular_descuento_vip(Decimal("0.00"))
        Decimal('0.00')

        >>> calcular_descuento_vip(Decimal("-50.00"))
        Traceback (most recent call last):
            ...
        ValueError: El monto debe ser estrictamente no negativo.
    """
    if monto < Decimal("0.00"):
        raise ValueError("El monto debe ser estrictamente no negativo.")

    descuento = monto * Decimal("0.15")
    return (monto - descuento).quantize(Decimal("0.01"))
```

Ejecución en CI con Pytest:
```bash
# Ejecuta todos los doctests en el proyecto como parte de la suite de pruebas:
pytest --doctest-modules src/
```

## 5. Descripción Didáctica de los Cambios

1. **Sintaxis Doctest Canónica:** El bloque de documentación utiliza la sintaxis interactiva `>>>` con entradas y salidas exactas.
2. **Validación de Casos Límite y Excepciones:** Se documenta y verifica tanto el caso feliz como el manejo del error (`ValueError` con `Traceback (most recent call last): ...`).
3. **Verificación Automatizada en CI:** El comando `pytest --doctest-modules` ejecuta los ejemplos en milisegundos y detiene el build si el resultado difiere de la documentación.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Ejemplos con I/O Pesado o Servicios Externos:** Probar ejemplos que llaman a pasarelas de pago reales o bases de datos gigantes en un docstring no es adecuado; los doctests deben reservarse para **funciones puras, utilitarios y lógica algorítmica**.
- **Salidas No Deterministas:** Operaciones que devuelven UUIDs aleatorios o timestamps requieren directivas de doctest (`# doctest: +ELLIPSIS`) para evitar falsos negativos.
- **Verbosidad Excesiva:** Incluir cientos de líneas de casos de prueba dentro de un docstring dificulta la lectura visual del código fuente (los tests complejos pertenecen a la carpeta `tests/`).

## 7. Checklist de Verificación

- [ ] ¿Los docstrings de funciones clave incluyen ejemplos interactivos en formato doctest (`>>>`)?
- [ ] ¿El comando `pytest --doctest-modules` se ejecuta automáticamente en el pipeline de CI?
- [ ] ¿Los ejemplos documentan tanto los casos válidos como las excepciones esperadas?
- [ ] ¿Los fragmentos de código en archivos Markdown se validan con herramientas como `pytest-codeblocks`?