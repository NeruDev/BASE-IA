#!/usr/bin/env python3
"""
Validador determinista del Manifiesto de Composición y Perfiles (BASE-IA).
Valida sintaxis JSONC, conformidad contra manifest.schema.json, existencia física
de plantillas declaradas y ausencia de conflictos entre módulos.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

try:
    import jsonschema
except ImportError:
    jsonschema = None


def strip_jsonc_comments(text: str) -> str:
    """Elimina comentarios de una cadena JSONC (// y /* ... */) preservando cadenas literales."""
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|("(?:\\.|[^"\\])*")',
        re.DOTALL | re.MULTILINE
    )

    def replace(match: re.Match[str]) -> str:
        s = match.group(0)
        if s.startswith('"'):
            return s
        return ""

    return pattern.sub(replace, text)


def load_jsonc(path: Path) -> dict[str, Any]:
    """Carga y parsea un archivo JSONC eliminando comentarios."""
    raw_content = path.read_text(encoding="utf-8")
    clean_json = strip_jsonc_comments(raw_content)
    return json.loads(clean_json)


def validate_manifest(base_dir: Path) -> tuple[int, list[str]]:
    """Ejecuta todas las reglas de validación sobre el manifiesto y perfiles."""
    errors: list[str] = []
    manifest_path = base_dir / "core" / "repo_manifest.jsonc"
    schema_path = base_dir / "schemas" / "manifest.schema.json"

    if not manifest_path.exists():
        errors.append(f"No se encontró el manifiesto maestro en {manifest_path}")
        return len(errors), errors

    try:
        manifest = load_jsonc(manifest_path)
    except Exception as e:
        errors.append(f"Error al parsear {manifest_path}: {e}")
        return len(errors), errors

    # 1. Validación contra JSON Schema si jsonschema está disponible
    if schema_path.exists() and jsonschema:
        try:
            schema = json.loads(schema_path.read_text(encoding="utf-8"))
            validator = jsonschema.Draft202012Validator(schema)
            for err in validator.iter_errors(manifest):
                errors.append(f"Error de esquema en {manifest_path.name}: {err.message} en {'/'.join(str(p) for p in err.path)}")
        except Exception as e:
            errors.append(f"Fallo al validar JSON Schema de {manifest_path}: {e}")

    # 2. Verificar existencia física de archivos core
    core_files = manifest.get("core_files", [])
    for core_rel in core_files:
        core_file = base_dir / core_rel
        if not core_file.exists():
            errors.append(f"Archivo core declarado no existe físicamente: {core_rel}")

    # 3. Verificar módulos y sus archivos fuentes
    modules: dict[str, Any] = manifest.get("modules", {})
    for mod_key, mod_def in modules.items():
        if "source" in mod_def:
            src_file = base_dir / mod_def["source"]
            if not src_file.exists():
                errors.append(f"Módulo '{mod_key}' referencia 'source' inexistente: {mod_def['source']}")

        if "files_map" in mod_def:
            for src_rel, _ in mod_def["files_map"].items():
                src_file = base_dir / src_rel
                if not src_file.exists():
                    errors.append(f"Módulo '{mod_key}' referencia archivo en 'files_map' inexistente: {src_rel}")

    # 4. Validar perfiles definidos y verificar conflictos
    profiles: dict[str, Any] = manifest.get("profiles_definition", {})
    for prof_key, prof_def in profiles.items():
        enabled = prof_def.get("enabled_modules", [])

        # Verificar que los módulos habilitados existan
        for mod_id in enabled:
            if mod_id not in modules:
                errors.append(f"Perfil '{prof_key}' habilita módulo desconocido: '{mod_id}'")

        # Verificar conflictos de módulos
        for mod_id in enabled:
            mod_data = modules.get(mod_id, {})
            conflicts = mod_data.get("conflicts", [])
            for conflict_id in conflicts:
                if conflict_id in enabled:
                    errors.append(f"Conflicto en perfil '{prof_key}': módulo '{mod_id}' entra en conflicto con '{conflict_id}'")

            # Verificar dependencias requeridas (requires)
            requires = mod_data.get("requires", [])
            for req_id in requires:
                if req_id != "core" and req_id not in enabled:
                    errors.append(f"Dependencia incumplida en perfil '{prof_key}': '{mod_id}' requiere '{req_id}'")

    # 5. Validar archivos de perfil individuales en profiles/
    profiles_dir = base_dir / "profiles"
    if profiles_dir.exists():
        for prof_file in profiles_dir.glob("*/profile.jsonc"):
            try:
                prof_data = load_jsonc(prof_file)
                if schema_path.exists() and jsonschema:
                    schema = json.loads(schema_path.read_text(encoding="utf-8"))
                    validator = jsonschema.Draft202012Validator(schema)
                    for err in validator.iter_errors(prof_data):
                        errors.append(f"Error de esquema en {prof_file.name}: {err.message} en {'/'.join(str(p) for p in err.path)}")
            except Exception as e:
                errors.append(f"Error al parsear archivo de perfil {prof_file}: {e}")

    return len(errors), errors


def main() -> None:
    # Localizar el directorio raíz de formato_minimo
    current_dir = Path(__file__).resolve().parent
    base_dir = current_dir.parent if current_dir.name == "validators" else current_dir

    print(f"[*] Validando Manifiesto y Perfiles en: {base_dir}")
    err_count, errors = validate_manifest(base_dir)

    if err_count == 0:
        print("[+] Manifest & Profiles Validation PASSED: 0 errores encontrados.")
        sys.exit(0)
    else:
        print(f"[-] Manifest & Profiles Validation FAILED: {err_count} errores detectados:")
        for err in errors:
            print(f"    - {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()
