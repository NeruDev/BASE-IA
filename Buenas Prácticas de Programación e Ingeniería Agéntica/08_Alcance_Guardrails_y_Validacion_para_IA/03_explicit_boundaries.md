---
id: bp_7e30p4dhfbbp9atwfz2z3c46vm
name: 03_explicit_boundaries
title: "Límites Explícitos de Mutación (Explicit Boundaries)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/08_Alcance_Guardrails_y_Validacion_para_IA/03_explicit_boundaries.md
version: 1.1.0
category: agentic
tags: [explicit-boundaries, protection, readonly-zones, guardrails, security, universal_principles]
description: "Límites Explícitos de Mutación: declaración taxativa de zonas, archivos y configuraciones intocables para agentes."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:30:00Z
schema_version: 1.0.0
---

# 03 - Límites Explícitos de Mutación (Explicit Boundaries)

## 1. Definición y Fundamento Teórico

Originada en los principios de **Confinamiento de Procesos (*Sandboxing*)** y en las políticas de **Inmutabilidad por Diseño**, la práctica de **Límites Explícitos de Mutación** postula:

> *"El repositorio debe declarar de forma taxativa, explícita y no negociable cuáles zonas, directorios, archivos de configuración e interfaces son de estricto **modo solo lectura** para los agentes de IA, impidiendo que modifiquen infraestructura, credenciales, contratos públicos o suites de seguridad sin autorización humana formal."*

Esta directiva establece un cortafuegos que prohíbe a los modelos resolver problemas mediante atajos destructivos o modificaciones fuera de su perímetro asignado.

## 2. Por Qué Existe y Problemas que Resuelve

- **Prevención de Atajos Inseguros:** Evita que un agente "resuelva" un fallo de autenticación relajando los requisitos de seguridad o comentando validaciones en `src/core/security.py`.
- **Protección de la Configuración de Producción:** Impide la alteración accidental de manifiestos de Kubernetes, Docker Compose o variables de entorno críticas.
- **Preservación de Contratos de API Públicos:** Garantiza que los esquemas consumidos por clientes externos permanezcan estables.

## 3. Relevancia en Sistemas con IA Agéntica

- **Guardrail Pre-Commit Automatizado:** Un hook de Git o script en CI puede verificar que el diff del agente no contenga modificaciones en las rutas protegidas.
- **Claridad Inmediata para el Agente:** Al leer `AGENTS.md`, el modelo sabe desde el primer segundo qué archivos no debe intentar editar, evitando intentos fallidos de tool calling.
- **Aislamiento Seguro en Pipelines Desatendidos:** Permite otorgar autonomía a los agentes para modificar lógica de negocio con la certeza de que no alterarán la infraestructura base.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: El Agente "Arregla" un Test Modificando la Seguridad)

```text
# Situación: El agente debe implementar un endpoint pero el test de auth falla con 401 Unauthorized.
# ANTIPATRÓN: Como no había límites explícitos declarados, el agente decide:
1. Editar `src/core/security.py` para desactivar la verificación de tokens JWT:
   # def verificar_token(token): return True # Bypass inseguro
2. El test pasa, pero la seguridad del sistema queda totalmente vulnerada.
```

### ✅ Declaración y Validación de Límites Explícitos (`AGENTS.md` + Hook)

Directiva en `AGENTS.md`:
```markdown
## 🛑 Zonas Protegidas de Solo Lectura (PROHIBIDO MODIFICAR)
Los agentes tienen terminantemente prohibido alterar los siguientes archivos y rutas:
- `src/core/security.py` (Módulo criptográfico y de autenticación)
- `.env*` y configuraciones de infraestructura (`docker-compose.yml`, `Dockerfile`)
- `.github/workflows/*` (Pipelines de CI/CD)
- `docs/adr/*` (Registros inmutables de arquitectura)

Cualquier cambio propuesto en estas zonas será rechazado automáticamente por el CI.
```

Script de Protección en Pre-Commit (`scripts/check_boundaries.py`):
```python
# scripts/check_boundaries.py
import subprocess
import sys

RUTAS_PROTEGIDAS = [
    "src/core/security.py",
    "docker-compose.yml",
    "Dockerfile",
    ".github/workflows/",
    "docs/adr/",
]

def validar_limites_de_mutacion() -> int:
    # Obtiene la lista de archivos modificados en la rama/commit
    resultado = subprocess.run(["git", "diff", "--name-only", "origin/main...HEAD"], capture_output=True, text=True)
    archivos_modificados = resultado.stdout.splitlines()

    violaciones = []
    for archivo in archivos_modificados:
        for protegida in RUTAS_PROTEGIDAS:
            if archivo.startswith(protegida) or archivo == protegida:
                violaciones.append(archivo)

    if violaciones:
        print("[!] ERROR DE GUARDRAIL: El agente intentó modificar archivos protegidos de solo lectura:")
        for v in violaciones:
            print(f"  - {v}")
        return 1

    print("[✓] Límites de mutación respetados exitosamente.")
    return 0

if __name__ == "__main__":
    sys.exit(validar_limites_de_mutacion())
```

## 5. Descripción Didáctica de los Cambios

1. **Declaración Taxativa:** `AGENTS.md` lista con claridad las 4 rutas protegidas no negociables.
2. **Validación Programática Dura:** `scripts/check_boundaries.py` inspecciona el `git diff` e interrumpe el commit si se detectan violaciones.
3. **Imposibilidad de Bypasses:** El agente no puede vulnerar el sistema de autenticación para hacer pasar sus pruebas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Tareas Específicas de Infraestructura o Seguridad:** Cuando la tarea asignada es explícitamente actualizar la versión de Docker o mejorar la suite de seguridad, se debe autorizar el cambio mediante una **puerta de aprobación humana explícita (*Approval Gate*)**.

## 7. Checklist de Verificación

- [ ] ¿Las rutas de seguridad, CI/CD e infraestructura están explícitamente listadas como de solo lectura en `AGENTS.md`?
- [ ] ¿Existe un script o hook de CI (`scripts/check_boundaries.py`) que verifique que las rutas protegidas no fueron alteradas?
- [ ] ¿Los agentes son advertidos de que modificar archivos protegidos causará el rechazo inmediato de su entrega?
- [ ] ¿Los cambios legítimos en zonas protegidas requieren confirmación humana explícita?