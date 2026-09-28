#!/usr/bin/env python3
"""
CLI de Inicialización Determinista de Repositorios por Perfil (BASE-IA).
Permite componer e instanciar un nuevo repositorio agéntico a partir del manifiesto
y de un perfil elegido (minimal, python_service, web_frontend, embedded_iot, etc.).
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path
from typing import Any


def strip_jsonc_comments(text: str) -> str:
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
    raw = path.read_text(encoding="utf-8")
    return json.loads(strip_jsonc_comments(raw))


def bootstrap_profile(
    framework_root: Path,
    profile_name: str,
    target_dir: Path,
    dry_run: bool = False
) -> list[str]:
    """Genera la estructura de un repositorio basado en el perfil seleccionado."""
    manifest_path = framework_root / "core" / "repo_manifest.jsonc"
    if not manifest_path.exists():
        raise FileNotFoundError(f"No se encontró el manifiesto en: {manifest_path}")

    manifest = load_jsonc(manifest_path)
    profiles_def = manifest.get("profiles_definition", {})

    if profile_name not in profiles_def:
        available = ", ".join(profiles_def.keys())
        raise ValueError(f"Perfil '{profile_name}' no encontrado. Perfiles disponibles: {available}")

    profile = profiles_def[profile_name]
    enabled_modules = profile.get("enabled_modules", [])
    modules_catalog = manifest.get("modules", {})

    generated_files: list[str] = []

    # 1. Copiar archivos Core Mínimos
    core_map = {
        "core/AGENTS_core.md": "AGENTS.md",
        "core/README_core.md": "README.md",
        "core/gitignore_core": ".gitignore",
        "core/editorconfig_core": ".editorconfig",
        "core/repo_manifest.jsonc": "repo_manifest.jsonc"
    }

    print(f"[*] Componiendo repositorio con perfil '{profile_name}' en: {target_dir}")

    for src_rel, dst_rel in core_map.items():
        src_path = framework_root / src_rel
        dst_path = target_dir / dst_rel
        if src_path.exists():
            if not dry_run:
                dst_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src_path, dst_path)
            generated_files.append(dst_rel)
            print(f"    [+] Core: {dst_rel}")

    # 2. Copiar archivos de módulos habilitados
    for mod_id in enabled_modules:
        mod_def = modules_catalog.get(mod_id)
        if not mod_def:
            print(f"    [!] Advertencia: Módulo '{mod_id}' no encontrado en el catálogo.")
            continue

        print(f"    [*] Aplicando módulo: {mod_def.get('name', mod_id)}")

        # Caso A: source -> target directo
        if "source" in mod_def and "target" in mod_def:
            src_path = framework_root / mod_def["source"]
            dst_path = target_dir / mod_def["target"]
            if src_path.exists():
                if not dry_run:
                    dst_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_path, dst_path)
                generated_files.append(mod_def["target"])
                print(f"        -> {mod_def['target']}")

        # Caso B: files_map explícito
        if "files_map" in mod_def:
            for src_rel, dst_rel in mod_def["files_map"].items():
                src_path = framework_root / src_rel
                dst_path = target_dir / dst_rel
                if src_path.exists():
                    if not dry_run:
                        dst_path.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(src_path, dst_path)
                    generated_files.append(dst_rel)
                    print(f"        -> {dst_rel}")

    # 3. Incluir suite de validadores para asegurar CI local
    validators_dir = framework_root / "validators"
    if validators_dir.exists():
        dst_validators = target_dir / "validators"
        for val_file in validators_dir.glob("*.py"):
            dst_val = dst_validators / val_file.name
            if not dry_run:
                dst_val.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(val_file, dst_val)
            generated_files.append(f"validators/{val_file.name}")

    # 4. Incluir schemas
    schemas_dir = framework_root / "schemas"
    if schemas_dir.exists():
        dst_schemas = target_dir / "schemas"
        for schema_file in schemas_dir.glob("*.json"):
            dst_sch = dst_schemas / schema_file.name
            if not dry_run:
                dst_sch.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(schema_file, dst_sch)
            generated_files.append(f"schemas/{schema_file.name}")

    return generated_files


def main() -> None:
    parser = argparse.ArgumentParser(description="CLI de Inicialización Determinista de Perfiles (BASE-IA)")
    parser.add_argument("--profile", "-p", required=True, help="Nombre del perfil (ej. minimal, python_service, embedded_iot, agentic_system)")
    parser.add_argument("--target", "-t", required=True, help="Directorio destino donde se inicializará el repositorio")
    parser.add_argument("--dry-run", action="store_true", help="Simular generación sin escribir archivos físicamente")

    args = parser.parse_args()

    current_dir = Path(__file__).resolve().parent
    framework_root = current_dir.parent if current_dir.name == "validators" else current_dir
    target_dir = Path(args.target).resolve()

    try:
        files = bootstrap_profile(framework_root, args.profile, target_dir, dry_run=args.dry_run)
        print(f"\n[+] Bootstrap completado exitosamente con perfil '{args.profile}' ({len(files)} archivos generados).")
    except Exception as e:
        print(f"\n[-] Error durante bootstrap: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
