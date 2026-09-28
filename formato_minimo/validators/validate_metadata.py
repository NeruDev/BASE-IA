#!/usr/bin/env python3
"""
Validador determinista de Metadatos YAML Frontmatter (BASE-IA).
Parsea el encabezado YAML de todos los archivos Markdown (.md),
valida contra frontmatter.schema.json, verifica formato TypeID y unicidad global de IDs.
"""

from __future__ import annotations

import datetime
import json
import re
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    yaml = None

try:
    import jsonschema
except ImportError:
    jsonschema = None

TYPEID_REGEX = re.compile(r"^[a-z]{2,12}_[0-9a-hjkmnp-tv-z]{26}$")
FRONTMATTER_REGEX = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def normalize_yaml_data(obj: Any) -> Any:
    """Convierte tipos nativos de PyYAML (como datetime) a tipos serializables JSON/Schema."""
    if isinstance(obj, (datetime.datetime, datetime.date)):
        if isinstance(obj, datetime.datetime):
            # Formatear a ISO 8601 UTC
            if obj.tzinfo is not None:
                iso = obj.isoformat()
                return iso.replace("+00:00", "Z")
            return f"{obj.isoformat()}Z"
        return obj.isoformat()
    if isinstance(obj, dict):
        return {k: normalize_yaml_data(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [normalize_yaml_data(v) for v in obj]
    return obj


def extract_frontmatter(content: str) -> tuple[dict[str, Any] | None, str | None]:
    """Extrae y parsea el bloque YAML frontmatter si existe."""
    match = FRONTMATTER_REGEX.match(content)
    if not match:
        return None, "No se encontró bloque YAML frontmatter inicial (--- ... ---)"

    yaml_text = match.group(1)
    if not yaml:
        return None, "Módulo PyYAML no instalado"

    try:
        data = yaml.safe_load(yaml_text)
        if not isinstance(data, dict):
            return None, "El bloque frontmatter no es un diccionario YAML válido"
        data = normalize_yaml_data(data)
        return data, None
    except Exception as e:
        return None, f"Error de sintaxis YAML: {e}"


def validate_all_metadata(target_dir: Path, schema_file: Path | None = None) -> tuple[int, list[str]]:
    """Valida todos los archivos .md en el directorio objetivo."""
    errors: list[str] = []
    seen_ids: dict[str, Path] = {}

    schema: dict[str, Any] | None = None
    validator: Any = None
    if schema_file and schema_file.exists() and jsonschema:
        try:
            schema = json.loads(schema_file.read_text(encoding="utf-8"))
            validator = jsonschema.Draft202012Validator(schema)
        except Exception as e:
            errors.append(f"No se pudo cargar frontmatter.schema.json: {e}")

    md_files = sorted(target_dir.rglob("*.md"))
    for md_file in md_files:
        # Excluir README internos de sandbox y directorios temporales si aplica
        if md_file.name in ("README.md", "sandbox_readme.md") and ("sandbox" in md_file.parts or "modules/sandbox" in md_file.as_posix()):
            continue

        try:
            content = md_file.read_text(encoding="utf-8")
        except Exception as e:
            errors.append(f"Error al leer {md_file}: {e}")
            continue

        frontmatter, err = extract_frontmatter(content)
        if err:
            errors.append(f"Metadatos en {md_file.relative_to(target_dir)}: {err}")
            continue

        assert frontmatter is not None

        # 1. Validar contra JSON Schema
        if validator:
            for schema_err in validator.iter_errors(frontmatter):
                field = "/".join(str(p) for p in schema_err.path)
                errors.append(
                    f"Violación de esquema en {md_file.relative_to(target_dir)}: "
                    f"{schema_err.message} (campo: '{field}')"
                )

        # 2. Validar formato TypeID
        doc_id = frontmatter.get("id")
        if doc_id:
            if not isinstance(doc_id, str) or not TYPEID_REGEX.match(doc_id):
                errors.append(
                    f"ID inválido en {md_file.relative_to(target_dir)}: '{doc_id}' "
                    f"no cumple el formato TypeID (^[a-z]{{2,12}}_[0-9a-hjkmnp-tv-z]{{26}}$)"
                )
            elif doc_id in seen_ids:
                prev_file = seen_ids[doc_id]
                errors.append(
                    f"ID duplicado '{doc_id}' en {md_file.relative_to(target_dir)} "
                    f"(ya utilizado en {prev_file.relative_to(target_dir)})"
                )
            else:
                seen_ids[doc_id] = md_file

    return len(errors), errors


def main() -> None:
    current_dir = Path(__file__).resolve().parent
    base_dir = current_dir.parent if current_dir.name == "validators" else current_dir
    schema_path = base_dir / "schemas" / "frontmatter.schema.json"

    print(f"[*] Validando metadatos YAML Frontmatter en: {base_dir}")
    err_count, errors = validate_all_metadata(base_dir, schema_path)

    if err_count == 0:
        print("[+] Metadata Validation PASSED: 0 errores de metadatos.")
        sys.exit(0)
    else:
        print(f"[-] Metadata Validation FAILED: {err_count} errores detectados:")
        for err in errors:
            print(f"    - {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()
