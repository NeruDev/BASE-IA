haz una lista de archivos estandar de Git que se usan comunmente en github para repos creados con IA agentica (README.md, ARCHITECTURE.md, AGENTS.md, etc), define su uso comun y secciones frecuentes (como "como instalar" en un readme y "arbol de directorios" en "ARCHITECTURE.md") 

Para un repositorio pensado para **trabajo humano + IA agéntica**, conviene separar tres cosas que GitHub, porque aparentemente necesitábamos otra capa de documentación, suele mezclar alegremente:

1. **Documentación para humanos**: qué es el proyecto y cómo usarlo.
2. **Contexto para agentes**: qué pueden tocar, cómo deben trabajar y qué reglas seguir.
3. **Metadatos y automatización del repositorio**: CI, issues, PRs, seguridad, releases, etc.

No todos estos archivos son estándares oficiales de Git. Algunos son convenciones de GitHub, otros de la comunidad, y otros se han vuelto especialmente útiles con agentes como Claude Code, Codex, Copilot, Gemini CLI, Cursor, etc.

# 1. Documentación principal del proyecto

| Archivo           | Uso común                               | Secciones frecuentes                                                                                        |
| ----------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `README.md`       | Puerta de entrada del repositorio       | Descripción, características, instalación, uso, ejemplos, requisitos, estructura, contribución, licencia    |
| `ARCHITECTURE.md` | Explica cómo está construido el sistema | Visión general, componentes, árbol de directorios, flujo de datos, dependencias, decisiones arquitectónicas |
| `CONTRIBUTING.md` | Explica cómo contribuir                 | Preparación del entorno, flujo Git, estilo de código, pruebas, commits, PRs                                 |
| `CHANGELOG.md`    | Historial de cambios relevantes         | Versiones, Added, Changed, Fixed, Deprecated, Removed                                                       |
| `ROADMAP.md`      | Plan de evolución del proyecto          | Estado actual, objetivos, próximas versiones, backlog, prioridades                                          |
| `FAQ.md`          | Preguntas frecuentes                    | Instalación, errores comunes, configuración, conceptos                                                      |
| `GLOSSARY.md`     | Define terminología del proyecto        | Términos, acrónimos, conceptos internos                                                                     |
| `DECISIONS.md`    | Resumen de decisiones técnicas          | Decisión, contexto, alternativas, consecuencias                                                             |

---

# 2. `README.md`

El archivo más universal del ecosistema. Si alguien entra al repositorio y no entiende qué demonios hace el proyecto, el `README.md` falló.

Una estructura frecuente sería:

```text
README.md
│
├── Título y descripción
├── Estado del proyecto
├── Características principales
├── Requisitos
├── Instalación
├── Configuración
├── Uso
├── Ejemplos
├── Estructura básica del proyecto
├── Scripts disponibles
├── Pruebas
├── Documentación adicional
├── Contribución
├── Licencia
└── Créditos
```

Para repositorios con IA agéntica, añadiría además:

### Contexto rápido para agentes

```markdown
## Para agentes de IA

Antes de modificar el repositorio:

1. Leer `AGENTS.md`.
2. Revisar `ARCHITECTURE.md`.
3. Consultar las instrucciones específicas del directorio.
4. Ejecutar las pruebas correspondientes antes de finalizar.
```

El README debería ser una **vista panorámica**, no una enciclopedia de 14 000 líneas escrita por alguien que descubrió Markdown a las tres de la mañana.

---

# 3. `ARCHITECTURE.md`

Este archivo es especialmente importante para IA agéntica.

Su objetivo es responder:

> **¿Cómo está organizado este sistema y cómo se relacionan sus partes?**

Una estructura recomendable:

```text
ARCHITECTURE.md
│
├── 1. Propósito arquitectónico
├── 2. Visión general del sistema
├── 3. Componentes principales
├── 4. Árbol de directorios
├── 5. Responsabilidades por módulo
├── 6. Flujo de datos
├── 7. Dependencias
├── 8. Interfaces y contratos
├── 9. Patrones arquitectónicos
├── 10. Restricciones técnicas
└── 11. Decisiones importantes
```

Ejemplo del árbol:

```text
project/
├── src/
│   ├── core/
│   ├── services/
│   ├── api/
│   └── ui/
├── tests/
├── scripts/
├── docs/
├── config/
└── .github/
```

Pero para una IA, el árbol por sí solo sirve aproximadamente lo mismo que entregarle un mapa del metro sin nombres de estaciones.

Conviene añadir responsabilidades:

```markdown
## `src/core/`

Contiene la lógica de dominio.

- No depende de la interfaz gráfica.
- No realiza llamadas HTTP.
- No accede directamente a la base de datos.

## `src/services/`

Coordina operaciones entre componentes.

- Puede depender de `core`.
- No debe contener lógica de presentación.
```

Eso permite que el agente no tenga que inferir toda la arquitectura a partir de nombres de carpetas.

---

# 4. `AGENTS.md`

Este es probablemente el archivo más importante cuando el repositorio será manipulado regularmente por IA agéntica.

Su función es responder:

> **¿Cómo debe comportarse un agente dentro de este repositorio?**

Secciones recomendadas:

```text
AGENTS.md
│
├── Propósito
├── Instrucciones generales
├── Entorno de desarrollo
├── Comandos permitidos
├── Comandos de prueba
├── Convenciones de código
├── Convenciones de nombres
├── Arquitectura relevante
├── Archivos sensibles
├── Restricciones
├── Flujo de trabajo
├── Validación antes de finalizar
└── Referencias a otros documentos
```

Ejemplo:

````markdown
# AGENTS.md

## Antes de modificar

1. Leer `ARCHITECTURE.md`.
2. Identificar el módulo responsable.
3. Buscar implementaciones relacionadas.
4. Revisar las pruebas existentes.

## Convenciones

- Usar `snake_case`.
- Codificación UTF-8.
- No introducir dependencias sin justificación.
- Mantener compatibilidad con Python 3.12.

## Antes de finalizar

Ejecutar:

```powershell
pytest
python -m ruff check .
````

## Prohibiciones

* No modificar archivos generados manualmente.
* No editar `config/production`.
* No eliminar pruebas para hacer pasar el pipeline.

````

El punto importante es que `AGENTS.md` no debería convertirse en una segunda constitución de 400 páginas. Debe contener **instrucciones operativas**, no cada detalle imaginable del proyecto.

---

# 5. `CONTEXT.md`

No es un estándar oficial universal, pero resulta muy útil para agentes.

Su propósito es proporcionar **contexto conceptual condensado**.

```text
CONTEXT.md
│
├── Qué problema resuelve el proyecto
├── Usuarios objetivo
├── Conceptos importantes
├── Restricciones del dominio
├── Suposiciones
├── Casos límite conocidos
└── Objetivos y no objetivos
````

Ejemplo:

```markdown
## Objetivo

El sistema procesa mediciones de sensores IoT y genera alertas.

## No objetivo

No pretende sustituir sistemas industriales SCADA.

## Restricciones

- Debe funcionar sin conexión permanente.
- La latencia máxima aceptable es 500 ms.
- Los dispositivos pueden enviar datos incompletos.
```

Esto ayuda mucho más a una IA que simplemente decir:

> "Aquí está el código. Buena suerte."

Método tradicional de ingeniería, aparentemente.

---

# 6. `DOMAIN.md`

Muy recomendable en proyectos con lógica de negocio compleja.

Explica el **dominio del problema**, no la implementación.

```text
DOMAIN.md
│
├── Entidades
├── Conceptos
├── Reglas de negocio
├── Estados
├── Transiciones
├── Invariantes
└── Casos especiales
```

Ejemplo:

```markdown
## Sensor

Un sensor puede tener los estados:

- `online`
- `offline`
- `error`

### Regla

Un sensor no puede pasar directamente de `offline` a `error`
sin registrar primero una conexión.
```

Esto evita que el agente tenga que intentar reconstruir reglas de negocio leyendo 47 archivos y sacrificando varias cabras digitales.

---

# 7. `SPECIFICATION.md`

Define **qué debe hacer el sistema**.

Especialmente útil cuando quieres separar:

* **qué debe ocurrir**
* de
* **cómo está implementado actualmente**

Secciones:

```text
SPECIFICATION.md
│
├── Objetivos
├── Requisitos funcionales
├── Requisitos no funcionales
├── Casos de uso
├── Entradas
├── Salidas
├── Restricciones
└── Criterios de aceptación
```

Ejemplo:

```markdown
## RF-01

El sistema debe permitir registrar un nuevo dispositivo.

### Entrada

Identificador único y tipo de dispositivo.

### Resultado esperado

El dispositivo queda disponible para recibir mediciones.

### Criterio de aceptación

El registro debe rechazar identificadores duplicados.
```

Para agentes, los **criterios de aceptación** son especialmente valiosos porque proporcionan una forma objetiva de saber cuándo una tarea está terminada.

---

# 8. `DEVELOPMENT.md`

Explica cómo trabajar localmente con el proyecto.

```text
DEVELOPMENT.md
│
├── Requisitos
├── Configuración del entorno
├── Instalación de dependencias
├── Variables de entorno
├── Ejecución local
├── Depuración
├── Pruebas
├── Formateo
└── Troubleshooting
```

Ejemplo:

````markdown
## Configuración

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
````

## Ejecutar

```powershell
python src/main.py
```

````

Esto evita que las instrucciones operativas llenen el README o el AGENTS.md.

---

# 9. `TESTING.md`

Documenta la estrategia de pruebas.

```text
TESTING.md
│
├── Filosofía de testing
├── Tipos de pruebas
├── Estructura de tests
├── Convenciones
├── Fixtures
├── Mocking
├── Cobertura
├── Comandos
└── Casos críticos
````

Ejemplo:

```markdown
## Estructura

tests/
├── unit/
├── integration/
└── e2e/

## Regla

- La lógica de dominio requiere pruebas unitarias.
- Las integraciones externas deben utilizar mocks.
```

Esto es bastante útil para impedir que un agente "arregle" una prueba eliminándola. Sí, algunos modelos consideran esa una solución. Técnicamente también puedes arreglar un incendio demoliendo el edificio.

---

# 10. `SECURITY.md`

Convención ampliamente usada en GitHub.

Secciones frecuentes:

```text
SECURITY.md
│
├── Versiones soportadas
├── Reporte de vulnerabilidades
├── Información que no debe publicarse
├── Manejo de secretos
└── Proceso de respuesta
```

Ejemplo:

```markdown
## Secretos

Nunca almacenar:

- API keys
- Tokens
- Contraseñas
- Credenciales de producción
```

Para IA agéntica conviene indicar explícitamente:

```markdown
Los agentes no deben imprimir, registrar ni copiar secretos
en archivos de documentación, commits o pruebas.
```

---

# 11. `CONTRIBUTING.md`

Explica el procedimiento para modificar el proyecto.

Secciones:

```text
CONTRIBUTING.md
│
├── Código de conducta
├── Configuración del entorno
├── Flujo de ramas
├── Convenciones
├── Commits
├── Pruebas
├── Pull Requests
└── Revisión
```

Un agente puede usar este archivo como definición del flujo estándar:

```text
Issue
  ↓
Crear rama
  ↓
Modificar
  ↓
Ejecutar pruebas
  ↓
Actualizar documentación
  ↓
Commit
  ↓
Pull Request
```

---

# 12. `CHANGELOG.md`

Registra cambios significativos.

Una estructura común sigue el estilo **Keep a Changelog**:

```markdown
# Changelog

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

## [1.2.0]

### Added

- Nueva API para sensores.

### Fixed

- Corrección en la validación de dispositivos.
```

Para IA, también puede servir como **memoria histórica resumida**.

Sin embargo, no debería convertirse en el lugar donde el agente describe cada variable que renombró. Nadie merece leer eso.

---

# 13. `ROADMAP.md`

Sirve para indicar hacia dónde va el proyecto.

```text
ROADMAP.md
│
├── Objetivos actuales
├── Próxima versión
├── Futuras versiones
├── Funcionalidades experimentales
├── Deuda técnica
└── Elementos descartados
```

Para agentes es útil incluir:

```markdown
## Prioridades

### Alta

- Estabilizar API.

### Media

- Mejorar rendimiento.

### Baja

- Rediseño visual.

## No implementar actualmente

- Sistema de plugins.
- Aplicación móvil.
```

El apartado **"No implementar"** es sorprendentemente útil. Una IA puede detectar una oportunidad para "mejorar" algo que nadie pidió y convertir una tarea de 20 minutos en una reescritura arquitectónica.

---

# 14. ADRs: `docs/adr/`

En proyectos serios, las decisiones arquitectónicas importantes suelen documentarse mediante **Architecture Decision Records**.

Ejemplo:

```text
docs/
└── adr/
    ├── 0001-use-python.md
    ├── 0002-use-postgresql.md
    └── 0003-event-driven-architecture.md
```

Cada ADR suele contener:

```text
Título
│
├── Contexto
├── Problema
├── Decisión
├── Alternativas consideradas
├── Consecuencias
└── Estado
```

Ejemplo:

```markdown
# ADR-0002: Usar PostgreSQL

## Contexto

El sistema requiere consultas relacionales complejas.

## Decisión

Se utilizará PostgreSQL.

## Alternativas

- SQLite
- MongoDB

## Consecuencias

- Mayor complejidad de despliegue.
- Mejor soporte para consultas complejas.
```

Para IA agéntica, los ADR son excelentes porque explican **por qué algo es así**, no solamente cómo funciona.

---

# 15. Archivos específicos de proveedores de IA

Aquí empieza el pequeño zoológico de instrucciones incompatibles porque cada proveedor decidió que claramente hacía falta su propio archivo.

| Archivo                                       | Ecosistema                                       |
| --------------------------------------------- | ------------------------------------------------ |
| `AGENTS.md`                                   | Convención general para agentes                  |
| `CLAUDE.md`                                   | Claude Code                                      |
| `GEMINI.md`                                   | Gemini CLI / herramientas Gemini                 |
| `.github/copilot-instructions.md`             | GitHub Copilot                                   |
| `.cursorrules` o configuraciones equivalentes | Cursor                                           |
| `CODEX.md`                                    | Convención usada en algunos proyectos para Codex |
| `instructions.md`                             | Convención genérica o interna                    |

El problema es la duplicación.

Una arquitectura recomendable sería:

```text
project/
├── AGENTS.md
├── ARCHITECTURE.md
├── CONTEXT.md
│
├── .github/
│   └── copilot-instructions.md
│
├── CLAUDE.md
├── GEMINI.md
│
└── docs/
    └── agents/
        ├── coding_rules.md
        ├── testing_rules.md
        └── workflows.md
```

La idea sería:

```text
AGENTS.md
    ↓
Reglas universales del repositorio
    ↓
Documentación especializada
    ↓
Instrucciones específicas del proveedor
```

Así reduces la duplicación.

---

# 16. Archivos estándar de Git y GitHub

También están los clásicos que no existen específicamente para IA, pero que un agente necesita respetar.

| Archivo                  | Uso                                      |
| ------------------------ | ---------------------------------------- |
| `.gitignore`             | Archivos que Git no debe rastrear        |
| `.gitattributes`         | Configuración de atributos de archivos   |
| `.gitmodules`            | Configuración de submódulos              |
| `LICENSE`                | Licencia del proyecto                    |
| `CODE_OF_CONDUCT.md`     | Normas de comportamiento                 |
| `SECURITY.md`            | Política de seguridad                    |
| `SUPPORT.md`             | Canales de soporte                       |
| `FUNDING.yml`            | Información de financiación              |
| `CITATION.cff`           | Cómo citar el proyecto                   |
| `.editorconfig`          | Convenciones básicas de formato          |
| `.github/dependabot.yml` | Actualización automática de dependencias |

---

# 17. `.github/`

La carpeta `.github` concentra gran parte del comportamiento del repositorio en GitHub.

```text
.github/
├── workflows/
├── ISSUE_TEMPLATE/
├── PULL_REQUEST_TEMPLATE.md
├── dependabot.yml
├── CODEOWNERS
└── copilot-instructions.md
```

## `workflows/`

Automatización mediante GitHub Actions:

```text
.github/workflows/
├── tests.yml
├── lint.yml
├── build.yml
└── release.yml
```

## `ISSUE_TEMPLATE/`

Plantillas para reportes:

```text
.github/ISSUE_TEMPLATE/
├── bug_report.md
├── feature_request.md
└── config.yml
```

## `PULL_REQUEST_TEMPLATE.md`

Estructura estándar para PRs:

```markdown
## Descripción

## Cambios realizados

## Pruebas ejecutadas

## Checklist

- [ ] Las pruebas pasan.
- [ ] La documentación fue actualizada.
- [ ] No se introdujeron secretos.
```

---

# 18. `CODEOWNERS`

Define quién es responsable de determinadas partes.

```text
/src/core/ @backend-team
/docs/ @documentation-team
/.github/ @devops-team
```

En un repositorio con IA también puede funcionar como información adicional de responsabilidad humana.

Un agente podría interpretar:

```text
src/core/
```

como una zona especialmente sensible donde los cambios requieren mayor validación.

---

# 19. `.editorconfig`

Define reglas de formato independientes del editor.

Ejemplo:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```

Es muy útil para evitar que un agente, un editor, una extensión y otro desarrollador entren en guerra santa por espacios, tabs y saltos de línea.

---

# 20. `DEPENDENCIES.md` o `TECH_STACK.md`

No son estándares universales, pero son especialmente útiles para agentes.

## `TECH_STACK.md`

```text
├── Lenguajes
├── Frameworks
├── Bases de datos
├── Herramientas
├── Versiones
├── Dependencias principales
└── Integraciones externas
```

Ejemplo:

```markdown
| Tecnología | Uso | Versión |
|---|---|---|
| Python | Backend | 3.12 |
| FastAPI | API | 0.115 |
| PostgreSQL | Base de datos | 16 |
```

Esto evita que el agente tenga que recorrer `package.json`, `pyproject.toml`, `requirements.txt`, Dockerfiles y media docena de archivos para descubrir qué demonios usa el proyecto.

---

# 21. `OPERATIONS.md`

Útil si el repositorio incluye despliegue o infraestructura.

```text
OPERATIONS.md
│
├── Entornos
├── Desarrollo
├── Staging
├── Producción
├── Variables
├── Despliegue
├── Rollback
├── Logs
└── Monitorización
```

Para agentes, aquí pueden declararse límites explícitos:

```markdown
## Producción

Los agentes no deben:

- ejecutar despliegues;
- modificar secretos;
- ejecutar migraciones destructivas;
- eliminar infraestructura.
```

---

# 22. `TROUBLESHOOTING.md`

Muy recomendable cuando un proyecto mezcla tecnologías.

```text
TROUBLESHOOTING.md
│
├── Problemas conocidos
├── Síntomas
├── Causas posibles
├── Diagnóstico
├── Solución
└── Información para debugging
```

Ejemplo:

````markdown
## La interfaz no muestra datos

### Posibles causas

1. API no disponible.
2. Error CORS.
3. Evento WebSocket no recibido.
4. Error de serialización.

### Diagnóstico

```powershell
python scripts/check_api.py
````

````

Esto es oro para agentes, especialmente en sistemas como los que mezclan Python, frontend y comunicación entre procesos.

---

# 23. `STYLE_GUIDE.md`

Documenta convenciones que van más allá de un formatter.

```text
STYLE_GUIDE.md
│
├── Nombres
├── Organización de archivos
├── Imports
├── Comentarios
├── Documentación
├── Manejo de errores
└── Logging
````

Ejemplo:

```markdown
## Funciones

Usar:

snake_case

## Clases

Usar:

PascalCase

## Logging

No usar `print()` en código de producción.
Usar el sistema centralizado de logging.
```

---

# 24. Estructura que recomendaría para un repositorio con IA agéntica

Para no convertir el repositorio en una biblioteca burocrática donde la documentación pesa más que el código:

```text
project/
│
├── README.md
├── AGENTS.md
├── ARCHITECTURE.md
├── CONTEXT.md
├── DEVELOPMENT.md
├── TESTING.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── ROADMAP.md
├── SECURITY.md
├── LICENSE
│
├── .gitignore
├── .gitattributes
├── .editorconfig
│
├── CLAUDE.md
├── GEMINI.md
│
├── docs/
│   ├── adr/
│   │   ├── 0001-example.md
│   │   └── ...
│   │
│   ├── DOMAIN.md
│   ├── SPECIFICATION.md
│   ├── STYLE_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── OPERATIONS.md
│
├── .github/
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CODEOWNERS
│   └── copilot-instructions.md
│
├── src/
├── tests/
├── scripts/
└── config/
```

# Mi clasificación práctica

Si tuviera que dividirlos por **nivel de importancia para un proyecto asistido por IA**, quedaría así:

### Nivel 1: casi imprescindibles

```text
README.md
AGENTS.md
ARCHITECTURE.md
.gitignore
LICENSE
.editorconfig
CONTRIBUTING.md
```

### Nivel 2: muy recomendables

```text
DEVELOPMENT.md
TESTING.md
CHANGELOG.md
SECURITY.md
ROADMAP.md
TROUBLESHOOTING.md
```

### Nivel 3: según complejidad

```text
CONTEXT.md
DOMAIN.md
SPECIFICATION.md
STYLE_GUIDE.md
TECH_STACK.md
OPERATIONS.md
GLOSSARY.md
FAQ.md
```

### Nivel 4: cuando el proyecto ya tiene cierta madurez

```text
docs/adr/
CODEOWNERS
SUPPORT.md
CITATION.cff
dependabot.yml
ISSUE_TEMPLATE/
PULL_REQUEST_TEMPLATE.md
```

## La distinción más importante para IA agéntica

Yo estructuraría la información mental del agente así:

```text
¿QUÉ ES?
    README.md

¿QUÉ PROBLEMA RESUELVE?
    CONTEXT.md
    DOMAIN.md
    SPECIFICATION.md

¿CÓMO ESTÁ CONSTRUIDO?
    ARCHITECTURE.md
    TECH_STACK.md
    ADRs

¿CÓMO DEBO TRABAJAR?
    AGENTS.md
    CONTRIBUTING.md
    STYLE_GUIDE.md

¿CÓMO EJECUTO Y PRUEBO?
    DEVELOPMENT.md
    TESTING.md

¿QUÉ NO DEBO ROMPER?
    SECURITY.md
    AGENTS.md
    CODEOWNERS

¿QUÉ HA CAMBIADO Y HACIA DÓNDE VA?
    CHANGELOG.md
    ROADMAP.md
```

La clave no es acumular archivos con nombres impresionantes. Una IA agéntica obtiene más valor de **documentación pequeña, explícita, estructurada y con responsabilidades bien separadas** que de un gigantesco `AGENTS.md` donde arquitectura, instalación, reglas, dominio, estilo y rituales ancestrales estén mezclados en un mismo documento.





si el repo va a ser creado por 1 sola persona y la IA agentica, que estandares de documentacion existen actualmente para realizar ese tipo de repos y cuales son las buenas practicas a seguir para ese caso ?

Sí, pero hay una corrección importante: **no existe actualmente un estándar único y universal llamado “documentación para repositorios creados por una persona + IA agéntica”**. Lo que existe es una combinación de estándares y convenciones maduras, y el truco consiste en adaptarlos sin montar una burocracia corporativa para un proyecto donde, literalmente, hay una persona, un agente y una carpeta `.git`.

La buena práctica central sería:

> **Documentar para minimizar la reconstrucción de contexto, no para simular que el repositorio tiene 400 empleados.**

Eso cambia bastante la estructura que recomendaría frente a un proyecto open source tradicional.


## La respuesta corta: usa estándares existentes, pero no todos

Para un repositorio mantenido por **una sola persona y una o varias IAs agénticas**, yo no copiaría ciegamente el modelo de un proyecto open source con decenas de contribuidores.

Actualmente hay **cuatro familias de estándares o convenciones** que se pueden combinar:

1. **Estándares tradicionales de Git/GitHub**
2. **Documentación técnica y arquitectónica**
3. **Archivos de instrucciones para agentes**
4. **Documentación ejecutable y validación automática**

La tendencia más clara en 2026 es que `AGENTS.md` se está consolidando como una capa relativamente portable para instrucciones de agentes. Codex utiliza instrucciones jerárquicas basadas en `AGENTS.md`, y GitHub Copilot ya reconoce `AGENTS.md`, `CLAUDE.md` y `GEMINI.md` en distintos flujos de agentes. ([GitHub][1])

---

# 1. El modelo que recomendaría: documentación por capas

En vez de esto:

```text
AGENTS.md
└── 2,000 líneas de:
    ├── arquitectura
    ├── instalación
    ├── reglas
    ├── estilo
    ├── testing
    ├── decisiones
    ├── dominio
    └── posiblemente la historia de la humanidad
```

conviene separar:

```text
                ┌─────────────────┐
                │     README      │
                │  Qué es esto?   │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │    AGENTS.md    │
                │ Cómo trabajar?  │
                └────────┬────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
   ARCHITECTURE      DEVELOPMENT      TESTING
   Cómo funciona     Cómo ejecutar    Cómo validar
          │
          ▼
        docs/
          │
   ┌──────┼─────────┐
   ▼      ▼         ▼
 DOMAIN  ADRs    TROUBLESHOOTING
```

La regla sería:

> **Cada documento debe responder una pregunta diferente.**

Si dos archivos responden exactamente lo mismo, probablemente uno sobra o ambos están mal definidos.

---

# 2. Estándares que realmente usaría

## Nivel A: base mínima

Para prácticamente cualquier proyecto:

```text
README.md
AGENTS.md
ARCHITECTURE.md
.gitignore
.editorconfig
LICENSE
```

### `README.md`

Pregunta que responde:

> ¿Qué es este proyecto y cómo empiezo?

Debe contener:

```text
- Propósito
- Características
- Requisitos
- Instalación rápida
- Uso básico
- Enlaces a documentación
- Estado del proyecto
```

No metería aquí toda la arquitectura.

---

### `AGENTS.md`

Pregunta:

> ¿Cómo debe trabajar una IA dentro de este repositorio?

Aquí pondría únicamente información **operativa y accionable**:

```text
- Cómo inspeccionar el proyecto
- Qué documentos leer según la tarea
- Comandos de instalación
- Comandos de test
- Reglas obligatorias
- Archivos protegidos
- Restricciones
- Criterios para considerar una tarea terminada
```

La documentación de Codex describe precisamente un modelo jerárquico: instrucciones globales, instrucciones del repositorio e instrucciones más específicas en subdirectorios, donde las más cercanas al área de trabajo pueden refinar las generales. También existe un límite de contexto configurable, con 32 KiB como valor predeterminado para la documentación de proyecto combinada en Codex, lo cual refuerza una regla bastante sana: **no convertir `AGENTS.md` en un vertedero de contexto**. ([GitHub][1])

---

### `ARCHITECTURE.md`

Pregunta:

> ¿Cómo está construido el sistema?

Contenido:

```text
- Visión general
- Componentes
- Árbol de directorios
- Responsabilidad de cada módulo
- Dependencias
- Flujo de datos
- Interfaces importantes
- Restricciones arquitectónicas
```

Aquí está una diferencia importante.

No basta con:

```text
src/
├── backend/
├── frontend/
└── utils/
```

Conviene explicar:

```text
src/backend/
    Responsabilidad: lógica del servidor.

src/frontend/
    Responsabilidad: presentación.

src/utils/
    Solo utilidades compartidas.
    No debe contener lógica de negocio.
```

Eso reduce enormemente la necesidad de que el agente "adivine" dónde debería modificar algo.

---

# 3. Nivel B: documentación que separaría cuando el proyecto crezca

```text
DEVELOPMENT.md
TESTING.md
SECURITY.md
CHANGELOG.md
```

## `DEVELOPMENT.md`

Pregunta:

> ¿Cómo preparo y ejecuto el entorno?

```text
- Requisitos
- Instalación
- Entorno virtual
- Dependencias
- Variables de entorno
- Ejecución
- Depuración
```

---

## `TESTING.md`

Pregunta:

> ¿Cómo verificamos que algo funciona?

```text
- Tipos de pruebas
- Ubicación de tests
- Comandos
- Fixtures
- Mocks
- Casos críticos
- Cobertura
```

Para un proyecto humano + IA, esta es una de las piezas más importantes.

Una IA no debería terminar una tarea con:

> "Implementado correctamente."

Eso significa exactamente cero hasta que se defina **cómo se valida**.

La documentación debe permitir:

```text
Modificar código
      ↓
Ejecutar validación específica
      ↓
Ejecutar pruebas
      ↓
Lint / type checking
      ↓
Actualizar documentación si cambió el comportamiento
      ↓
Terminar
```

---

# 4. El estándar más importante para un proyecto personal con IA: "documentation as interface"

Aquí creo que está el verdadero cambio respecto a un repositorio tradicional.

Para una IA, la documentación no es solamente algo que se lee.

La documentación funciona como una **interfaz de control**.

Por ejemplo:

````markdown
## Validación obligatoria

Después de modificar `src/api/`:

```powershell
pytest tests/api
ruff check src/api
````

## Restricciones

* No modificar contratos públicos sin actualizar `docs/api.md`.
* No añadir dependencias sin justificarlo.
* No editar archivos generados.

````

Esto es mucho más útil para un agente que:

```markdown
Nuestro proyecto busca la excelencia tecnológica
mediante soluciones innovadoras y escalables.
````

Hermoso. Inspirador. Completamente inútil para decidir qué archivo modificar.

---

# 5. Buenas prácticas específicas para una sola persona + IA

## 5.1 Mantener una sola fuente de verdad

Esta es probablemente la regla más importante.

No hagas esto:

```text
AGENTS.md
    "Usamos Python 3.12"

CLAUDE.md
    "Usamos Python 3.13"

GEMINI.md
    "Preferimos Python 3.11"

copilot-instructions.md
    "Quién sabe, sorpréndenos"
```

La arquitectura correcta sería:

```text
                 AGENTS.md
                      │
                      ▼
              Política del repo
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
   ARCHITECTURE   DEVELOPMENT   TESTING
```

Y los archivos específicos de herramientas deberían ser adaptadores mínimos.

GitHub Copilot admite actualmente instrucciones para todo el repositorio mediante `.github/copilot-instructions.md`, instrucciones específicas por ruta mediante `.github/instructions/*.instructions.md` y, para ciertos flujos de agentes, `AGENTS.md`, `CLAUDE.md` y `GEMINI.md`. ([GitHub Docs][2])

Mi recomendación sería:

```text
AGENTS.md
    ↓
Fuente de verdad universal

CLAUDE.md
GEMINI.md
.github/copilot-instructions.md
    ↓
Solo instrucciones necesarias
para compatibilidad con cada herramienta
```

No duplicar toda la política.

---

# 6. Usar instrucciones jerárquicas

Esta es una práctica especialmente buena cuando el repositorio crece.

Por ejemplo:

```text
project/
│
├── AGENTS.md
│
├── backend/
│   ├── AGENTS.md
│   └── ...
│
├── frontend/
│   ├── AGENTS.md
│   └── ...
│
└── docs/
    ├── AGENTS.md
    └── ...
```

El de raíz puede contener:

```markdown
# Reglas globales

- UTF-8.
- No modificar archivos generados.
- Ejecutar tests relevantes.
- Mantener documentación actualizada.
```

Y:

```text
backend/AGENTS.md
```

puede añadir:

```markdown
# Backend

- Usar Python 3.12.
- Ejecutar pytest.
- No realizar llamadas HTTP desde la capa de dominio.
```

Mientras que:

```text
docs/AGENTS.md
```

podría contener:

```markdown
# Documentación

- Mantener enlaces relativos.
- No modificar archivos generados en `site/`.
- Actualizar el índice cuando se agreguen documentos.
```

Codex y GitHub Copilot soportan modelos de instrucciones con alcance y especificidad por directorio, aunque los detalles exactos dependen de la herramienta y entorno utilizado. ([GitHub][1])

**Pero no hay que crear un `AGENTS.md` en cada maldita carpeta.**

Solo cuando realmente existan reglas locales diferentes.

---

# 7. Separar hechos, reglas y procedimientos

Yo clasificaría toda la documentación en tres categorías.

## A. Hechos

Cosas que describen el sistema:

```text
ARCHITECTURE.md
DOMAIN.md
TECH_STACK.md
```

Ejemplo:

```markdown
La API utiliza FastAPI.
La base de datos es PostgreSQL.
El frontend se comunica mediante REST.
```

---

## B. Reglas

Cosas que no deben violarse:

```text
AGENTS.md
SECURITY.md
STYLE_GUIDE.md
```

Ejemplo:

```markdown
No almacenar secretos.
No introducir dependencias sin revisión.
No modificar contratos públicos sin actualizar tests.
```

---

## C. Procedimientos

Cosas que indican qué hacer:

```text
DEVELOPMENT.md
TESTING.md
TROUBLESHOOTING.md
```

Ejemplo:

```markdown
Para ejecutar las pruebas:

pytest tests/
```

Esta separación es excelente para IA porque reduce ambigüedad.

Una frase como:

> "La aplicación usa una arquitectura modular."

¿Es una descripción? ¿Una recomendación? ¿Una prohibición de hacer un monolito?

Nadie sabe. Las máquinas tampoco leen la mente, por mucho que marketing haya decidido fingir lo contrario.

---

# 8. Usar documentación verificable

Una buena práctica para proyectos agénticos es que las instrucciones puedan verificarse.

En vez de:

```markdown
Asegúrate de probar correctamente el proyecto.
```

usar:

```markdown
Antes de finalizar:

1. Ejecutar:

   pytest

2. Ejecutar:

   ruff check .

3. Ejecutar:

   python scripts/validate_docs.py
```

La IA puede ejecutar esto.

También puede fallar.

Y entonces tienes evidencia.

Es una mejora considerable sobre confiar en que un modelo lingüístico haya desarrollado un profundo compromiso moral con la calidad del software.

---

# 9. Convertir decisiones importantes en ADRs

Para un desarrollador individual, esto puede parecer excesivo.

No lo es si el proyecto va a durar.

Usaría:

```text
docs/
└── adr/
    ├── 0001-python-3.12.md
    ├── 0002-fastapi.md
    └── 0003-postgresql.md
```

Cada uno:

```text
# Contexto

¿Qué problema existía?

# Decisión

¿Qué se decidió?

# Alternativas

¿Qué otras opciones existían?

# Consecuencias

¿Qué ventajas y desventajas tiene?
```

La razón para hacerlo con IA es muy simple:

Dentro de seis meses tú puedes olvidar por qué elegiste algo.

La IA nunca lo supo.

Sin ADR:

```text
IA:
"Voy a reemplazar PostgreSQL por SQLite
porque es más simple."
```

Con ADR:

```text
IA:
"Existe una decisión documentada que explica
por qué PostgreSQL es necesario."
```

El contexto histórico evita una cantidad absurda de regresiones arquitectónicas.

---

# 10. No documentar cosas que el código puede declarar

Esta es otra regla importante.

Evita:

```markdown
TECH_STACK.md

Python: 3.12
FastAPI: 0.115
NumPy: 2.0
```

si esas versiones ya existen en:

```text
pyproject.toml
requirements.txt
package.json
```

Porque eventualmente tendrás:

```text
pyproject.toml → Python 3.13
TECH_STACK.md → Python 3.12
README → Python 3.11
AGENTS.md → "instala la última versión"
```

El caos documental, versión artesanal.

Mejor:

```markdown
## Fuente de versiones

Las versiones soportadas se definen en:

- `pyproject.toml`
- `package.json`
```

La documentación debería explicar **por qué**, **cómo** y **cuándo**.

La configuración debería definir **valores exactos**.

---

# 11. Tratar las instrucciones como código

Para un repositorio agéntico, `AGENTS.md` no debería ser un documento intocable.

Debería evolucionar mediante algo parecido a este ciclo:

```text
La IA comete un error
        ↓
¿Fue por falta de contexto?
        ↓
Sí
        ↓
Agregar una instrucción mínima
        ↓
Repetir tarea similar
        ↓
¿El error desapareció?
        ↓
Mantener
```

Es decir:

> **La documentación de agentes debe evolucionar a partir de fallos reales.**

No intentar anticipar todos los errores posibles.

Porque terminarás con:

```markdown
Regla 437:
El agente no deberá cambiar el nombre de una variable
si el nombre empieza por la letra Q
durante luna llena.
```

Y el modelo tendrá que procesar eso cada vez que quiera añadir una línea.

Las recomendaciones actuales sobre `AGENTS.md` también enfatizan mantenerlo conciso y mover información detallada a documentos especializados, precisamente para evitar desperdiciar contexto y crear instrucciones confusas. ([Codex Best Practices][3])

---

# 12. Distinguir entre "debe saber" y "puede consultar"

Esta distinción es fundamental.

## Siempre en contexto

Información necesaria casi siempre:

```text
AGENTS.md

- reglas
- comandos principales
- restricciones
- mapa mínimo
```

## Consultable bajo demanda

Información especializada:

```text
docs/

- arquitectura completa
- ADRs
- troubleshooting
- especificaciones
- dominio
```

La estructura sería:

```text
AGENTS.md
│
├── MUST READ
│   ├── ARCHITECTURE.md
│   └── TESTING.md
│
└── READ WHEN RELEVANT
    ├── docs/adr/
    ├── DOMAIN.md
    └── TROUBLESHOOTING.md
```

Así el agente no necesita ingerir toda la biblioteca para cambiar una función.

---

# 13. Usar GitHub como parte del sistema de memoria

Aunque seas la única persona, seguiría usando:

```text
Issues
Pull Requests
Commits
Tags
Releases
```

pero no necesariamente como una ceremonia empresarial.

## Issues

Para:

```text
- Bugs
- Deuda técnica
- Ideas
- Investigaciones pendientes
```

## Commits

Deben explicar:

> qué cambió

No:

```text
fix
update
changes
final_final_ahora_si
```

Humanidad, por favor.

Mejor:

```text
fix(api): validate duplicate sensor identifiers
```

## Pull Requests

Aunque seas tú mismo, pueden ser útiles cuando una IA hace cambios grandes.

Sirven como una **unidad de revisión y contexto**.

GitHub mantiene convenciones específicas para archivos de salud de comunidad, plantillas de issues y pull requests, políticas de seguridad y otros metadatos de colaboración, aunque en un proyecto individual no necesitas adoptar todos solo porque existen. ([GitHub Docs][4])

---

# 14. Estructura que yo recomendaría específicamente para ti

Dado que estás trabajando bastante con **Python, tecnologías web, scripts, documentación técnica y agentes dentro de VS Code/PowerShell**, no usaría una estructura gigantesca desde el principio.

Usaría algo así:

```text
project/
│
├── README.md
├── AGENTS.md
├── ARCHITECTURE.md
├── DEVELOPMENT.md
├── TESTING.md
├── CHANGELOG.md
├── SECURITY.md
│
├── LICENSE
├── .gitignore
├── .gitattributes
├── .editorconfig
│
├── docs/
│   ├── INDEX.md
│   │
│   ├── architecture/
│   │   └── adr/
│   │
│   ├── domain/
│   │   └── DOMAIN.md
│   │
│   ├── development/
│   │   ├── DEBUGGING.md
│   │   └── TROUBLESHOOTING.md
│   │
│   └── specifications/
│
├── .github/
│   ├── copilot-instructions.md
│   ├── workflows/
│   └── instructions/
│
├── src/
│
├── tests/
│
├── scripts/
│
└── config/
```

Y si diferentes áreas empiezan a tener reglas realmente distintas:

```text
src/
├── backend/
│   └── AGENTS.md
│
└── frontend/
    └── AGENTS.md
```

---

# 15. Mi conjunto de buenas prácticas definitivo

Para un desarrollador individual con IA agéntica:

### 1. Una fuente de verdad

```text
AGENTS.md
```

para reglas generales del repositorio.

### 2. Documentación modular

No poner todo en el mismo archivo.

### 3. Instrucciones accionables

Preferir:

```text
Ejecuta X.
No modifiques Y.
Actualiza Z si cambia A.
```

sobre:

```text
Mantén una alta calidad.
```

La IA tampoco sabe qué significa eso sin una definición concreta. Y, francamente, los humanos tampoco.

### 4. Validación automatizada

Todo lo posible debe terminar en:

```text
test
lint
type-check
build
validation script
```

### 5. ADRs para decisiones costosas

Especialmente tecnologías, arquitectura e interfaces.

### 6. Contexto jerárquico

Reglas globales arriba, reglas especializadas cerca del código correspondiente.

### 7. No duplicar información

Si una versión vive en `pyproject.toml`, no copiarla manualmente a cinco Markdown.

### 8. Documentación basada en errores observados

Actualizar instrucciones cuando un patrón de fallo real lo justifique.

### 9. Definir límites explícitos

Especialmente:

```text
No tocar producción.
No modificar secretos.
No borrar migraciones.
No reescribir APIs públicas sin autorización.
No añadir dependencias automáticamente.
```

### 10. Separar "política" de "conocimiento"

```text
AGENTS.md
    Qué hacer.

ARCHITECTURE.md
    Cómo está construido.

DOMAIN.md
    Qué significa el sistema.

TESTING.md
    Cómo comprobarlo.

ADRs
    Por qué se tomaron decisiones.
```

## Mi conclusión

Para un repositorio **1 humano + IA agéntica**, no intentaría adoptar un supuesto "estándar definitivo", porque todavía no existe uno que domine todo el ecosistema.

Lo más cercano a una arquitectura moderna y portable sería:

```text
                ┌──────────────┐
                │   README.md  │
                └──────┬───────┘
                       │
                ┌──────▼───────┐
                │   AGENTS.md  │
                │ Política IA  │
                └──────┬───────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
 ARCHITECTURE.md  DEVELOPMENT.md  TESTING.md
        │
        ▼
     docs/
        │
   ┌────┼────┐
   ▼    ▼    ▼
 ADRs DOMAIN DEBUGGING
```

Y luego **solo añadir archivos cuando aparezca una necesidad real**.

Ese último punto es el más importante. La IA necesita contexto, sí. Pero **más documentación no significa automáticamente mejor contexto**. Contexto redundante, contradictorio o irrelevante es simplemente ruido con extensión `.md`.

La combinación de `AGENTS.md` como contrato operativo, documentación especializada para conocimiento persistente y validación automatizada para comprobar el resultado es, ahora mismo, el enfoque que considero más sólido para ese tipo de repositorio. ([GitHub][1])

[1]: https://github.com/quadmangle/OpenAI_Codex/blob/main/docs/agents_md.md?utm_source=chatgpt.com "OpenAI_Codex/docs/agents_md.md at main · quadmangle/OpenAI_Codex · GitHub"
[2]: https://docs.github.com/en/copilot/reference/customization-cheat-sheet?utm_source=chatgpt.com "Copilot customization cheat sheet - GitHub Docs"
[3]: https://codex-best-practices-d67bea.pages.oit.duke.edu/best-practices/agents.html?utm_source=chatgpt.com "Part 3: AGENTS.md — Codex Starter Best Practices"
[4]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file?utm_source=chatgpt.com "Creating a default community health file - GitHub Docs"





que buenas practicas de programacion existen (o han surgido recientemente con la IA agentica) y como las clasificarias segun su uso ? elabora una tabla donde coloques la practica, su definicion, su nivel de uso (universal, de un lenguaje especifico o de un tipo de proyecto), y describe su uso comun

Sí. Aquí conviene separar **buenas prácticas clásicas de ingeniería** de las que han ganado importancia o han surgido específicamente con la **IA agéntica**. No todo lo nuevo merece llamarse "metodología revolucionaria"; a veces es simplemente una práctica vieja que ahora necesitamos aplicar porque el compañero de trabajo estadístico puede editar 80 archivos antes del café.

Una clasificación útil es por **alcance de aplicación**:

* **Universal**: aplicable a casi cualquier lenguaje y proyecto.
* **Específica de lenguaje/ecosistema**: depende de herramientas o características concretas.
* **Específica de tipo de proyecto**: útil sobre todo en web, embedded, librerías, IA, sistemas distribuidos, etc.
* **Emergente para IA agéntica**: prácticas orientadas a dirigir, limitar, verificar y hacer reproducible el trabajo de agentes.

A continuación incluyo prácticas consolidadas y las tendencias recientes más relevantes, distinguiendo lo que ya es ingeniería clásica de lo que realmente cambia con los agentes.


# Tabla de buenas prácticas de programación, incluyendo IA agéntica

Primero, una precisión importante: **la IA agéntica no ha sustituido las buenas prácticas clásicas**. Lo que ha hecho es volver algunas de ellas mucho más importantes y crear otras relacionadas con **contexto, autonomía, validación y control del alcance**.

La siguiente clasificación usa:

* **Universal**: válida para casi cualquier lenguaje y proyecto.
* **Lenguaje/ecosistema**: depende de tecnologías concretas.
* **Tipo de proyecto**: especialmente útil para cierto tipo de software.
* **IA agéntica**: surgida o reforzada específicamente por agentes de programación.

| Práctica                          | Definición                                                    | Nivel de uso                               | Uso común                               |
| --------------------------------- | ------------------------------------------------------------- | ------------------------------------------ | --------------------------------------- |
| **DRY**                           | Evitar duplicar conocimiento o lógica                         | Universal                                  | Centralizar lógica repetida             |
| **KISS**                          | Preferir soluciones simples                                   | Universal                                  | Evitar abstracciones innecesarias       |
| **YAGNI**                         | No implementar algo hasta necesitarlo                         | Universal                                  | Evitar funcionalidades especulativas    |
| **SOLID**                         | Principios para diseñar componentes mantenibles               | Universal, especialmente OO                | Diseño de clases y módulos              |
| **Separation of Concerns**        | Separar responsabilidades diferentes                          | Universal                                  | UI, lógica, datos e infraestructura     |
| **Single Source of Truth**        | Una información importante debe tener una fuente autoritativa | Universal                                  | Configuración, estado, documentación    |
| **Encapsulación**                 | Ocultar detalles internos detrás de interfaces                | Universal                                  | APIs, módulos, clases                   |
| **Modularidad**                   | Dividir el sistema en unidades con responsabilidades claras   | Universal                                  | Paquetes, módulos, componentes          |
| **Cohesión alta**                 | Elementos relacionados deben permanecer juntos                | Universal                                  | Diseño de módulos                       |
| **Acoplamiento bajo**             | Reducir dependencias innecesarias                             | Universal                                  | Arquitectura y diseño                   |
| **Fail Fast**                     | Detectar errores lo antes posible                             | Universal                                  | Validación temprana                     |
| **Defensive Programming**         | Considerar entradas y estados inválidos                       | Universal                                  | Validación y manejo de errores          |
| **Explicit over Implicit**        | Preferir comportamientos claros a magia oculta                | Universal                                  | APIs y configuración                    |
| **Convention over Configuration** | Usar convenciones para reducir configuración                  | Ecosistema                                 | Frameworks como Django o Rails          |
| **Code Review**                   | Revisar cambios antes de integrarlos                          | Universal                                  | PRs y revisión humana o automática      |
| **Refactoring continuo**          | Mejorar estructura sin cambiar comportamiento                 | Universal                                  | Reducir deuda técnica                   |
| **Technical Debt Management**     | Identificar y controlar compromisos técnicos                  | Universal                                  | Issues, backlog y ADRs                  |
| **Clean Code**                    | Priorizar legibilidad y mantenibilidad                        | Universal                                  | Nombres, funciones pequeñas, estructura |
| **Boy Scout Rule**                | Dejar el código ligeramente mejor de como estaba              | Universal                                  | Pequeñas mejoras locales                |
| **Design by Contract**            | Definir explícitamente precondiciones y garantías             | Universal                                  | APIs e interfaces                       |
| **Immutability by Default**       | Evitar mutaciones innecesarias                                | Lenguaje/ecosistema                        | Estado y concurrencia                   |
| **Dependency Injection**          | Proporcionar dependencias externamente                        | Universal, común en OO                     | Testing y desacoplamiento               |
| **Inversion of Control**          | Delegar el control del flujo a una arquitectura               | Arquitectura                               | Frameworks y sistemas extensibles       |
| **Repository Pattern**            | Separar acceso a datos de lógica de negocio                   | Tipo de proyecto                           | Backends y aplicaciones empresariales   |
| **MVC/MVP/MVVM**                  | Separar presentación y lógica                                 | Tipo de proyecto                           | Web, desktop y mobile                   |
| **Hexagonal Architecture**        | Separar dominio de infraestructura externa                    | Tipo de proyecto                           | Sistemas complejos                      |
| **Clean Architecture**            | Organizar dependencias hacia el dominio                       | Tipo de proyecto                           | Aplicaciones grandes                    |
| **Event-Driven Architecture**     | Comunicación mediante eventos                                 | Tipo de proyecto                           | Sistemas distribuidos y tiempo real     |
| **API First**                     | Diseñar contratos antes de implementar consumidores           | Tipo de proyecto                           | APIs y microservicios                   |
| **Contract Testing**              | Verificar que servicios respeten contratos                    | Tipo de proyecto                           | APIs y microservicios                   |
| **Test Pyramid**                  | Priorizar unit tests sobre pruebas lentas                     | Universal                                  | Estrategia de testing                   |
| **TDD**                           | Escribir pruebas antes o junto con implementación             | Universal                                  | Desarrollo guiado por tests             |
| **BDD**                           | Expresar comportamiento mediante escenarios                   | Tipo de proyecto                           | Sistemas orientados a negocio           |
| **Regression Testing**            | Evitar que cambios rompan funciones existentes                | Universal                                  | Suites automáticas                      |
| **CI**                            | Ejecutar validaciones automáticamente                         | Universal                                  | Tests, lint y builds                    |
| **CD**                            | Automatizar entrega o despliegue                              | Tipo de proyecto                           | Servicios y aplicaciones                |
| **Linting**                       | Detectar problemas estáticos de estilo o calidad              | Lenguaje/ecosistema                        | Ruff, ESLint, Clippy                    |
| **Static Analysis**               | Analizar código sin ejecutarlo                                | Universal                                  | Bugs potenciales y seguridad            |
| **Type Checking**                 | Verificar compatibilidad de tipos                             | Lenguaje/ecosistema                        | mypy, TypeScript, Rust                  |
| **Formatting automático**         | Aplicar formato consistente                                   | Lenguaje/ecosistema                        | Black, Prettier, rustfmt                |
| **Observability**                 | Diseñar para poder observar el sistema                        | Tipo de proyecto                           | Logs, métricas y trazas                 |
| **Structured Logging**            | Registrar eventos con datos estructurados                     | Universal                                  | JSON logs y diagnóstico                 |
| **Reproducibility**               | Poder reproducir builds y entornos                            | Universal                                  | Lockfiles, contenedores                 |
| **Infrastructure as Code**        | Definir infraestructura mediante código                       | Tipo de proyecto                           | Cloud y DevOps                          |
| **Security by Design**            | Considerar seguridad desde el diseño                          | Universal                                  | Autenticación y secretos                |
| **Least Privilege**               | Dar solo permisos necesarios                                  | Universal                                  | Usuarios, servicios y agentes           |
| **Threat Modeling**               | Identificar amenazas antes de implementar                     | Tipo de proyecto                           | Sistemas expuestos                      |
| **Dependency Management**         | Controlar dependencias y versiones                            | Universal                                  | Lockfiles y actualizaciones             |
| **Semantic Versioning**           | Versionar según impacto de cambios                            | Universal                                  | Librerías y APIs                        |
| **Conventional Commits**          | Estandarizar mensajes de commit                               | Universal                                  | Historial y automatización              |
| **Trunk-Based Development**       | Integrar cambios pequeños frecuentemente                      | Tipo de proyecto                           | Equipos y CI                            |
| **Feature Flags**                 | Activar funciones sin desplegar ramas separadas               | Tipo de proyecto                           | Producción y experimentación            |
| **Documentation as Code**         | Mantener documentación junto al código                        | Universal                                  | Markdown versionado                     |
| **ADRs**                          | Registrar decisiones arquitectónicas                          | Universal, más útil en proyectos complejos | Conservar el "por qué"                  |
| **Living Documentation**          | Mantener documentación conectada con el sistema real          | Universal                                  | Docs generadas y verificadas            |
| **Executable Documentation**      | Documentación que puede validarse o ejecutarse                | Tipo de proyecto                           | Ejemplos y tests                        |
| **Progressive Disclosure**        | Mostrar solo el contexto necesario inicialmente               | Universal, muy relevante para IA           | Documentación jerárquica                |

---

# Prácticas especialmente relevantes con IA agéntica

Aquí está la parte nueva e interesante.

## 1. Context Engineering

| Práctica                               | Definición                                         | Nivel       | Uso común                        |
| -------------------------------------- | -------------------------------------------------- | ----------- | -------------------------------- |
| **Context Engineering**                | Diseñar qué información recibe el agente y cuándo  | IA agéntica | Documentación, reglas y contexto |
| **Contextual Hierarchy**               | Organizar instrucciones por alcance                | IA agéntica | `AGENTS.md` global y local       |
| **Progressive Context Loading**        | Cargar información según la tarea                  | IA agéntica | Documentación bajo demanda       |
| **Persistent Agent Context**           | Mantener conocimiento estable del proyecto         | IA agéntica | `AGENTS.md`, ADRs                |
| **Single Source of Truth for Context** | Evitar instrucciones contradictorias               | IA agéntica | Política central del repo        |
| **Context Budgeting**                  | Tratar el contexto como recurso limitado           | IA agéntica | Evitar archivos gigantes         |
| **Repository as System of Record**     | El conocimiento durable vive versionado en el repo | IA agéntica | Docs, ADRs, specs                |
| **Agent Discoverability**              | Facilitar que el agente encuentre información      | IA agéntica | Índices y estructura predecible  |

OpenAI describe una lección particularmente clara para agentes: **darles un mapa del repositorio en lugar de un manual gigantesco**. Un `AGENTS.md` monolítico consume contexto, puede ocultar restricciones importantes y se degrada rápidamente cuando acumula reglas obsoletas. ([OpenAI][1])

---

## 2. Scope Control

Una de las prácticas que más importancia ha ganado.

| Práctica                       | Definición                                     | Nivel          | Uso común                 |
| ------------------------------ | ---------------------------------------------- | -------------- | ------------------------- |
| **Scoped Tasks**               | Dividir trabajo en unidades delimitadas        | IA agéntica    | Una tarea, objetivo claro |
| **Small Diffs**                | Preferir cambios pequeños                      | Universal + IA | Facilitar revisión        |
| **Explicit Boundaries**        | Declarar qué puede y no puede modificarse      | IA agéntica    | `AGENTS.md`               |
| **Minimal Surface Area**       | Cambiar el menor número de componentes posible | Universal + IA | Reducir regresiones       |
| **Incremental Implementation** | Implementar en pasos verificables              | Universal + IA | Features complejas        |
| **Plan Before Execute**        | Analizar y planear antes de editar             | IA agéntica    | Modo Ask/Plan             |
| **No Unrelated Changes**       | No arreglar cosas fuera del objetivo           | Universal + IA | Evitar scope creep        |

OpenAI recomienda comenzar cambios importantes en modo de análisis o planificación y mantener las tareas bien delimitadas. También señala que estructurar una solicitud como una issue o PR, incluyendo rutas, componentes y ejemplos relevantes, mejora el trabajo del agente. ([OpenAI][2])

Un ejemplo de mala tarea:

```text
Mejora el backend.
```

Eso es prácticamente pedirle a una entidad con acceso a tu repositorio que improvise.

Una tarea mejor:

```text
Objetivo:
Corregir la pérdida de eventos WebSocket.

Alcance:
- src/websocket/
- tests/websocket/

No modificar:
- Base de datos
- API REST
- Configuración de producción

Criterio de aceptación:
Los eventos deben llegar al cliente y los tests existentes
deben continuar pasando.
```

---

# 3. Agent-Oriented Development

Estas prácticas son casi específicas del nuevo paradigma.

| Práctica                      | Definición                                   | Nivel       | Uso común                   |
| ----------------------------- | -------------------------------------------- | ----------- | --------------------------- |
| **Agent Instructions**        | Reglas explícitas para agentes               | IA agéntica | `AGENTS.md`                 |
| **Hierarchical Instructions** | Reglas globales y locales                    | IA agéntica | Directorios complejos       |
| **Tool-Aware Instructions**   | Documentar herramientas disponibles          | IA agéntica | Scripts y CLI               |
| **Agent Guardrails**          | Límites explícitos de autonomía              | IA agéntica | Secretos, producción        |
| **Human Approval Gates**      | Requerir aprobación para acciones críticas   | IA agéntica | Migraciones y deploys       |
| **Agent Feedback Loop**       | Mejorar instrucciones a partir de errores    | IA agéntica | Evolución del repo          |
| **Task Artifacts**            | Guardar planes o resultados de tareas largas | IA agéntica | Investigación y migraciones |
| **Agent Evaluation**          | Evaluar sistemáticamente calidad del agente  | IA agéntica | Benchmarks internos         |

`AGENTS.md` ya funciona como mecanismo de instrucciones jerárquicas en Codex: las instrucciones pueden aplicar a un árbol de directorios y las más específicas prevalecen dentro de su alcance. GitHub Copilot también soporta `AGENTS.md`, además de `CLAUDE.md`, `GEMINI.md` y archivos de instrucciones por ruta según el flujo utilizado. ([OpenAI][3])

---

# 4. Validation-First Development

Con IA esto pasa de ser "buena idea" a casi requisito de supervivencia.

| Práctica                      | Definición                                    | Nivel          | Uso común              |
| ----------------------------- | --------------------------------------------- | -------------- | ---------------------- |
| **Automated Validation**      | Validar automáticamente cambios               | Universal      | CI                     |
| **Acceptance Criteria**       | Definir cuándo una tarea está terminada       | Universal + IA | Issues y prompts       |
| **Definition of Done**        | Lista objetiva de condiciones de finalización | Universal + IA | PRs                    |
| **Evidence-Based Completion** | No afirmar éxito sin evidencia                | IA agéntica    | Logs y tests           |
| **Test Before Claim**         | Ejecutar pruebas antes de declarar éxito      | Universal + IA | Trabajo de agentes     |
| **Layered Validation**        | Validar en varias capas                       | Universal      | Unit, integration, e2e |
| **Deterministic Checks**      | Preferir validaciones reproducibles           | Universal + IA | Scripts                |
| **Self-Verification**         | El agente revisa su propio resultado          | IA agéntica    | Review automático      |

La regla moderna sería:

```text
La IA implementa
        ↓
Ejecuta validación específica
        ↓
Ejecuta pruebas
        ↓
Revisa el diff
        ↓
Comprueba criterios de aceptación
        ↓
Reporta evidencia
```

No:

```text
IA:
"Todo está solucionado."

Humano:
"¿Ejecutaste algo?"

IA:
"...el código tiene una vibra muy positiva."
```

Codex, por ejemplo, aplica explícitamente las comprobaciones programáticas definidas en las instrucciones del proyecto y espera que se ejecuten después de realizar cambios. ([OpenAI][3])

---

# 5. Repository-as-Context

Esta es una de las ideas más importantes que está emergiendo.

El repositorio deja de ser solamente:

```text
Código
+
Git
```

y pasa a ser:

```text
┌──────────────────────┐
│       Código         │
├──────────────────────┤
│   Arquitectura       │
├──────────────────────┤
│    Decisiones        │
├──────────────────────┤
│  Especificaciones    │
├──────────────────────┤
│    Instrucciones     │
├──────────────────────┤
│     Tests            │
├──────────────────────┤
│ Automatización       │
└──────────────────────┘
          ↓
    Contexto operativo
```

| Práctica                           | Definición                                          | Nivel                 | Uso común               |
| ---------------------------------- | --------------------------------------------------- | --------------------- | ----------------------- |
| **Repository as Context**          | El repo contiene conocimiento necesario para operar | IA agéntica           | Desarrollo autónomo     |
| **Repository as System of Record** | La información durable se versiona                  | IA agéntica           | ADRs y especificaciones |
| **Documentation Discoverability**  | La información debe poder localizarse fácilmente    | IA agéntica           | `docs/INDEX.md`         |
| **Knowledge Versioning**           | Versionar conocimiento junto al código              | Universal + IA        | Markdown y Git          |
| **Contextual Traceability**        | Relacionar requisito, código y prueba               | Tipo de proyecto + IA | Sistemas críticos       |

OpenAI describe precisamente el conocimiento del repositorio como el sistema de registro para agentes y advierte contra concentrarlo todo en un único archivo de instrucciones. ([OpenAI][1])

---

# 6. Reversibility

Esta práctica clásica está ganando nueva importancia porque un agente puede producir muchos cambios rápidamente.

| Práctica                      | Definición                                  | Nivel            | Uso común             |
| ----------------------------- | ------------------------------------------- | ---------------- | --------------------- |
| **Atomic Commits**            | Un commit representa una unidad lógica      | Universal        | Git                   |
| **Small PRs**                 | Cambios revisables y acotados               | Universal        | Code review           |
| **Rollback-Friendly Changes** | Diseñar cambios fáciles de revertir         | Universal        | Producción            |
| **Feature Flags**             | Separar despliegue y activación             | Tipo de proyecto | Servicios             |
| **Incremental Migration**     | Migrar sistemas por etapas                  | Tipo de proyecto | Refactors grandes     |
| **Checkpointing**             | Crear puntos seguros antes de tareas largas | IA agéntica      | Agentes autónomos     |
| **Workspace Isolation**       | Aislar cambios experimentales               | IA agéntica      | Worktrees y sandboxes |

Para agentes, esta estructura es especialmente útil:

```text
Estado limpio
    ↓
Checkpoint / commit
    ↓
Agente trabaja
    ↓
Tests
    ↓
Review del diff
    ↓
Commit
```

Porque permitir que un agente modifique medio repositorio sin puntos de retorno es una experiencia educativa. Principalmente para aprender a valorar los backups.

---

# 7. Observabilidad para desarrollo y debugging

Especialmente importante en proyectos con múltiples tecnologías.

| Práctica                     | Definición                             | Nivel                 | Uso común          |
| ---------------------------- | -------------------------------------- | --------------------- | ------------------ |
| **Structured Logging**       | Logs con estructura consistente        | Universal             | Debugging          |
| **Correlation IDs**          | Identificar operaciones relacionadas   | Sistemas distribuidos | Trazabilidad       |
| **Tracing**                  | Seguir una operación entre componentes | Sistemas distribuidos | Diagnóstico        |
| **Metrics**                  | Medir comportamiento cuantitativo      | Producción            | Rendimiento        |
| **Debuggable by Design**     | Diseñar pensando en diagnóstico        | Universal             | Sistemas complejos |
| **Reproducible Bug Reports** | Pasos claros para reproducir errores   | Universal             | Issues             |
| **Minimal Reproduction**     | Reducir un error a su caso mínimo      | Universal             | Debugging          |

Para IA agéntica esto es fundamental.

Un agente es mucho más eficaz cuando puede responder:

```text
Evento A
    ↓
Backend recibió X
    ↓
Procesó Y
    ↓
Envió Z
    ↓
Frontend recibió Z
    ↓
Renderizado falló aquí
```

que cuando solo ve:

```text
"No funciona."
```

---

# 8. Prácticas para evitar errores típicos de agentes

Estas son particularmente útiles en tu escenario.

| Práctica                      | Problema que evita             | Uso                                                |
| ----------------------------- | ------------------------------ | -------------------------------------------------- |
| **Explicit Invariants**       | Romper reglas invisibles       | Documentar condiciones que siempre deben cumplirse |
| **Protected Files**           | Cambios accidentales           | Declarar archivos sensibles                        |
| **Generated File Boundaries** | Editar archivos generados      | Marcar fuentes y outputs                           |
| **Dependency Approval**       | Instalar paquetes innecesarios | Requerir justificación                             |
| **No Silent Fallbacks**       | Ocultar errores                | Fallar explícitamente                              |
| **Diff Review**               | Cambios inesperados            | Revisar antes de aceptar                           |
| **Change Budget**             | Refactors gigantescos          | Limitar alcance                                    |
| **Task-Specific Validation**  | Tests irrelevantes             | Definir pruebas por área                           |
| **Known Pitfalls Registry**   | Repetir errores históricos     | Documentar trampas conocidas                       |
| **Architecture Constraints**  | Violaciones estructurales      | Reglas automáticas o documentadas                  |

Ejemplo:

```markdown
## Invariantes

- Un usuario nunca puede pertenecer a dos sesiones activas.
- Las mediciones deben conservar su timestamp original.
- La capa `domain` no puede importar módulos de `ui`.

## Archivos protegidos

No modificar sin aprobación:

- migrations/
- production.yaml
- generated/
```

Esto es mucho más útil que decirle:

> "Escribe código de calidad."

La IA probablemente ya recibió esa instrucción en algún momento de su existencia. Y la humanidad sigue produciendo software bancario con botones que dicen `Submit2`.

---

# 9. Clasificación resumida por familias

Yo organizaría todas las prácticas así:

| Familia            | Objetivo                                   |
| ------------------ | ------------------------------------------ |
| **Diseño**         | Organizar correctamente el código          |
| **Simplicidad**    | Evitar complejidad innecesaria             |
| **Calidad**        | Mantener código legible y mantenible       |
| **Testing**        | Verificar comportamiento                   |
| **Automatización** | Reducir trabajo manual                     |
| **Seguridad**      | Evitar daños y vulnerabilidades            |
| **Arquitectura**   | Controlar dependencias y estructura        |
| **Versionado**     | Mantener historial y reversibilidad        |
| **Documentación**  | Conservar conocimiento                     |
| **Observabilidad** | Diagnosticar sistemas                      |
| **Operaciones**    | Desplegar y mantener software              |
| **IA agéntica**    | Controlar contexto, autonomía y validación |

---

# Las 15 que considero más importantes para un repositorio humano + IA

Si tuviera que seleccionar solo quince para empezar, serían estas:

| #  | Práctica                        | Por qué                               |
| -- | ------------------------------- | ------------------------------------- |
| 1  | **Small Scoped Tasks**          | Evita cambios fuera del objetivo      |
| 2  | **Plan Before Execute**         | Reduce decisiones precipitadas        |
| 3  | **Single Source of Truth**      | Evita contradicciones                 |
| 4  | **Separation of Concerns**      | Facilita comprender el sistema        |
| 5  | **Modularidad**                 | Reduce el área de impacto             |
| 6  | **Automated Testing**           | Permite verificar cambios             |
| 7  | **Layered Validation**          | Detecta errores en diferentes niveles |
| 8  | **Static Analysis**             | Detecta problemas rápidamente         |
| 9  | **AGENTS.md jerárquico**        | Proporciona contexto operativo        |
| 10 | **Progressive Context Loading** | Evita saturar el contexto             |
| 11 | **Explicit Invariants**         | Evita romper reglas invisibles        |
| 12 | **Atomic Commits**              | Facilita revertir y entender cambios  |
| 13 | **ADRs**                        | Conservan el porqué de decisiones     |
| 14 | **Structured Logging**          | Hace depurables sistemas complejos    |
| 15 | **Evidence-Based Completion**   | El agente debe demostrar que funcionó |

## Mi clasificación conceptual para tu caso

Dado el tipo de repositorios que estás planteando, yo construiría el flujo alrededor de esto:

```text
                    TAREA
                      │
                      ▼
              ┌───────────────┐
              │ PLANIFICACIÓN │
              └───────┬───────┘
                      │
                      ▼
                CONTEXTO
         ┌────────────┼────────────┐
         ▼            ▼            ▼
      AGENTS      ARCHITECTURE    ADRs
         │
         ▼
               IMPLEMENTACIÓN
                      │
         ┌────────────┼────────────┐
         ▼            ▼            ▼
      Límites     Modularidad    Invariantes
                      │
                      ▼
                 VALIDACIÓN
         ┌────────────┼────────────┐
         ▼            ▼            ▼
       Tests        Lint        Type Check
                      │
                      ▼
                REVIEW DEL DIFF
                      │
                      ▼
                  EVIDENCIA
                      │
                      ▼
                    COMMIT
```

Mi conclusión sería que la gran práctica emergente no es simplemente **"usar IA para programar"**. Eso es demasiado superficial.

El cambio real es pasar de una ingeniería centrada exclusivamente en:

> **escribir código correcto**

a una que también debe responder:

> **¿Puede otro agente entender qué debe hacer, encontrar dónde hacerlo, saber qué no debe tocar y demostrar objetivamente que no rompió nada?**

Ese es, en mi opinión, el verdadero cambio metodológico. La IA agéntica está convirtiendo el **contexto, las restricciones y la validación** en componentes de primera clase del proceso de ingeniería, junto con el código. OpenAI recomienda explícitamente proporcionar contexto persistente mediante `AGENTS.md`, mejorar iterativamente el entorno de trabajo y formular tareas con estructura y alcance claros; GitHub, por su parte, ya soporta varias capas de instrucciones para agentes y rutas específicas. ([OpenAI][4])

Y esa clasificación tiene una consecuencia bastante útil para diseñar tus repositorios: **no necesitas adoptar 60 prácticas**. Necesitas seleccionar las que reduzcan errores reales en tu flujo humano + agente, automatizar las verificables y documentar únicamente el conocimiento que el código no puede expresar por sí solo. El resto es, en muchos casos, decoración ceremonial con Markdown.

[1]: https://openai.com/es-419/index/harness-engineering/?utm_source=chatgpt.com "Ingeniería de sistemas: Codex en un mundo centrado en agentes | OpenAI"
[2]: https://openai.com/es-419/business/guides-and-resources/how-openai-uses-codex/?utm_source=chatgpt.com "Cómo OpenAI usa Codex | OpenAI"
[3]: https://openai.com/es-419/index/introducing-codex/?utm_source=chatgpt.com "Presentamos Codex | OpenAI"
[4]: https://openai.com/business/guides-and-resources/how-openai-uses-codex/?utm_source=chatgpt.com "How OpenAI uses Codex | OpenAI"




ademas de buenas practicas y archivos dedicados, que otros aspectos pueden mejorar la capacidad de la IA de escribir codigo y documentacion? 

Sí. De hecho, **los archivos de documentación y las buenas prácticas son solo una parte del problema**. Para que una IA escriba mejor código y documentación hay que mejorar también el **entorno cognitivo y operativo** en el que trabaja.

Yo lo dividiría en **10 capas**:

| Capa                      | Qué mejora                              |
| ------------------------- | --------------------------------------- |
| 1. Contexto               | Qué entiende del proyecto               |
| 2. Estructura             | Qué tan fácil es navegar el repositorio |
| 3. Especificación         | Qué tan claro está el objetivo          |
| 4. Herramientas           | Qué puede inspeccionar y ejecutar       |
| 5. Observabilidad         | Qué tan fácil es encontrar errores      |
| 6. Validación             | Qué tan bien puede comprobar su trabajo |
| 7. Restricciones          | Qué tan difícil es romper cosas         |
| 8. Memoria y trazabilidad | Qué decisiones previas puede recuperar  |
| 9. Feedback               | Qué tan rápido aprende del resultado    |
| 10. Diseño de tareas      | Qué tan bien se le entrega el trabajo   |

La idea importante es esta:

```text
Calidad del agente
        ≠
Solo calidad del modelo

Calidad del resultado
        =
Modelo
× Contexto
× Herramientas
× Especificación
× Validación
× Feedback
```

Puedes darle el mejor modelo del planeta y luego decirle:

> "Arregla el proyecto."

Eso sigue siendo una forma bastante eficiente de producir creatividad no solicitada.

---

# 1. Mejorar la estructura del repositorio

Una IA trabaja mejor cuando el repositorio tiene una estructura **predecible**.

Por ejemplo:

```text
project/
│
├── src/
│   ├── core/
│   ├── services/
│   ├── infrastructure/
│   └── ui/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── docs/
│
├── scripts/
│
├── config/
│
└── generated/
```

La IA puede inferir mucho mejor:

```text
"Quiero modificar la lógica de negocio"
        ↓
src/core/

"Quiero revisar infraestructura"
        ↓
src/infrastructure/

"Quiero encontrar pruebas"
        ↓
tests/
```

que con esto:

```text
project/
├── stuff/
├── utils/
├── helpers/
├── common/
├── misc/
├── old/
└── final/
```

Las carpetas `utils`, `helpers`, `common` y `misc` son básicamente el equivalente informático de un cajón lleno de cables. Algo útil probablemente está ahí. Buena suerte encontrándolo.

## Práctica: Information Architecture

No solo importa **qué información existe**, sino:

* dónde está;
* cómo se llama;
* cómo se relaciona;
* qué tan fácil es descubrirla.

Esto mejora directamente la capacidad de navegación del agente.

---

# 2. Crear un mapa navegable del repositorio

Además del árbol de directorios, puedes crear algo parecido a un **mapa semántico**.

Ejemplo:

```markdown
# Repository Map

## Entry points

- `src/main.py`
  Punto de entrada principal.

- `src/api/app.py`
  Inicialización de la API.

## Core logic

- `src/domain/`
  Reglas de negocio.

## External systems

- `src/infrastructure/database/`
- `src/infrastructure/http/`

## Tests

- `tests/unit/`
- `tests/integration/`
```

Incluso puede existir un archivo:

```text
REPO_MAP.md
```

o generarse automáticamente.

Esto mejora algo que llamaría:

> **discoverability**

Es decir, la capacidad de encontrar rápidamente lo relevante.

---

# 3. Mejorar las especificaciones de las tareas

La calidad de la tarea entregada al agente importa muchísimo.

Una petición pobre:

```text
Arregla el sistema de autenticación.
```

Una tarea bien especificada:

```text
Objetivo:
Corregir el fallo que impide renovar tokens JWT.

Comportamiento actual:
El refresh token es rechazado después de 24 horas.

Comportamiento esperado:
Debe poder renovar el access token mientras el refresh token
siga siendo válido.

Archivos probablemente relevantes:
- src/auth/
- tests/auth/

No modificar:
- esquema de usuarios
- API pública existente

Criterios de aceptación:
- Los tests existentes deben pasar.
- Agregar un test para el caso de expiración.
- No introducir dependencias.
```

Esto es prácticamente convertir una conversación ambigua en una **especificación ejecutable por un agente**.

---

# 4. Usar contratos explícitos

Las IA entienden mucho mejor sistemas con contratos claros.

Ejemplos:

```text
API Contract
Database Schema
JSON Schema
Type Definitions
Protocol Definitions
Interface Definitions
```

Por ejemplo:

```typescript
interface UserRepository {
    findById(id: string): Promise<User | null>;
    save(user: User): Promise<void>;
}
```

Eso es más útil para un agente que encontrar una clase de 1,700 líneas llamada:

```text
UserManagerHelperServiceFactory
```

Los contratos reducen la necesidad de inferir comportamiento desde implementaciones.

## Práctica: Contract-Driven Development

La IA puede trabajar sobre:

```text
Entrada
↓
Contrato
↓
Implementación
↓
Tests
```

en lugar de:

```text
Código existente
↓
Suposiciones
↓
Más código
↓
Esperanza
```

---

# 5. Tipado fuerte y análisis estático

Esto mejora muchísimo la capacidad de una IA para corregirse.

Por ejemplo:

```python
def process_sensor(data):
```

frente a:

```python
def process_sensor(data: SensorMeasurement) -> ProcessedMeasurement:
```

En el segundo caso:

* la IA entiende mejor las expectativas;
* el IDE puede detectar errores;
* el type checker puede validar cambios;
* las interfaces sirven como documentación.

El tipado se convierte en una forma de:

> **documentación verificable automáticamente.**

Herramientas como:

```text
Python
├── pyright
├── mypy
└── ruff

TypeScript
├── tsc
└── eslint

Rust
└── compiler + clippy

C/C++
├── compiler warnings
├── clang-tidy
└── sanitizers
```

actúan casi como una segunda capa de razonamiento externo.

La IA propone.

El analizador responde:

> No. Intenta otra vez.

Un proceso sorprendentemente similar a la universidad.

---

# 6. Diseñar el código para que sea fácil de inspeccionar

Esto es distinto de simplemente escribir "código limpio".

Una IA trabaja mejor cuando el sistema tiene:

* funciones pequeñas;
* nombres semánticos;
* responsabilidades claras;
* interfaces explícitas;
* dependencias visibles;
* pocos efectos secundarios ocultos.

Ejemplo:

```python
def calculate_total(order):
    ...
```

mejor que:

```python
def process(data, mode=None, config=None):
```

porque el agente puede razonar sobre el primer caso con menos exploración.

Podemos llamar a esto:

> **Agent-readable code**

No significa escribir código extraño para IA.

Significa escribir código que reduzca la cantidad de inferencia necesaria.

---

# 7. Añadir puntos de entrada y puntos de salida explícitos

La IA necesita entender el flujo.

Ejemplo:

```text
User Request
      ↓
API Router
      ↓
Service
      ↓
Domain Logic
      ↓
Repository
      ↓
Database
```

Si este flujo existe solo "en la cabeza del desarrollador", el agente tiene que reconstruirlo cada vez.

Conviene documentar:

* entry points;
* main flows;
* data flows;
* async flows;
* external integrations.

Especialmente en sistemas con:

```text
Python
+
JavaScript
+
WebSockets
+
Database
+
Background workers
+
APIs
```

que es exactamente el tipo de sistema donde un bug puede estar funcionando perfectamente en cinco capas y desaparecer misteriosamente en la sexta.

---

# 8. Mejorar la observabilidad

Una IA no puede arreglar fácilmente lo que no puede observar.

Un sistema bueno para agentes debería tener:

```text
Logs
Metrics
Traces
Debug commands
Health checks
Diagnostic scripts
```

Ejemplo:

```text
scripts/
├── check_api.py
├── check_database.py
├── validate_config.py
└── diagnose_websocket.py
```

Entonces el agente puede hacer:

```text
Problema detectado
        ↓
Ejecutar diagnóstico
        ↓
Obtener evidencia
        ↓
Localizar capa problemática
        ↓
Modificar
        ↓
Reejecutar diagnóstico
```

Esto es mucho mejor que permitirle inspeccionar 200 archivos buscando dónde murió un mensaje.

## Práctica emergente: Diagnostic Tooling

Crear herramientas específicamente para que humanos **y agentes** puedan diagnosticar el sistema.

---

# 9. Convertir operaciones comunes en scripts

No obligues al agente a recordar:

```text
1. activar entorno
2. instalar dependencias
3. iniciar backend
4. iniciar frontend
5. configurar variables
6. ejecutar pruebas
```

Mejor:

```powershell
./scripts/setup.ps1
./scripts/dev.ps1
./scripts/test.ps1
./scripts/check.ps1
```

O usando:

```text
Makefile
Taskfile
Justfile
npm scripts
pyproject scripts
```

Por ejemplo:

```text
task setup
task test
task lint
task check
task build
```

Esto tiene una ventaja enorme:

> **reduces el número de decisiones que el agente debe tomar.**

Cada decisión adicional es una oportunidad para que invente una.

---

# 10. Crear una interfaz de comandos estable

Idealmente:

```text
setup
build
test
lint
typecheck
run
clean
check
```

independientemente de la tecnología interna.

Por ejemplo:

```text
project/
├── Python
├── Node.js
└── Docker
```

pero el agente solo necesita saber:

```text
task setup
task test
task check
```

Esto es una especie de:

> **API operativa del repositorio**

Y es extremadamente útil para IA agéntica.

---

# 11. Crear validadores específicos del proyecto

Además de tests generales.

Ejemplo:

```text
scripts/
├── validate_architecture.py
├── validate_imports.py
├── validate_docs.py
└── validate_project.py
```

Podrías comprobar automáticamente:

```text
¿domain importa infrastructure?
→ ERROR

¿hay enlaces rotos en documentación?
→ ERROR

¿un archivo generado fue modificado manualmente?
→ ERROR

¿faltan metadatos?
→ ERROR
```

Esto es importantísimo.

La regla ideal sería:

> **Si una regla puede comprobarse automáticamente, no confíes únicamente en que la IA la recuerde.**

---

# 12. Añadir tests arquitectónicos

No solamente:

```text
¿La función devuelve 5?
```

También:

```text
¿La arquitectura sigue siendo válida?
```

Ejemplo conceptual:

```text
src/domain/
    ✗ No puede importar
      src/infrastructure/

src/ui/
    ✓ Puede importar
      src/services/
```

Esto protege contra uno de los problemas clásicos de la IA:

```text
"Necesito estos datos."

*importa una dependencia desde cualquier sitio*

"Problema resuelto."
```

Localmente, sí.

Arquitectónicamente, acabas de perforar tres capas.

---

# 13. Proporcionar ejemplos reales

Los ejemplos son contexto de altísimo valor.

Por ejemplo:

```text
examples/
├── correct_api_usage.py
├── expected_config.yaml
└── valid_output.json
```

La IA aprende mejor del patrón existente que de una descripción abstracta.

En lugar de:

```markdown
Las funciones deben seguir el patrón estándar.
```

mostrar:

```python
def create_sensor(
    sensor: SensorInput,
    repository: SensorRepository,
) -> Sensor:
    ...
```

Ejemplo concreto > párrafo filosófico.

---

# 14. Crear casos de referencia

Para sistemas complejos, puedes mantener:

```text
fixtures/
golden/
examples/
reference/
```

Ejemplo:

```text
tests/golden/
├── valid_output.json
├── complex_output.json
└── edge_case_output.json
```

La IA puede modificar código y comparar resultados contra casos conocidos.

Esto es especialmente útil para:

* parsers;
* compiladores;
* procesamiento de datos;
* generación de documentos;
* APIs;
* gráficos;
* transformaciones.

## Práctica: Golden Tests

La idea:

```text
Input conocido
      ↓
Sistema
      ↓
Output
      ↓
Comparar contra referencia
```

---

# 15. Mantener una base de errores conocidos

Por ejemplo:

```text
docs/
└── known_issues.md
```

O mejor estructurado:

```text
docs/troubleshooting/
├── websocket.md
├── rendering.md
└── environment.md
```

Cada problema:

```markdown
## Síntoma

El componente existe pero no aparece.

## Causa conocida

El contenedor padre tiene `display: none`.

## Cómo diagnosticar

Ejecutar...

## Solución
...
```

Esto permite reutilizar experiencia.

Porque una IA puede ser muy inteligente y aun así volver a investigar exactamente el mismo error que resolviste hace tres semanas. Una cualidad profundamente humana, por desgracia.

---

# 16. Mejorar la calidad del feedback

El feedback:

```text
No funciona.
```

es casi inútil.

Mejor:

```text
Expected:
El gráfico debe aparecer.

Actual:
El elemento se crea en el DOM pero tiene width = 0.

Logs:
...

Último cambio funcional:
commit abc123
```

La IA puede razonar sobre evidencia.

Por eso conviene conservar:

```text
Expected behavior
Actual behavior
Reproduction steps
Logs
Environment
Relevant files
```

Esto también mejora los issues.

---

# 17. Usar worktrees o entornos aislados

Cuando el agente realiza cambios importantes:

```text
main/
│
├── Estado estable
│
└── worktree-agent/
    └── Experimento
```

Beneficios:

* no contaminas el trabajo principal;
* puedes comparar cambios;
* puedes ejecutar varios agentes;
* puedes descartar experimentos completos.

Esto permite una práctica especialmente interesante:

> **Parallel Agent Exploration**

```text
Agente A
→ Investiga causa

Agente B
→ Propone implementación

Agente C
→ Revisa arquitectura

Agente D
→ Ejecuta tests
```

No siempre necesitas cuatro agentes, porque gastar recursos para resolver un error de una línea también es una forma creativa de calentar el planeta.

Pero para problemas complejos puede ser útil.

---

# 18. Separar exploración, implementación y revisión

Una IA no tiene por qué hacer todo en un único paso.

Un flujo más robusto:

```text
FASE 1
Explorar
↓
FASE 2
Identificar causa
↓
FASE 3
Crear plan
↓
FASE 4
Implementar
↓
FASE 5
Validar
↓
FASE 6
Revisar diff
```

Esto reduce el comportamiento típico:

```text
Usuario:
"Hay un bug."

IA:
"Ya cambié 37 archivos."
```

Separar fases permite detectar errores antes de modificar el sistema.

---

# 19. Usar roles especializados cuando tenga sentido

Para tareas grandes puedes separar:

```text
Architect
    ↓
Define estructura

Developer
    ↓
Implementa

Tester
    ↓
Busca fallos

Reviewer
    ↓
Inspecciona cambios
```

Esto no significa que necesites crear cuatro GPTs para cambiar un `if`.

Pero para:

* migraciones;
* refactors;
* cambios arquitectónicos;
* investigación;
* sistemas grandes;

la separación de responsabilidades puede mejorar la calidad.

---

# 20. Crear una "Definition of Done" ejecutable

Por ejemplo:

```text
Una tarea está terminada solo si:

[ ] El comportamiento solicitado existe.
[ ] Los tests pasan.
[ ] El lint pasa.
[ ] El type checker pasa.
[ ] No hay cambios fuera del alcance.
[ ] La documentación relevante fue actualizada.
[ ] El diff fue revisado.
```

Idealmente:

```text
task check
```

ejecuta la mayoría.

Eso convierte:

> "Creo que terminé"

en:

> "El sistema de validación confirma que se cumplen estas condiciones."

Mucho menos poético. Mucho más útil.

---

# 21. Añadir invariantes explícitos

Las invariantes son reglas que **siempre deben cumplirse**.

Ejemplo:

```markdown
## Invariantes

- Un ID de usuario es inmutable.
- Las mediciones nunca pueden tener timestamp futuro.
- El dominio no depende de la interfaz.
- Las operaciones destructivas requieren confirmación.
```

Una IA puede modificar la implementación.

Pero debería saber:

```text
Implementación
puede cambiar
        ↓
Invariantes
no pueden romperse
```

Esto proporciona límites semánticos.

---

# 22. Diseñar para reversibilidad

Con agentes esto es fundamental.

Cada operación importante debería poder:

```text
Revertirse
Reproducirse
Compararse
Aislarse
```

Herramientas:

```text
Git commits
Git worktrees
Feature flags
Migrations
Backups
Checkpoints
Lockfiles
Containers
```

Un flujo saludable:

```text
Estado limpio
      ↓
Commit/checkpoint
      ↓
Agente modifica
      ↓
Validación
      ↓
Revisión
      ↓
Commit
```

---

# 23. Crear "knowledge loops"

Esta me parece una de las prácticas más interesantes para repositorios con IA.

Cada error relevante puede producir conocimiento reutilizable:

```text
Bug
 ↓
Diagnóstico
 ↓
Solución
 ↓
¿Puede repetirse?
 ↓
Sí
 ↓
Agregar:
- test
- invariant
- troubleshooting
- instrucción
- validador
```

El sistema evoluciona así:

```text
Experiencia
    ↓
Conocimiento
    ↓
Automatización
    ↓
Prevención
```

Esta es probablemente una de las diferencias más importantes entre simplemente **usar una IA** y diseñar un verdadero **entorno de ingeniería asistido por agentes**.

---

# 24. Mi clasificación general

Yo ampliaría el modelo anterior de esta forma:

| Categoría                | Ejemplos                                            |
| ------------------------ | --------------------------------------------------- |
| **Contexto**             | AGENTS.md, arquitectura, ADRs                       |
| **Navegabilidad**        | estructura, índices, mapas del repo                 |
| **Especificación**       | requisitos, contratos, criterios de aceptación      |
| **Legibilidad**          | modularidad, nombres, tipos                         |
| **Herramientas**         | CLI, scripts, diagnósticos                          |
| **Observabilidad**       | logs, métricas, trazas                              |
| **Validación**           | tests, lint, type checking                          |
| **Restricciones**        | invariantes, archivos protegidos                    |
| **Automatización**       | CI, scripts, validadores                            |
| **Reversibilidad**       | commits, worktrees, checkpoints                     |
| **Memoria**              | ADRs, changelog, known issues                       |
| **Feedback**             | resultados, errores, diffs                          |
| **Aprendizaje del repo** | convertir errores en reglas o tests                 |
| **Orquestación**         | planificación, roles, fases, agentes especializados |

---

# La arquitectura ideal para un repositorio agéntico

Yo lo visualizaría así:

```text
                    OBJETIVO
                       │
                       ▼
                ESPECIFICACIÓN
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
       CONTEXTO    RESTRICCIONES  CONTRATOS
          │            │            │
          └────────────┼────────────┘
                       ▼
                 IA AGÉNTICA
                       │
          ┌────────────┼─────────────┐
          ▼            ▼             ▼
       CÓDIGO      DOCUMENTACIÓN   SCRIPTS
          │            │             │
          └────────────┼─────────────┘
                       ▼
                  VALIDACIÓN
          ┌────────────┼─────────────┐
          ▼            ▼             ▼
        TESTS        LINT        TYPE CHECK
                       │
                       ▼
                   EVIDENCIA
                       │
                       ▼
                  REVIEW DIFF
                       │
                       ▼
                     GIT
                       │
                       ▼
               CONOCIMIENTO NUEVO
                       │
                       └──────────► CONTEXTO
```

## Mi conclusión

Si tuviera que resumir todo en una sola idea:

> **La capacidad de una IA para trabajar en un repositorio depende menos de cuánto código puede escribir y más de qué tan bien diseñado está el entorno para que pueda observar, comprender, modificar y verificar el sistema.**

Por eso, además de buenas prácticas y archivos como `AGENTS.md`, los elementos que más mejoraría serían:

1. **Estructura semántica y navegable del repositorio**.
2. **Especificaciones y criterios de aceptación explícitos**.
3. **Contratos y tipado verificable**.
4. **Scripts estables para todas las operaciones comunes**.
5. **Herramientas de diagnóstico y observabilidad**.
6. **Tests arquitectónicos y validadores específicos**.
7. **Ejemplos y casos de referencia**.
8. **Separación entre exploración, implementación y revisión**.
9. **Cambios pequeños, reversibles y aislados**.
10. **Un ciclo donde cada error importante se convierta en conocimiento, prueba o automatización**.

En otras palabras, el objetivo no es construir un repositorio que simplemente **contenga código**. Es construir un repositorio que funcione como un **entorno de trabajo inteligible**, tanto para ti como para cualquier agente que llegue después. Y, por una vez, hacerle la vida fácil a ambos lados de la colaboración.
