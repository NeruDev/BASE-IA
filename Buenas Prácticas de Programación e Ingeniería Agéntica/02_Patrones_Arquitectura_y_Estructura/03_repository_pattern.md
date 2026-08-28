---
id: bp_264h46tr5bbz8sb4stq7j0g6j0
name: 03_repository_pattern
title: "Patrón Repositorio (Repository Pattern)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/03_repository_pattern.md
version: 1.1.0
category: architecture
tags: [repository-pattern, persistence, ddd, data-access, universal_principles]
description: "Patrón Repositorio: mediación entre el dominio y la persistencia de datos."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 03 - Patrón Repositorio (Repository Pattern)

## 1. Definición y Fundamento Teórico

Formulado por **Eric Evans** en *Domain-Driven Design (DDD)* (2003) y formalizado por **Martin Fowler** en *Patterns of Enterprise Application Architecture* (2002), el **Patrón Repositorio** postula que:

> *"El acceso a las entidades de dominio persistidas debe abstraerse simulando una colección de objetos en memoria, encapsulando toda la lógica de consultas, mapeo de tablas e infraestructura de almacenamiento."*

El repositorio actúa como un mediador entre la capa de Dominio/Aplicación y la capa de acceso a datos, exponiendo métodos semánticos orientados a colecciones (`add`, `get_by_id`, `delete`, `list_active`) en lugar de operaciones directas de bases de datos (`SELECT`, `INSERT`, `UPDATE`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Desacoplamiento de la Persistencia:** La lógica de negocio no contiene sentencias SQL, consultas ORM ni detalles de conexión de red.
- **Sustitución de Infraestructura:** Permite migrar de SQLite a PostgreSQL, DynamoDB o una API externa modificando únicamente la clase del repositorio.
- **Testabilidad Aislada:** Facilita la creación de repositorios en memoria (`InMemoryRepository`) para ejecutar suites de tests completas sin base de datos real.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prevención de Alucinaciones e Inyecciones SQL:** Los agentes de IA generan errores frecuentes al escribir consultas SQL crudas o alucinar nombres de columnas. Una interfaz de repositorio fuertemente tipada guía al agente mediante autocompletado y validación estática.
- **Testing Inmediato en Entornos Agénticos:** Permite a los agentes ejecutar pruebas unitarias locales ultrarrápidas inyectando repositorios simulados basados en diccionarios.
- **Transparencia en Tool Calling:** Las herramientas de acceso a datos expuestas a los agentes pueden invocar métodos claros de repositorio (`user_repo.get_by_email(email)`) en lugar de requerir que el agente diseñe la query.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Consultas SQL Embebidas en la Lógica de Negocio)

```python
# Antipatrón: El servicio de negocio construye SQL crudo y gestiona la conexión
import sqlite3

class OrderProcessingService:
    def complete_order(self, order_id: str) -> None:
        conn = sqlite3.connect("ecommerce.db")
        cursor = conn.cursor()
        
        # ERROR: SQL disperso en la lógica de negocio, vulnerable y difícil de mockear
        cursor.execute("SELECT id, status, total FROM orders WHERE id = ?", (order_id,))
        row = cursor.fetchone()
        if not row:
            conn.close()
            raise ValueError("Orden no encontrada.")

        # Lógica de negocio mezclada con persistencia
        cursor.execute("UPDATE orders SET status = 'COMPLETED' WHERE id = ?", (order_id,))
        conn.commit()
        conn.close()
```

### ✅ Código Correcto (Conforme al Patrón Repositorio: Interfaz e Implementaciones)

```python
# src/domain/orders.py (Entidad y Contrato de Repositorio en Dominio)
from dataclasses import dataclass
from typing import Protocol

@dataclass
class Order:
    id: str
    total: float
    is_completed: bool = False

    def complete(self) -> None:
        if self.is_completed:
            raise ValueError("La orden ya se encuentra completada.")
        self.is_completed = True

class OrderRepository(Protocol):
    """Contrato del repositorio: simula una colección en memoria."""
    def get_by_id(self, order_id: str) -> Order | None:
        ...
    def save(self, order: Order) -> None:
        ...

# src/application/services.py (Servicio que consume la abstracción)
class OrderProcessingService:
    def __init__(self, repository: OrderRepository) -> None:
        self._repository = repository

    def complete_order(self, order_id: str) -> Order:
        order = self._repository.get_by_id(order_id)
        if order is None:
            raise ValueError(f"Orden no encontrada: {order_id}")

        order.complete()
        self._repository.save(order)
        return order

# src/infrastructure/in_memory_repository.py (Implementación para Tests/Agentes)
class InMemoryOrderRepository:
    """Implementación simulada en memoria para testing instantáneo."""
    def __init__(self) -> None:
        self._storage: dict[str, Order] = {}

    def get_by_id(self, order_id: str) -> Order | None:
        return self._storage.get(order_id)

    def save(self, order: Order) -> None:
        self._storage[order.id] = order
```

## 5. Descripción Didáctica de los Cambios

1. **Abstracción del Acceso a Datos:** `OrderRepository` define las operaciones esenciales (`get_by_id`, `save`) sin revelar si el almacenamiento es relacional, de documentos o en memoria.
2. **Entidad de Dominio Pura:** `Order` encapsula su regla de negocio (`complete()`), permitiendo que el servicio opere sobre objetos de dominio limpios.
3. **Soporte para Mocks en Tests:** `InMemoryOrderRepository` permite probar el flujo completo en microsegundos sin requerir archivos de base de datos ni migraciones.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Consultas Analíticas y Reportes Masivos (OLAP):** Cargar cientos de miles de entidades de dominio completas en memoria para calcular un promedio o generar un reporte tabular genera un consumo de memoria masivo. En estos casos, se utiliza el patrón **CQRS** con consultas DTO directas optimizadas.
- **Sobrecarga en Aplicaciones Simples con ORM Directo:** Si una aplicación sencilla ya utiliza un ORM con patrón *Active Record* (como Django ORM) y no requiere sustitución de motor ni arquitectura hexagonal, envolver cada modelo en un repositorio puede ser redundante.
- **Paginación y Filtrado Complejo Dinámico:** Diseñar métodos de repositorio para soportar combinaciones arbitrarias de decenas de filtros puede complicar la interfaz innecesariamente si no se usa el patrón *Specification*.

## 7. Checklist de Verificación

- [ ] ¿El repositorio expone una interfaz orientada a colecciones (`add`, `get_by_id`, `save`, `delete`)?
- [ ] ¿La capa de negocio está libre de sentencias SQL, sesiones de ORM o llamadas HTTP a bases de datos?
- [ ] ¿El repositorio retorna y recibe entidades de dominio puro o Value Objects?
- [ ] ¿Existe una implementación en memoria (`InMemoryRepository`) para ejecutar pruebas unitarias ultrarrápidas?