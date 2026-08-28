---
id: bp_4rqx4ftrhha3gs72nnkqg9r5xk
name: 05_progressive_disclosure
title: "Divulgación Progresiva del Contexto (Progressive Disclosure)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/05_progressive_disclosure.md
version: 1.1.0
category: standards
tags: [progressive-disclosure, context-engineering, token-optimization, agents-md, information-architecture, universal_principles]
description: "Divulgación Progresiva: estructuración jerárquica en capas para revelar profundidad técnica bajo demanda a agentes de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 05 - Divulgación Progresiva del Contexto (Progressive Disclosure)

## 1. Definición y Fundamento Teórico

Originado en el diseño de **Interacción Humano-Computadora (HCI)** por **Jakob Nielsen** (1994) y adaptado a la **Ingeniería de Contexto para Modelos de Lenguaje**, el principio de **Divulgación Progresiva del Contexto** postula:

> *"La información técnica, las directivas y la documentación del sistema deben organizarse en capas jerárquicas de profundidad creciente, ofreciendo inicialmente un mapa panorámico de alto nivel y facilitando mecanismos explícitos para cargar detalles técnicos profundos únicamente cuando sean requeridos bajo demanda."*

La jerarquía de divulgación se estructura en tres capas canónicas:
1. **Nivel 1 - Índice y Directivas Globales (`AGENTS.md` / `README.md`):** Visión general compacta (<200 líneas), convenciones globales y mapa de rutas a los dominios.
2. **Nivel 2 - Contratos e Interfaces de Módulo (`docs/api/`, `__init__.py`):** Firmas públicas, esquemas de datos y protocolos del subsistema.
3. **Nivel 3 - Detalle de Implementación e Historial (Código fuente, ADRs, logs):** Inspeccionados selectivamente mediante herramientas de lectura (`view_file`, `grep_search`).

## 2. Por Qué Existe y Problemas que Resuelve

- **Mitigación de la Saturación de Contexto (*Context Stuffing*):** Evita saturar la memoria de trabajo con miles de líneas de información irrelevante para la tarea inmediata.
- **Prevención del Síndrome 'Lost in the Middle':** Los modelos de lenguaje pierden precisión atencional cuando el contexto contiene volúmenes masivos de texto disperso.
- **Reducción Radical de Costos y Latencia:** Minimiza el conteo de tokens en cada turno de conversación o invocación de agente.

## 3. Relevancia en Sistemas con IA Agéntica

- **Navegación Eficiente del Repositorio:** El agente lee primero el índice raíz (`AGENTS.md`) y utiliza sus herramientas de navegación para cargar únicamente el archivo correspondiente al módulo sobre el que trabajará.
- **Enrutamiento de Subagentes Especializados:** Permite que un agente orquestador delegue tareas a subagentes adjuntando exclusivamente el Nivel 2 del dominio asignado.
- **Ahorro de Ventana de Contexto en Tareas Largas:** Conserva espacio vital en la ventana de contexto para el historial de herramientas, razonamiento (*thoughts*) y diffs de código.

## 4. Comparativa Didáctica de Código

### ❌ Estructura Incorrecta (Antipatrón: Context Stuffing Monolítico)

```text
# Antipatrón: Archivo monolítico SYSTEM_PROMPT.md de 6,000 líneas
- Incluye: todo el esquema de la base de datos (50 tablas), guías de frontend,
  código de 25 endpoints y todas las reglas de negocio en un solo bloque gigante.
RESULTADO:
1. Cada llamada al LLM cuesta 10x más dinero en tokens de entrada.
2. La atención del modelo se degrada, provocando alucinaciones y omisión de directivas críticas.
```

### ✅ Estructura Correcta (Conforme a Divulgación Progresiva: AGENTS.md Jerárquico)

Documento Nivel 1 en raíz (`AGENTS.md`):
```markdown
# Directivas para Agentes de Desarrollo

Bienvenido al repositorio Core de Pagos. Sigue esta jerarquía para consultar contexto:

## Mapa del Sistema y Rutas de Contexto
- **Facturación y Pagos:** Ver [`docs/billing/README.md`](docs/billing/README.md) para reglas tributarias y endpoints.
- **Autenticación y Seguridad:** Ver [`docs/auth/README.md`](docs/auth/README.md) para gestión de tokens JWT y permisos.
- **Base de Datos y Esquemas:** Ver [`docs/db/schema.md`](docs/db/schema.md) para diagramas ER y migraciones.

## Convenciones Globales Obligatorias
- Ejecutar `ruff check --fix` y `mypy --strict` tras cualquier edición.
- Toda nueva función debe incluir anotaciones de tipo y doctests.
- PRs con diffs inferiores a 250 líneas.
```

Documento Nivel 2 bajo demanda (`docs/billing/README.md`):
```markdown
# Módulo de Facturación (Billing)

## Interfaces Principales
- `PaymentGatewayProtocol`: Contrato en `src/billing/gateways.py`
- Modelos de Entrada: `PaymentRequestSchema` en `src/billing/schemas.py`

## Reglas de Negocio
- Compras > $100 tienen envío gratuito automático.
- Tasas de recargo calculadas según ADR-004.
```

## 5. Descripción Didáctica de los Cambios

1. **Estructura Ligera en Nivel 1:** El archivo raíz ocupa menos de 40 líneas de tokens, guiando al agente hacia las fuentes especializadas.
2. **Carga Bajo Demanda (Just-in-Time Context):** El agente solo utiliza su herramienta `view_file` sobre `docs/billing/README.md` si la tarea involucra facturación.
3. **Optimización de Recursos:** Se reduce en un 85% el consumo de tokens por turno manteniendo la máxima precisión semántica.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobre-fragmentación Excesiva (*Over-nesting*):** Dividir la documentación en 15 niveles de profundidad donde encontrar un valor requiere saltar por 8 archivos genera latencia innecesaria en el bucle del agente.
- **Proyectos Monolíticos de un Solo Archivo:** En scripts autónomos de 100 líneas, un único archivo `README.md` directo es más práctico que crear jerarquías de carpetas.

## 7. Checklist de Verificación

- [ ] ¿El archivo raíz (`AGENTS.md` / `README.md`) resume las reglas globales y proporciona enlaces a subsistemas en menos de 200 líneas?
- [ ] ¿La documentación detallada está modularizada por dominio en carpetas específicas (`docs/<modulo>/`)?
- [ ] ¿Los agentes de IA son guiados a consultar archivos puntuales mediante herramientas en lugar de recibir volcados monolíticos de texto?
- [ ] ¿Se eliminó la duplicación masiva de información entre las diferentes capas jerárquicas?