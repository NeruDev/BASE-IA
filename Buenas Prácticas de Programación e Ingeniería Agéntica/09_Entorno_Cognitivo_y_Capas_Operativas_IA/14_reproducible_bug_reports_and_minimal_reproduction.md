---
id: bp_01m1343cz0egsa3shy9jtqe1d4
name: 14_reproducible_bug_reports_and_minimal_reproduction
title: "Reportes de Bugs Reproducibles y Casos Mínimos de Reproducción (MRE)"
file_path: Buenas Prácticas de Programación e Ingeniería Agéntica/09_Entorno_Cognitivo_y_Capas_Operativas_IA/14_reproducible_bug_reports_and_minimal_reproduction.md
version: 1.0.0
category: agentic
tags: [bug-reports, mre, reproduction-script, issue-template, determinism, debugging]
description: "Protocolo para formular reportes de bugs reproducibles y construir Casos Mínimos de Reproducción (MREs) optimizados para agentes de IA."
owner: AI Engineering & Architecture Team
status: active
created_at: 2026-08-27T17:00:00Z
updated_at: 2026-08-27T17:00:00Z
schema_version: 1.0.0
---

# 14 - Reportes de Bugs Reproducibles y Casos Mínimos de Reproducción (MRE)

Para que un agente de IA pueda diagnosticar y reparar un defecto en el código de forma determinista, el reporte del problema debe proveer un **Ejemplo Mínimo Reproducible (*Minimal Reproducible Example - MRE*)**.

---

## 1. La Anatomía de un Bug Report Eficaz para IA

1. **Comportamiento Observado vs Esperado:** Declaración formal y unívoca del desvío.
2. **Script Mínimo de Reproducción:** Un script autónomo (`scripts/repro.py`) o un test fallido (`test_repro_issue_12.py`) que demuestre el error con un `exit code != 0`.
3. **Traza Estructurada de Error:** Payload JSON o log del fallo exacto.
4. **Entorno y Commit:** Versión del intérprete, sistema operativo y hash de commit de Git.

---

## 2. Plantilla de Script Mínimo Reproducible (`scripts/repro.py`)

```python
"""Script de reproducción mínima para el Issue #42.

Este script debe fallar antes del fix y terminar con exit code 0 tras aplicar la solución.
"""
import sys
from my_package.auth import validate_token

def test_reproduction() -> None:
    try:
        # Caso límite que detona el bug
        result = validate_token("token_invalido_con_espacios ")
        print("❌ Fallo: Se esperaba ValueError y se retornó:", result)
        sys.exit(1)
    except ValueError:
        print("✅ Éxito: Excepción esperada capturada.")
        sys.exit(0)

if __name__ == "__main__":
    test_reproduction()
```
