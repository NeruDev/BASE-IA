---
id: bp_5x6hjsn9tja34atp0x6ns1hfs0
name: 03_living_documentation
title: "Documentación Viva y Sincronizada (Living Documentation)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/03_living_documentation.md
version: 1.1.0
category: standards
tags: [living-documentation, pydantic, openapi, single-source-of-truth, autodoc, universal_principles]
description: "Living Documentation: sincronización garantizada y autogeneración de especificaciones desde el código fuente real."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 03 - Documentación Viva y Sincronizada (Living Documentation)

## 1. Definición y Fundamento Teórico

Conceptualizada y formalizada por **Cyrille Martraire** en *Living Documentation: Continuous Knowledge Sharing by Design* (2019), la **Documentación Viva** postula que:

> *"La documentación técnica de un sistema no debe ser un artefacto estático redactado manualmente al margen del desarrollo; debe generarse, extraerse y sincronizarse de forma automática y continua directamente desde el código fuente ejecutable, los tipos estáticos y los contratos formales, garantizando una fidelidad del 100% en todo momento."*

Los mecanismos principales de la documentación viva incluyen:
- **Esquemas OpenAPI y JSON Schema Auto-generados:** Derivados en tiempo de compilación o arranque desde modelos fuertemente tipados (**Pydantic**).
- **Docstrings Autoverificados:** Documentación de firmas y excepciones extraída automáticamente por herramientas como Sphinx o MkDocs-Material.
- **Especificaciones Ejecutables BDD:** Escenarios Given-When-Then que actúan simultáneamente como pruebas y manual funcional del sistema.

## 2. Por Qué Existe y Problemas que Resuelve

- **Erradicación de la 'Deuda de Documentación':** La documentación nunca envejece ni diverge del comportamiento real del software.
- **Eliminación del Esfuerzo Manual Duplicado:** Modificar un modelo de datos actualiza simultáneamente la validación, la base de datos, el cliente de API y la documentación técnica.
- **Auditoría Transparente de Contratos:** Los consumidores y equipos de integración siempre disponen de la versión más fiel de los endpoints y eventos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Ground Truth Infalible para LLMs:** Los agentes de IA utilizan las especificaciones JSON Schema para el descubrimiento y parametrización de herramientas (*Tool Calling*). La documentación viva asegura que el agente nunca intente usar argumentos obsoletos o inventados.
- **Generación Dinámica de Prompts:** Permite inyectar esquemas de herramientas actualizados al milisegundo directamente desde la definición de clases de Python en el contexto del agente.
- **Prevención de Alucinaciones de Integración:** Si un endpoint cambia, el agente recibe el nuevo contrato sin necesidad de que un humano reescriba guías manuales.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Documentación Manual Desfasada del Código Real)

```markdown
<!-- Antipatrón: Archivo api_docs.md redactado a mano en 2024 -->
### Endpoint: POST /users
Parámetros:
- `name` (string)
- `email` (string)
<!-- ERROR: El código en Python fue actualizado en 2026 agregando `age` obligatorio
     y renombrando `name` a `full_name`. La documentación manual miente. -->
```

### ✅ Código Correcto (Conforme a Living Documentation: Esquemas Pydantic Autogenerados)

```python
# src/schemas/user.py
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime, timezone

class UserRegistrationSchema(BaseModel):
    """Modelo autoritativo: actúa como validador, tipado y documentación viva."""

    full_name: str = Field(
        min_length=2,
        max_length=80,
        description="Nombre completo del usuario registrado.",
        examples=["Alice Johnson"]
    )
    email: EmailStr = Field(
        description="Correo electrónico institucional único y validado.",
        examples=["alice@empresa.com"]
    )
    age: int = Field(
        ge=18,
        le=120,
        description="Edad en años cumplidos (debe ser mayor de edad).",
        examples=[28]
    )

# src/api/main.py
from fastapi import FastAPI, status
from src.schemas.user import UserRegistrationSchema

app = FastAPI(
    title="Core User API",
    description="Documentación viva auto-generada desde modelos Pydantic.",
    version="2.0.0"
)

@app.post("/users", status_code=status.HTTP_201_CREATED)
def register_user(payload: UserRegistrationSchema) -> dict[str, str]:
    """Registra un nuevo usuario en la plataforma.
    
    FastAPI genera automáticamente el esquema OpenAPI 3.1 en `/openapi.json`
    y el portal interactivo Swagger en `/docs` sin redactar una sola línea manual.
    """
    return {"status": "SUCCESS", "email": payload.email}
```

## 5. Descripción Didáctica de los Cambios

1. **Fuente Única de Verdad (SSOT):** `UserRegistrationSchema` concentra los tipos, validaciones (`ge=18`), descripciones semánticas y ejemplos.
2. **Generación Automática de OpenAPI:** El portal interactivo en `/docs` y el archivo `/openapi.json` se sincronizan automáticamente con cada cambio en el modelo.
3. **Consumo Agéntico Directo:** El esquema generado puede exportarse como herramienta (*Tool Spec*) para agentes de IA mediante `UserRegistrationSchema.model_json_schema()`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **El 'Qué' vs. el 'Por Qué':** La documentación viva describe con precisión quirúrgica *qué* hace el código y *cómo* se estructuran sus datos, pero no puede deducir el *porqué* estratégico del negocio (los motivos arquitectónicos requieren ADRs narrativos).
- **Sobrecarga de Anotaciones en Modelos Internos:** Agregar descripciones exhaustivas a cada variable en clases privadas de bajo nivel añade ruido innecesario; debe priorizarse en las **fronteras públicas y APIs**.

## 7. Checklist de Verificación

- [ ] ¿Los esquemas de API y contratos de herramientas se generan automáticamente desde modelos de código (Pydantic / FastAPI)?
- [ ] ¿Los campos incluyen descripciones semánticas (`description`) y ejemplos reales (`examples`)?
- [ ] ¿Se eliminaron tablas manuales de parámetros en Markdown que duplican la información del código?
- [ ] ¿Las herramientas expuestas a agentes de IA se nutren del JSON Schema generado dinámicamente?