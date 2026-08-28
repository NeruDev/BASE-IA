---
id: bp_7t8pt3ksznahfv052rf69zccx8
name: 04_solid_principles
title: "Principios SOLID de Diseño de Software"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/01_Principios_Universales_y_Diseno/04_solid_principles.md
version: 1.1.0
category: universal_principles
tags: [solid, oop, design_patterns, srp, ocp, lsp, isp, dip, universal_principles]
description: "Principios SOLID (SRP, OCP, LSP, ISP, DIP) aplicados a módulos y clases desacopladas."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T14:55:00Z
schema_version: 1.0.0
---

# 04 - Principios SOLID de Diseño de Software

## 1. Definición y Fundamento Teórico

Compilados por **Robert C. Martin ("Uncle Bob")** a principios de los años 2000 y formalizados bajo el acrónimo sugerido por **Michael Feathers**, los cinco principios **SOLID** representan la base del diseño orientado a objetos y arquitectura limpia:

1. **S - Single Responsibility Principle (SRP):** Un módulo o clase debe tener una y solo una razón para cambiar (responder a un único actor o responsabilidad).
2. **O - Open/Closed Principle (OCP):** Las entidades de software deben estar abiertas a la extensión, pero cerradas a la modificación (comportamiento extensible mediante polimorfismo o composición sin alterar código probado).
3. **L - Liskov Substitution Principle (LSP):** Formulada por **Barbara Liskov** (1987): Si $S$ es un subtipo de $T$, los objetos de tipo $T$ deben poder ser reemplazados por objetos de tipo $S$ sin alterar las propiedades deseadas del programa.
4. **I - Interface Segregation Principle (ISP):** Los clientes no deben verse obligados a depender de interfaces o métodos que no utilizan (preferir interfaces delgadas y específicas sobre interfaces monolíticas).
5. **D - Dependency Inversion Principle (DIP):** Los módulos de alto nivel no deben depender de módulos de bajo nivel; ambos deben depender de abstracciones (interfaces o protocolos). Las abstracciones no deben depender de los detalles; los detalles deben depender de las abstracciones.

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Fragilidad del Software:** Evita que un cambio en un módulo cause fallos inesperados en cascada en partes no relacionadas.
- **Testabilidad Aislada:** Permite sustituir dependencias de I/O pesado (bases de datos, redes) por mocks o fakes en memoria mediante inversión de dependencias.
- **Evolución Sostenible:** Facilita añadir nuevas funcionalidades sin tener que reescribir ni re-testear componentes existentes estables.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prevención de Clases Monolíticas ("God Objects"):** Los agentes de IA se desorientan fácilmente cuando una sola clase supera cientos de líneas mezclando persistencia, lógica y red.
- **Modularidad de Prompts y Tareas:** Con interfaces segregadas (ISP) y responsabilidad única (SRP), un agente puede refactorizar un repositorio o un conector de base de datos sin necesidad de cargar todo el código del sistema en su ventana de contexto.
- **Inyección de Mocks para Verificación Automatizada:** Permite a los agentes ejecutar pruebas unitarias locales inmediatas sin requerir credenciales externas o servicios de terceros activos.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Violación Múltiple de SOLID)

```python
# Antipatrón: Viola SRP (mezcla validación, persistencia SQLite y envío SMTP),
# OCP (modificar para soportar PostgreSQL u otro notificador) y DIP (acoplamiento directo a implementaciones concretas).
import sqlite3
import smtplib

class UserManager:
    def register_user(self, email: str, raw_password: str) -> None:
        # Validación interna
        if "@" not in email or len(raw_password) < 8:
            raise ValueError("Datos inválidos.")

        # Persistencia concreta acoplada (Viola SRP y DIP)
        conn = sqlite3.connect("users.db")
        cursor = conn.cursor()
        cursor.execute("INSERT INTO users (email, password) VALUES (?, ?)", (email, raw_password))
        conn.commit()
        conn.close()

        # Envío directo acoplado a SMTP (Viola SRP y DIP)
        server = smtplib.SMTP("smtp.example.com")
        server.sendmail("noreply@app.com", email, "Bienvenido a la plataforma")
        server.quit()
```

### ✅ Código Correcto (Conforme a SOLID: SRP, DIP, ISP y OCP)

```python
# src/domain/user.py
from typing import Protocol
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    email: str
    password_hash: str

# Interfaces delgadas (ISP y DIP)
class UserRepository(Protocol):
    def save(self, user: User) -> None:
        ...

class NotificationService(Protocol):
    def notify(self, recipient: str, message: str) -> None:
        ...

# Servicio con Responsabilidad Única (SRP) e Inversión de Dependencias (DIP)
class UserRegistrationService:
    def __init__(
        self,
        repository: UserRepository,
        notifier: NotificationService
    ) -> None:
        self._repository = repository
        self._notifier = notifier

    def register(self, email: str, password_hash: str) -> User:
        """Registra un nuevo usuario y envía la notificación correspondiente."""
        if "@" not in email:
            raise ValueError(f"Email inválido: {email}")

        user = User(email=email, password_hash=password_hash)
        self._repository.save(user)
        self._notifier.notify(user.email, "Bienvenido a la plataforma.")
        return user
```

## 5. Descripción Didáctica de los Cambios

1. **SRP (Responsabilidad Única):** La lógica de orquestación reside en `UserRegistrationService`, mientras que el almacenamiento y el envío de notificaciones quedan delegados a componentes especializados.
2. **DIP & ISP (Inversión y Segregación):** Se definieron protocolos (`UserRepository`, `NotificationService`) que actúan como contratos limpios. `UserRegistrationService` no depende de SQLite ni de SMTP.
3. **OCP (Abierto a Extensión):** Es posible cambiar SQLite por PostgreSQL o SMTP por Amazon SES creando una nueva clase que implemente el protocolo, sin modificar una sola línea de `UserRegistrationService`.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobre-ingeniería en Scripts y Herramientas CLI Simples:** Aplicar los cinco principios con múltiples interfaces, inyectores de dependencias y fábricas en un script utilitario de 40 líneas añade sobrecarga cognitiva y lentitud de desarrollo sin beneficio tangible.
- **Indirección Excesiva:** Crear una interfaz por cada clase cuando solo existirá una única implementación durante todo el ciclo de vida del proyecto (*Interface Soup*) dificulta la navegación en el código.
- **Rendimiento Extremo:** En sistemas de procesamiento de datos de alta frecuencia (HFT, kernels gráficos), la indirección de punteros virtuales y el polimorfismo dinámico pueden tener un costo medible en cachés de CPU frente a llamadas directas.

## 7. Checklist de Verificación

- [ ] **SRP:** ¿Cada clase/módulo tiene una única responsabilidad conceptual y un solo motivo de cambio?
- [ ] **OCP:** ¿Se pueden añadir nuevos comportamientos mediante nuevas clases/funciones sin alterar el código existente probado?
- [ ] **LSP:** ¿Las subclases cumplen los mismos contratos e invariantes que sus clases padre sin romper expectativas?
- [ ] **ISP:** ¿Las interfaces son pequeñas y específicas en lugar de generales y pesadas?
- [ ] **DIP:** ¿Los módulos de alto nivel dependen de abstracciones (`Protocol`, `ABC`) en lugar de implementaciones concretas?