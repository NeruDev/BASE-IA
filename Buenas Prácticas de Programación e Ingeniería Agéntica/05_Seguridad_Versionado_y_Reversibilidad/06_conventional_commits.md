---
id: bp_4h4mwx17s5ahkt2vwq2k7xyjew
name: 06_conventional_commits
title: "Commits Convencionales (Conventional Commits)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/06_conventional_commits.md
version: 1.1.0
category: standards
tags: [conventional-commits, git, changelog, semantic-release, automation, universal_principles]
description: "Conventional Commits: mensajes de commit estructurados para trazabilidad y automatización de changelogs."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 06 - Commits Convencionales (Conventional Commits)

## 1. Definición y Fundamento Teórico

Basada en las directrices de contribución de Angular y formalizada en la especificación **Conventional Commits 1.0.0**, esta práctica establece:

> *"Todos los mensajes de confirmación en Git deben seguir una estructura sintáctica estandarizada y legible tanto por humanos como por máquinas, permitiendo la generación automatizada de changelogs, la trazabilidad de requerimientos y el cálculo automático de versiones SemVer."*

La estructura canónica del mensaje es:
```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Los prefijos semánticos principales son:
- `feat:` Introduce una nueva funcionalidad (corresponde a **MINOR** en SemVer).
- `fix:` Corrige un defecto o bug (corresponde a **PATCH** en SemVer).
- `docs:` Cambios exclusivos en la documentación.
- `refactor:` Refactorización de código que no altera el comportamiento externo.
- `perf:` Optimización de rendimiento.
- `test:` Añade o corrige pruebas automatizadas.
- `chore:` Tareas de mantenimiento, dependencias o configuración de build.
- `feat!:` o `fix!:` Indica un **Breaking Change** (corresponde a **MAJOR** en SemVer).

## 2. Por Qué Existe y Problemas que Resuelve

- **Generación Automatizada de Changelogs (`CHANGELOG.md`):** Herramientas como `semantic-release` leen los commits para compilar notas de release ordenadas por categoría sin intervención humana.
- **Historial de Git Limpio y Profesional:** Facilita la búsqueda con `git log --grep="^fix"` para auditar cuándo se introdujo o reparó un defecto.
- **Claridad Inmediata en Code Reviews:** El revisor o subagente comprende la naturaleza y alcance del cambio antes de leer el diff.

## 3. Relevancia en Sistemas con IA Agéntica

- **Estandarización de Salida para Agentes de Código:** Los modelos de lenguaje pueden redactar mensajes caóticos si no se les impone una gramática estricta. Conventional Commits actúa como el esquema de serialización obligatorio para sus commits.
- **Automatización de Tareas CI/CD Multi-Agente:** Permite a un subagente de release determinar si el PR requiere lanzar una nueva versión mayor, menor o parche basándose en los mensajes de commit recibidos.
- **Vinculación con Tickets y Trazabilidad:** Facilita que el agente asocie cada commit al issue correspondiente en Jira o GitHub (`Refs: #1042`).

## 4. Comparativa Didáctica de Código

### ❌ Mensajes de Commit Incorrectos (Antipatrón: Inexpresivos y Sin Estructura)

```text
# Antipatrón: Mensajes opacos que destruyen la trazabilidad del repositorio Git
git commit -m "fix bug"
git commit -m "cambios varios en billing"
git commit -m "update"
git commit -m "wip"
# ERROR: Imposible generar un changelog automatizado o saber qué versión SemVer corresponde.
```

### ✅ Mensaje de Commit Correcto (Conforme a Conventional Commits v1.0.0)

```text
feat(billing): implementar calculo de flete con tarifas por distancia

Incorpora soporte para tarifas de flete dinámicas calculadas a partir
de la distancia en kilómetros, preservando el beneficio de envío gratuito
para compras superiores a $100.

- Añade constantes UMBRAL_ENVIO_GRATIS y COSTO_POR_KM_EXTRA.
- Integra validación defensiva para montos y distancias negativas.
- Añade cobertura de pruebas unitarias al 100% con pytest.

Closes: #342
Reviewed-by: @senior-dev
```

Ejemplo de Breaking Change:
```text
feat(auth)!: migrar tokens JWT a formato Paseto v4

BREAKING CHANGE: La clave pública anterior ya no es compatible. Todos los
clientes API deben actualizar a las nuevas cabeceras de autorización.
```

## 5. Descripción Didáctica de los Cambios

1. **Estructura Semántica (`type(scope): description`):** Identifica inmediatamente que se trata de una nueva feature en el módulo de facturación (`billing`).
2. **Cuerpo Explicativo (*Body*):** Justifica el *por qué* del cambio y resume las decisiones técnicas adoptadas.
3. **Pie Formal (*Footer*):** Vincula el cierre del issue (`Closes: #342`) para automatizar el cierre del ticket en GitHub/GitLab.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Commits Locales de Exploración (*WIP Commits*):** Durante el desarrollo interactivo temprano en una rama privada, obligarse a redactar mensajes formales para cada commit de 2 minutos puede ser tedioso; la solución es realizar un **Squash and Merge** aplicando Conventional Commits en el commit final hacia `main`.
- **Scopes Hiper-Granulares Confusos:** Definir 200 scopes distintos (ej. `feat(billing-ui-button-icon)`) crea fricción; los scopes deben mantenerse a nivel de módulo o paquete principal (`feat(billing)`).

## 7. Checklist de Verificación

- [ ] ¿El mensaje de commit comienza con un tipo válido (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`)?
- [ ] ¿La descripción está redactada en tiempo presente imperativo y en minúsculas (sin punto final)?
- [ ] ¿Los breaking changes están señalizados con `!` o con el footer `BREAKING CHANGE:`?
- [ ] ¿Se utiliza una herramienta de linting de commits (`commitlint`) en los hooks de pre-commit?