---
id: bp_43d0pxjrs4bcx9vbxxe3jsjacj
name: 11_layered_validation
title: "Validación en Capas (Layered Validation)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/03_Calidad_Testing_y_CI_CD/11_layered_validation.md
version: 1.1.0
category: code_standards
tags: [layered-validation, fail-fast, ci-cd, testing-pipeline, performance, universal_principles]
description: "Validación en Capas: ejecución escalonada y progresiva (Sintaxis -> Tipos -> Unit -> Integración -> E2E)."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:05:00Z
schema_version: 1.0.0
---

# 11 - Validación en Capas (Layered Validation)

## 1. Definición y Fundamento Teórico

La **Validación en Capas (Layered Validation)** es una estrategia de optimización del proceso de calidad basada en el principio *Fail-Fast* y la jerarquía de costos de verificación, que establece:

> *"Las comprobaciones de calidad deben ordenarse en capas secuenciales progresivas de menor a mayor costo temporal y computacional, abortando la ejecución inmediatamente ante el primer fallo detectado en la capa más temprana posible."*

La jerarquía canónica de capas es:
1. **Capa 1: Sintaxis y Formato (<1s):** Linters ultrarrápidos y formateadores (Ruff, Flake8).
2. **Capa 2: Análisis Estático de Tipos (1-3s):** Verificación de tipos y contratos estáticos (Mypy, Pyright).
3. **Capa 3: Pruebas Unitarias Aisladas (2-5s):** Ejecución de lógica pura en memoria sin I/O (Pytest Unit).
4. **Capa 4: Pruebas de Integración y Contrato (10-30s):** Verificación con bases de datos de prueba y adaptadores.
5. **Capa 5: Pruebas End-to-End y Seguridad (1-10min):** Flujos completos de usuario y escaneos de vulnerabilidades (Bandit, Trivy, Playwright).

## 2. Por Qué Existe y Problemas que Resuelve

- **Optimización Radical del Tiempo de Diagnóstico:** Evita esperar 8 minutos a que corra una suite pesada para descubrir un error de sintaxis tipográfica o de tipado que pudo detectarse en 200ms.
- **Ahorro de Cómputo e Inferencia:** Reduce el consumo de servidores de CI y tiempo de espera de los ingenieros y agentes.
- **Graduación Clara del Tipo de Fallo:** Permite al desarrollador saber de inmediato si el error es de forma (Capa 1/2), de lógica interna (Capa 3) o de integración externa (Capa 4/5).

## 3. Relevancia en Sistemas con IA Agéntica

- **Aceleración del Bucle ReAct de Agentes:** En bucles de codificación agéntica, el agente necesita feedback en menos de 2 segundos. Si el modelo comete un error de tipado, la Capa 2 le avisa de inmediato, permitiéndole corregir sin esperas prolongadas.
- **Ahorro de Tokens de Contexto:** Los mensajes de error de capas tempranas (Mypy/Ruff) son concisos y directos, ocupando pocos tokens en la ventana de contexto del LLM.
- **Condición Gradual de Aprobación:** Permite definir compuertas (*Quality Gates*) donde un subagente de nivel junior solo necesita validar hasta la Capa 3, delegando las Capas 4 y 5 al pipeline central.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Validación Plana y Desordenada)

```bash
# Antipatrón: Ejecutar primero las pruebas más lentas y pesadas sin compuertas previas
echo "Iniciando validación..."
pytest tests/e2e/test_all_slow_flows.py   # TARDA 12 MINUTOS
# Si el código tiene un typo o un error de sintaxis obvio, el pipeline
# malgasta 12 minutos antes de abortar o falla a mitad del camino confusamente.
ruff check .
mypy src/
```

### ✅ Código Correcto (Conforme a Validación en Capas: Escalonamiento Progresivo)

```python
# scripts/layered_gate.py (Compuerta Escalonada de Calidad)
import subprocess
import sys
import time

def ejecutar_capa(numero: int, nombre: str, comando: list[str]) -> bool:
    print(f"\n[CAPA {numero}] Iniciando: {nombre}...")
    inicio = time.perf_counter()
    resultado = subprocess.run(comando, capture_output=True, text=True)
    duracion = time.perf_counter() - inicio

    if resultado.returncode != 0:
        print(f"[!] FALLO EN CAPA {numero} ({nombre}) tras {duracion:.2f}s:")
        print(resultado.stdout)
        print(resultado.stderr)
        return False

    print(f"[✓] CAPA {numero} SUPERADA con éxito en {duracion:.2f}s.")
    return True

def validar_pipeline_escalonado() -> int:
    """Ejecuta las capas en orden ascendente de costo temporal con Fail-Fast."""
    capas = [
        (1, "Sintaxis y Formato (Ruff)", ["ruff", "check", "."]),
        (2, "Chequeo Estático de Tipos (Mypy)", ["mypy", "src/"]),
        (3, "Pruebas Unitarias Aisladas (Pytest Unit)", ["pytest", "tests/unit", "-q"]),
        (4, "Pruebas de Integración y Contrato", ["pytest", "tests/integration", "-q"]),
    ]

    for num, nombre, cmd in capas:
        if not ejecutar_capa(num, nombre, cmd):
            print(f"\n[X] Pipeline abortado en Capa {num}. Corrige los errores para avanzar a la siguiente capa.")
            return 1

    print("\n[✓✓✓] TODAS LAS CAPAS FUERON COMPLETADAS EXITOSAMENTE.")
    return 0

if __name__ == "__main__":
    sys.exit(validar_pipeline_escalonado())
```

## 5. Descripción Didáctica de los Cambios

1. **Orden Riguroso de Costo Temporal:** La Capa 1 (Ruff) y Capa 2 (Mypy) resuelven la gran mayoría de errores en <2 segundos.
2. **Interrupción Inmediata (*Fail-Fast*):** Si la Capa 1 falla, el script no ejecuta Mypy ni Pytest, ahorrando tiempo de computación.
3. **Métricas de Latencia:** Mide e imprime el tiempo exacto de cada capa, permitiendo identificar rápidamente cuellos de botella en la suite de pruebas.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Ejecución Paralela en CI de Alta Capacidad:** En entornos de CI distribuidos en la nube con decenas de runners libres, ejecutar Capa 1 (Linter), Capa 2 (Tipos) y Capa 3 (Unit tests) **en paralelo** puede reducir el tiempo total de reloj (*Wall Clock Time*), a costa de consumir más minutos de CPU simultáneos.
- **Proyectos Minúsculos de un Solo Archivo:** Para un script de 30 líneas, montar un pipeline de 5 capas es innecesario frente a una simple ejecución directa de `pytest`.
- **Falsa Sensación de Seguridad de Capas Tempranas:** Superar la Capa 1 y 2 no significa que el código funcione; solo garantiza que está bien escrito y tipado. Las Capas 3 y 4 siguen siendo indispensables.

## 7. Checklist de Verificación

- [ ] ¿Los chequeos de calidad se ejecutan en orden estricto de menor a mayor costo temporal?
- [ ] ¿El proceso se detiene inmediatamente ante el primer fallo detectado sin ejecutar capas más pesadas?
- [ ] ¿Las dos primeras capas (formato y tipos estáticos) se resuelven en menos de 3 segundos?
- [ ] ¿Las pruebas lentas (E2E y seguridad) están ubicadas en las capas finales del pipeline?