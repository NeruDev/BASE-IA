---
id: bp_55cfv98epwb28r1jbzskzw6wes
name: 02_static_analysis
title: "Análisis Estático de Código y Seguridad (SAST)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/04_Analisis_Estatico_Observabilidad_y_Operaciones/02_static_analysis.md
version: 1.1.0
category: code_standards
tags: [static-analysis, sast, security, bandit, semgrep, vulnerabilities, universal_principles]
description: "Análisis Estático: detección preventiva de fallos de seguridad, inyecciones y complejidad ciclomática."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:10:00Z
schema_version: 1.0.0
---

# 02 - Análisis Estático de Código y Seguridad (SAST)

## 1. Definición y Fundamento Teórico

El **Análisis Estático de Código (Static Application Security Testing - SAST)** es una disciplina de aseguramiento de calidad y seguridad basada en métodos formales y teoría de compiladores que establece:

> *"La estructura del código fuente debe examinarse exhaustivamente mediante el análisis de su Árbol de Sintaxis Abstracta (AST) y Grafo de Control de Flujo (CFG) sin requerir ejecución, identificando patrones de vulnerabilidad, fallos de seguridad (OWASP Top 10), fugas de recursos y complejidad ciclomática excesiva antes de que el código llegue a producción."*

A diferencia de los linters cosméticos, las herramientas de SAST (**Bandit**, **Semgrep**, **SonarQube**) buscan **fallos semánticos profundos** como inyecciones de comandos, deserializaciones inseguras (`pickle`), secretos expuestos y configuraciones criptográficas débiles.

## 2. Por Qué Existe y Problemas que Resuelve

- **Detección Preventiva de Vulnerabilidades Críticas:** Encuentra fallos de inyección SQL, ejecución remota de código (RCE) y Cross-Site Scripting (XSS) en segundos.
- **Auditoría de Cumplimiento de Seguridad:** Garantiza que las directivas de seguridad corporativa se cumplan de forma uniforme en todos los repositorios.
- **Control de la Complejidad Ciclomática:** Detecta funciones con excesivas ramificaciones condicionales que dificultan el mantenimiento y la cobertura de pruebas.

## 3. Relevancia en Sistemas con IA Agéntica

- **Cortafuegos contra Código Vulnerable Generado por LLMs:** Los modelos de lenguaje suelen recurrir a atajos inseguros (`shell=True`, `eval()`, bypass de verificación SSL) para resolver problemas rápidamente. El análisis estático bloquea estos parches automáticamente.
- **Detección de Secretos Hardcodeados:** Evita que los agentes de IA comiteen claves de API, tokens JWT o contraseñas reales obtenidas durante la resolución de tareas.
- **Validación Automática de Dependencias:** Permite escanear librerías sugeridas por agentes contra bases de datos de vulnerabilidades conocidas (CVEs con `pip-audit`).

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Vulnerabilidad Crítica de Inyección de Comandos)

```python
# Antipatrón: Vulnerabilidad de Command Injection detectada por Bandit (B602: subprocess_popen_with_shell_equals_true)
import subprocess

def diagnosticar_conexion_inseguro(host_remoto: str) -> str:
    # ERROR GRAVE: shell=True y concatenación de cadenas permite inyección de comandos
    # Si host_remoto es "8.8.8.8; rm -rf /", se ejecutará el comando malicioso
    comando = f"ping -c 1 {host_remoto}"
    resultado = subprocess.Popen(comando, shell=True, stdout=subprocess.PIPE)
    salida, _ = resultado.communicate()
    return salida.decode()
```

### ✅ Código Correcto (Conforme a SAST: Ejecución Segura y Sanitizada)

```python
# src/network/diagnostics.py
import subprocess
import ipaddress
import shlex

def diagnosticar_conexion_seguro(host_remoto: str) -> str:
    """Ejecuta un diagnóstico de ping seguro validando la entrada y sin shell.

    Args:
        host_remoto: Dirección IP válida a diagnosticar.

    Returns:
        Salida estándar del comando ping.

    Raises:
        ValueError: Si la IP ingresada no es válida.
    """
    # 1. Validación defensiva de formato (Evita inyecciones desde la raíz)
    try:
        ipaddress.ip_address(host_remoto)
    except ValueError as exc:
        raise ValueError(f"Dirección IP no válida: {host_remoto}") from exc

    # 2. Ejecución segura: lista de argumentos y shell=False (Pasa análisis de Bandit)
    comando = ["ping", "-c", "1", host_remoto]
    
    resultado = subprocess.run(
        comando,
        shell=False,  # SEGURO: No interpreta caracteres de control del shell
        capture_output=True,
        text=True,
        check=True,
        timeout=5.0   # Previene bloqueo indefinido de recursos
    )
    return resultado.stdout
```

## 5. Descripción Didáctica de los Cambios

1. **Eliminación de `shell=True`:** Se sustituyó la llamada vulnerable por una lista de argumentos explícitos (`["ping", "-c", "1", host_remoto]`), impidiendo la concatenación de comandos maliciosos.
2. **Validación Semántica Previa:** Se valida que `host_remoto` sea una dirección IP legítima mediante `ipaddress.ip_address`.
3. **Control de Recursos:** Se añadió un parámetro de `timeout=5.0` para prevenir denegaciones de servicio por procesos colgados.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Falsos Positivos y Supresiones Explícitas:** Las herramientas SAST pueden alertar sobre usos legítimos y seguros de ciertas funciones; en esos casos, se debe documentar la supresión explícita (`# nosec Bxxx`) con justificación técnica en code review.
- **No Sustituye al Análisis Dinámico (DAST):** El análisis estático no puede comprobar si un endpoint protegido permite escalada de privilegios lógica en runtime; debe complementarse con pruebas de penetración y DAST.
- **Sobrecarga de Reglas en Proyectos Pequeños:** Configurar suites de escaneo excesivamente rígidas en scripts sencillos puede generar demoras en los pipelines.

## 7. Checklist de Verificación

- [ ] ¿Se ejecuta un escáner de seguridad estático (ej. `bandit -r src/`) en el pipeline de CI?
- [ ] ¿Se prohibió el uso de `shell=True`, `eval()`, `exec()` y `pickle.loads()` en la base de código?
- [ ] ¿Se verificó que no existan credenciales, tokens o secretos hardcodeados mediante detectores de secretos (ej. `detect-secrets`)?
- [ ] ¿Las excepciones y supresiones de reglas (`# nosec`) están justificadas y auditadas?