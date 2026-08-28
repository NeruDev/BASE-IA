---
id: bp_7awkdmc6s9b2e9dxzwkae36400
name: 03_type_checking
title: "Verificación Estricta de Tipos (Static Type Checking)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/03_type_checking.md
version: 1.1.0
category: code_standards
tags: [type-checking, mypy, pyright, pep-484, typing, type-safety, universal_principles]
description: "Type Checking: verificación formal de tipos con Mypy y Pyright como razonador externo para agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 03 - Verificación Estricta de Tipos (Static Type Checking)

## 1. Definición y Fundamento Teórico

Basado en los fundamentos de la **Teoría de Tipos** (*Alonzo Church, Robin Milner*) y formalizado en Python mediante el **Tipado Gradual (PEP 484 / PEP 526)** por *Guido van Rossum*, *Jukka Lehtosalo* y *Łukasz Langa*, el principio de **Verificación Estricta de Tipos** establece:

> *"Todas las firmas de función, parámetros, valores de retorno y estructuras de datos deben contener anotaciones de tipo estáticas inequívocas, verificadas formalmente por un analizador estático (Mypy, Pyright) antes de cualquier ejecución."*

Esta práctica transforma el sistema de tipos en un **contrato matemático ejecutable** que garantiza la coherencia de interfaces y erradica por completo la familia de errores `AttributeError: 'NoneType' object has no attribute...` y `TypeError` en producción.

## 2. Por Qué Existe y Problemas que Resuelve

- **Detección Preventiva de Errores de Nulabilidad (*None-Safety*):** Obliga a contemplar explícitamente el caso en que una variable pueda ser `None` (`Optional[T] / T | None`).
- **Auto-documentación Viva en IDEs:** Proporciona autocompletado inteligente, refactorización segura de nombres y navegación instantánea a definiciones.
- **Mantenimiento a Gran Escala:** Permite modificar estructuras de datos en proyectos de millones de líneas con la certeza de que el compilador/analizador señalará cada punto del código que requiera adaptación.

## 3. Relevancia en Sistemas con IA Agéntica

- **Razonador Lógico Externo para LLMs:** Los modelos de lenguaje cometen errores frecuentes al asumir que una función retorna un tipo que en realidad no devuelve. Mypy actúa como un árbitro determinista externo que guía la auto-corrección del agente con mensajes de error precisos.
- **Generación Determinista de Tool Calling:** Las herramientas expuestas a los agentes requieren firmas de tipo estrictas para que el LLM pueda serializar los parámetros JSON correctamente.
- **Confianza en Refactorizaciones Autónomas:** Un agente puede sustituir o actualizar módulos enteros con total seguridad si la suite de Mypy en modo estricto (`--strict`) pasa con cero errores.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Código Sin Tipar con Nulabilidad No Manejada)

```python
# Antipatrón: Dinámico sin tipar; falla en producción si el usuario no existe o no tiene saldo
def obtener_balance_usuario(db, user_id):
    # ¿Qué tipo es db? ¿Qué retorna si no encuentra nada?
    user = db.find_user(user_id)
    # CRASH EN PRODUCCIÓN si user es None: AttributeError: 'NoneType' object has no attribute 'balance'
    return user.balance * 1.05
```

### ✅ Código Correcto (Conforme a Verificación Estricta de Tipos: Mypy Strict)

```python
# src/domain/users.py
from dataclasses import dataclass
from decimal import Decimal
from typing import Protocol

@dataclass(frozen=True)
class Usuario:
    id: str
    nombre: str
    balance: Decimal

class BaseDatosUsuarios(Protocol):
    """Contrato formal tipado para la base de datos."""
    def buscar_por_id(self, user_id: str) -> Usuario | None:
        ...

def obtener_balance_con_interes(
    db: BaseDatosUsuarios,
    user_id: str,
    tasa_interes: Decimal = Decimal("0.05")
) -> Decimal:
    """Calcula el balance proyectado manejando explícitamente la nulabilidad.

    Args:
        db: Instancia que cumple el protocolo BaseDatosUsuarios.
        user_id: Identificador único del usuario.
        tasa_interes: Tasa de interés adicional (por defecto 5%).

    Returns:
        Decimal con el balance calculado.

    Raises:
        ValueError: Si el usuario no existe en la base de datos.
    """
    usuario: Usuario | None = db.buscar_por_id(user_id)
    
    # CHEQUEO DE NULABILIDAD ESTRICTO (Mypy obliga a resolver este caso)
    if usuario is None:
        raise ValueError(f"No existe usuario registrado con el ID: {user_id}")

    return usuario.balance * (Decimal("1.00") + tasa_interes)
```

## 5. Descripción Didáctica de los Cambios

1. **Anotaciones Completas de Tipo:** Todas las variables, parámetros y retornos tienen tipos explícitos (`Usuario | None`, `Decimal`).
2. **Eliminación de Errores de Nulabilidad:** Mypy exige verificar `if usuario is None:` antes de acceder a `usuario.balance`, evitando crashes en tiempo de ejecución.
3. **Protocolo Tipado (`Protocol`):** Se definió `BaseDatosUsuarios` como una interfaz abstracta que permite la verificación estática del llamador y el mockeo fácil en pruebas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Metaprogramación Dinámica Avanzada:** Tipar decoradores altamente dinámicos o fábricas de clases dinámicas en Python puede requerir construcciones complejas (`ParamSpec`, `TypeVarTuple`, `Concatenate`) que añaden sobrecarga sintáctica.
- **Librerías de Terceros sin Stubs:** Si se utilizan librerías antiguas que carecen de anotaciones de tipo (`types-*`), puede requerirse configurar excepciones de importación (`ignore_missing_imports`).
- **Prototipos Efímeros de Exploración:** En scripts de análisis exploratorio interactivo en Jupyter Notebooks, la exigencia estricta de tipos puede ralentizar el análisis de datos de un solo uso.

## 7. Checklist de Verificación

- [ ] ¿El proyecto ejecuta `mypy --strict` en el pipeline de CI sin advertencias ni errores?
- [ ] ¿Todas las funciones públicas tienen anotaciones de tipo en todos sus argumentos y valor de retorno?
- [ ] ¿Se utiliza `T | None` para valores opcionales con comprobación explícita de nulabilidad?
- [ ] ¿Se eliminó el uso de `Any` arbitrario en favor de tipos precisos, uniones o genéricos tipados (`TypeVar`)?