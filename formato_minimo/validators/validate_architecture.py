#!/usr/bin/env python3
"""
Validador determinista de Límites Arquitectónicos e Importaciones AST (BASE-IA).
Verifica que las capas de Dominio/Core (src/**/core/, src/**/domain/) no importen
módulos de infraestructura, adaptadores o librerías externas de E/S.
"""

from __future__ import annotations

import ast
import sys
from pathlib import Path

FORBIDDEN_CORE_IMPORTS = {
    "requests",
    "httpx",
    "aiohttp",
    "urllib3",
    "sqlalchemy",
    "psycopg2",
    "mysql",
    "pymongo",
    "redis",
    "fastapi",
    "flask",
    "django",
    "tornado",
    "adapters",
    "infra",
    "infrastructure",
    "presentation",
    "views",
    "controllers"
}


class ImportVisitor(ast.NodeVisitor):
    def __init__(self, file_path: Path) -> None:
        self.file_path = file_path
        self.violations: list[str] = []

    def visit_Import(self, node: ast.Import) -> None:
        for alias in node.names:
            base_module = alias.name.split(".")[0]
            if base_module in FORBIDDEN_CORE_IMPORTS:
                self.violations.append(
                    f"{self.file_path}:{node.lineno} - Importación prohibida en capa Core/Dominio: 'import {alias.name}'"
                )
        self.generic_visit(node)

    def visit_ImportFrom(self, node: ast.ImportFrom) -> None:
        if node.module:
            base_module = node.module.split(".")[0]
            if base_module in FORBIDDEN_CORE_IMPORTS:
                self.violations.append(
                    f"{self.file_path}:{node.lineno} - Importación prohibida en capa Core/Dominio: 'from {node.module} import ...'"
                )
        self.generic_visit(node)


def validate_python_architecture(src_dir: Path) -> tuple[int, list[str]]:
    """Inspecciona recursivamente los archivos Python bajo rutas de core/domain."""
    violations: list[str] = []

    if not src_dir.exists():
        return 0, []

    for py_file in src_dir.rglob("*.py"):
        # Identificar si el archivo reside en una capa de dominio/core
        parts = [p.lower() for p in py_file.parts]
        is_core_layer = any(layer in parts for layer in ("core", "domain", "pure_domain"))

        if is_core_layer:
            try:
                tree = ast.parse(py_file.read_text(encoding="utf-8"), filename=str(py_file))
                visitor = ImportVisitor(py_file)
                visitor.visit(tree)
                violations.extend(visitor.violations)
            except SyntaxError as e:
                violations.append(f"Error de sintaxis en {py_file}:{e.lineno} - {e.msg}")
            except Exception as e:
                violations.append(f"Error al analizar AST de {py_file}: {e}")

    return len(violations), violations


def main() -> None:
    current_dir = Path(__file__).resolve().parent
    base_dir = current_dir.parent if current_dir.name == "validators" else current_dir

    print(f"[*] Validando límites de arquitectura e importaciones AST en: {base_dir}")
    err_count, errors = validate_python_architecture(base_dir)

    if err_count == 0:
        print("[+] Architecture Boundaries Validation PASSED: 0 violaciones de importación.")
        sys.exit(0)
    else:
        print(f"[-] Architecture Validation FAILED: {err_count} violaciones detectadas:")
        for err in errors:
            print(f"    - {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()
