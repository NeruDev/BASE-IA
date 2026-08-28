---
id: bp_0a7ndntes7bb3b1h5cw7mcgg25
name: 10_automated_validation
title: "Validación Automatizada de Cambios"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/10_automated_validation.md
version: 1.1.0
category: code_standards
tags: [automated-validation, shift-left, pre-commit, verification, determinism, universal_principles]
description: "Validación Automatizada: hooks y scripts locales de chequeo determinista antes de confirmar cambios."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 10 - Validación Automatizada de Cambios

## 1. Definición y Fundamento Teórico

Basada en el principio de **Shift-Left Testing** (desplazar la verificación lo más a la izquierda posible en el ciclo de vida del software), la **Validación Automatizada de Cambios** establece que:

> *"Ningún cambio de código debe confirmarse en el control de versiones sin haber sido validado previamente mediante comprobaciones locales deterministas y reproducibles (formato, linting, tipos, tests rápidos y escaneo de secretos)."*

Esta práctica convierte la calidad en un **filtro preventivo local** en lugar de una detección reactiva tardía en el servidor de integración continua.

## 2. Por Qué Existe y Problemas que Resuelve

- **Ahorro de Tiempo y Recursos de CI:** Evita disparar builds completos en la nube para descubrir errores tipográficos o fallos de formato que pudieron detectarse en local en 100ms.
- **Mantener el Historial de Git Limpio:** Elimina los habituales commits de ruido (*"fix linter"*, *"arregla typo"*).
- **Evidencia Programática Objetiva:** Sustituye la opinión subjetiva del desarrollador sobre si *"el código está bien"* por un resultado binario ejecutable (`exit code 0`).

## 3. Relevancia en Sistemas con IA Agéntica

- **Prohibición de Autocomplacencia Agéntica:** Un modelo de lenguaje tiende a afirmar confiadamente que *"la tarea está resuelta"* incluso cuando su código tiene errores de importación. La validación automatizada obliga al agente a ejecutar el script y aportar evidencia antes de concluir.
- **Bucle de Auto-Corrección Inmediato:** Provee al agente de mensajes de error estructurados y exactos en su entorno local, permitiéndole subsanar fallos de forma autónoma antes de enviar el PR.
- **Blindaje Pre-Commit:** Los hooks de Git (`pre-commit`) aseguran que ningún agente pueda comitear credenciales hardcodeadas ni código que rompa el tipado estático.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Finalización Subjetiva sin Verificación Programática)

```python
# Antipatrón: El agente edita el código y asume que funciona sin correr validaciones:
def resolver_ticket_agente(archivo_a_editar: str, nuevo_codigo: str):
    with open(archivo_a_editar, "w") as f:
        f.write(nuevo_codigo)
    
    # ERROR GRAVE: El agente declara victoria sin ejecutar comprobaciones
    return "Tarea completada exitosamente. El código ha sido actualizado."
    # En realidad: el nuevo código tiene un error de sintaxis y rompe 4 tests.
```

### ✅ Código Correcto (Conforme a Validación Automatizada: Script de Chequeo Determinista)

```python
# scripts/validate.py (Script de Validación Automatizada para Desarrolladores y Agentes)
import subprocess
import sys

def ejecutar_comando(comando: list[str], descripcion: str) -> bool:
    print(f"[*] Ejecutando {descripcion}...")
    resultado = subprocess.run(comando, capture_output=True, text=True)
    if resultado.returncode != 0:
        print(f"[!] FALLO en {descripcion}:")
        print(resultado.stdout)
        print(resultado.stderr)
        return False
    print(f"[✓] {descripcion} SUPERADO.")
    return True

def validar_cambios_locales() -> int:
    """Ejecuta la suite completa de validación determinista local."""
    pasos = [
        (["ruff", "check", "."], "Linter y Calidad Estática (Ruff)"),
        (["ruff", "format", "--check", "."], "Formato de Código"),
        (["mypy", "src/"], "Verificación Estricta de Tipos (Mypy)"),
        (["pytest", "-q", "-x"], "Pruebas Unitarias Rápidas (Pytest - Fail Fast)"),
    ]

    for comando, descripcion in pasos:
        if not ejecutar_comando(comando, descripcion):
            print("\n[X] La validación automatizada ha fallado. Corrige los errores antes de confirmar.")
            return 1

    print("\n[✓✓✓] TODOS LOS CHEQUEOS PASARON. Código listo para commit.")
    return 0

if __name__ == "__main__":
    sys.exit(validar_cambios_locales())
```

## 5. Descripción Didáctica de los Cambios

1. **Secuencia Determinista:** `scripts/validate.py` orquesta en un solo comando la comprobación de formato, calidad estática, tipos y pruebas unitarias con interrupción inmediata ante el primer fallo (`-x`).
2. **Salida Diagnóstica Completa:** En caso de error, captura la salida exacta de stdout y stderr para permitir que el agente de IA entienda el fallo y lo rectifique.
3. **Código de Salida Binario:** Retorna `0` únicamente si todas las verificaciones fueron 100% exitosas, sirviendo como condición de parada para flujos agénticos.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Sobrecarga de Tiempo en Local (>15 segundos):** Si la validación local ejecuta suites de pruebas pesadas o análisis lentos, los desarrolladores desactivarán los hooks (`git commit --no-verify`). Los chequeos locales deben ser ultrarrápidos (<5s).
- **Entornos Incompletos:** Pruebas que requieren bases de datos distribuidas pesadas o servicios en la nube no deben forzarse en validación local pre-commit; esas se delegan al pipeline de CI.
- **Falsos Bloqueos por Dependencias de Herramientas:** Si el entorno local no tiene instalada la versión exacta del linter, el script puede fallar por problemas de entorno y no de código.

## 7. Checklist de Verificación

- [ ] ¿Existe un script unificado de validación local (`scripts/validate.py` o comando `make validate`)?
- [ ] ¿Los hooks de pre-commit ejecutan linters, chequeo de tipos y detección de secretos?
- [ ] ¿El agente de IA tiene la instrucción explícita de ejecutar el script de validación antes de dar por cerrada su tarea?
- [ ] ¿La suite de validación local se ejecuta en menos de 5 segundos?