---
id: tmpl_01m13dbjg4edysrf12yamyhv8a
name: guia_rapida_buenas_practicas
title: "Guía Rápida Universal de Buenas Prácticas de Ingeniería Agéntica y Desarrollo de Software"
file_path: formato_minimo/guia_rapida_buenas_practicas.md
version: 2.0.0
category: guides
tags: [best-practices, agentic-engineering, architecture-patterns, testing-ci-cd, observability, security, documentation, context-engineering, guardrails, cognitive-environment, complete-checklists, quick-reference]
description: "Compendio y guía rápida de referencia universal de 97 buenas prácticas con definiciones, casos de uso, límites operativos, directivas agénticas y checklists completas de verificación para agentes autónomos de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T23:30:00Z
updated_at: 2026-08-27T23:38:00Z
schema_version: 1.0.0
---

# Guía Rápida de Buenas Prácticas de Ingeniería Agéntica y Arquitectura

Este documento constituye el **compendio y catálogo de referencia rápida universal** de las 97 buenas prácticas de ingeniería de software y desarrollo asistido por IA (Secciones 2 a 9). Ha sido diseñado para ser **100% portable, desacoplado de repositorios locales y optimizado para la consulta rápida en $O(1)$ de tokens**, conteniendo las **checklists completas de verificación** para servir como base de pruebas automatizadas y auditoría técnica.

> [!NOTE]
> Para los **13 Principios Universales y de Diseño de Software** (DRY, KISS, YAGNI, SOLID, SoC, SSOT, Encapsulamiento, Modularidad, Cohesión/Acoplamiento, Fail Fast, Programación Defensiva, Lo Explícito sobre lo Implícito y Convención sobre Configuración), consultar [`principios_universales_guia.md`](principios_universales_guia.md).

---

## Índice de Secciones

1. [Sección 2: Patrones de Arquitectura y Estructura](#sección-2-patrones-de-arquitectura-y-estructura)
2. [Sección 3: Calidad, Testing y CI/CD](#sección-3-calidad-testing-y-cicd)
3. [Sección 4: Análisis Estático, Observabilidad y Operaciones](#sección-4-análisis-estático-observabilidad-y-operaciones)
4. [Sección 5: Seguridad, Versionado y Reversibilidad](#sección-5-seguridad-versionado-y-reversibilidad)
5. [Sección 6: Documentación y Gestión de Conocimiento](#sección-6-documentación-y-gestión-de-conocimiento)
6. [Sección 7: Ingeniería Agéntica y Control de Contexto](#sección-7-ingeniería-agéntica-y-control-de-contexto)
7. [Sección 8: Alcance, Guardrails y Validación para IA](#sección-8-alcance-guardrails-y-validación-para-ia)
8. [Sección 9: Entorno Cognitivo y Capas Operativas para IA](#sección-9-entorno-cognitivo-y-capas-operativas-para-ia)

---


## Sección 2: Patrones de Arquitectura y Estructura

### 2.1 Arquitectura Hexagonal (Puertos y Adaptadores)
- **Definición:** Arquitectura Hexagonal (Puertos y Adaptadores): aislamiento de I/O y mocks en memoria.
- **Límites y Anti-Patrones:** Aplicaciones CRUD Simples o MVPs:** Si la aplicación únicamente lee y escribe tablas directamente sin reglas de negocio complejas, crear capas de puertos y adaptadores genera sobrecarga y *boilerplate* injustificado. | Herramientas de Línea de Comandos de Un Solo Uso:** Para scripts utilitarios o automatizaciones efímeras, la arquitectura hexagonal introduce una complejidad estructural excesiva.
- **Checklist Completa de Verificación:**
  - [ ] ¿El núcleo de dominio está libre de librerías de frameworks externos, clientes de LLM o clientes de bases de datos?
  - [ ] ¿Todas las dependencias de I/O están declaradas como Puertos (`Protocol` o `ABC`) dentro del dominio?
  - [ ] ¿Los adaptadores concretos implementan los puertos sin filtrar detalles tecnológicos al núcleo?
  - [ ] ¿Existe una suite de pruebas unitarias que verifique la lógica del dominio usando adaptadores simulados en memoria?

### 2.2 Clean Architecture (Arquitectura Limpia)
- **Definición:** Clean Architecture: regla de dependencia centrípeta hacia las entidades de dominio puro.
- **Límites y Anti-Patrones:** Sobrecarga de Mapeo de Datos (*Mapping Fatigue*):** En aplicaciones con modelos simples, transformar constantemente datos entre `ORM Model -> Entity -> Input DTO -> Output DTO -> View Model` añade un volumen significativo de código boilerplate. | Proyectos de Corto Alcance / Prototipos:** Para PoCs o microservicios que solo realizan transformaciones ETL básicas, la Clean Architecture completa puede resultar contraproducente en tiempo de entrega.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las entidades y casos de uso están 100% libres de dependencias de frameworks web (FastAPI, Flask) o bases de datos (SQLAlchemy, Django ORM)?
  - [ ] ¿El código fuente de las capas internas no contiene importaciones de capas externas (*Regla de Dependencia*)?
  - [ ] ¿Los casos de uso reciben y devuelven estructuras de datos desacopladas (DTOs / Entidades puras)?
  - [ ] ¿Es posible ejecutar la suite de casos de uso de la aplicación sin iniciar servicios externos?

### 2.3 Repositorio (Repository Pattern)
- **Definición:** Patrón Repositorio: mediación entre el dominio y la persistencia de datos.
- **Límites y Anti-Patrones:** Consultas Analíticas y Reportes Masivos (OLAP):** Cargar cientos de miles de entidades de dominio completas en memoria para calcular un promedio o generar un reporte tabular genera un consumo de memoria masivo. En estos casos, se utiliza el patrón **CQRS** con consultas DTO directas optimizadas. | Sobrecarga en Aplicaciones Simples con ORM Directo:** Si una aplicación sencilla ya utiliza un ORM con patrón *Active Record* (como Django ORM) y no requiere sustitución de motor ni arquitectura hexagonal, envolver cada modelo en un repositorio puede ser redundante.
- **Checklist Completa de Verificación:**
  - [ ] ¿El repositorio expone una interfaz orientada a colecciones (`add`, `get_by_id`, `save`, `delete`)?
  - [ ] ¿La capa de negocio está libre de sentencias SQL, sesiones de ORM o llamadas HTTP a bases de datos?
  - [ ] ¿El repositorio retorna y recibe entidades de dominio puro o Value Objects?
  - [ ] ¿Existe una implementación en memoria (`InMemoryRepository`) para ejecutar pruebas unitarias ultrarrápidas?

### 2.4 Arquitectura Orientada a Eventos (Event-Driven Architecture - EDA)
- **Definición:** Arquitectura Orientada a Eventos: desacoplamiento temporal y espacial mediante eventos inmutables.
- **Límites y Anti-Patrones:** Complejidad de Depuración y Trazabilidad:** Al no existir un flujo secuencial directo en código, rastrear el camino de un evento requiere herramientas de *Distributed Tracing* (OpenTelemetry, Correlation IDs). | Consistencia Eventual (*Eventual Consistency*):** Los suscriptores procesan los datos con cierto desfase temporal; no es adecuado para operaciones que exigen consistencia transaccional inmediata ACID en la misma base de datos.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los eventos representan hechos en tiempo pasado (`OrderPaid`, `AgentFinished`) y son completamente inmutables?
  - [ ] ¿Los emisores de eventos desconocen la existencia y número de suscriptores?
  - [ ] ¿Cada evento contiene marcas temporales (`timestamp`) e identificadores de correlación (*trace/correlation ID*)?
  - [ ] ¿Se cuenta con mecanismos para prevenir bucles de retroalimentación de eventos y gestionar la consistencia eventual?

### 2.5 Patrones de Presentación: MVC, MVP y MVVM
- **Definición:** Patrones de Presentación: separación estricta entre modelo de datos, estado y vistas de usuario.
- **Límites y Anti-Patrones:** Servicios Backend Puros y Microservicios:** En APIs REST/gRPC que no disponen de interfaces visuales humanas, la estructura MVC tradicional o la arquitectura en capas (Clean Architecture / Hexagonal) es más pertinente que MVP o MVVM. | Complejidad del Data-Binding Oculto:** En MVVM con frameworks de enlace complejos, diagnosticar por qué una propiedad no se actualiza en la vista puede ser difícil debido a la magia reactiva de bindings bidireccionales.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los componentes visuales (vistas) carecen de lógica de cálculo de negocio y accesos directos a bases de datos?
  - [ ] ¿Es posible testear unitariamente el ViewModel/Presenter/Controller sin renderizar componentes gráficos?
  - [ ] ¿El Modelo de datos es independiente de la tecnología de presentación (HTML, CLI, GUI)?
  - [ ] ¿La comunicación entre la vista y el modelo está canalizada de forma unidireccional o mediante enlace de datos controlado?

### 2.6 Inyección de Dependencias (Dependency Injection - DI)
- **Definición:** Inyección de Dependencias: suministro externo de componentes para máxima testabilidad y desacoplamiento.
- **Límites y Anti-Patrones:** Contenedores Mágicos de DI Hipercomplejos:** En ecosistemas Python, usar librerías de inyección mágica con reflexión y decoradores oscuros puede generar dificultad de depuración; la inyección manual explícita (*Pure DI*) suele ser más idiomática y clara. | Sobrecarga en Clases Simples de Utilidad Pura:** Clases que no tienen estado ni interactúan con I/O (ej. funciones matemáticas o parseadores de texto puro) no requieren inyección de dependencias.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las clases declaran todas sus dependencias de I/O en sus constructores en lugar de crearlas internamente?
  - [ ] ¿Las dependencias inyectadas están tipadas mediante abstracciones (`Protocol` / `ABC`)?
  - [ ] ¿Existe un único punto de ensamblado (*Composition Root*) donde se configuran e instancian los servicios reales?
  - [ ] ¿Es posible instanciar la clase en un test unitario pasando implementaciones simuladas en memoria?

### 2.7 Inversión de Control (Inversion of Control - IoC)
- **Definición:** Inversión de Control: delegación del ciclo de vida y control de ejecución a frameworks y motores de agentes.
- **Límites y Anti-Patrones:** Pérdida de Transparencia Secuencial (*Framework Mystery*):** Seguir el flujo exacto de ejecución paso a paso en depuración se vuelve más complejo cuando existen decenas de interceptores y middlewares activos. | Acoplamiento al Ciclo de Vida del Framework (*Vendor Lock-in*):** Adaptar el código a la estructura de un framework específico puede dificultar migrar a otro motor agéntico en el futuro.
- **Checklist Completa de Verificación:**
  - [ ] ¿El motor central gestiona el ciclo de vida transversal (medición, reintentos, auditoría) de forma unificada?
  - [ ] ¿Es posible registrar plugins, herramientas o hooks adicionales sin modificar el código fuente del motor?
  - [ ] ¿Los contratos de extensión (`Protocol` / callbacks) están claramente delimitados y tipados?
  - [ ] ¿Se evitó el exceso de indirección cuando una simple llamada secuencial directa es suficiente?

### 2.8 Enfoque API-First (API-First Design)
- **Definición:** Enfoque API-First: diseño formal de contratos OpenAPI y esquemas antes de la implementación.
- **Límites y Anti-Patrones:** Fases de Ideación y Prototipado Ultrarrápido:** Durante *hackathons* o pruebas de concepto donde la estructura del dato muta cada media hora, diseñar esquemas OpenAPI completos por adelantado puede ralentizar el descubrimiento inicial. | Interfaces Internas de un Mismo Proceso:** Para comunicación entre clases privadas dentro de un único paquete de software cerrado, las firmas de función con tipos en Python son suficientes sin requerir esquemas de API externos.
- **Checklist Completa de Verificación:**
  - [ ] ¿El contrato de la API (esquemas de request, response y códigos de error) se diseñó antes de escribir la lógica de negocio?
  - [ ] ¿Los esquemas incluyen restricciones de validación explícitas (rangos, longitudes, expresiones regulares)?
  - [ ] ¿La especificación OpenAPI/JSON Schema está disponible para alimentar la definición de herramientas de agentes de IA?
  - [ ] ¿Los equipos y agentes de frontend/consumidores pueden desarrollar y testear contra mocks basados en el contrato?

### 2.9 Pruebas de Contrato (Contract Testing)
- **Definición:** Pruebas de Contrato: verificación desacoplada y asíncrona de compatibilidad entre servicios consumidores y proveedores.
- **Límites y Anti-Patrones:** No Reemplaza Pruebas de Negocio Profundas:** El contract testing valida la *forma* de los mensajes y respuestas, pero no valida si el cálculo financiero interno del proveedor es matemáticamente correcto. | No Apto para APIs Públicas de Acceso Masivo Desconocido:** En APIs públicas abiertas (ej. Twitter/X API pública), el proveedor no puede recolectar los contratos de millones de consumidores individuales; en ese caso se utiliza *Provider-Driven Versioning*.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los contratos capturan únicamente los campos que el consumidor realmente utiliza?
  - [ ] ¿El proveedor ejecuta pruebas de verificación de contrato en su pipeline de CI antes de fusionar código?
  - [ ] ¿Se cuenta con un repositorio central de contratos (*Pact Broker* o esquemas versionados) para compartir contratos?
  - [ ] ¿Se reemplazaron pruebas E2E lentas e inestables por pruebas de contrato aisladas?

### 2.10 Inmutabilidad por Defecto (Immutability by Default)
- **Definición:** Inmutabilidad por defecto: estructuras de datos inmutables y funciones puras para concurrencia segura.
- **Límites y Anti-Patrones:** Procesamiento Numérico y Gráfico de Alto Rendimiento:** En algoritmos de machine learning (PyTorch, TensorFlow, OpenCV) o procesamiento masivo de arrays (NumPy), mutar buffers de memoria directamente (*in-place*) es indispensable para evitar saturar la memoria RAM y el recolector de basura (*Garbage Collector*). | Sobrecarga de Asignación en Bucles Intensivos:** Si un bucle ejecuta 10 millones de iteraciones por segundo creando nuevos objetos en cada ciclo, el costo de CPU de crear y destruir instancias puede ser inaceptable.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las entidades de valor (*Value Objects*), mensajes y eventos están configurados como inmutables (`@dataclass(frozen=True)` o `tuple`)?
  - [ ] ¿Las operaciones que transforman datos retornan nuevas instancias en lugar de modificar el objeto recibido?
  - [ ] ¿Se eliminaron variables globales mutables compartidas entre hilos o corrutinas asíncronas?
  - [ ] ¿Se evaluó el impacto de rendimiento en secciones con procesamiento intensivo de datos numéricos o streaming de alta frecuencia?

### 2.11 Expand and Contract (Parallel Change) para Migraciones y Refactorizaciones
- **Definición:** Guía del patrón de diseño arquitectónico Expand and Contract para ejecutar refactorizaciones y migraciones sin disrupción ni downtime.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó expand and contract (parallel change) para migraciones y refactorizaciones conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 3: Calidad, Testing y CI/CD

### 3.1 Código Limpio (Clean Code)
- **Definición:** Código Limpio: legibilidad inmediata, funciones pequeñas, nombres con intención y abstracción coherente.
- **Límites y Anti-Patrones:** Micro-fragmentación Excesiva (*Function Proliferation*):** Dividir una función lineal y clara de 15 líneas en 7 micro-funciones de 2 líneas que solo se llaman una vez añade saltos visuales y sobrecarga mental sin beneficio real. | Rendimiento Extremo en Bucles Críticos:** En algoritmos de cómputo intensivo o procesamiento de imágenes a nivel de píxel, la extracción excesiva de funciones pequeñas puede tener impacto por la sobrecarga de *call-stack* (en lenguajes interpretados).
- **Checklist Completa de Verificación:**
  - [ ] ¿Los nombres de funciones y variables expresan con claridad su propósito sin necesidad de adivinar?
  - [ ] ¿Cada función opera en un único nivel de abstracción y tiene una responsabilidad acotada?
  - [ ] ¿Se eliminaron números mágicos y cadenas de texto hardcodeadas en favor de constantes nombradas?
  - [ ] ¿El código carece de comentarios que simplemente repiten lo que el código ya dice de forma evidente?

### 3.2 La Regla del Boy Scout (The Boy Scout Rule)
- **Definición:** Regla del Boy Scout: refactorizaciones pequeñas, continuas y acotadas en el código tocado.
- **Límites y Anti-Patrones:** Desviación del Alcance (*Scope Creep*):** La regla del Boy Scout no autoriza reescribir la arquitectura de un módulo entero, cambiar frameworks o alterar interfaces públicas compartidas en un PR de un bugfix menor. | Falta de Pruebas Unitarias:** Si el código que se toca carece de pruebas automatizadas, refactorizarlo a ciegas puede introducir regresiones inadvertidas; en ese caso, la prioridad es escribir primero una prueba antes de limpiar.
- **Checklist Completa de Verificación:**
  - [ ] ¿La tarea principal solicitada fue completada de forma correcta y prioritaria?
  - [ ] ¿Se mejoró algún detalle menor adyacente (nombres, tipos, eliminación de número mágico o código muerto)?
  - [ ] ¿La refactorización se mantuvo estrictamente acotada al contexto inmediato del cambio?
  - [ ] ¿Todos los tests existentes pasan con éxito tras la micro-limpieza?

### 3.3 Diseño por Contrato (Design by Contract - DbC)
- **Definición:** Diseño por Contrato: especificación formal de precondiciones, postcondiciones e invariantes de clase.
- **Límites y Anti-Patrones:** DbC vs. Validación Defensiva en Fronteras:** DbC asume que dentro del sistema los módulos cooperan bajo contratos. Para datos no confiables de usuarios externos o LLMs en crudo, se requiere **validación defensiva previa** (ej. Pydantic) antes de entrar al núcleo DbC. | Sobrecarga de Rendimiento en Invariantes Complejas:** Si un invariante requiere recorrer un árbol de 100,000 nodos en cada llamada de método, el chequeo dinámico en producción puede degradar el rendimiento (suele desactivarse en producción manteniendo las precondiciones activas).
- **Checklist Completa de Verificación:**
  - [ ] ¿Están documentadas y verificadas las precondiciones que el llamador debe cumplir?
  - [ ] ¿Se garantizan las postcondiciones que el método promete entregar tras su ejecución?
  - [ ] ¿La clase mantiene un invariante de integridad que se verifica en cada estado observable?
  - [ ] ¿Se distingue claramente entre la validación de entrada externa (defensiva) y los contratos internos de diseño (DbC)?

### 3.4 La Pirámide de Pruebas (Test Pyramid)
- **Definición:** Pirámide de Pruebas: base amplia de tests unitarios ultrarrápidos, integración equilibrada y mínimos tests E2E.
- **Límites y Anti-Patrones:** El Trofeo de Pruebas (*Testing Trophy*):** En aplicaciones web modernas con lógica de negocio delegada a servicios integrados (BFFs, GraphQL, lambdas intermediarias), las **pruebas de integración** con base de datos en memoria (SQLite/testcontainers) pueden ofrecer un mejor retorno de inversión (ROI) que obsesionarse con tests unitarios hiper-aislados con mocks. | Herramientas de Integración Exclusivas:** Para drivers de hardware o clientes de APIs de terceros donde casi no existe lógica pura, la base de la pirámide naturalmente se desplaza hacia pruebas de integración y contratos.
- **Checklist Completa de Verificación:**
  - [ ] ¿La suite de pruebas unitarias se ejecuta en menos de 10 segundos en local?
  - [ ] ¿Los tests unitarios están libres de dependencias de red, sockets y bases de datos reales?
  - [ ] ¿La gran mayoría (~70-80%) de los casos límite y ramas de decisión se cubren a nivel unitario?
  - [ ] ¿Las pruebas E2E se reservan exclusivamente para los caminos críticos (*Happy Paths*) del negocio?

### 3.5 TDD: Test-Driven Development
- **Definición:** Test-Driven Development: ciclo Red-Green-Refactor para desarrollo guiado por pruebas.
- **Límites y Anti-Patrones:** Spikes de Investigación y PoCs Desconocidos:** Cuando no se comprende cómo funciona una librería externa o un algoritmo experimental, forzar TDD puede bloquear la creatividad; en esos casos se realiza un *Spike* de código exploratorio y luego se reescribe con TDD. | Diseño Visual e Interfaces Gráficas Cambiantes:** Diseñar la estética de un frontend mediante TDD es ineficiente; es preferible usar herramientas visuales interactivas y aplicar TDD al ViewModel o capa lógica.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se escribió y ejecutó la prueba unitaria antes de comenzar el código de producción?
  - [ ] ¿Se verificó que la prueba fallara inicialmente por la razón correcta (fase Red)?
  - [ ] ¿Se implementó la solución más sencilla posible para pasar la prueba (fase Green)?
  - [ ] ¿Se realizó una refactorización de limpieza garantizando que todos los tests continúen en verde?

### 3.6 BDD: Behavior-Driven Development
- **Definición:** Behavior-Driven Development: especificación formal del comportamiento en escenarios Given-When-Then.
- **Límites y Anti-Patrones:** Sobrecarga de Pegamento (*Glue Code Maintenance*):** Utilizar frameworks BDD pesados (como Cucumber o Behave) para funciones técnicas internas añade una capa de indirección innecesaria frente a un test directo con `pytest`. | No Apto para Lógica Algorítmica de Bajo Nivel:** Algoritmos de encriptación, drivers de red o parsing binario se benefician más de TDD unitario directo que de historias de usuario Given-When-Then.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los escenarios están redactados desde la perspectiva del comportamiento de negocio sin detalles técnicos de implementación?
  - [ ] ¿Se utiliza la estructura formal *Given-When-Then* de forma coherente?
  - [ ] ¿Los tests verifican resultados observables en lugar del estado interno privado de las clases?
  - [ ] ¿Se reservó el uso de BDD para flujos de negocio y criterios de aceptación principales?

### 3.7 Pruebas de Regresión Automatizadas
- **Definición:** Pruebas de Regresión: blindaje automatizado contra fallos introducidos por agentes y refactorizaciones.
- **Límites y Anti-Patrones:** Sobrecarga de Tiempo de Ejecución (*Test Suite Bloat*):** Acumular miles de pruebas pesadas sin optimización puede hacer que la suite tarde horas. Es indispensable categorizar en **Smoke Regression** (rápida para PRs) y **Full Regression** (nocturna). | Pruebas de Regresión Obsoletas:** Mantener tests que validan comportamientos o flujos de negocio que ya fueron explícitamente reemplazados introduce fricción y falsos negativos.
- **Checklist Completa de Verificación:**
  - [ ] ¿Cada corrección de bug incluye una prueba de regresión automatizada que reproduce el problema?
  - [ ] ¿La suite de regresión se ejecuta automáticamente en cada commit o Pull Request?
  - [ ] ¿Los tests de regresión están categorizados para optimizar los tiempos de ejecución en CI?
  - [ ] ¿Se eliminan o actualizan periódicamente las pruebas de regresión asociadas a características deprecadas?

### 3.8 Integración Continua (Continuous Integration - CI)
- **Definición:** Integración Continua: automatización de builds, linters, chequeo de tipos y pruebas en GitHub Actions.
- **Límites y Anti-Patrones:** Pipelines Excesivamente Lentos (>15 minutos):** Si el CI tarda demasiado, los desarrolladores y agentes pierden el ritmo de trabajo continuo; es crítico paralelizar jobs y almacenar dependencias en caché. | Tests Inestables (*Flaky Tests*):** Pruebas que fallan aleatoriamente por problemas de red destruyen la confianza del equipo en el CI; los tests inestables deben aislarse o repararse de inmediato.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un pipeline de CI automatizado configurado en el repositorio (GitHub Actions / GitLab CI)?
  - [ ] ¿El pipeline se ejecuta automáticamente en cada Pull Request antes de permitir la fusión?
  - [ ] ¿Se incluyen pasos de verificación de estilo (linters), tipos estáticos y pruebas unitarias?
  - [ ] ¿El tiempo total de ejecución del pipeline se mantiene por debajo de 10 minutos?

### 3.9 Entrega y Despliegue Continuo (CD)
- **Definición:** Entrega Continua: pipelines reproducibles de empaquetado, release y despliegue seguro con rollback.
- **Límites y Anti-Patrones:** Despliegue Continuo sin Observabilidad:** Aplicar despliegue continuo automático sin telemetría en tiempo real (APM, tasas de error, alertas) es peligroso; un fallo puede afectar a todos los usuarios antes de que el equipo lo note. | Entornos Altamente Regulados (Banca / Salud):** Sectores regulados exigen firmas y aprobaciones formales de auditoría humana por ley; en estos casos se adopta *Continuous Delivery* con una compuerta manual de liberación.
- **Checklist Completa de Verificación:**
  - [ ] ¿El proceso de release y despliegue está 100% automatizado mediante scripts o pipelines de CD?
  - [ ] ¿Los artefactos de producción son inmutables y están etiquetados con versiones de Git (SemVer / Commit SHA)?
  - [ ] ¿El pipeline incluye verificaciones de salud post-despliegue (*Health Checks*) con reversión (*Rollback*) automática?
  - [ ] ¿Las migraciones de base de datos son compatibles hacia atrás con la versión previa del código?

### 3.10 Validación Automatizada de Cambios
- **Definición:** Validación Automatizada: hooks y scripts locales de chequeo determinista antes de confirmar cambios.
- **Límites y Anti-Patrones:** Sobrecarga de Tiempo en Local (>15 segundos):** Si la validación local ejecuta suites de pruebas pesadas o análisis lentos, los desarrolladores desactivarán los hooks (`git commit --no-verify`). Los chequeos locales deben ser ultrarrápidos (<5s). | Entornos Incompletos:** Pruebas que requieren bases de datos distribuidas pesadas o servicios en la nube no deben forzarse en validación local pre-commit; esas se delegan al pipeline de CI.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un script unificado de validación local (`scripts/validate.py` o comando `make validate`)?
  - [ ] ¿Los hooks de pre-commit ejecutan linters, chequeo de tipos y detección de secretos?
  - [ ] ¿El agente de IA tiene la instrucción explícita de ejecutar el script de validación antes de dar por cerrada su tarea?
  - [ ] ¿La suite de validación local se ejecuta en menos de 5 segundos?

### 3.11 Validación en Capas (Layered Validation)
- **Definición:** Validación en Capas: ejecución escalonada y progresiva (Sintaxis -> Tipos -> Unit -> Integración -> E2E).
- **Límites y Anti-Patrones:** Ejecución Paralela en CI de Alta Capacidad:** En entornos de CI distribuidos en la nube con decenas de runners libres, ejecutar Capa 1 (Linter), Capa 2 (Tipos) y Capa 3 (Unit tests) **en paralelo** puede reducir el tiempo total de reloj (*Wall Clock Time*), a costa de consumir más minutos de CPU simultáneos. | Proyectos Minúsculos de un Solo Archivo:** Para un script de 30 líneas, montar un pipeline de 5 capas es innecesario frente a una simple ejecución directa de `pytest`.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los chequeos de calidad se ejecutan en orden estricto de menor a mayor costo temporal?
  - [ ] ¿El proceso se detiene inmediatamente ante el primer fallo detectado sin ejecutar capas más pesadas?
  - [ ] ¿Las dos primeras capas (formato y tipos estáticos) se resuelven en menos de 3 segundos?
  - [ ] ¿Las pruebas lentas (E2E y seguridad) están ubicadas en las capas finales del pipeline?

### 3.12 Refactorización Continua: Preservación de Invariantes y Reducción de Deuda Técnica
- **Definición:** Metodología y disciplina de refactorización continua de código para preservar la legibilidad y reducir la deuda técnica sin alterar el comportamiento observable.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó refactorización continua: preservación de invariantes y reducción de deuda técnica conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?

### 3.13 Criterios de Aceptación Objetivos y Definition of Done (DoD) Ejecutable
- **Definición:** Especificación de criterios de aceptación objetivos y definición formal de una Definition of Done (DoD) ejecutable y determinista para tareas asignadas a agentes de IA.
- **Checklist Completa de Verificación:**
  - [ ] Si el número de serie tiene menos de 8 caracteres, lanzar `ValidationError`.
  - [ ] No permitir duplicados en memoria durante el registro.
  - [ ] Agregar tests unitarios en `tests/unit/test_device_invariants.py` cubriendo casos límite.


## Sección 4: Análisis Estático, Observabilidad y Operaciones

### 4.1 Linting y Formateo Automático de Código
- **Definición:** Linting y Formateo: estandarización automática de código y prevención de fallas estáticas.
- **Límites y Anti-Patrones:** Reglas Excesivamente Pedantes:** Habilitar cientos de reglas de linter sin discernimiento (como forzar docstrings en funciones privadas triviales) genera fatiga de desarrollo sin aportar valor real. | Conflictos Masivos en Adopción Inicial:** Aplicar un formateador a un proyecto heredado gigante de 500,000 líneas en un solo commit puede ensuciar el `git blame` histórico; debe realizarse configurando `.git-blame-ignore-revs`.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un archivo de configuración centralizado (`pyproject.toml` / `.ruff.toml`) con las reglas de linting del proyecto?
  - [ ] ¿El formateo y linting se ejecutan automáticamente en los hooks de pre-commit y en el CI?
  - [ ] ¿Se eliminaron imports comodín (`from module import *`) y variables no utilizadas?
  - [ ] ¿El agente de IA ejecuta `ruff check --fix` y `ruff format` tras generar o editar código?

### 4.2 Análisis Estático de Código y Seguridad (SAST)
- **Definición:** Análisis Estático: detección preventiva de fallos de seguridad, inyecciones y complejidad ciclomática.
- **Límites y Anti-Patrones:** Falsos Positivos y Supresiones Explícitas:** Las herramientas SAST pueden alertar sobre usos legítimos y seguros de ciertas funciones; en esos casos, se debe documentar la supresión explícita (`# nosec Bxxx`) con justificación técnica en code review. | No Sustituye al Análisis Dinámico (DAST):** El análisis estático no puede comprobar si un endpoint protegido permite escalada de privilegios lógica en runtime; debe complementarse con pruebas de penetración y DAST.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se ejecuta un escáner de seguridad estático (ej. `bandit -r src/`) en el pipeline de CI?
  - [ ] ¿Se prohibió el uso de `shell=True`, `eval()`, `exec()` y `pickle.loads()` en la base de código?
  - [ ] ¿Se verificó que no existan credenciales, tokens o secretos hardcodeados mediante detectores de secretos (ej. `detect-secrets`)?
  - [ ] ¿Las excepciones y supresiones de reglas (`# nosec`) están justificadas y auditadas?

### 4.3 Verificación Estricta de Tipos (Static Type Checking)
- **Definición:** Type Checking: verificación formal de tipos con Mypy y Pyright como razonador externo para agentes.
- **Límites y Anti-Patrones:** Metaprogramación Dinámica Avanzada:** Tipar decoradores altamente dinámicos o fábricas de clases dinámicas en Python puede requerir construcciones complejas (`ParamSpec`, `TypeVarTuple`, `Concatenate`) que añaden sobrecarga sintáctica. | Librerías de Terceros sin Stubs:** Si se utilizan librerías antiguas que carecen de anotaciones de tipo (`types-*`), puede requerirse configurar excepciones de importación (`ignore_missing_imports`).
- **Checklist Completa de Verificación:**
  - [ ] ¿El proyecto ejecuta `mypy --strict` en el pipeline de CI sin advertencias ni errores?
  - [ ] ¿Todas las funciones públicas tienen anotaciones de tipo en todos sus argumentos y valor de retorno?
  - [ ] ¿Se utiliza `T | None` para valores opcionales con comprobación explícita de nulabilidad?
  - [ ] ¿Se eliminó el uso de `Any` arbitrario en favor de tipos precisos, uniones o genéricos tipados (`TypeVar`)?

### 4.4 Observabilidad de Sistemas (Logs, Métricas y Trazas)
- **Definición:** Observabilidad: pilares de telemetría (Logs, Métricas y Trazas distribuidas) para auditoría cuantitativa.
- **Límites y Anti-Patrones:** Explosión de Alta Cardinalidad (*High Cardinality*):** Indexar identificadores únicos de usuario o textos completos de prompts como etiquetas de métricas en Prometheus puede saturar la base de datos de series temporales; los datos de alta cardinalidad deben ir a **Logs/Trazas**, no a etiquetas de métricas. | Costo de Almacenamiento de Telemetría:** En sistemas de alto volumen, emitir trazas completas del 100% del tráfico puede ser inviable; se utiliza **muestreo probabilístico (*Sampling*)** (ej. guardar el 5% del tráfico exitoso y el 100% de los errores).
- **Checklist Completa de Verificación:**
  - [ ] ¿El sistema emite métricas cuantitativas clave (latencia, tasa de errores, consumo de recursos/tokens)?
  - [ ] ¿Los eventos de log contienen contexto estructurado (IDs de traza, timestamps UTC y niveles de severidad)?
  - [ ] ¿Se cuenta con dashboards y alertas automáticas basadas en umbrales de error y latencia?
  - [ ] ¿Se configuró una estrategia de muestreo (*sampling*) para controlar los costos de almacenamiento de telemetría?

### 4.5 Logging Estructurado en Formato JSON
- **Definición:** Logging Estructurado: emisión de eventos en formato JSON con pares clave-valor tipados para ingesta y análisis.
- **Límites y Anti-Patrones:** Legibilidad para Humanos en Desarrollo Local:** El formato JSON puede ser denso para lectura manual rápida en consola local; la solución es configurar formato legible y coloreado en entornos de desarrollo local y JSON estricto en producción. | Fuga Accidental de Secretos (PII):** Si los desarrolladores o agentes pasan objetos completos en `context` sin filtrar, pueden emitirse tokens o datos personales sensibles; se deben implementar procesadores de ofuscación.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los logs se emiten en formato JSON estructurado con timestamps en UTC e ISO 8601?
  - [ ] ¿Los eventos usan nombres semánticos breves y normalizados en lugar de frases arbitrarias?
  - [ ] ¿Las variables de contexto se pasan como campos clave-valor en lugar de interpolarse en el string del mensaje?
  - [ ] ¿Existe un mecanismo de filtrado automático para evitar la emisión de contraseñas o tokens (PII)?

### 4.6 Trazabilidad Distribuida y Correlation IDs
- **Definición:** Tracing Distribuido: propagación de Correlation IDs y Spans para seguimiento causal de transacciones multi-agente.
- **Límites y Anti-Patrones:** Propagación Manual en Protocolos Heterogéneos:** Si los servicios se comunican a través de sockets crudos o colas sin soporte nativo de metadatos, la inyección y extracción de headers de trazabilidad debe implementarse manualmente. | Sobrecarga de Almacenamiento de Trazas:** Almacenar trazas completas con todos sus payloads en sistemas de alta frecuencia genera un volumen gigantesco de datos; se debe aplicar **muestreo inteligente (*Head/Tail-based Sampling*)**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Cada solicitud entrante recibe o genera un Correlation ID (`X-Correlation-ID` / `traceparent`)?
  - [ ] ¿El Correlation ID se propaga automáticamente a todas las llamadas HTTP salientes, mensajes de cola y subagentes?
  - [ ] ¿Todas las líneas de log estructurado incluyen el Correlation ID actual?
  - [ ] ¿Las herramientas y APIs externas registran la duración de cada Span individual?

### 4.7 Reproducibilidad de Entornos y Builds
- **Definición:** Reproducibilidad: fijación determinista de dependencias con lockfiles criptográficos y contenedores.
- **Límites y Anti-Patrones:** Obsolescencia de Dependencias (*Dependency Staleness*):** Un lockfile estricto puede perpetuar vulnerabilidades de seguridad si no se cuenta con herramientas automatizadas de actualización (Dependabot, Renovate). | Sobrecarga en Scripts Utilitarios de 10 Líneas:** Para un script de un solo archivo que solo usa la librería estándar de Python, configurar lockfiles y Docker es innecesario.
- **Checklist Completa de Verificación:**
  - [ ] ¿El repositorio incluye un archivo de bloqueo (`uv.lock` / `poetry.lock`) bajo control de versiones en Git?
  - [ ] ¿Los pipelines de CI utilizan comandos de instalación congelada (`uv sync --frozen` / `pip sync`)?
  - [ ] ¿La versión de Python está explícitamente fijada tanto en `pyproject.toml` como en el `.python-version` y `Dockerfile`?
  - [ ] ¿Se cuenta con un escáner automático de dependencias (Dependabot / Renovate) para actualizar vulnerabilidades?

### 4.8 Infraestructura como Código (Infrastructure as Code - IaC)
- **Definición:** Infraestructura como Código: aprovisionamiento declarativo y versionado en Git de entornos y recursos.
- **Límites y Anti-Patrones:** Modificaciones Manuales Directas (*ClickOps*):** Si los miembros del equipo modifican configuraciones directamente en la consola web de AWS/Azure, el estado de IaC se desincroniza (*Drift*). Se deben aplicar permisos de solo lectura para humanos en producción. | Gestión de Estado y Bloqueos:** En herramientas como Terraform, la pérdida o corrupción del archivo de estado remoto (`terraform.tfstate`) puede requerir reconstrucciones complejas.
- **Checklist Completa de Verificación:**
  - [ ] ¿Toda la infraestructura requerida para desarrollo, testing y producción está definida en archivos de código en Git?
  - [ ] ¿Se eliminaron las instrucciones manuales de configuración de servidores en favor de scripts o manifiestos IaC?
  - [ ] ¿Los manifiestos definen chequeos de salud (*health checks*) y límites de recursos (memoria/CPU)?
  - [ ] ¿Es posible destruir y reconstruir el entorno completo de forma determinista con un solo comando?

### 4.9 Interruptores de Funcionalidad (Feature Flags / Toggles)
- **Definición:** Feature Flags: activación dinámica de funcionalidades desacoplada del despliegue para releases seguros.
- **Límites y Anti-Patrones:** Deuda Técnica de Flags (*Flag Debt / Spaghetti Toggles*):** Si los flags no se retiran una vez que la funcionalidad está 100% estabilizada, el código se llena de condicionales muertos y bifurcaciones difíciles de entender. | Explosión Combinatoria en Testing:** Tener 10 flags independientes activos genera $2^{10} = 1024$ estados posibles del sistema, haciendo imposible probar todas las combinaciones en CI.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las nuevas funcionalidades complejas o experimentales están protegidas detrás de un Feature Flag?
  - [ ] ¿Existe un plan formal con fecha límite para retirar el Feature Flag una vez completado el release al 100%?
  - [ ] ¿Las herramientas de agentes y proveedores de LLM cuentan con interruptores de apagado rápido (*Kill Switches*)?
  - [ ] ¿El código cuenta con un camino de degradación elegante (*Fallback*) si el flag falla?

### 4.10 Desarrollo Basado en Tronco (Trunk-Based Development - TBD)
- **Definición:** Trunk-Based Development: ramas cortas y commits atómicos integrados continuamente a la rama principal.
- **Límites y Anti-Patrones:** Falta de Suite de Pruebas Automatizadas Sólida:** TBD depende críticamente de un pipeline de CI con alta cobertura de pruebas; si el repositorio carece de tests automatizados, fusionar a `main` diariamente puede desestabilizar la rama productiva. | Proyectos Open Source con Contribuidores Externos Desconocidos:** En proyectos públicos con miles de contribuidores externos (ej. Linux Kernel o CPython), el modelo de *Forks* y revisiones asíncronas extendidas es preferible por motivos de gobernanza y seguridad.
- **Checklist Completa de Verificación:**
  - [ ] ¿Todas las ramas de trabajo se fusionan a `main` en menos de 24 horas desde su creación?
  - [ ] ¿Los Pull Requests son pequeños, atómicos y modifican pocos archivos a la vez?
  - [ ] ¿Las funcionalidades incompletas se integran a `main` protegidas detrás de Feature Flags?
  - [ ] ¿La rama principal (`main`) se mantiene en estado verde y desplegable en todo momento?

### 4.11 Métricas Cuantitativas y Telemetría de Rendimiento para Sistemas y Agentes
- **Definición:** Guía de instrumentación de métricas cuantitativas, 4 Golden Signals y telemetría de rendimiento bajo estándares como OpenTelemetry y Prometheus.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó métricas cuantitativas y telemetría de rendimiento para sistemas y agentes conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?

### 4.12 Debuggable by Design: Arquitectura Introspectiva y Transparencia Operativa
- **Definición:** Principios y patrones de diseño para construir sistemas cuya arquitectura interna sea intrínsecamente transparente, auditable y fácil de depurar.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó debuggable by design: arquitectura introspectiva y transparencia operativa conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 5: Seguridad, Versionado y Reversibilidad

### 5.1 Seguridad por Diseño (Security by Design)
- **Definición:** Seguridad por Diseño: integración nativa de autenticación, cifrado y secretos desde la arquitectura inicial.
- **Límites y Anti-Patrones:** Sobrecarga de Algoritmos Pesados en Tests:** Usar 600,000 iteraciones de hashing en suites de pruebas unitarias locales con 500 usuarios puede ralentizar los tests; se recomienda configurar un factor de costo reducido (`iterations=1000`) exclusivamente para el entorno de pruebas unitarias. | Entornos Locales de Prototipado Rápido:** No es necesario contratar un servicio de HSM (Hardware Security Module) en la nube para un script de prueba de concepto local.
- **Checklist Completa de Verificación:**
  - [ ] ¿El repositorio está 100% libre de claves de API, tokens o contraseñas hardcodeadas?
  - [ ] ¿Todos los secretos se cargan mediante variables de entorno protegidas con `SecretStr`?
  - [ ] ¿Se utilizan algoritmos criptográficos modernos (Argon2id, PBKDF2-SHA256, AES-GCM) en lugar de MD5/SHA1?
  - [ ] ¿Las comparaciones de tokens y hashes utilizan funciones de tiempo constante (`hmac.compare_digest`)?

### 5.2 de Menor Privilegio (Principle of Least Privilege - PoLP)
- **Definición:** Menor Privilegio: concesión estricta de permisos mínimos a herramientas, procesos y agentes.
- **Límites y Anti-Patrones:** Micro-gestión Excesiva de Permisos (*Permission Gridlock*):** Crear 50 roles hiper-granulares para un equipo de 3 desarrolladores puede paralizar el trabajo diario por denegaciones de acceso continuas. | Herramientas de Mantenimiento Legítimas:** Ciertas herramientas administrativas y agentes de migración de esquema necesitan legítimamente permisos de escritura; en estos casos se requiere aprobación humana explícita (*Human-in-the-Loop*).
- **Checklist Completa de Verificación:**
  - [ ] ¿Los agentes y herramientas de solo lectura tienen conexiones y credenciales con permisos exclusivos de `SELECT`?
  - [ ] ¿Los contenedores de ejecución de código para agentes corren sin privilegios de `root` (`USER nonroot`)?
  - [ ] ¿Las claves de API tienen permisos y alcances (*scopes*) mínimos acotados a su función específica?
  - [ ] ¿Se eliminaron usuarios administradores compartidos en favor de identidades específicas por servicio?

### 5.3 Modelado de Amenazas (Threat Modeling)
- **Definición:** Modelado de Amenazas: identificación preventiva de vectores de ataque y mitigación STRIDE en sistemas agénticos.
- **Límites y Anti-Patrones:** Parálisis por Análisis (*Analysis Paralysis*):** Elaborar matrices de amenazas complejas de 50 páginas para un script utilitario local o un prototipo efímero ralentiza la entrega sin justificación. | Modelos Estáticos Desactualizados:** Un modelado de amenazas realizado hace 12 meses pierde validez si el sistema añadió nuevas herramientas de IA con acceso a bases de datos o red externa.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se identificaron formalmente las fronteras de confianza entre el usuario, las fuentes de datos externas y el LLM?
  - [ ] ¿Se aplicaron mitigaciones STRIDE para cada vector de ataque detectado?
  - [ ] ¿Las entradas externas no confiables están encapsuladas con delimitadores claros en los prompts?
  - [ ] ¿Existen límites estrictos de pasos ($N$ llamadas máximas) y cuotas de tokens para prevenir ataques de denegación de servicio?

### 5.4 Gestión y Auditoría de Dependencias
- **Definición:** Gestión de Dependencias: auditorías automatizadas de vulnerabilidades (pip-audit) y seguridad en la cadena de suministro.
- **Límites y Anti-Patrones:** Vulnerabilidades en Herramientas Exclusivas de Desarrollo:** Bloquear el despliegue a producción por una vulnerabilidad de severidad baja en una herramienta que solo corre en local (ej. una librería de gráficos de testing) puede generar falsos bloqueos; se deben separar `dev-dependencies` de dependencias de producción. | CVEs sin Parche Disponible (*Zero-Day / No Fix*):** Si una vulnerabilidad carece de versión corregida oficial, se debe evaluar el riesgo y documentar una excepción temporal en el archivo de configuración de auditoría.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se ejecuta `pip-audit` o una herramienta equivalente en el pipeline de CI?
  - [ ] ¿Las dependencias están separadas estrictamente entre producción y desarrollo (`[project.optional-dependencies]`)?
  - [ ] ¿Existe una herramienta automatizada (Dependabot / Renovate) para recibir PRs de actualización de seguridad?
  - [ ] ¿Se verifica la reputación y existencia legítima de paquetes nuevos antes de añadirlos a `pyproject.toml`?

### 5.5 Versionado Semántico (Semantic Versioning - SemVer)
- **Definición:** Versionado Semántico (SemVer 2.0.0): comunicación formal y matemática del impacto de cambios en APIs.
- **Límites y Anti-Patrones:** Servicios Web Internos con Despliegue Continuo (SaaS):** En aplicaciones web monolíticas que se despliegan 10 veces al día y no exponen APIs públicas empaquetadas, el versionado basado en fechas (**CalVer** `2026.08.27`) o hashes de Git es más práctico que SemVer. | Miedo a Incrementar MAJOR (*Zero Version Syndrome*):** Mantener un proyecto en `v0.x.y` durante 5 años por temor a lanzar `v1.0.0` comunica inestabilidad injustificada.
- **Checklist Completa de Verificación:**
  - [ ] ¿Cualquier cambio incompatible con versiones anteriores (*Breaking Change*) incrementa el número MAJOR?
  - [ ] ¿Las nuevas funcionalidades compatibles hacia atrás incrementan exclusivamente el número MINOR?
  - [ ] ¿Los parches y arreglos de bugs incrementan exclusivamente el número PATCH?
  - [ ] ¿Se emiten advertencias de deprecación (*DeprecationWarning*) con al menos una versión de anticipación antes de retirar una función?

### 5.6 Commits Convencionales (Conventional Commits)
- **Definición:** Conventional Commits: mensajes de commit estructurados para trazabilidad y automatización de changelogs.
- **Límites y Anti-Patrones:** Commits Locales de Exploración (*WIP Commits*):** Durante el desarrollo interactivo temprano en una rama privada, obligarse a redactar mensajes formales para cada commit de 2 minutos puede ser tedioso; la solución es realizar un **Squash and Merge** aplicando Conventional Commits en el commit final hacia `main`. | Scopes Hiper-Granulares Confusos:** Definir 200 scopes distintos (ej. `feat(billing-ui-button-icon)`) crea fricción; los scopes deben mantenerse a nivel de módulo o paquete principal (`feat(billing)`).
- **Checklist Completa de Verificación:**
  - [ ] ¿El mensaje de commit comienza con un tipo válido (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`)?
  - [ ] ¿La descripción está redactada en tiempo presente imperativo y en minúsculas (sin punto final)?
  - [ ] ¿Los breaking changes están señalizados con `!` o con el footer `BREAKING CHANGE:`?
  - [ ] ¿Se utiliza una herramienta de linting de commits (`commitlint`) en los hooks de pre-commit?

### 5.7 Commits Atómicos y Reversibilidad
- **Definición:** Commits Atómicos: unidades lógicas de cambio completas, funcionales y reversibles mediante git revert.
- **Límites y Anti-Patrones:** Micro-commits Incompletos (*Broken Intermediate Commits*):** Dividir un cambio en commits tan pequeños que dejan el código roto (ej. commit 1: añade función, commit 2: arregla typo de sintaxis, commit 3: añade imports) destruye la utilidad de `git bisect`; **cada commit debe compilar y pasar tests**. | Fricción en Prototipos Descartables:** En branches privadas experimentales destinadas a ser descartadas, la atomicidad estricta no es necesaria hasta el momento de preparar el PR para `main`.
- **Checklist Completa de Verificación:**
  - [ ] ¿Cada commit resuelve un único problema o introduce una única capacidad lógica?
  - [ ] ¿El código compila y pasa el 100% de los tests unitarios en cada commit individual?
  - [ ] ¿El commit incluye tanto el código de producción como sus pruebas automatizadas asociadas?
  - [ ] ¿Es posible revertir el commit mediante `git revert` sin provocar errores de sintaxis o dependencias rotas?

### 5.8 Cambios Diseñados para Reversión (Rollback-Friendly Changes)
- **Definición:** Cambios Diseñados para Reversión: patrón expand/contract en migraciones y despliegues sin downtime.
- **Límites y Anti-Patrones:** Disciplina de Múltiples Despliegues:** Requiere planificar 2 o 3 releases sucesivos para completar un cambio de esquema en lugar de 1 solo paso. | Entornos de Desarrollo Inicial sin Producción:** En fases tempranas de diseño donde la base de datos se recrea desde cero en cada ejecución local, el patrón Expand/Contract añade sobrecarga innecesaria.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las migraciones de base de datos añaden campos o tablas sin eliminar ni renombrar columnas existentes (*Fase Expand*)?
  - [ ] ¿El nuevo código soporta escritura dual o lectura con fallback para garantizar compatibilidad hacia atrás?
  - [ ] ¿Se verificó que la versión anterior de la aplicación continúe funcionando si se realiza un rollback inmediato?
  - [ ] ¿Existe una tarea programada para la *Fase Contract* que retire las columnas deprecadas solo tras estabilizar el release?

### 5.9 Revisión de Código y Pull Requests Acotados
- **Definición:** Revisión de Código y PRs Acotados: revisiones rigurosas de diffs menores a 300 líneas para control de calidad.
- **Límites y Anti-Patrones:** Fragmentación Artificial Rota (*Broken Micro-PRs*):** Dividir una feature en PRs tan pequeños que no pueden compilar o probarse por separado es un antipatrón; cada PR debe ser pequeño pero **funcionalmente completo y verificable**. | Refactorizaciones Automatizadas de Formato Masivo:** Cambios mecánicos generados por herramientas (ej. renombrado de paquete o formateo con Ruff) pueden superar las 300 líneas si son 100% deterministas y van aislados en su propio PR de tipo `chore`.
- **Checklist Completa de Verificación:**
  - [ ] ¿El Pull Request modifica menos de 300 líneas de código de lógica/producción?
  - [ ] ¿El PR resuelve un único objetivo conceptual y está vinculado a un issue de seguimiento?
  - [ ] ¿El PR incluye las pruebas unitarias que verifican los nuevos cambios?
  - [ ] ¿La descripción del PR explica el *por qué* del cambio y los pasos de validación realizados?

### 5.10 Gestión y Control de Deuda Técnica
- **Definición:** Gestión de Deuda Técnica: registro, control mediante ADRs y pago planificado de compromisos técnicos.
- **Límites y Anti-Patrones:** Dogmatismo de "Cero Deuda Técnica" (*Gold Plating*):** Exigir una arquitectura perfecta e inmaculada antes de lanzar cualquier funcionalidad puede llevar a la quiebra comercial por falta de velocidad de mercado. | Deuda No Asumida Formalmente:** Atajos que comprometen la seguridad, la integridad de los datos financieros o la privacidad de los usuarios **nunca son deuda técnica aceptable**; son negligencias inaceptables.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los compromisos y atajos técnicos temporales están documentados en un ADR o issue del backlog?
  - [ ] ¿Se reserva un porcentaje fijo de capacidad (ej. 15-20%) en cada ciclo para el pago de deuda técnica?
  - [ ] ¿Se eliminaron comentarios `TODO` o `FIXME` huérfanos sin ticket de seguimiento asociado?
  - [ ] ¿Las métricas de cobertura de tests y complejidad ciclomática se monitorean para evitar la degradación estructural?

### 5.11 Checkpointing, Commits de Seguridad y Migración Incremental para Tareas Agénticas
- **Definición:** Metodología de creación de puntos de control (checkpoints), commits de seguridad intermedios y migraciones incrementales para garantizar total reversibilidad en tareas agénticas.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó checkpointing, commits de seguridad y migración incremental para tareas agénticas conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 6: Documentación y Gestión de Conocimiento

### 6.1 Documentación como Código (Docs-as-Code)
- **Definición:** Docs-as-Code: tratamiento de la documentación con el mismo rigor, versionado y testing que el código fuente.
- **Límites y Anti-Patrones:** Documentación Comercial para Usuarios No Técnicos:** Documentos de marketing, presentaciones ejecutivas o actas de reuniones de RRHH no encajan en el modelo Docs-as-Code de Git; pertenecen a plataformas colaborativas de oficina. | Barrera de Entrada en Equipos No Técnicos:** Redactores de contenido que no dominan Git o Markdown pueden requerir interfaces visuales integradas (CMS headless basados en Git como Decap CMS o Forestry).
- **Checklist Completa de Verificación:**
  - [ ] ¿Toda la documentación técnica de arquitectura y APIs reside en el repositorio Git (`docs/`)?
  - [ ] ¿Los cambios de código que modifican interfaces públicas incluyen la actualización de la documentación en el mismo PR?
  - [ ] ¿Existe un workflow de CI que valida la sintaxis Markdown y detecta enlaces rotos automáticamente?
  - [ ] ¿La documentación está escrita en formatos de texto plano versionables (Markdown / AsciiDoc)?

### 6.2 Registros de Decisiones de Arquitectura (ADRs)
- **Definición:** ADRs: preservación del contexto histórico y consecuencias de decisiones técnicas clave en docs/adr/.
- **Límites y Anti-Patrones:** Micro-decisiones Triviales (*ADR Overload*):** Escribir un ADR para elegir el nombre de una variable, instalar una librería de testing menor o cambiar el color de un botón genera burocracia innecesaria. | ADRs Obsoletos No Mantenidos:** Si una decisión cambia pero no se publica el ADR sucesor (`Superseded by ADR-008`), se genera confusión histórica.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las decisiones técnicas estructurales y de alto impacto están registradas en `docs/adr/`?
  - [ ] ¿Cada ADR incluye la fecha, estado, contexto, alternativas consideradas y consecuencias?
  - [ ] ¿Los ADRs modificados se marcan formalmente como `Superseded` en lugar de borrar el archivo original?
  - [ ] ¿El catálogo de ADRs se encuentra en texto plano Markdown accesible para desarrolladores y agentes de IA?

### 6.3 Documentación Viva y Sincronizada (Living Documentation)
- **Definición:** Living Documentation: sincronización garantizada y autogeneración de especificaciones desde el código fuente real.
- **Límites y Anti-Patrones:** El 'Qué' vs. el 'Por Qué':** La documentación viva describe con precisión quirúrgica *qué* hace el código y *cómo* se estructuran sus datos, pero no puede deducir el *porqué* estratégico del negocio (los motivos arquitectónicos requieren ADRs narrativos). | Sobrecarga de Anotaciones en Modelos Internos:** Agregar descripciones exhaustivas a cada variable en clases privadas de bajo nivel añade ruido innecesario; debe priorizarse en las **fronteras públicas y APIs**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los esquemas de API y contratos de herramientas se generan automáticamente desde modelos de código (Pydantic / FastAPI)?
  - [ ] ¿Los campos incluyen descripciones semánticas (`description`) y ejemplos reales (`examples`)?
  - [ ] ¿Se eliminaron tablas manuales de parámetros en Markdown que duplican la información del código?
  - [ ] ¿Las herramientas expuestas a agentes de IA se nutren del JSON Schema generado dinámicamente?

### 6.4 Documentación Ejecutable y Verificable
- **Definición:** Documentación Ejecutable: ejemplos y fragmentos de código testeados automáticamente en CI mediante doctests.
- **Límites y Anti-Patrones:** Ejemplos con I/O Pesado o Servicios Externos:** Probar ejemplos que llaman a pasarelas de pago reales o bases de datos gigantes en un docstring no es adecuado; los doctests deben reservarse para **funciones puras, utilitarios y lógica algorítmica**. | Salidas No Deterministas:** Operaciones que devuelven UUIDs aleatorios o timestamps requieren directivas de doctest (`# doctest: +ELLIPSIS`) para evitar falsos negativos.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los docstrings de funciones clave incluyen ejemplos interactivos en formato doctest (`>>>`)?
  - [ ] ¿El comando `pytest --doctest-modules` se ejecuta automáticamente en el pipeline de CI?
  - [ ] ¿Los ejemplos documentan tanto los casos válidos como las excepciones esperadas?
  - [ ] ¿Los fragmentos de código en archivos Markdown se validan con herramientas como `pytest-codeblocks`?

### 6.5 Divulgación Progresiva del Contexto (Progressive Disclosure)
- **Definición:** Divulgación Progresiva: estructuración jerárquica en capas para revelar profundidad técnica bajo demanda a agentes de IA.
- **Límites y Anti-Patrones:** Sobre-fragmentación Excesiva (*Over-nesting*):** Dividir la documentación en 15 niveles de profundidad donde encontrar un valor requiere saltar por 8 archivos genera latencia innecesaria en el bucle del agente. | Proyectos Monolíticos de un Solo Archivo:** En scripts autónomos de 100 líneas, un único archivo `README.md` directo es más práctico que crear jerarquías de carpetas.
- **Checklist Completa de Verificación:**
  - [ ] ¿El archivo raíz (`AGENTS.md` / `README.md`) resume las reglas globales y proporciona enlaces a subsistemas en menos de 200 líneas?
  - [ ] ¿La documentación detallada está modularizada por dominio en carpetas específicas (`docs/<modulo>/`)?
  - [ ] ¿Los agentes de IA son guiados a consultar archivos puntuales mediante herramientas en lugar de recibir volcados monolíticos de texto?
  - [ ] ¿Se eliminó la duplicación masiva de información entre las diferentes capas jerárquicas?

### 6.6 El Repositorio como Sistema de Registro (System of Record)
- **Definición:** System of Record: el repositorio Git como fuente canónica, completa y autoritativa de todo el conocimiento.
- **Límites y Anti-Patrones:** Grandes Volúmenes de Datos Binarios (*Big Data / Blobs*):** Almacenar datasets de Machine Learning de 50GB o vídeos en el repositorio satura Git; estos artefactos deben guardarse en buckets S3/GCS y rastrearse mediante punteros ligeros versionados (**DVC** o **Git LFS**). | Secretos y Credenciales Reales en Producción:** Claves privadas, certificados y tokens nunca deben guardarse en el repositorio; el repo define el *manifiesto de infraestructura* y la referencia al gestor de secretos (*Vault*), pero no el valor confidencial en texto plano.
- **Checklist Completa de Verificación:**
  - [ ] ¿Es posible clonar el repositorio en una máquina limpia y levantar el entorno completo con comandos documentados?
  - [ ] ¿Toda la arquitectura, decisiones (ADRs) y reglas de negocio están versionadas en Git en texto plano?
  - [ ] ¿Existe un archivo `AGENTS.md` en la raíz con directivas claras para el trabajo de modelos de lenguaje?
  - [ ] ¿Los datos binarios pesados se gestionan mediante Git LFS / DVC en lugar de comitearse directamente al historial?

### 6.7 Separación Estricta de Hechos, Reglas y Procedimientos en la Documentación
- **Definición:** Marco teórico y metodológico para categorizar toda la documentación técnica en tres dimensiones semánticas (Hechos, Reglas y Procedimientos), eliminando la ambigüedad en LLMs.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó separación estricta de hechos, reglas y procedimientos en la documentación conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 7: Ingeniería Agéntica y Control de Contexto

### 7.1 Ingeniería de Contexto para Agentes de IA (Context Engineering)
- **Definición:** Context Engineering: diseño y curación de la información técnica inyectada al agente en cada paso.
- **Límites y Anti-Patrones:** Poda Excesiva (*Over-pruning*):** Eliminar demasiado contexto puede ocultar la causa raíz de un bug sutil que ocurrió 50 líneas antes en el log; la poda debe ser inteligente y configurable. | Sobrecarga de Pre-procesamiento:** Implementar clasificadores pesados de machine learning para decidir qué contexto incluir puede añadir latencia al inicio del agente.
- **Checklist Completa de Verificación:**
  - [ ] ¿El contexto inyectado al agente contiene únicamente archivos e interfaces relevantes para la tarea?
  - [ ] ¿Las salidas de terminal, logs y stack traces se podan para no saturar la ventana de tokens?
  - [ ] ¿La información está estructurada con encabezados claros y delimitadores semánticos?
  - [ ] ¿Se mide y monitorea el conteo de tokens de entrada por cada invocación del agente?

### 7.2 Jerarquía Contextual de Instrucciones
- **Definición:** Jerarquía Contextual: reglas globales en raíz y directivas locales especializadas por subdirectorio.
- **Límites y Anti-Patrones:** Jerarquías Hiper-Profundas (*Nesting Hell*):** Crear archivos de reglas en 5 niveles anidados (`src/a/b/c/d/AGENTS.md`) dificulta saber qué directiva prevalece; se recomienda un máximo de **2 niveles (Raíz y Dominio)**. | Proyectos Monolíticos Pequeños de un Solo Lenguaje:** Para un paquete simple de 5 archivos, un único `AGENTS.md` en la raíz es suficiente.
- **Checklist Completa de Verificación:**
  - [ ] ¿El archivo `AGENTS.md` de la raíz contiene exclusivamente reglas transversales (Git, CI, Seguridad)?
  - [ ] ¿Los subsistemas con tecnologías distintas tienen su propio archivo de directivas local?
  - [ ] ¿Las reglas locales refinan o especializan las globales sin contradecir las políticas de seguridad?
  - [ ] ¿La jerarquía de contexto no supera los 2 niveles de profundidad para evitar confusiones de precedencia?

### 7.3 Carga Progresiva de Contexto Bajo Demanda
- **Definición:** Carga Progresiva de Contexto: lectura de índices livianos y recuperación bajo demanda mediante herramientas.
- **Límites y Anti-Patrones:** Índices Desactualizados o Vagos:** Si `INDEX.md` no describe con claridad los módulos, el agente puede verse forzado a ejecutar 10 llamadas a `grep_search` a ciegas, aumentando la latencia total. | Tareas de Refactorización Global Transversal:** Para tareas que requieren renombrar un símbolo en todo el proyecto simultáneamente, la carga progresiva individual puede ser más lenta que una búsqueda global automatizada.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un archivo de índice liviano (`INDEX.md` / `AGENTS.md`) que mapea los subsistemas principales?
  - [ ] ¿El agente dispone de herramientas de lectura acotada (`view_file` con `StartLine` y `EndLine`)?
  - [ ] ¿Se evita la inyección masiva de código no solicitado en el prompt de arranque?
  - [ ] ¿Las herramientas de búsqueda (`grep_search`, `find_by_name`) están habilitadas para la localización autónoma de símbolos?

### 7.4 Contexto Agéntico Persistente y Estable
- **Definición:** Contexto Persistente: conocimiento duradero en archivos versionados (AGENTS.md) para mitigar la amnesia de LLMs.
- **Límites y Anti-Patrones:** Contaminación con Contexto Efímero (*Context Staling*):** Llenar `AGENTS.md` con notas temporales ("*arreglar el bug de Juan mañana*") ensucia el contexto permanente; las tareas temporales deben gestionarse en issues de Git, no en el archivo de contexto duradero. | Tamaño Excesivo:** Mantener archivos de contexto persistente de más de 30 KiB puede saturar la ventana de atención de modelos ligeros.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un archivo `AGENTS.md` en la raíz del repositorio versionado en Git?
  - [ ] ¿Se especifican las herramientas canónicas de empaquetado, linters y comandos de validación?
  - [ ] ¿Las directivas operativas son leídas automáticamente por los agentes al iniciar la sesión?
  - [ ] ¿Se eliminaron notas temporales o efímeras del archivo de contexto persistente?

### 7.5 Fuente Única de Verdad para Contexto de IA
- **Definición:** Fuente Única de Verdad de Contexto: AGENTS.md central con adaptadores mínimos para herramientas de IA.
- **Límites y Anti-Patrones:** Herramientas Sin Soporte de Enlaces Externos:** Si un asistente no tiene la capacidad de leer archivos locales referenciados en su prompt de sistema, se puede utilizar un script de pre-commit que sincronice mecánicamente el contenido de `AGENTS.md` en los demás archivos. | Configuraciones Específicas de IDE:** Si Cursor requiere opciones técnicas exclusivas (ej. paths de extensiones), estas pueden coexistir en `.cursorrules` manteniendo las directivas de código enlazadas a `AGENTS.md`.
- **Checklist Completa de Verificación:**
  - [ ] ¿Todas las directivas operativas residen en el archivo canónico `AGENTS.md`?
  - [ ] ¿Los archivos `CLAUDE.md`, `.cursorrules` y `copilot-instructions.md` actúan como punteros delgados hacia `AGENTS.md`?
  - [ ] ¿Se eliminaron reglas de código duplicadas o contradictorias entre los distintos archivos de configuración?
  - [ ] ¿Cualquier actualización de directivas técnicas se realiza exclusivamente en `AGENTS.md`?

### 7.6 Gestión del Presupuesto de Contexto y Límite de Tokens
- **Definición:** Presupuesto de Contexto: gestión del límite de tokens (~32 KiB) para optimizar atención y coste.
- **Límites y Anti-Patrones:** Sobre-compresión Críptica (*Over-compression*):** Comprimir el texto con acrónimos ininteligibles o eliminar instrucciones de seguridad esenciales por ahorrar 20 tokens es un antipatrón peligroso; la claridad semántica prevalece sobre el ahorro extremo. | Modelos de Contexto Masivo (1M+ Tokens):** Aunque modelos como Gemini 1.5 Pro admiten millones de tokens, mantener el prompt de sistema compacto sigue siendo una buena práctica para reducir latencia y costes.
- **Checklist Completa de Verificación:**
  - [ ] ¿El archivo `AGENTS.md` pesa menos de 32 KiB (idealmente <15 KiB / <3,000 tokens)?
  - [ ] ¿La información se presenta en formato estructurado (tablas de comandos, viñetas)?
  - [ ] ¿Se eliminaron explicaciones narrativas de relleno o tutoriales extensos del prompt de sistema?
  - [ ] ¿Los detalles de dominio residen en archivos complementarios enlazados bajo demanda?

### 7.7 Descubribilidad para Agentes (Agent Discoverability)
- **Definición:** Discoverability: estructuras predecibles e índices semánticos para navegación autónoma y veloz de agentes.
- **Límites y Anti-Patrones:** Profundidad de Anidamiento Excesiva:** Crear carpetas de 6 niveles (`src/a/b/c/d/e/service.py`) genera fricción en la consola y paths excesivamente largos en Windows (`MAX_PATH`). | Mantenimiento del Índice en Repositorios Dinámicos:** Si el equipo crea archivos constantemente pero olvida actualizar `INDEX.md`, se genera desincronización; se recomienda un script de verificación en CI que valide que todo módulo en `src/` tenga entrada en `INDEX.md`.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe una estructura espejo 1:1 entre los archivos de `src/` y los de `tests/unit/`?
  - [ ] ¿Existe un archivo `docs/INDEX.md` que mapea módulos de código con sus responsabilidades?
  - [ ] ¿Se eliminaron nombres de archivo genéricos u opacos (`utils.py`, `helpers.py`, `misc.py`)?
  - [ ] ¿Un agente de IA puede deducir la ruta de un test a partir de la ruta del archivo de producción sin realizar búsquedas?

### 7.8 El Repositorio como Contexto Operativo
- **Definición:** El Repositorio como Contexto Operativo: entorno integral, autosuficiente y ejecutable para agentes de IA.
- **Límites y Anti-Patrones:** Pipelines de Validación Excesivamente Lentos:** Si `validate.py` tarda 25 minutos porque ejecuta pruebas end-to-end completas contra navegadores, el bucle del agente se volverá inviablemente lento; el script local/agéntico debe limitarse a **tests unitarios y chequeos estáticos rápidos (<30 segundos)**. | Almacenamiento de Secretos Reales:** El repositorio provee el contexto operativo, pero jamás debe incluir credenciales productivas reales; utiliza `.env.example` y variables de entorno mockeadas para desarrollo.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un script unificado de validación en un solo paso (`python scripts/validate.py`)?
  - [ ] ¿El entorno de desarrollo puede levantarse de forma determinista mediante `docker compose up -d` o `uv sync`?
  - [ ] ¿Las directivas operativas (`AGENTS.md`) documentan claramente los comandos de verificación?
  - [ ] ¿La suite de validación rápida para agentes se ejecuta en menos de 30 segundos?

### 7.9 Documentation as Interface: La Documentación como Plano de Control Ejecutable
- **Definición:** Estudio del paradigma donde la documentación deja de ser texto pasivo y se convierte en una interfaz operativa activa y ejecutable para agentes.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó documentation as interface: la documentación como plano de control ejecutable conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 8: Alcance, Guardrails y Validación para IA

### 8.1 Tareas Delimitadas (Scoped Tasks)
- **Definición:** Tareas Delimitadas: definición formal de objetivos, archivos permitidos y prohibidos para evitar desvíos del agente.
- **Checklist Completa de Verificación:**
  - [ ] ¿La tarea define un objetivo único y específico sin mezclar múltiples responsabilidades?
  - [ ] ¿Se especificó la lista explícita de archivos permitidos (*In-Scope*)?
  - [ ] ¿Se declararon las zonas prohibidas (*Forbidden/Out-of-Scope*)?
  - [ ] ¿Existe un comando de prueba automatizada para verificar la finalización exitosa?

### 8.2 Preferencia por Diffs Pequeños (Small Diffs)
- **Definición:** Diffs Pequeños: modificaciones quirúrgicas y acotadas que facilitan la auditoría humana y reducen regresiones.
- **Límites y Anti-Patrones:** Creación de Nuevos Módulos Desde Cero:** Al crear un nuevo archivo, el diff contendrá la totalidad del nuevo código, pero el módulo en sí debe diseñarse con bajo acoplamiento y tamaño conciso (<200 líneas). | Refactorizaciones Mayores Justificadas:** Cambios arquitectónicos estructurales planificados en un ADR pueden generar diffs mayores, pero deben descomponerse en una secuencia de PRs pequeños.
- **Checklist Completa de Verificación:**
  - [ ] ¿El diff modifica únicamente las líneas estrictamente necesarias para resolver la tarea?
  - [ ] ¿Se utilizaron herramientas de reemplazo puntual (`replace_file_content`) en lugar de sobrescribir archivos enteros?
  - [ ] ¿Se preservaron los comentarios, docstrings y formato del resto del archivo?
  - [ ] ¿El diff total de la tarea es menor a 150 líneas modificadas?

### 8.3 Límites Explícitos de Mutación (Explicit Boundaries)
- **Definición:** Límites Explícitos de Mutación: declaración taxativa de zonas, archivos y configuraciones intocables para agentes.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las rutas de seguridad, CI/CD e infraestructura están explícitamente listadas como de solo lectura en `AGENTS.md`?
  - [ ] ¿Existe un script o hook de CI (`scripts/check_boundaries.py`) que verifique que las rutas protegidas no fueron alteradas?
  - [ ] ¿Los agentes son advertidos de que modificar archivos protegidos causará el rechazo inmediato de su entrega?
  - [ ] ¿Los cambios legítimos en zonas protegidas requieren confirmación humana explícita?

### 8.4 Área de Superficie Mínima de Modificación
- **Definición:** Superficie Mínima de Modificación: resolver problemas alterando el menor número posible de módulos y componentes.
- **Límites y Anti-Patrones:** Parches Chapuceros (*Monkey Patching*):** Forzar la superficie mínima no debe ser una excusa para meter lógica con fórceps en un lugar equivocado solo por no crear un archivo nuevo cuando la arquitectura lo exige limpiamente. | Refactorizaciones Estructurales:** Si una clase ha violado el principio de responsabilidad única y debe dividirse, la creación de nuevos archivos está justificada mediante un ADR.
- **Checklist Completa de Verificación:**
  - [ ] ¿La solución al problema se implementó modificando el menor número posible de archivos (idealmente 1-3)?
  - [ ] ¿Se evitó modificar firmas de métodos o contratos públicos en módulos no relacionados?
  - [ ] ¿La lógica añadida es altamente cohesiva y reside en el dominio correspondiente?
  - [ ] ¿Se verificó que los módulos adyacentes no sufrieran cambios colaterales innecesarios?

### 8.5 Planificar Antes de Ejecutar (Plan Before Execute)
- **Definición:** Planificar Antes de Ejecutar: fase formal de análisis y diseño de pasos previa a cualquier mutación de archivos.
- **Límites y Anti-Patrones:** Micro-correcciones Triviales:** Para tareas atómicas de 1 línea (ej. arreglar un error ortográfico en un comentario o corregir un typo evidente), exigir un plan formal de 3 páginas añade fricción innecesaria. | Planes Rígidos e Inmutables:** Si durante la ejecución se descubre una restricción imprevista, el plan debe actualizarse dinámicamente en lugar de insistir ciegamente en un plan obsoleto.
- **Checklist Completa de Verificación:**
  - [ ] ¿El agente inspeccionó los archivos y contratos relevantes antes de formular su plan?
  - [ ] ¿El plan divide la tarea en pasos secuenciales acotados y testeables?
  - [ ] ¿Se definió el criterio de validación automatizada al final del plan?
  - [ ] ¿Se pausó la ejecución para verificar que el enfoque respeta la arquitectura del proyecto?

### 8.6 Instrucciones Estructuradas para Agentes
- **Definición:** Instrucciones para Agentes: directivas imperativas, accionables, binarias y deterministas en AGENTS.md.
- **Límites y Anti-Patrones:** Instrucciones Contradictorias Acumuladas:** Acumular 50 reglas que se contradicen entre sí (ej. *"escribe código ultra-conciso"* vs. *"añade docstrings de 20 líneas en cada función"*) provoca que el modelo entre en bucle o ignore ambas; **las directivas deben ser coherentes y priorizadas**. | Sobre-especificación Rígida de Algoritmos:** No es necesario dictar cada línea de código; especifica las *restricciones, contratos y pruebas*, permitiendo al LLM sintetizar la lógica algorítmica.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las directivas están redactadas en lenguaje imperativo y directo (Obligatorio / Prohibido)?
  - [ ] ¿Se eliminaron frases pasivas o ambiguas (*"sería bueno si..."*, *"en lo posible..."*)?
  - [ ] ¿Cada bloque de directivas incluye un comando de verificación programática?
  - [ ] ¿Se verificó que no existan directivas contradictorias en el documento?

### 8.7 Instrucciones Conscientes de Herramientas (Tool-Aware Instructions)
- **Definición:** Instrucciones Conscientes de Herramientas: documentación explícita de comandos exactos, scripts y herramientas disponibles.
- **Límites y Anti-Patrones:** Mantenimiento ante Cambios de Tooling:** Si el proyecto migra de `pytest` a otro runner de pruebas, la tabla en `AGENTS.md` debe actualizarse inmediatamente para no desorientar a los agentes.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se especifica el sistema operativo y shell de ejecución (Windows/PowerShell vs. Linux/Bash)?
  - [ ] ¿Los comandos de validación y testing están documentados con su sintaxis exacta y flags correspondientes?
  - [ ] ¿Se instruye al agente a priorizar herramientas nativas sobre comandos crudos de terminal?
  - [ ] ¿Se verificó que todos los comandos documentados se ejecuten exitosamente sin errores de sintaxis?

### 8.8 Guardrails y Barreras Inviolables para Agentes
- **Definición:** Guardrails: límites no negociables e inviolables (no secretos, no borrar tests, no alterar producción).
- **Límites y Anti-Patrones:** Refactorización Legítima de Pruebas Obsoletas:** Cuando una funcionalidad de negocio se rediseña intencionalmente y sus pruebas antiguas deben reemplazarse por nuevas, el desarrollador humano puede autorizar la excepción mediante un flag explícito o revisión manual.
- **Checklist Completa de Verificación:**
  - [ ] ¿Están declarados los guardrails inviolables (no secretos, no alterar producción, no borrar tests) en `AGENTS.md`?
  - [ ] ¿Existe un script automatizado que bloquee la eliminación de aserciones de prueba en CI?
  - [ ] ¿Se escanea el diff en busca de posibles fugas de claves o tokens con `detect-secrets`?
  - [ ] ¿Cualquier modificación en la suite de seguridad requiere revisión humana obligatoria?

### 8.9 Puertas de Aprobación Humana (Human Approval Gates)
- **Definición:** Puertas de Aprobación Humana: interrupción y confirmación obligatoria ante acciones destructivas o de alto riesgo.
- **Límites y Anti-Patrones:** Fatiga de Aprobación (*Approval Fatigue*):** Exigir confirmación humana para operaciones triviales (como ejecutar pytest o leer un archivo local) genera frustración y lleva a que el humano apruebe todo automáticamente sin leer; las puertas deben reservarse **exclusivamente para acciones críticas e irreversibles**. | Entornos de Sandbox Aislados:** En contenedores efímeros locales diseñados específicamente para destruirse, se puede relajar la supervisión humana.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las operaciones destructivas (DDL, borrado de datos, push forzado) requieren aprobación humana explícita?
  - [ ] ¿El agente presenta una vista previa clara del impacto y los comandos a ejecutar al solicitar aprobación?
  - [ ] ¿Las operaciones rutinarias y de solo lectura se ejecutan con plena autonomía para no generar fatiga cognitiva?
  - [ ] ¿Los pipelines de despliegue a producción cuentan con una puerta de revisión formal en GitHub Actions / GitLab CI?

### 8.10 Bucle de Retroalimentación de Agentes (Agent Feedback Loop)
- **Definición:** Bucle de Feedback de Agentes: refinamiento continuo de directivas a partir de fallos y correcciones observadas.
- **Límites y Anti-Patrones:** Sobrecarga de Reglas para Errores Aislados Únicos (*Over-reacting*):** Añadir una regla en `AGENTS.md` por un error tipográfico casual de un solo carácter que nunca volverá a ocurrir satura el archivo de instrucciones; solo deben persistirse **patrones arquitectónicos y errores recurrentes de dominio**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Tras resolver un error recurrente o complejo, se actualizó `AGENTS.md` con una directiva preventiva?
  - [ ] ¿Los incidentes técnicos conocidos están documentados en `docs/TROUBLESHOOTING.md` con su causa y solución?
  - [ ] ¿Las nuevas directivas incluyen ejemplos claros de la sintaxis correcta y la prohibida?
  - [ ] ¿El archivo `AGENTS.md` se revisa periódicamente para consolidar reglas y eliminar duplicados?

### 8.11 Finalización Basada en Evidencia (Evidence-Based Completion)
- **Definición:** Finalización Basada en Evidencia: prohibición estricta de declarar éxito sin salida verificable de tests y linters.
- **Límites y Anti-Patrones:** Tareas de Documentación Exclusiva:** Para cambios en guías Markdown donde no hay tests unitarios de Python, la evidencia debe consistir en la salida del linter de documentación (`markdownlint`) o la prueba de enlaces. | Capturas Masivas Innecesarias:** Adjuntar 5,000 líneas de logs en el reporte satura el contexto; el agente debe adjuntar el **resumen final consolidado de la prueba**.
- **Checklist Completa de Verificación:**
  - [ ] ¿El reporte final incluye la salida de terminal real de la ejecución de tests?
  - [ ] ¿Se ejecutó el script de validación unificado (`python scripts/validate.py`) antes de dar por terminada la tarea?
  - [ ] ¿El conteo de pruebas aprobadas coincide con los requerimientos asignados?
  - [ ] ¿Se prohíben afirmaciones subjetivas de éxito si no van acompañadas de la evidencia correspondiente?

### 8.12 Ejecutar Tests Antes de Declarar Éxito (Test Before Claim)
- **Definición:** Ejecutar Tests Antes de Declarar Éxito: validación programática obligatoria tras cada cambio antes de reportar.
- **Límites y Anti-Patrones:** Límite de Reintentos de Auto-Corrección (*Max Retries Gate*):** Si el agente intenta corregir el test 4 o 5 veces sucesivas sin éxito, debe detenerse y pedir ayuda al usuario explicando exactamente qué hipótesis probó y por qué está bloqueado, evitando consumir tokens en bucles infinitos.
- **Checklist Completa de Verificación:**
  - [ ] ¿El agente ejecuta los tests inmediatamente después de realizar cualquier edición de código?
  - [ ] ¿Se prohíbe pedirle al usuario que pruebe el código si el agente cuenta con herramientas para ejecutar tests?
  - [ ] ¿El agente analiza los errores de terminal de pytest para auto-corregir su solución de forma autónoma?
  - [ ] ¿Se cuenta con un límite máximo de reintentos (ej. 4 intentos) para solicitar intervención humana ante bloqueos complejos?

### 8.13 Auto-Verificación y Revisión de Diff (Self-Verification)
- **Definición:** Auto-Verificación del Diff: inspección del propio git diff antes de concluir para descartar líneas espurias.
- **Límites y Anti-Patrones:** Instrucciones Explícitas de Telemetría:** Si la tarea solicitada por el usuario fue específicamente *"añadir logs de monitoreo en el servicio"*, los logs estructurados legítimos forman parte de la solución y no deben confundirse con prints de depuración temporales.
- **Checklist Completa de Verificación:**
  - [ ] ¿El agente ejecutó `git diff` para inspeccionar todas las líneas modificadas antes de dar por cerrada la tarea?
  - [ ] ¿Se eliminaron todos los `print()` de depuración, breakpoints o comentarios temporales?
  - [ ] ¿Se eliminaron los archivos temporales (`.tmp`, `.scratch`, `test_temp.py`) creados durante el desarrollo?
  - [ ] ¿El diff final contiene únicamente los cambios estrictamente relacionados con el requerimiento?

### 8.14 Invariantes Explícitos del Sistema
- **Definición:** Invariantes Explícitos: reglas de negocio inmutables documentadas en DOMAIN.md y protegidas en código.
- **Límites y Anti-Patrones:** Confundir Invariantes con Reglas de UI Efímeras:** Las reglas visuales (ej. *"el botón debe ser azul si el usuario es VIP"*) no son invariantes de dominio; **los invariantes son verdades lógicas e inmutables del núcleo de negocio**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los invariantes críticos de negocio están formalmente documentados y numerados en `docs/DOMAIN.md`?
  - [ ] ¿Las entidades de dominio protegen sus invariantes lanzando excepciones ante estados inconsistentes?
  - [ ] ¿Existen pruebas automatizadas específicas que intenten violar los invariantes para comprobar que son rechazados?
  - [ ] ¿El agente de IA consulta `DOMAIN.md` al diseñar flujos transaccionales?

### 8.15 Archivos Protegidos y Fronteras de Código Generado
- **Definición:** Archivos Protegidos y Código Generado: marcado estricto de solo lectura para evitar ediciones efímeras.
- **Límites y Anti-Patrones:** Repositorios Sin Generadores de Código:** En proyectos que no utilizan Protobuf, GraphQL Code Generator ni generadores de clientes OpenAPI, esta regla no añade restricciones.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los directorios y archivos de código generado están claramente identificados (`src/generated/`)?
  - [ ] ¿Los archivos generados incluyen encabezados explícitos advirtiendo que no deben editarse a mano?
  - [ ] ¿`AGENTS.md` documenta el script canónico para regenerar los artefactos a partir de los esquemas fuente?
  - [ ] ¿El pipeline de CI valida que los archivos generados comiteados coincidan exactamente con la compilación limpia del esquema?

### 8.16 Registro de Errores y Trampas Conocidas (Known Pitfalls)
- **Definición:** Registro de Trampas Conocidas: catálogo de errores no intuitivos y soluciones probadas en TROUBLESHOOTING.md.
- **Límites y Anti-Patrones:** Catálogos Desactualizados (*Stale Pitfalls*):** Si una trampa correspondía a un bug de una librería que ya fue corregido en la versión actual, la entrada debe retirarse o archivarse para no confundir al agente. | No Documentar Errores Triviales de Sintaxis:** Documentar que falta un dos puntos (`:`) tras un `if` es ruido; el registro debe contener **peculiaridades no obvias y trampas arquitectónicas**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un archivo `docs/TROUBLESHOOTING.md` con las trampas conocidas del stack técnico?
  - [ ] ¿Cada entrada sigue la estructura estándar: Síntoma, Causa Raíz y Solución con código?
  - [ ] ¿Se instruye a los agentes en `AGENTS.md` a consultar este registro ante errores inesperados?
  - [ ] ¿El registro se actualiza cada vez que se resuelve un bug complejo o incidente no trivial?

### 8.17 No Unrelated Changes y Presupuesto de Modificación (Change Budget)
- **Definición:** Directrices estrictas para limitar el alcance de mutación de los agentes, prohibiendo modificaciones no relacionadas y fijando un presupuesto máximo de cambios.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó no unrelated changes y presupuesto de modificación (change budget) conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?

### 8.18 No Silent Fallbacks: Prohibición de Enmascaramiento y Fallo Explícito
- **Definición:** Norma de ingeniería para prohibir capturas genéricas de excepciones silenciosas y forzar fallos explícitos y tipados.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó no silent fallbacks: prohibición de enmascaramiento y fallo explícito conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?

### 8.19 Task Artifacts y Retención de Memoria Operativa en Sesiones Agénticas
- **Definición:** Práctica de generación, estructuración y persistencia de artefactos de tarea para retener memoria operativa a lo largo de sesiones multi-turno.
- **Checklist Completa de Verificación:**
  - [ ] Subtarea 1: Análisis estático y localización de llamadas deprecadas.
  - [ ] Subtarea 2: Creación de tests unitarios de caracterización.
  - [ ] Subtarea 4: Validación de DoD y suite verde.

### 8.20 Evaluación Sistemática y Benchmarking de Agentes de IA en el Repositorio
- **Definición:** Metodología y herramientas para evaluar y benchmarkear cuantitativamente el desempeño, consumo de tokens y tasa de éxito de agentes en el repositorio.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó evaluación sistemática y benchmarking de agentes de ia en el repositorio conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?


## Sección 9: Entorno Cognitivo y Capas Operativas para IA

### 9.1 Las 10 Capas del Entorno Cognitivo y Operativo para IA Agéntica
- **Definición:** Las 10 Capas del Entorno Cognitivo: marco integral y fórmula de calidad para ingeniería de software agéntica.
- **Límites y Anti-Patrones:** Proyectos de Una Sola Función / Scripts Descartables:** Para un script de 20 líneas de scraping de un solo uso, implementar las 10 capas completas representa sobre-ingeniería innecesaria; el marco está diseñado para **sistemas de software profesionales y bases de código en producción**.
- **Checklist Completa de Verificación:**
  - [ ] ¿El repositorio cuenta con las capas de memoria persistente (`AGENTS.md`) y mapa semántico (`REPO_MAP.md`)?
  - [ ] ¿Los contratos de dominio están formalizados mediante tipos estáticos y Pydantic?
  - [ ] ¿Existen scripts de diagnóstico (`doctor.py`) y validación unificada (`validate.py`)?
  - [ ] ¿Los fallos resueltos se incorporan sistemáticamente a las directivas y tests preventivos (Capa 10)?

### 9.2 Arquitectura de Información y Mapa Semántico del Repositorio
- **Definición:** Information Architecture y REPO_MAP.md: mapa de navegación semántica y eliminación de carpetas cajón de sastre.
- **Límites y Anti-Patrones:** Sobre-atomización (*Over-fragmentation*):** Crear 30 dominios con 1 solo archivo de 10 líneas cada uno genera sobrecarga de navegación; los dominios deben agrupar **unidades lógicas con tamaño sustancial**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se eliminaron del repositorio las carpetas `utils`, `helpers`, `misc` y `common`?
  - [ ] ¿Existe un archivo `docs/REPO_MAP.md` que indexe todos los subsistemas y sus rutas?
  - [ ] ¿Cada dominio de negocio cuenta con su carpeta de código y su carpeta espejo de tests?
  - [ ] ¿El mapa semántico es conciso y está estructurado en formato tabular?

### 9.3 Desarrollo Guiado por Contratos y Tipado Estricto
- **Definición:** Contract-Driven Development: interfaces tipadas y contratos formales como razonador externo para agentes de IA.
- **Límites y Anti-Patrones:** Prototipado Exploratorio Rápido:** En análisis de datos interactivos en notebooks donde la estructura de datos es desconocida de antemano, los esquemas estrictos pueden ralentizar la exploración inicial.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los contratos de entrada y salida están definidos mediante modelos Pydantic o `@dataclass(frozen=True)`?
  - [ ] ¿Las dependencias externas se abstraen mediante interfaces `typing.Protocol`?
  - [ ] ¿El analizador estático `mypy --strict src/` pasa con cero errores de tipo?
  - [ ] ¿Se prohibió el paso de diccionarios genéricos `dict[str, Any]` sin tipar en las interfaces del dominio?

### 9.4 Código Diseñado para Inspección Agéntica (Agent-Readable Code)
- **Definición:** Agent-Readable Code: código estructurado para mínima inferencia inductiva, linealidad y máxima comprensibilidad.
- **Límites y Anti-Patrones:** Frameworks con Decoradores Establecidos:** Usar `@app.get()` en FastAPI o `@pytest.fixture` en Pytest es estándar y bien comprendido por los LLMs; lo que se prohíbe es **crear frameworks caseros de metaprogramación indocumentada**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las funciones de negocio tienen menos de 30 líneas de código y baja complejidad ciclomática?
  - [ ] ¿Todas las dependencias y parámetros se reciben explícitamente sin magia de `**kwargs` o `setattr`?
  - [ ] ¿Las estructuras de datos son inmutables y declaran explícitamente todos sus atributos y tipos?
  - [ ] ¿El flujo de ejecución es lineal y predecible sin efectos secundarios ocultos?

### 9.5 Herramientas y Scripts de Diagnóstico Dedicados (Diagnostic Tooling)
- **Definición:** Diagnostic Tooling: scripts de diagnóstico rápido (doctor.py) para aislar fallos y obtener evidencia inmediata.
- **Límites y Anti-Patrones:** Scripts de Diagnóstico Pesados:** Un script de diagnóstico que tarda 5 minutos en ejecutar pruebas de carga pierde su propósito; `doctor.py` debe ser **ultrarrápido (<2 segundos)** para que el agente lo ejecute sin fricción.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe un script `scripts/doctor.py` en el repositorio?
  - [ ] ¿El script valida versiones de runtime, herramientas requeridas y variables de entorno?
  - [ ] ¿La salida indica con claridad la causa y los pasos de solución ante cada fallo?
  - [ ] ¿Se instruye al agente en `AGENTS.md` a ejecutar el diagnóstico como primer paso de triage?

### 9.6 API Operativa del Repositorio e Interfaz de Comandos Estable
- **Definición:** API de Comandos Estable: interfaz estándar y unificada de tareas operativas (setup, test, check, build).
- **Límites y Anti-Patrones:** Dependencia de Binarios No Portables:** Si se usa `make` en un equipo donde conviven desarrolladores de Windows sin WSL, la ejecución puede fallar; se recomienda usar **Taskfile (Go binario portátil)** o runners nativos en Python (`python scripts/task.py`).
- **Checklist Completa de Verificación:**
  - [ ] ¿Existe una interfaz de comandos estándar (`Taskfile.yml`, `Makefile` o `scripts/validate.py`)?
  - [ ] ¿Las tareas principales (`setup`, `lint`, `typecheck`, `test`, `check`) están definidas?
  - [ ] ¿El comando `check` ejecuta la totalidad de las validaciones de calidad en un solo paso?
  - [ ] ¿Las directivas en `AGENTS.md` instruyen al agente a usar la Task API estandarizada?

### 9.7 Tests Arquitectónicos y Validadores a Medida
- **Definición:** Tests Arquitectónicos: validación automatizada de capas de importación con pytest-archon y analizadores AST.
- **Límites y Anti-Patrones:** Sistemas Legacy con Alto Acoplamiento Previo:** En proyectos antiguos con miles de violaciones históricas, activar reglas globales puede bloquear todo el desarrollo; se deben configurar reglas con excepciones acotadas (*allow-lists*) y sanearlas de forma progresiva.
- **Checklist Completa de Verificación:**
  - [ ] ¿Existen tests arquitectónicos automatizados en la carpeta `tests/arch/`?
  - [ ] ¿Se verifica que el núcleo de dominio no importe módulos de infraestructura ni frameworks web?
  - [ ] ¿Se audita la ausencia de importaciones cíclicas en todo el proyecto?
  - [ ] ¿Los tests arquitectónicos se ejecutan en cada corrida de `python scripts/validate.py`?

### 9.8 Golden Tests y Casos de Referencia Concretos
- **Definición:** Golden Tests: comparación determinista contra snapshots y casos de referencia inmutables en fixtures/golden/.
- **Límites y Anti-Patrones:** Datos No Deterministas en Snapshots:** Si la salida contiene fechas dinámicas (`datetime.now()`) o IDs aleatorios (`uuid4()`), el Golden Test fallará continuamente; se deben **mockear los generadores de tiempo y UUIDs** para garantizar salidas 100% deterministas. | Aceptación Ciega de Snapshots Rotos:** Actualizar los archivos golden automáticamente sin revisar el diff humano puede perpetuar bugs en el archivo de referencia.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los subsistemas de parsing y serialización compleja cuentan con Golden Tests en `tests/fixtures/golden/`?
  - [ ] ¿Los datos variables (timestamps, UUIDs) están normalizados o mockeados para asegurar determinismo?
  - [ ] ¿Los archivos de referencia dorados están bajo control de versiones en Git?
  - [ ] ¿Cualquier modificación intencional en la estructura golden requiere revisión y aprobación explícita?

### 9.9 Protocolo de Feedback Estructurado de Alta Fidelidad
- **Definición:** Protocolo de Feedback Estructurado: formato Expected vs Actual y captura de trazas exactas para resolución veloz.
- **Límites y Anti-Patrones:** Consultas Conceptuales Abiertas:** Cuando el usuario solicita una sesión de lluvia de ideas sobre arquitectura o diseño preliminar, exigir el formato *Expected vs Actual* es inapropiado; el protocolo aplica estrictamente a **reportes de bugs, tareas de corrección y revisiones de código**.
- **Checklist Completa de Verificación:**
  - [ ] ¿El feedback incluye las secciones explícitas *Expected Behavior* y *Actual Behavior*?
  - [ ] ¿Se proporciona el comando de terminal exacto para reproducir la falla?
  - [ ] ¿Se adjunta la traza de error completa o el mensaje de fallo del linter/compilador?
  - [ ] ¿Se identifican las rutas de los archivos afectados con números de línea aproximados?

### 9.10 Aislamiento con Git Worktrees y Exploración Paralela
- **Definición:** Aislamiento con Git Worktrees: ramas y directorios aislados para exploración paralela multi-agente sin colisiones.
- **Límites y Anti-Patrones:** Colisiones de Puertos en Bases de Datos Locales:** Si ambos worktrees intentan levantar un servidor local en el puerto `8000` o usar la misma base de datos SQLite de archivo, habrá colisión de red; se deben configurar **puertos dinámicos o bases de datos en memoria para cada worktree**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Los agentes paralelos operan en sus propios Git Worktrees aislados?
  - [ ] ¿El directorio `.agent/worktrees/` está añadido a `.gitignore`?
  - [ ] ¿Existe un mecanismo automatizado para destruir los worktrees temporales tras el merge?
  - [ ] ¿Los servicios locales y tests utilizan bases de datos y puertos independientes por worktree?

### 9.11 Flujo de Ejecución por Fases y Roles Agénticos Especializados
- **Definición:** Flujo por Fases y Roles Especializados: pipeline secuencial de Architect, Developer, Tester y Reviewer.
- **Límites y Anti-Patrones:** Tareas Atómicas Simples:** Para fixes de 2 líneas (ej. corregir un typo en una constante), convocar el pipeline de 4 roles añade sobrecarga innecesaria; un solo agente con auto-verificación es suficiente.
- **Checklist Completa de Verificación:**
  - [ ] ¿Las tareas complejas se dividen en fases claras (Plan -> Code -> Test -> Review)?
  - [ ] ¿Los roles cuentan con directivas y prompts especializados para su función?
  - [ ] ¿El rol de testing/review audita de forma independiente el código antes de la entrega final?
  - [ ] ¿Cada fase produce un artefacto verificable antes de transferir el control a la siguiente?

### 9.12 Bucles de Conocimiento y Aprendizaje Continuo (Knowledge Loops)
- **Definición:** Knowledge Loops: transformación sistemática de fallos e incidentes en tests, invariantes y directivas preventivas.
- **Límites y Anti-Patrones:** Sobrecarga de Documentación para Typos Menores:** Documentar un error tipográfico en una cadena de texto en `DOMAIN.md` o crear un test de regresión para una coma es innecesario; los Knowledge Loops deben activarse ante **defectos lógicos, fallos de concurrencia, problemas de seguridad o roturas de contratos**.
- **Checklist Completa de Verificación:**
  - [ ] ¿Cada bug resuelto incluye su correspondiente test de regresión automatizado?
  - [ ] ¿Las reglas de negocio descubiertas se registraron como invariantes en `docs/DOMAIN.md`?
  - [ ] ¿Los errores no intuitivos del stack se incorporaron a `docs/TROUBLESHOOTING.md`?
  - [ ] ¿Se actualizaron las directivas en `AGENTS.md` para prohibir explícitamente el antipatrón que originó el fallo?

### 9.13 Ejemplos Concretos e Implementaciones de Referencia (Few-Shot in-Repo)
- **Definición:** Guía para el diseño de carpetas de ejemplos canónicos que proporcionen a los modelos de lenguaje patrones de código ejecutables y testeados en CI.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó ejemplos concretos e implementaciones de referencia (few-shot in-repo) conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?

### 9.14 Reportes de Bugs Reproducibles y Casos Mínimos de Reproducción (MRE)
- **Definición:** Protocolo para formular reportes de bugs reproducibles y construir Casos Mínimos de Reproducción (MREs) optimizados para agentes de IA.
- **Checklist Completa de Verificación:**
  - [ ] ¿Se implementó y verificó reportes de bugs reproducibles y casos mínimos de reproducción (mre) conforme a los estándares de arquitectura?
  - [ ] ¿Existen pruebas automatizadas que garanticen su cumplimiento continuo?
