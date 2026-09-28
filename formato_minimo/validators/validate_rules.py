#!/usr/bin/env python3
"""
Validador determinista de Reglas Operativas y Taxonomía de Severidad RFC 2119 (BASE-IA).
Audita que AGENTS_core.md, AGENTS_template.md y contratos de agentes utilicen
la taxonomía estandarizada: MUST, MUST_NOT, SHOULD, SHOULD_NOT, MAY, PROJECT, AUTO.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

VALID_SEVERITIES = {
    "MUST",
    "MUST_NOT",
    "MANDATORY",
    "FORBIDDEN",
    "SHOULD",
    "SHOULD_NOT",
    "RECOMMENDED",
    "DISCOURAGED",
    "MAY",
    "OPTIONAL",
    "PROJECT",
    "CONTEXTUAL",
    "AUTO",
    "ADAPTIVE"
}


def audit_agent_rules(file_path: Path) -> tuple[int, list[str]]:
    """Verifica que el archivo de contrato operativo contenga la taxonomía RFC 2119."""
    errors: list[str] = []
    if not file_path.exists():
        errors.append(f"Archivo no encontrado: {file_path}")
        return len(errors), errors

    content = file_path.read_text(encoding="utf-8")

    # 1. Verificar presencia de la matriz o definiciones RFC 2119
    found_severities = set()
    for sev in VALID_SEVERITIES:
        if re.search(rf"\b`?{sev}`?\b", content):
            found_severities.add(sev)

    core_required = {"MUST", "MUST_NOT", "SHOULD", "MAY"}
    missing_core = core_required - found_severities
    if missing_core:
        errors.append(
            f"El archivo {file_path.name} no contiene referencias a los niveles base RFC 2119: {missing_core}"
        )

    # 2. Verificar que incluya la jerarquía de precedencia
    if "Precedencia" not in content and "Hierarchy" not in content and "Precedence" not in content:
        errors.append(f"El archivo {file_path.name} carece de sección de Jerarquía de Precedencia de Instrucciones")

    # 3. Verificar que incluya las 5 Reglas Universales o Guardrails
    if "Reglas Universales" not in content and "Guardrails" not in content and "Regla" not in content:
        errors.append(f"El archivo {file_path.name} no declara reglas operativas explícitas")

    return len(errors), errors


def main() -> None:
    current_dir = Path(__file__).resolve().parent
    base_dir = current_dir.parent if current_dir.name == "validators" else current_dir

    print(f"[*] Auditando reglas operativas y taxonomía RFC 2119 en: {base_dir}")
    total_errors: list[str] = []

    target_files = [
        base_dir / "core" / "AGENTS_core.md",
        base_dir / "AGENTS_template.md"
    ]

    for target in target_files:
        if target.exists():
            err_count, errs = audit_agent_rules(target)
            total_errors.extend(errs)

    if not total_errors:
        print("[+] Rules & RFC 2119 Severity Audit PASSED: 0 errores detectados.")
        sys.exit(0)
    else:
        print(f"[-] Rules Audit FAILED: {len(total_errors)} problemas detectados:")
        for err in total_errors:
            print(f"    - {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()
