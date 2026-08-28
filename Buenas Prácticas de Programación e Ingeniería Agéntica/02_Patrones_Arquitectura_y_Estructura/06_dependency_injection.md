---
id: bp_32fp9sq8y4bjq8cxv6x8be2q02
name: 06_dependency_injection
title: "Inyección de Dependencias (Dependency Injection - DI)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/06_dependency_injection.md
version: 1.1.0
category: architecture
tags: [dependency-injection, di, testability, decoupling, universal_principles]
description: "Inyección de Dependencias: suministro externo de componentes para máxima testabilidad y desacoplamiento."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 06 - Inyección de Dependencias (Dependency Injection - DI)

## 1. Definición y Fundamento Teórico

Formalizado por **Martin Fowler** en su seminal artículo *Inversion of Control Containers and the Dependency Injection pattern* (2004) como la materialización práctica del Principio de Inversión de Dependencias (DIP), la **Inyección de Dependencias (DI)** es una técnica de diseño que establece:

> *"Un objeto no debe ser responsable de buscar, instanciar o configurar sus propias dependencias; en su lugar, las dependencias deben ser suministradas ('inyectadas') desde el exterior por un ensamblador o cliente."*

Las tres variantes primarias de inyección son:
1. **Inyección por Constructor (*Constructor Injection*):** Las dependencias requeridas se declaran como parámetros obligatorios en `__init__` (la más segura e idiomática).
2. **Inyección por Método (*Method/Parameter Injection*):** La dependencia se pasa únicamente al método específico que la necesita.
3. **Inyección por Propiedad (*Setter/Property Injection*):** Las dependencias opcionales se asignan mediante atributos o métodos *setter*.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del Acoplamiento Rígido:** Las clases no quedan atadas a implementaciones concretas ni a cadenas de conexión fijas en su código interno.
- **Testabilidad Unitaria Aislada:** Permite sustituir servicios costosos, lentos o externos (pasarelas de pago, APIs de LLMs, bases de datos) por implementaciones simuladas (*Fakes / Mocks*) en entornos de prueba.
- **Centralización de la Configuración (*Composition Root*):** La composición y cableado de todo el grafo de dependencias ocurre en un único punto de entrada de la aplicación.

## 3. Relevancia en Sistemas con IA Agéntica

- **Entornos Seguros de Evaluación para Agentes:** Los agentes autónomos pueden ejecutar ciclos completos de validación de código inyectando *fakes* en memoria sin riesgo de invocar APIs de pago externas ni alterar bases de datos de producción.
- **Modularidad de Tools para LLMs:** Permite parametrizar las herramientas expuestas al agente (inyectando diferentes configuraciones de contexto o límites de ejecución) sin modificar el código de la herramienta.
- **Claridad de Requisitos:** Las firmas de constructor explícitas permiten a los modelos de lenguaje deducir inmediatamente qué servicios necesita una clase para operar.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Instanciación Interna Rígida)

```python
# Antipatrón: La clase instancia directamente sus dependencias concretas
import smtplib
import sqlite3

class NotificationNotifier:
    def __init__(self):
        # ERROR: Instanciación interna rígida (Hardcoded dependency)
        # Imposible de testear sin una base de datos SQLite y servidor SMTP activo
        self.db = sqlite3.connect("users.db")
        self.smtp = smtplib.SMTP("smtp.empresa.com", 587)

    def alert_user(self, user_id: str, message: str) -> None:
        cursor = self.db.cursor()
        cursor.execute("SELECT email FROM users WHERE id = ?", (user_id,))
        email = cursor.fetchone()[0]
        self.smtp.sendmail("alerts@empresa.com", email, message)
```

### ✅ Código Correcto (Conforme a DI: Inyección por Constructor con Protocolos)

```python
# src/domain/contracts.py
from typing import Protocol

class UserLookupService(Protocol):
    def get_email_by_id(self, user_id: str) -> str | None:
        ...

class EmailSender(Protocol):
    def send_email(self, to_address: str, content: str) -> None:
        ...

# src/services/notifications.py (Dependencias Inyectadas Explícitamente)
class NotificationNotifier:
    """Servicio desacoplado: recibe sus colaboradores en el constructor."""
    def __init__(
        self,
        user_lookup: UserLookupService,
        email_sender: EmailSender
    ) -> None:
        self._user_lookup = user_lookup
        self._email_sender = email_sender

    def alert_user(self, user_id: str, message: str) -> None:
        email = self._user_lookup.get_email_by_id(user_id)
        if email is None:
            raise ValueError(f"Usuario no encontrado: {user_id}")

        self._email_sender.send_email(to_address=email, content=message)
```

## 5. Descripción Didáctica de los Cambios

1. **Inyección por Constructor:** `NotificationNotifier` recibe `user_lookup` y `email_sender` a través de `__init__`.
2. **Contratos Abstractos:** Utiliza `Protocol` de Python para definir las interfaces requeridas, permitiendo inyectar clientes reales en producción y fakes en pruebas.
3. **Control Total en Tests:** En una prueba unitaria, un agente de IA puede pasar un diccionario simple como `user_lookup` y una lista acumuladora como `email_sender` sin tocar la red.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Contenedores Mágicos de DI Hipercomplejos:** En ecosistemas Python, usar librerías de inyección mágica con reflexión y decoradores oscuros puede generar dificultad de depuración; la inyección manual explícita (*Pure DI*) suele ser más idiomática y clara.
- **Sobrecarga en Clases Simples de Utilidad Pura:** Clases que no tienen estado ni interactúan con I/O (ej. funciones matemáticas o parseadores de texto puro) no requieren inyección de dependencias.
- **Paso en Cascada de Dependencias (*Prop Drilling*):** Si una clase intermedia tiene que recibir 10 dependencias solo para pasarlas a objetos hijos sin usarlas, indica un problema de diseño o cohesión deficiente.

## 7. Checklist de Verificación

- [ ] ¿Las clases declaran todas sus dependencias de I/O en sus constructores en lugar de crearlas internamente?
- [ ] ¿Las dependencias inyectadas están tipadas mediante abstracciones (`Protocol` / `ABC`)?
- [ ] ¿Existe un único punto de ensamblado (*Composition Root*) donde se configuran e instancian los servicios reales?
- [ ] ¿Es posible instanciar la clase en un test unitario pasando implementaciones simuladas en memoria?