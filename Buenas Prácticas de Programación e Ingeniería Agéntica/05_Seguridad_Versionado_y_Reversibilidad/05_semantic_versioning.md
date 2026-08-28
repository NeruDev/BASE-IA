---
id: bp_5fsde9xaxmbm59ft4t0807fccx
name: 05_semantic_versioning
title: "Versionado Semántico (Semantic Versioning - SemVer)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/05_semantic_versioning.md
version: 1.1.0
category: standards
tags: [semver, semantic-versioning, releases, breaking-changes, packaging, universal_principles]
description: "Versionado Semántico (SemVer 2.0.0): comunicación formal y matemática del impacto de cambios en APIs."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 05 - Versionado Semántico (Semantic Versioning - SemVer)

## 1. Definición y Fundamento Teórico

Formalizado por **Tom Preston-Werner** (co-fundador de GitHub) en la especificación **SemVer 2.0.0**, el **Versionado Semántico** es el estándar de nomenclatura de versiones que postula:

> *"El número de versión de un paquete o API pública debe transmitir matemáticamente el grado de compatibilidad y el impacto de los cambios realizados mediante una terna numérica estrictamente estructurada: `MAJOR.MINOR.PATCH`."*

Las reglas formales de incremento son:
1. **MAJOR ($X.0.0$):** Se incrementa cuando se introducen cambios incompatibles con versiones anteriores (*Breaking Changes* / Roturas de Contrato).
2. **MINOR ($X.Y.0$):** Se incrementa cuando se añade nueva funcionalidad preservando el 100% de la compatibilidad hacia atrás (*Backward Compatible*).
3. **PATCH ($X.Y.Z$):** Se incrementa cuando se aplican exclusivamente correcciones de errores (*Bug Fixes*) compatibles hacia atrás.

Extensiones estándar:
- **Pre-releases:** `1.2.0-alpha.1`, `1.2.0-rc.2` (inestables para pruebas).
- **Build Metadata:** `1.2.0+20260827.sha1234` (metadatos informativos que no alteran la precedencia).

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del 'Dependency Hell':** Permite a los gestores de paquetes (`uv`, `pip`, `npm`) resolver actualizaciones automáticas seguras mediante operadores de rango (`^1.2.0` o `~=1.2.0`).
- **Claridad de Expectativas para Clientes:** Los consumidores saben instantáneamente si una actualización requiere modificar su código o si es una instalación transparente.
- **Disciplina de Deprecación:** Obliga a anunciar advertencias de obsolescencia (*Deprecation Warnings*) en versiones MINOR antes de eliminar interfaces en la siguiente versión MAJOR.

## 3. Relevancia en Sistemas con IA Agéntica

- **Razonamiento Automatizado de Upgrades:** Los agentes de IA pueden analizar dependencias y determinar con certeza si actualizar una librería externa o herramienta es seguro o si requerirá refactorizar llamadas.
- **Versionado de Herramientas de Agentes (*Tools*):** Si una herramienta expuesta a un LLM cambia el esquema de sus parámetros JSON, incrementar la versión MAJOR alerta a los sistemas de orquestación para actualizar la descripción del prompt.
- **Automatización de Releases:** Permite que pipelines de agentes integrados con herramientas como `semantic-release` calculen la siguiente versión y publiquen el changelog de forma 100% desatendida.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Breaking Change Disfrazado de Parche PATCH)

```python
# Versión previa: v1.0.0
def obtener_resumen_agente(user_id: int) -> dict:
    return {"id": user_id, "summary": "Resumen del usuario"}

# ANTIPATRÓN: El desarrollador o agente renombró el argumento y cambió el tipo de retorno
# pero publicó el cambio bajo la versión "v1.0.1" (PATCH).
# Todos los consumidores y subagentes que llamaban con user_id fallarán con TypeError en producción:
def obtener_resumen_agente(id_usuario: str) -> list[str]:  # BREAKING CHANGE ILEGAL EN PATCH
    return [f"Usuario {id_usuario}"]
```

### ✅ Código Correcto (Conforme a SemVer: Deprecación Gradual y Compatibilidad)

```python
# src/api/user_summary.py
import warnings
from dataclasses import dataclass

@dataclass(frozen=True)
class UserSummaryResponse:
    """Modelo formal de respuesta compatible con SemVer."""
    user_id: int
    summary: str

# VERSIÓN 1.1.0 (MINOR): Nueva capacidad añadida con retrocompatibilidad y advertencia
def obtener_resumen_agente(
    user_id: int | None = None,
    *,
    id_usuario: str | None = None  # Nuevo parámetro opcional compatible
) -> UserSummaryResponse:
    """Obtiene el resumen del usuario respetando el contrato SemVer v1.x.

    Nota de Deprecación:
        El argumento `user_id` será deprecado en favor de `id_usuario` en v2.0.0.
    """
    if id_usuario is not None:
        warnings.warn(
            "El soporte para id_usuario como str es preliminar; se consolidará en v2.0.0.",
            DeprecationWarning,
            stacklevel=2
        )
        uid_int = int(id_usuario)
    elif user_id is not None:
        uid_int = user_id
    else:
        raise ValueError("Debe proporcionarse user_id o id_usuario.")

    return UserSummaryResponse(user_id=uid_int, summary="Resumen compatible")
```

## 5. Descripción Didáctica de los Cambios

1. **Preservación del Contrato Anterior:** La función continúa aceptando `user_id: int` y retornando un objeto compatible con `v1.0.0`.
2. **Advertencia Explícita de Deprecación:** Se utiliza `warnings.warn(..., DeprecationWarning)` para notificar a los clientes sobre cambios futuros sin romper su ejecución actual.
3. **Evolución Ordenada hacia v2.0.0:** La eliminación definitiva del parámetro antiguo se posterga formalmente para la versión mayor `2.0.0`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Servicios Web Internos con Despliegue Continuo (SaaS):** En aplicaciones web monolíticas que se despliegan 10 veces al día y no exponen APIs públicas empaquetadas, el versionado basado en fechas (**CalVer** `2026.08.27`) o hashes de Git es más práctico que SemVer.
- **Miedo a Incrementar MAJOR (*Zero Version Syndrome*):** Mantener un proyecto en `v0.x.y` durante 5 años por temor a lanzar `v1.0.0` comunica inestabilidad injustificada.
- **Librerías de Uso Estrictamente Privado:** En paquetes internos de un solo archivo, una versión incremental simple puede ser suficiente.

## 7. Checklist de Verificación

- [ ] ¿Cualquier cambio incompatible con versiones anteriores (*Breaking Change*) incrementa el número MAJOR?
- [ ] ¿Las nuevas funcionalidades compatibles hacia atrás incrementan exclusivamente el número MINOR?
- [ ] ¿Los parches y arreglos de bugs incrementan exclusivamente el número PATCH?
- [ ] ¿Se emiten advertencias de deprecación (*DeprecationWarning*) con al menos una versión de anticipación antes de retirar una función?