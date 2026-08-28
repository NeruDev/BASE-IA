---
id: bp_412vmpyk9taxda12m35rhmv02j
name: 01_hexagonal_architecture
title: "Arquitectura Hexagonal (Puertos y Adaptadores)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/02_Patrones_Arquitectura_y_Estructura/01_hexagonal_architecture.md
version: 1.1.0
category: architecture
tags: [hexagonal, ports-and-adapters, architecture, ddd, universal_principles]
description: "Arquitectura Hexagonal (Puertos y Adaptadores): aislamiento de I/O y mocks en memoria."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:00:00Z
schema_version: 1.0.0
---

# 01 - Arquitectura Hexagonal (Puertos y Adaptadores)

## 1. Definición y Fundamento Teórico

Propuesta por **Alistair Cockburn** en 2005 como el patrón *Ports and Adapters*, la **Arquitectura Hexagonal** establece que:

> *"Una aplicación debe estar estructurada de forma que su núcleo de lógica de negocio (Dominio) sea completamente agnóstico e independiente de las tecnologías externas (UI, bases de datos, APIs de terceros, LLMs, frameworks), comunicándose con el exterior exclusivamente a través de Puertos y Adaptadores."*

Los dos conceptos fundamentales son:
- **Puertos (*Ports*):** Interfaces o contratos (protocolos) definidos por y dentro del núcleo de la aplicación.
  - *Puertos Primarios / Conducentes (Driving/Inbound):* Definen la API de casos de uso que los actores externos (controladores HTTP, CLI, agentes) pueden invocar.
  - *Puertos Secundarios / Conducidos (Driven/Outbound):* Definen los servicios que el dominio necesita del exterior (repositorios de persistencia, proveedores de LLM, pasarelas de pago).
- **Adaptadores (*Adapters*):** Componentes concretos fuera del dominio que traducen las llamadas externas al formato del puerto o implementan los puertos conducidos usando tecnologías específicas (ej. `PostgreSQLAdapter`, `GeminiLLMAdapter`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Aislamiento Tecnológico Total:** Permite actualizar librerías, sustituir motores de base de datos o cambiar proveedores de nube sin modificar una sola línea del dominio central.
- **Testabilidad Inmediata en Memoria:** Facilita ejecutar el 100% de la lógica de negocio contra adaptadores simulados (*InMemoryFakes*) en milisegundos sin levantar infraestructura real.
- **Independencia de Frameworks:** El sistema no queda rehén de versiones de Django, FastAPI, Spring o librerías de persistencia.

## 3. Relevancia en Sistemas con IA Agéntica

- **Intercambiabilidad de Proveedores de Modelos (LLMs):** Permite cambiar el modelo base (OpenAI, Anthropic, Google Gemini, Ollama local) simplemente conectando un adaptador diferente sin tocar la orquestación del agente.
- **Evaluación y Testing Automatizado de Agentes:** Los agentes autónomos pueden probar sus herramientas contra adaptadores en memoria simulados sin incurrir en costos de inferencia ni alterar bases de datos productivas.
- **Delimitación de Contexto:** Al alimentar al LLM con el código de un caso de uso, el modelo no se distrae con conexiones de red ni sintaxis SQL compleja.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Dominio Acoplado a Proveedor Concreto)

```python
# Antipatrón: La lógica del agente está rígidamente acoplada a una librería de LLM y a SQLite
import openai
import sqlite3

class DocumentSummarizerService:
    def summarize_and_save(self, doc_id: str, text: str) -> str:
        # ACOPLAMIENTO DIRECTO: Dependencia rígida de OpenAI (imposible mockear limpiamente)
        client = openai.OpenAI(api_key="sk-secret")
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": f"Resume: {text}"}]
        )
        summary = response.choices[0].message.content

        # ACOPLAMIENTO DIRECTO: Persistencia SQLite incrustada
        conn = sqlite3.connect("data.db")
        conn.execute("INSERT INTO summaries (doc_id, summary) VALUES (?, ?)", (doc_id, summary))
        conn.commit()
        conn.close()

        return summary
```

### ✅ Código Correcto (Conforme a Arquitectura Hexagonal: Puertos y Adaptadores)

```python
# src/domain/ports.py (Puertos Secundarios - Interfaces en el Núcleo)
from typing import Protocol

class LLMProviderPort(Protocol):
    """Puerto que define el contrato de inferencia de lenguaje."""
    def generate_text(self, prompt: str) -> str:
        ...

class SummaryRepositoryPort(Protocol):
    """Puerto que define el contrato de persistencia de resúmenes."""
    def save_summary(self, doc_id: str, summary: str) -> None:
        ...

# src/domain/services.py (Núcleo de Dominio puro)
class DocumentSummarizerUseCase:
    """Caso de uso puro: depende exclusivamente de los puertos abstractos."""
    def __init__(
        self,
        llm_provider: LLMProviderPort,
        repository: SummaryRepositoryPort
    ) -> None:
        self._llm = llm_provider
        self._repository = repository

    def execute(self, doc_id: str, text: str) -> str:
        if not text.strip():
            raise ValueError("El texto a resumir no puede estar vacío.")

        prompt = f"Resume el siguiente documento de manera concisa:\n{text}"
        summary = self._llm.generate_text(prompt)
        self._repository.save_summary(doc_id, summary)
        return summary

# src/adapters/fake_adapters.py (Adaptadores para Testing Ultrarrápido)
class InMemoryLLMFake:
    def generate_text(self, prompt: str) -> str:
        return "Resumen simulado de prueba."

class InMemorySummaryRepositoryFake:
    def __init__(self) -> None:
        self.storage: dict[str, str] = {}

    def save_summary(self, doc_id: str, summary: str) -> None:
        self.storage[doc_id] = summary
```

## 5. Descripción Didáctica de los Cambios

1. **Definición de Puertos:** Se crearon protocolos abstractos (`LLMProviderPort`, `SummaryRepositoryPort`) dentro del dominio para representar los contratos de I/O.
2. **Caso de Uso Puro:** `DocumentSummarizerUseCase` desconoce si el texto es resumido por Gemini, OpenAI o un modelo local en Ollama, y desconoce si el almacenamiento es PostgreSQL o memoria.
3. **Adaptabilidad Instantánea:** En entornos de testing unitario o simulación de agentes, se inyectan `InMemoryLLMFake` y `InMemorySummaryRepositoryFake`, ejecutando pruebas en milisegundos sin coste de API.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Aplicaciones CRUD Simples o MVPs:** Si la aplicación únicamente lee y escribe tablas directamente sin reglas de negocio complejas, crear capas de puertos y adaptadores genera sobrecarga y *boilerplate* injustificado.
- **Herramientas de Línea de Comandos de Un Solo Uso:** Para scripts utilitarios o automatizaciones efímeras, la arquitectura hexagonal introduce una complejidad estructural excesiva.
- **Sobrecarga Inicial de Archivos:** Requiere una disciplina estricta de estructura de carpetas y múltiples clases/protocolos para cada integración.

## 7. Checklist de Verificación

- [ ] ¿El núcleo de dominio está libre de librerías de frameworks externos, clientes de LLM o clientes de bases de datos?
- [ ] ¿Todas las dependencias de I/O están declaradas como Puertos (`Protocol` o `ABC`) dentro del dominio?
- [ ] ¿Los adaptadores concretos implementan los puertos sin filtrar detalles tecnológicos al núcleo?
- [ ] ¿Existe una suite de pruebas unitarias que verifique la lógica del dominio usando adaptadores simulados en memoria?