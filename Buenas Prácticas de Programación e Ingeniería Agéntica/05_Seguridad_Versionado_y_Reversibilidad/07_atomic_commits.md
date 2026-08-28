---
id: bp_11ggag2pmnb9fahhf8y40tafez
name: 07_atomic_commits
title: "Commits Atómicos y Reversibilidad"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/07_atomic_commits.md
version: 1.1.0
category: standards
tags: [atomic-commits, git, reversibility, git-bisect, git-revert, universal_principles]
description: "Commits Atómicos: unidades lógicas de cambio completas, funcionales y reversibles mediante git revert."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 07 - Commits Atómicos y Reversibilidad

## 1. Definición y Fundamento Teórico

Originado en los principios de diseño de sistemas transaccionales (propiedad de **Atomicidad** en ACID) y formalizado en las mejores prácticas de la comunidad de **Git**, el principio de **Commits Atómicos** postula:

> *"Cada commit en el control de versiones debe encapsular una única unidad lógica de cambio indivisible, completa y coherente que deje el sistema en un estado 100% funcional (compila, pasa linters y aprueba todos los tests automatizados), garantizando que pueda revertirse limpiamente en cualquier momento mediante `git revert` sin efectos secundarios colaterales."*

La atomicidad exige dos condiciones simultáneas:
1. **Singularidad de Propósito:** El commit resuelve un único problema o tarea específica (no mezcla refactorizaciones con features ni fixes con actualizaciones de dependencias).
2. **Autoconsistencia:** El código nunca queda roto o a medio compilar en ningún commit individual del historial.

## 2. Por Qué Existe y Problemas que Resuelve

- **Reversión Quirúrgica Instantánea:** Si un cambio introduce un fallo en producción, se revierte con `git revert <hash>` en 2 segundos sin perder otras mejoras no relacionadas.
- **Depuración Ultrarrápida con `git bisect`:** Permite a herramientas automáticas realizar búsqueda binaria en el historial de Git para encontrar el commit exacto que introdujo una regresión, garantizando que cada paso intermedio sea ejecutable.
- **Revisiones de Código Claras y Enfocadas:** Los revisores humanos o agentes pueden evaluar el cambio commit por commit con una narrativa lógica transparente.

## 3. Relevancia en Sistemas con IA Agéntica

- **Prevención de Commits Monstruo por LLMs:** Los agentes de IA tienden a acumular todas las modificaciones realizadas durante una sesión en un solo commit gigante. Forzar commits atómicos obliga al agente a confirmar cada paso de forma ordenada.
- **Recuperación Autónoma de Errores:** Si un subagente comete un error en un paso posterior de un pipeline, el sistema puede revertir únicamente ese commit atómico y reintentar la tarea.
- **Trazabilidad de Razonamiento:** Cada commit atómico refleja un paso de decisión del agente con su correspondiente test de validación.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Commit Monolítico Multiproposito)

```bash
# Antipatrón: Un solo commit masivo que mezcla dependencias, refactorización y dos features
git add .
git commit -m "actualizar librerias, refactorizar auth y agregar endpoint de pagos"
# PELIGRO:
# Si el endpoint de pagos tiene un bug crítico y se hace 'git revert',
# se revertirá también la actualización de seguridad de librerías y la refactorización de auth.
```

### ✅ Flujo Correcto (Conforme a Commits Atómicos: Unidades Lógicas Separadas)

```bash
# PASO 1: Commit atómico de dependencias (Independiente y funcional)
git add pyproject.toml uv.lock
git commit -m "chore(deps): actualizar pydantic a v2.9.2"

# PASO 2: Commit atómico de refactorización de seguridad (Pasa todos los tests)
git add src/core/security.py tests/unit/test_security.py
git commit -m "refactor(auth): migrar hashing de passwords a pbkdf2-sha256"

# PASO 3: Commit atómico de nueva feature con su suite de tests completa
git add src/billing/payments.py tests/unit/test_payments.py
git commit -m "feat(billing): agregar servicio de cobro con tarjeta de credito"

# BENEFICIO: Si 'payments.py' falla en producción, ejecutamos:
# git revert <hash_del_paso_3>
# La actualización de Pydantic y la mejora de seguridad de auth permanecen intactas en producción.
```

## 5. Descripción Didáctica de los Cambios

1. **Separación de Responsabilidades:** Se crearon 3 commits independientes con alcances claramente diferenciados (`chore`, `refactor`, `feat`).
2. **Inclusión de Tests en el Mismo Commit:** Cada commit incluye tanto la modificación de código como sus pruebas unitarias correspondientes.
3. **Reversibilidad Garantizada:** La reversión de cualquiera de los commits no genera dependencias rotas en los demás.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Micro-commits Incompletos (*Broken Intermediate Commits*):** Dividir un cambio en commits tan pequeños que dejan el código roto (ej. commit 1: añade función, commit 2: arregla typo de sintaxis, commit 3: añade imports) destruye la utilidad de `git bisect`; **cada commit debe compilar y pasar tests**.
- **Fricción en Prototipos Descartables:** En branches privadas experimentales destinadas a ser descartadas, la atomicidad estricta no es necesaria hasta el momento de preparar el PR para `main`.

## 7. Checklist de Verificación

- [ ] ¿Cada commit resuelve un único problema o introduce una única capacidad lógica?
- [ ] ¿El código compila y pasa el 100% de los tests unitarios en cada commit individual?
- [ ] ¿El commit incluye tanto el código de producción como sus pruebas automatizadas asociadas?
- [ ] ¿Es posible revertir el commit mediante `git revert` sin provocar errores de sintaxis o dependencias rotas?