---
id: bp_0x3psp1desb91sxhghnpht79b3
name: 10_trunk_based_development
title: "Desarrollo Basado en Tronco (Trunk-Based Development - TBD)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/10_trunk_based_development.md
version: 1.1.0
category: code_standards
tags: [trunk-based-development, tbd, git, branching-strategy, dora-metrics, universal_principles]
description: "Trunk-Based Development: ramas cortas y commits atómicos integrados continuamente a la rama principal."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 10 - Desarrollo Basado en Tronco (Trunk-Based Development - TBD)

## 1. Definición y Fundamento Teórico

Formalizado por **Paul Hammant** (2013) y respaldado por la investigación científica del grupo **DORA** (*DevOps Research and Assessment - State of DevOps Report*), el **Desarrollo Basado en Tronco (Trunk-Based Development - TBD)** es la estrategia de control de versiones que postula:

> *"Todos los desarrolladores y agentes de software deben integrar sus cambios con frecuencia (varias veces al día) en una única rama principal compartida (`main` / `trunk`) mediante ramas de muy corta duración (vida útil menor a 24 horas) o commits directos protegidos por CI y Feature Flags."*

TBD contrasta frontalmente con estrategias complejas como **GitFlow**, las cuales mantienen ramas de larga duración (`develop`, `feature/*`, `release/*`) durante semanas o meses, provocando retrasos masivos y el temido "infierno de integración" (*Merge Hell*).

```text
Trunk (main) ──●───●──────●───────●──────●───●──> (Siempre desplegable)
                \ /        \     /        \ /
             (Rama corta)  (Rama corta)  (PR Agente <24h)
```

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación del 'Merge Hell':** Los conflictos de fusión se resuelven cuando son triviales (cambios de pocas líneas), en lugar de acumular colisiones gigantescas.
- **Aceleración del Time-to-Market:** Los cambios llegan a los usuarios en horas en lugar de esperar ciclos mensuales de release.
- **Visibilidad Total y Continua:** Todo el equipo y los sistemas automatizados trabajan sobre la versión más fresca y autoritativa de la base de código.

## 3. Relevancia en Sistemas con IA Agéntica

- **Flujo Óptimo para Agentes de Código:** Los modelos de lenguaje son excepcionalmente eficaces resolviendo tareas pequeñas y atómicas (PRs de 1 a 3 archivos con <150 líneas). TBD encaja de forma natural con esta dinámica de trabajo.
- **Prevención de Contexto Obsoleto:** Si un agente trabaja sobre una rama desactualizada de hace 2 semanas, alucinará soluciones basadas en código que ya fue refactorizado. TBD asegura que el agente siempre parta del estado más reciente de `main`.
- **Integración Automatizada sin Fricción:** Permite a pipelines de orquestación agéntica validar, aprobar y fusionar parches de agentes en minutos.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: GitFlow con Ramas Gigantescas y Conflictos Masivos)

```bash
# Antipatrón GitFlow: Rama abierta durante 4 semanas acumulando 60 commits y 80 archivos
git checkout -b feature/massive-agent-redesign
# ... 4 semanas después ...
git checkout main
git merge feature/massive-agent-redesign
# CONFLICTO MASIVO: 45 archivos en conflicto de merge.
# Requiere 2 días de trabajo manual arriesgado para desenredar los cambios.
```

### ✅ Flujo Correcto (Conforme a Trunk-Based Development: Rama Efímera y Commit Atómico)

```bash
# Paso 1: Partir siempre del tronco principal actualizado
git checkout main
git pull --rebase origin main

# Paso 2: Crear rama de vida corta (<24h) para una tarea atómica
git checkout -b fix/subscription-utc-offset

# Paso 3: Realizar el cambio acotado, validar localmente y comitear
# scripts/validate.py -> [✓✓✓] TODOS LOS CHEQUEOS PASARON
git commit -m "fix(billing): normalizar zona horaria a UTC en validacion de suscripcion"

# Paso 4: Push y Pull Request pequeño (<50 líneas modificadas)
git push origin fix/subscription-utc-offset

# Paso 5: CI pasa en 2 minutos -> Merge a main con Fast-Forward / Squash -> Eliminar rama
```

## 5. Descripción Didáctica de los Cambios

1. **Ramas de Vida Ultracorta:** La rama `fix/subscription-utc-offset` existe solo durante el tiempo que toma resolver la tarea puntual y validar el CI (minutos u horas, nunca días).
2. **Commits Atómicos y Cohesivos:** El cambio resuelve una sola responsabilidad de forma autocontenida con sus pruebas correspondientes.
3. **Fusión Continua al Tronco:** Al integrarse de inmediato a `main`, el resto de los desarrolladores y agentes reciben el fix al instante sin acumular desalineación.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Falta de Suite de Pruebas Automatizadas Sólida:** TBD depende críticamente de un pipeline de CI con alta cobertura de pruebas; si el repositorio carece de tests automatizados, fusionar a `main` diariamente puede desestabilizar la rama productiva.
- **Proyectos Open Source con Contribuidores Externos Desconocidos:** En proyectos públicos con miles de contribuidores externos (ej. Linux Kernel o CPython), el modelo de *Forks* y revisiones asíncronas extendidas es preferible por motivos de gobernanza y seguridad.
- **Desarrollo de Grandes Funcionalidades sin Feature Flags:** Intentar hacer TBD sin *Feature Flags* para funcionalidades que toman semanas de desarrollo puede llevar a romper código visible para usuarios.

## 7. Checklist de Verificación

- [ ] ¿Todas las ramas de trabajo se fusionan a `main` en menos de 24 horas desde su creación?
- [ ] ¿Los Pull Requests son pequeños, atómicos y modifican pocos archivos a la vez?
- [ ] ¿Las funcionalidades incompletas se integran a `main` protegidas detrás de Feature Flags?
- [ ] ¿La rama principal (`main`) se mantiene en estado verde y desplegable en todo momento?