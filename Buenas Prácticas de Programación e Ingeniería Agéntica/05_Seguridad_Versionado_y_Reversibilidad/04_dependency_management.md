---
id: bp_73htzr8gfhah2s97dx0zzm9j0z
name: 04_dependency_management
title: "Gestión y Auditoría de Dependencias"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/05_Seguridad_Versionado_y_Reversibilidad/04_dependency_management.md
version: 1.1.0
category: standards
tags: [dependency-management, supply-chain-security, pip-audit, cve, dependabot, universal_principles]
description: "Gestión de Dependencias: auditorías automatizadas de vulnerabilidades (pip-audit) y seguridad en la cadena de suministro."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-26T00:00:00Z
updated_at: 2026-08-27T15:15:00Z
schema_version: 1.0.0
---

# 04 - Gestión y Auditoría de Dependencias

## 1. Definición y Fundamento Teórico

Fundamentada en las directivas de **Seguridad en la Cadena de Suministro de Software (NIST SSDF / SLSA Framework)** y las directrices de la **OpenSSF**, la **Gestión y Auditoría de Dependencias** establece que:

> *"Todas las librerías, paquetes externos y dependencias transitivas deben auditarse continuamente contra bases de datos públicas de vulnerabilidades conocidas (CVEs), asegurando que ningún componente con fallos de seguridad críticos o malware sea introducido o permanezca en el sistema."*

La disciplina abarca tres controles indispensables:
1. **Auditoría Automatizada de CVEs:** Escaneo continuo mediante herramientas como `pip-audit`, `Safety` o `Trivy`.
2. **Prevención de Alucinación de Paquetes (*Package Hallucination*):** Verificación de autenticidad y reputación de librerías sugeridas por agentes de IA antes de su instalación.
3. **Control de Licencias:** Verificación de que las dependencias no utilicen licencias incompatibles con el modelo de distribución del proyecto (ej. GPL vs. MIT/Apache-2.0).

## 2. Por Qué Existe y Problemas que Resuelve

- **Protección contra Ataques a la Cadena de Suministro:** Previene el secuestro de dependencias (*Dependency Hijacking*) y ataques de confusión de dependencias (*Dependency Confusion*).
- **Parches Preventivos Automatizados:** Identifica y actualiza librerías vulnerables antes de que los atacantes exploten el CVE publicado.
- **Reducción del Hinchazón del Proyecto (*Dependency Bloat*):** Evita acumular cientos de paquetes innecesarios que aumentan la superficie de ataque y el peso de las imágenes Docker.

## 3. Relevancia en Sistemas con IA Agéntica

- **Protección contra Alucinación de Librerías por LLMs:** Los agentes de IA pueden inventar nombres de paquetes en Python (*Package Hallucination*). Los atacantes registran esos nombres en PyPI con código malicioso esperando que agentes autónomos los instalen.
- **Auditoría en Pipelines de Agentes:** Permite a los sistemas de orquestación agéntica ejecutar `pip-audit` en el sandbox del agente para rechazar cualquier PR que introduzca una librería vulnerable.
- **Mantenimiento Automatizado con Dependabot:** Los agentes pueden colaborar con herramientas como Dependabot o Renovate para generar PRs de actualización con pruebas en verde de forma desatendida.

## 4. Comparativa Didáctica de Código

### ❌ Código Incorrecto (Antipatrón: Instalación Descontrolada sin Auditoría de CVEs)

```bash
# Antipatrón: Un desarrollador o agente instala librerías obsoletas o alucinadas sin verificar
pip install requests==2.25.0  # VULNERABLE: Afectado por CVE-2023-32681 (fuga de credenciales en redirects)
pip install pydantic_super_agent_helper  # PELIGRO: Paquete alucinado potencialmente malicioso en PyPI
# No se ejecuta ninguna herramienta de escaneo de seguridad antes de comitear
```

### ✅ Código Correcto (Conforme a Gestión de Dependencias: Script de Auditoría con pip-audit)

```python
# scripts/audit_dependencies.py
import subprocess
import sys
import json

def auditar_seguridad_dependencias() -> int:
    """Escanea el árbol de dependencias contra la base de datos de vulnerabilidades PyPA."""
    print("[*] Iniciando escaneo de seguridad de dependencias con pip-audit...")
    
    # Ejecuta pip-audit en formato JSON con interrupción ante vulnerabilidades
    comando = ["pip-audit", "--format", "json", "--desc", "on"]
    resultado = subprocess.run(comando, capture_output=True, text=True)

    if resultado.returncode == 0:
        print("[✓] CERO VULNERABILIDADES detectadas en el árbol de dependencias.")
        return 0

    print("[!] VULNERABILIDADES DETECTADAS:")
    try:
        data = json.loads(resultado.stdout)
        for package in data.get("dependencies", []):
            for vuln in package.get("vulns", []):
                print(f"\n- Paquete: {package['name']} (Versión: {package['version']})")
                print(f"  ID: {vuln['id']} | Severidad: {vuln.get('fix_versions', 'Sin fix disponible')}")
                print(f"  Detalle: {vuln['description'][:150]}...")
    except Exception:
        print(resultado.stdout or resultado.stderr)

    return 1

if __name__ == "__main__":
    sys.exit(auditar_seguridad_dependencias())
```

Integración en GitHub Actions (`.github/workflows/security.yml`):
```yaml
name: Dependency Security Audit

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 6 * * 1'  # Escaneo recurrente todos los lunes

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install pip-audit
      - run: python scripts/audit_dependencies.py
```

## 5. Descripción Didáctica de los Cambios

1. **Auditoría Programática:** `scripts/audit_dependencies.py` consulta la base de datos de seguridad oficial de Python (*PyPA Advisory Database*) para verificar cada paquete instalado.
2. **Salida Estructurada para Agentes:** El formato JSON permite extraer los identificadores de CVE y versiones corregidas (`fix_versions`) para que un agente de IA aplique el parche automáticamente.
3. **Escaneo Recurrente Programado:** El cron semanal en GitHub Actions detecta nuevos CVEs publicados incluso si el código del repositorio no ha sido modificado recientemente.

## 6. Límites y Cuándo No Aplicar (Trade-offs)

- **Vulnerabilidades en Herramientas Exclusivas de Desarrollo:** Bloquear el despliegue a producción por una vulnerabilidad de severidad baja en una herramienta que solo corre en local (ej. una librería de gráficos de testing) puede generar falsos bloqueos; se deben separar `dev-dependencies` de dependencias de producción.
- **CVEs sin Parche Disponible (*Zero-Day / No Fix*):** Si una vulnerabilidad carece de versión corregida oficial, se debe evaluar el riesgo y documentar una excepción temporal en el archivo de configuración de auditoría.
- **Sobrecarga de Red en CI:** Ejecutar escaneos pesados de imágenes de contenedores en cada micro-commit puede saturar el ancho de banda; se recomienda reservar el escaneo profundo para PRs y builds nocturnos.

## 7. Checklist de Verificación

- [ ] ¿Se ejecuta `pip-audit` o una herramienta equivalente en el pipeline de CI?
- [ ] ¿Las dependencias están separadas estrictamente entre producción y desarrollo (`[project.optional-dependencies]`)?
- [ ] ¿Existe una herramienta automatizada (Dependabot / Renovate) para recibir PRs de actualización de seguridad?
- [ ] ¿Se verifica la reputación y existencia legítima de paquetes nuevos antes de añadirlos a `pyproject.toml`?