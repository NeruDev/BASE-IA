---
id: bp_2e7j89fcqea59vx4yfs16f6dk4
name: 02_clean_architecture
title: "Clean Architecture (Arquitectura Limpia)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/02_clean_architecture.md
version: 1.1.0
category: architecture
tags: [clean-architecture, architecture, dependency-rule, use-cases, universal_principles]
description: "Clean Architecture: regla de dependencia centrípeta hacia las entidades de dominio puro."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 02 - Clean Architecture (Arquitectura Limpia)

## 1. Definición y Fundamento Teórico

Formulada por **Robert C. Martin ("Uncle Bob")** en 2012 y consolidada en su obra homónima (2017), la **Clean Architecture (Arquitectura Limpia)** integra principios de la Arquitectura Hexagonal, Onion Architecture y Screaming Architecture en un modelo concéntrico gobernado por una ley fundamental:

> **La Regla de Dependencia (The Dependency Rule):**
> *"Las dependencias del código fuente solo pueden apuntar hacia adentro, hacia los círculos concéntricos de mayor nivel de abstracción y lógica de negocio. Ningún elemento de un círculo interno puede tener conocimiento alguno sobre elementos de los círculos externos."*

Las capas concéntricas esenciales son:
1. **Entidades (*Enterprise Business Rules*):** Modelos de dominio puros con invariantes de negocio transversales.
2. **Casos de Uso (*Application Business Rules*):** Orquestación de flujos específicos de la aplicación y coordinación de entidades.
3. **Adaptadores de Interfaz (*Interface Adapters*):** Controladores, presentadores y *gateways* que transforman los datos entre el formato de casos de uso y el formato de agentes o dispositivos externos.
4. **Frameworks y Drivers (*Frameworks & Drivers*):** Bases de datos, frameworks web (FastAPI, Django), APIs externas y sistemas de archivos.

## 2. Por Qué Existe y Problemas que Resuelve

- **Independencia de Frameworks:** Los frameworks son herramientas de entrega, no la esencia de la arquitectura. Se pueden actualizar o sustituir sin alterar la lógica de negocio.
- **Independencia de la Base de Datos y la UI:** Permite migrar de SQL a NoSQL o cambiar una API REST por una interfaz de agentes CLI sin afectar los casos de uso.
- **Testabilidad Máxima:** Los casos de uso y las entidades pueden ejecutarse en pruebas automatizadas completas sin inicializar servidores ni bases de datos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Protección contra Acoplamiento en Generación de Código:** Los agentes de IA suelen acoplar directamente librerías externas (ej. ORMs, clientes HTTP) en la lógica de negocio. La Regla de Dependencia establece una frontera estricta que restringe este comportamiento.
- **Enfoque de Razonamiento del LLM:** Permite presentar al agente únicamente la capa de Caso de Uso y las Entidades para resolver una tarea de negocio, ahorrando tokens de contexto.
- **Mapeo Claro de Responsabilidades:** Facilita la generación automatizada de contratos de entrada/salida (*Request/Response DTOs*) para cada caso de uso.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Violación de la Regla de Dependencia)

```python
# Antipatrón: El caso de uso depende directamente de capas externas (FastAPI y SQLAlchemy)
from fastapi import Request, HTTPException
from sqlalchemy.orm import Session
from models import ArticleDBModel  # Modelo atado al ORM

class PublishArticleUseCase:
    # ERROR: El caso de uso conoce la sesión del ORM y la petición HTTP externa
    def __init__(self, db_session: Session):
        self.db = db_session

    def execute(self, request: Request, article_id: int):
        user = request.state.user  # Acoplado a la infraestructura web
        article = self.db.query(ArticleDBModel).filter_by(id=article_id).first()
        if not article:
            raise HTTPException(status_code=404, detail="No encontrado") # Acoplado a HTTP
        
        article.is_published = True
        self.db.commit()
```

### ✅ Código Correcto (Conforme a Clean Architecture: Dependencia Centrípeta)

```python
# 1. CAPA DE ENTIDAD: src/domain/entities/article.py (Pura, sin frameworks)
from dataclasses import dataclass

@dataclass
class Article:
    id: int
    title: str
    is_published: bool = False

    def publish(self) -> None:
        """Regla de negocio pura de la entidad."""
        if self.is_published:
            raise ValueError("El artículo ya ha sido publicado previamente.")
        self.is_published = True

# 2. CAPA DE CASO DE USO: src/application/use_cases/publish_article.py
from typing import Protocol
from dataclasses import dataclass

class ArticleRepository(Protocol):
    """Contrato abstracto para persistencia (Gateway)."""
    def get_by_id(self, article_id: int) -> Article | None:
        ...
    def save(self, article: Article) -> None:
        ...

@dataclass(frozen=True)
class PublishArticleInputDTO:
    article_id: int

class PublishArticleUseCase:
    """Caso de uso de aplicación: orquesta la entidad y el repositorio."""
    def __init__(self, repository: ArticleRepository) -> None:
        self._repository = repository

    def execute(self, input_dto: PublishArticleInputDTO) -> Article:
        article = self._repository.get_by_id(input_dto.article_id)
        if article is None:
            raise ValueError(f"Artículo con ID {input_dto.article_id} no encontrado.")

        article.publish()
        self._repository.save(article)
        return article
```

## 5. Descripción Didáctica de los Cambios

1. **Aislamiento de la Entidad:** `Article` encapsula la regla de no republicación sin importar la tecnología de base de datos.
2. **Caso de Uso Puro con DTO:** `PublishArticleUseCase` opera sobre `PublishArticleInputDTO` e interfaces abstractas (`ArticleRepository`), sin referencias a `FastAPI`, `HTTPException` ni `SQLAlchemy`.
3. **Flujo de Control y Dependencia:** Las capas externas (controlador FastAPI y repositorio SQLAlchemy) adaptarán las peticiones e implementarán la interfaz apuntando hacia adentro.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobrecarga de Mapeo de Datos (*Mapping Fatigue*):** En aplicaciones con modelos simples, transformar constantemente datos entre `ORM Model -> Entity -> Input DTO -> Output DTO -> View Model` añade un volumen significativo de código boilerplate.
- **Proyectos de Corto Alcance / Prototipos:** Para PoCs o microservicios que solo realizan transformaciones ETL básicas, la Clean Architecture completa puede resultar contraproducente en tiempo de entrega.
- **Curva de Aprendizaje:** Requiere un entendimiento riguroso del equipo sobre qué lógica corresponde a una entidad vs. un caso de uso vs. un adaptador.

## 7. Checklist de Verificación

- [ ] ¿Las entidades y casos de uso están 100% libres de dependencias de frameworks web (FastAPI, Flask) o bases de datos (SQLAlchemy, Django ORM)?
- [ ] ¿El código fuente de las capas internas no contiene importaciones de capas externas (*Regla de Dependencia*)?
- [ ] ¿Los casos de uso reciben y devuelven estructuras de datos desacopladas (DTOs / Entidades puras)?
- [ ] ¿Es posible ejecutar la suite de casos de uso de la aplicación sin iniciar servicios externos?