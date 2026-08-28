---
id: bp_5jthvtga66brpt9kc45sbh9w7m
name: 06_repository_as_system_of_record
title: "El Repositorio como Sistema de Registro (System of Record)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/06_Documentacion_y_Gestion_de_Conocimiento/06_repository_as_system_of_record.md
version: 1.1.0
category: standards
tags: [system-of-record, single-source-of-truth, gitops, documentation, knowledge-management, universal_principles]
description: "System of Record: el repositorio Git como fuente canónica, completa y autoritativa de todo el conocimiento."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:20:00Z
schema_version: 1.0.0
---

# 06 - El Repositorio como Sistema de Registro (System of Record)

## 1. Definición y Fundamento Teórico

Basado en el principio de **Fuente Única de Verdad (Single Source of Truth - SSOT)** y en los postulados de la disciplina **GitOps** (*Alexis Richardson*, 2017), el concepto del **Repositorio como Sistema de Registro** establece:

> *"El repositorio de control de versiones (Git) debe constituir la única fuente autoritativa, completa, persistente y auditable de todo el conocimiento duradero del proyecto: código fuente, infraestructura declarativa, arquitectura, decisiones históricas (ADRs), directivas agénticas (`AGENTS.md`) y pipelines de validación."*

Bajo esta filosofía, cualquier conocimiento que no resida dentro del repositorio versionado se considera inexistente o informal.

```text
               ┌────────────────────────────────────────────────────────┐
               │              REPOSITORIO GIT (SYSTEM OF RECORD)        │
               ├─────────────────────────┬──────────────────────────────┤
               │  Código Fuente (.py)    │  Decisiones (docs/adr/)      │
               │  Infraestructura (IaC)  │  Directivas IA (AGENTS.md)   │
               │  Pipelines (.github/)   │  Documentación (docs/)       │
               └─────────────────────────┴──────────────────────────────┘
                                  ▲                    ▲
                                  │                    │
                          Human Developers        AI Agents
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del 'Tribal Knowledge' (Conocimiento Tribal No Escrito):** Erradica la dependencia de conocimientos que solo existen en la memoria de desarrolladores individuales.
- **Auditoría e Inmutabilidad Histórica:** Cualquier cambio en reglas de negocio o arquitectura queda registrado cronológicamente con firma criptográfica.
- **Onboarding Autónomo Instantáneo:** Cualquier desarrollador o agente de IA puede clonar el repositorio y obtener de inmediato toda la información necesaria para construir, probar y operar el sistema.

## 3. Relevancia en Sistemas con IA Agéntica

- **Entorno de Conocimiento Completo para LLMs:** Los agentes de IA carecen de acceso a conversaciones informales de chat o reuniones verbales. El repositorio es su universo completo de información (*Closed-World Assumption*).
- **Consistencia en la Toma de Decisiones Autónomas:** Centralizar directivas, reglas de negocio y ADRs en Git permite que múltiples agentes operen de forma coherente sin contradecirse.
- **Autonomía Operativa de Agentes:** Permite a los agentes diagnosticar fallos, levantar entornos de prueba reproducibles y aplicar parches sin requerir asistencia humana constante.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Conocimiento Fragmentado en Sistemas Desconectados)

```text
# Antipatrón: Información dispersa y no accesible para agentes
- Las reglas de negocio de facturación están en un Google Doc privado sin permisos.
- La configuración de base de datos se pasó por mensaje de Slack hace 6 meses.
- Los scripts de despliegue residen en la máquina local de un ingeniero senior.
RESULTADO: Cuando un agente de IA intenta resolver una incidencia o refactorizar,
carece del contexto y genera código que rompe supuestos implícitos.
```

### ✅ Estructura Correcta (Conforme a System of Record: Repositorio Autosuficiente)

Estructura canónica del repositorio:
```text
enterprise-agent-core/
├── AGENTS.md                   # Directivas y mapa cognitivo para agentes de IA
├── README.md                   # Guía de inicio rápido y onboarding humano
├── pyproject.toml              # Definición declarativa de dependencias y herramientas
├── uv.lock                     # Lockfile criptográfico determinista
├── docker-compose.yml          # Infraestructura declarativa reproducible (IaC)
├── src/                        # Código fuente modular y fuertemente tipado
├── tests/                      # Suite automatizada de pruebas (unit, int, e2e)
├── docs/                       # Documentación técnica como código (Docs-as-Code)
│   ├── adr/                    # Registro inmutable de decisiones arquitectónicas
│   └── architecture/           # Diagramas y especificaciones de subsistemas
└── .github/workflows/          # Definición de CI/CD automatizada
```

## 5. Descripción Didáctica de los Cambios

1. **Autosuficiencia Absoluta:** Un clon del repositorio contiene todo lo necesario para entender, compilar, levantar infraestructura de pruebas y desplegar el sistema.
2. **Inclusión de `AGENTS.md`:** Proporciona un contrato formal de instrucciones y límites para herramientas de IA directamente en la raíz.
3. **Persistencia de Decisiones:** Los ADRs en `docs/adr/` documentan el histórico de decisiones para evitar que se repitan errores del pasado.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Grandes Volúmenes de Datos Binarios (*Big Data / Blobs*):** Almacenar datasets de Machine Learning de 50GB o vídeos en el repositorio satura Git; estos artefactos deben guardarse en buckets S3/GCS y rastrearse mediante punteros ligeros versionados (**DVC** o **Git LFS**).
- **Secretos y Credenciales Reales en Producción:** Claves privadas, certificados y tokens nunca deben guardarse en el repositorio; el repo define el *manifiesto de infraestructura* y la referencia al gestor de secretos (*Vault*), pero no el valor confidencial en texto plano.

## 7. Checklist de Verificación

- [ ] ¿Es posible clonar el repositorio en una máquina limpia y levantar el entorno completo con comandos documentados?
- [ ] ¿Toda la arquitectura, decisiones (ADRs) y reglas de negocio están versionadas en Git en texto plano?
- [ ] ¿Existe un archivo `AGENTS.md` en la raíz con directivas claras para el trabajo de modelos de lenguaje?
- [ ] ¿Los datos binarios pesados se gestionan mediante Git LFS / DVC en lugar de comitearse directamente al historial?