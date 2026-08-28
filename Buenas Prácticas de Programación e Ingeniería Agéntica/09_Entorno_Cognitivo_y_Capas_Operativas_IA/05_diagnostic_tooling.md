---
id: bp_2ykwqyvmv6b0yv5fcyhmj248vy
name: 05_diagnostic_tooling
title: "Herramientas y Scripts de Diagnóstico Dedicados (Diagnostic Tooling)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/05_diagnostic_tooling.md
version: 1.1.0
category: agentic
tags: [diagnostic-tooling, doctor-pattern, healthcheck, troubleshooting, fault-isolation, universal_principles]
description: "Diagnostic Tooling: scripts de diagnóstico rápido (doctor.py) para aislar fallos y obtener evidencia inmediata."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:35:00Z
schema_version: 1.0.0
---

# 05 - Herramientas y Scripts de Diagnóstico Dedicados (Diagnostic Tooling)

## 1. Definición y Fundamento Teórico

Inspirado en el patrón arquitectónico **Doctor Pattern** (`flutter doctor`, `brew doctor`) y en los principios de **Aislamiento de Fallos por Capas (*Fault Isolation*)**, este principio postula:

> *"El repositorio debe incluir scripts utilitarios de diagnóstico dedicados y autocontenidos (`scripts/doctor.py`, `scripts/check_env.py`), permitiendo a los agentes de IA y desarrolladores comprobar en segundos la salud del entorno, versiones de runtime, dependencias y conectividad a servicios locales antes de intentar modificar código de producción."*

El ciclo operativo diagnóstico opera en 6 pasos estructurados:
$$\text{Problema} \longrightarrow \text{Diagnóstico con Script} \longrightarrow \text{Evidencia Exacta} \longrightarrow \text{Aislar Capa} \longrightarrow \text{Modificar} \longrightarrow \text{Reejecutar}$$

## 2. Por Qué Existe y Problemas que Resuelve

- **Eliminación de la Especulación en Diagnóstico:** Evita que el agente modifique código de negocio cuando el fallo real era una variable de entorno faltante o un puerto ocupado.
- **Aislamiento Inmediato de la Capa Defectuosa:** Distingue al instante entre fallos de entorno, fallos de red/base de datos y fallos de lógica de negocio.
- **Aceleración del Tiempo de Resolución (*MTTR*):** Reduce el diagnóstico de incidentes complejos de 40 minutos a 3 segundos.

## 3. Relevancia en Sistemas con IA Agéntica

- **Primer Paso de Triage Obligatorio:** Se instruye al agente en `AGENTS.md` a ejecutar `python scripts/doctor.py` ante cualquier fallo inesperado de entorno.
- **Salida Didáctica Parseable:** La salida del script proporciona causas y soluciones exactas que guían la auto-corrección del LLM.
- **Verificación de Sandboxes Efímeros:** Permite verificar que un contenedor o sandbox recién levantado esté 100% operativo antes de correr los tests.

## 4. Comparativa Didáctica de Código

### ❌ Flujo Incorrecto (Antipatrón: Especulación a Ciegas ante Fallo de Entorno)

```text
# Situación: Los tests fallan porque falta la variable de entorno APP_DATABASE_URL.
# ANTIPATRÓN: El agente no tiene script de diagnóstico y empieza a especular:
Turno 1: Agente modifica `src/database/session.py` hardcodeando una conexión SQLite local.
Turno 2: Rompe la configuración de PostgreSQL de los demás tests.
Turno 3: Intenta reinstalar SQLAlchemy.
# RESULTADO: 6 turnos desperdiciados y código de producción corrompido por falta de diagnóstico.
```

### ✅ Script de Diagnóstico Canónico (`scripts/doctor.py`)

```python
# scripts/doctor.py
import sys
import os
import shutil
import subprocess

def check_python_version() -> bool:
    v = sys.version_info
    if v.major == 3 and v.minor >= 11:
        print(f"[✓] Python Version: {sys.version.split()[0]} (>= 3.11)")
        return True
    print(f"[✗] Python Version: {sys.version.split()[0]} (Se requiere Python 3.11 o superior)")
    return False

def check_tool_installed(tool_name: str) -> bool:
    if shutil.which(tool_name):
        print(f"[✓] Herramienta disponible en PATH: {tool_name}")
        return True
    print(f"[✗] Herramienta FALTANTE: {tool_name}. Instálala antes de continuar.")
    return False

def check_environment_variables() -> bool:
    requeridas = ["APP_JWT_SECRET", "APP_ENCRYPTION_SALT"]
    faltantes = [v for v in requeridas if not os.getenv(v)]
    if not faltantes:
        print("[✓] Variables de entorno críticas configuradas.")
        return True
    print(f"[✗] Variables de entorno FALTANTES: {', '.join(faltantes)}")
    print("    SOLUCIÓN: Copia .env.example a .env y define los valores.")
    return False

def main() -> int:
    print("==================================================")
    print(" 🩺 DIAGNÓSTICO DEL ENTORNO OPERATIVO (DOCTOR.PY)")
    print("==================================================")
    
    chequeos = [
        check_python_version(),
        check_tool_installed("uv"),
        check_tool_installed("ruff"),
        check_environment_variables()
    ]
    
    if all(chequeos):
        print("\n[✓✓✓] ENTORNO SALUDABLE Y LISTO PARA OPERAR.")
        return 0

    print("\n[!] ENTORNO DEGRADADO: Corrige los problemas indicados arriba.")
    return 1

if __name__ == "__main__":
    sys.exit(main())
```

## 5. Descripción Didáctica de los Cambios

1. **Chequeo Integral en Segundos:** Valida versión de Python, herramientas de build y variables de entorno críticas en un solo comando.
2. **Mensajes de Solución Explícitos:** Si falta una variable, indica con precisión: *"Copia .env.example a .env"*.
3. **Código de Salida Determinista:** Retorna 0 si todo está sano y 1 si hay fallos, permitiendo su uso en scripts automatizados.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Scripts de Diagnóstico Pesados:** Un script de diagnóstico que tarda 5 minutos en ejecutar pruebas de carga pierde su propósito; `doctor.py` debe ser **ultrarrápido (<2 segundos)** para que el agente lo ejecute sin fricción.

## 7. Checklist de Verificación

- [ ] ¿Existe un script `scripts/doctor.py` en el repositorio?
- [ ] ¿El script valida versiones de runtime, herramientas requeridas y variables de entorno?
- [ ] ¿La salida indica con claridad la causa y los pasos de solución ante cada fallo?
- [ ] ¿Se instruye al agente en `AGENTS.md` a ejecutar el diagnóstico como primer paso de triage?