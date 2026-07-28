#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
===============================================================================
MatchMatrix
25_1_A_37_PATCH_A24_MM_STD_1000_REFERENCE_ROUTE_V1.py
===============================================================================

CO:
    Bezpečně doplní do aktivního A24 výjimku kanonické cesty pro dokument
    MM-STD-1000.

K ČEMU:
    MM-STD-1000 je řízeně uložen v:
        docs/10_REFERENCE/MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md

    Obecný registr A24 směruje prefix MM-STD do docs/12_STANDARD. Tento nástroj
    doplní přesnější směrování podle konkrétního Document ID.

BEZPEČNOST:
    - neprovádí A24 import,
    - nezapisuje do databáze,
    - neprovádí Git commit ani push,
    - před změnou vytvoří rollback kopii pod reports/,
    - vyžaduje přesné očekávané markery v aktivním A24,
    - po změně provede Python syntax check,
    - funkčně ověří trasu MM-STD-1000 i běžnou trasu MM-STD,
    - při chybě obnoví původní aktivní A24.

KDE:
    tools/documentation/25_1_A_37_PATCH_A24_MM_STD_1000_REFERENCE_ROUTE_V1.py
===============================================================================
"""

from __future__ import annotations

import importlib.util
import sys
from datetime import datetime
from pathlib import Path


ENGINE = "A37_PATCH_A24_MM_STD_1000_REFERENCE_ROUTE_V1_0"

A24_RELATIVE = Path(
    "tools/documentation/"
    "25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py"
)

BACKUP_ROOT_RELATIVE = Path(
    "reports/documentation/standardization/"
    "20260728_A24_MM_STD_1000_ROUTE_BACKUP"
)


def main() -> int:
    script_path = Path(__file__).resolve()
    project_root = script_path.parents[2]
    a24_path = project_root / A24_RELATIVE

    print()
    print("MATCHMATRIX – A37 OPRAVA TRASY MM-STD-1000 V A24")
    print("=" * 79)
    print(f"ENGINE        : {ENGINE}")
    print(f"PROJECT_ROOT  : {project_root}")
    print(f"A24           : {a24_path}")
    print("DATABASE WRITE: DISABLED")
    print("GIT COMMIT    : DISABLED")
    print()

    if not a24_path.is_file():
        raise FileNotFoundError(
            f"Aktivní A24 nebyl nalezen: {a24_path}"
        )

    original_bytes = a24_path.read_bytes()
    original_text = original_bytes.decode(
        "utf-8-sig",
        errors="strict",
    )

    old_engine = (
        'ENGINE_VERSION = '
        '"A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_V1_3_UNIVERSAL_IDS"'
    )
    new_engine = (
        'ENGINE_VERSION = '
        '"A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_'
        'V1_4_DOCUMENT_ID_ROUTE_OVERRIDES"'
    )

    already_patched = (
        "A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_"
        "V1_4_DOCUMENT_ID_ROUTE_OVERRIDES"
        in original_text
    )

    if already_patched:
        print(
            "Výjimka již byla v A24 nalezena. "
            "Pokračuji funkční kontrolou."
        )
        patched_text = original_text
    else:
        if old_engine not in original_text:
            raise RuntimeError(
                "Aktivní A24 nemá očekávanou verzi "
                "V1_3_UNIVERSAL_IDS. Nebyl změněn."
            )

        special_block = (
            'SPECIAL_PREFIX_DIRS: dict[str, tuple[str, ...]] = {\n'
            '    "MM-DL": ("docs", "09_HISTORY", "DENNÍ_ZÁPISY"),\n'
            '    "MM-NAV": ("docs", "09_HISTORY", '
            '"NAVÁZÁNÍ_NA_CHAT"),\n'
            '    "MM-PS": ("docs", "09_HISTORY", '
            '"PROJECT_SNAPSHOTS"),\n'
            '}\n'
        )

        if special_block not in original_text:
            raise RuntimeError(
                "Nebyl nalezen očekávaný registr "
                "SPECIAL_PREFIX_DIRS."
            )

        id_registry_block = special_block + (
            '\n'
            '# Přesnější výjimky podle konkrétního Document ID mají\n'
            '# přednost před obecným směrováním podle prefixu.\n'
            '# MM-STD-1000 je centrální index standardů a patří\n'
            '# do referenční oblasti docs/10_REFERENCE.\n'
            'DOCUMENT_ID_DIRS: dict[str, tuple[str, ...]] = {\n'
            '    "MM-STD-1000": ("docs", "10_REFERENCE"),\n'
            '}\n'
        )

        old_route = (
            '    prefix = str(identity["prefix"])\n'
            '    route_parts = (\n'
            '        SPECIAL_PREFIX_DIRS.get(prefix)\n'
            '        or CANONICAL_PREFIX_DIRS.get(prefix)\n'
            '    )\n'
        )

        new_route = (
            '    document_id = str(identity["document_id"]).upper()\n'
            '    prefix = str(identity["prefix"])\n'
            '    route_parts = (\n'
            '        DOCUMENT_ID_DIRS.get(document_id)\n'
            '        or SPECIAL_PREFIX_DIRS.get(prefix)\n'
            '        or CANONICAL_PREFIX_DIRS.get(prefix)\n'
            '    )\n'
        )

        if old_route not in original_text:
            raise RuntimeError(
                "Nebyl nalezen očekávaný směrovací blok "
                "ve validate_location."
            )

        patched_text = original_text.replace(
            old_engine,
            new_engine,
            1,
        )
        patched_text = patched_text.replace(
            special_block,
            id_registry_block,
            1,
        )
        patched_text = patched_text.replace(
            old_route,
            new_route,
            1,
        )

        if patched_text == original_text:
            raise RuntimeError("A24 nebyl změněn.")

    # Syntax kontrola ještě před přepsáním aktivního souboru.
    compile(patched_text, str(a24_path), "exec")

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = (
        project_root
        / BACKUP_ROOT_RELATIVE
        / stamp
        / A24_RELATIVE
    )

    if not already_patched:
        backup_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )
        backup_path.write_bytes(original_bytes)

        temporary = a24_path.with_suffix(
            a24_path.suffix + ".a37_new"
        )
        temporary.write_text(
            patched_text,
            encoding="utf-8",
            newline="\n",
        )

        try:
            compile(
                temporary.read_text(encoding="utf-8"),
                str(temporary),
                "exec",
            )
            temporary.replace(a24_path)
        except Exception:
            temporary.unlink(missing_ok=True)
            a24_path.write_bytes(original_bytes)
            raise

    try:
        module_name = "matchmatrix_a24_route_validation"
        spec = importlib.util.spec_from_file_location(
            module_name,
            a24_path,
        )
        if spec is None or spec.loader is None:
            raise RuntimeError(
                "Nelze načíst opravený A24 pro kontrolu."
            )

        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        spec.loader.exec_module(module)

        expected_engine = (
            "A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_"
            "V1_4_DOCUMENT_ID_ROUTE_OVERRIDES"
        )
        if module.ENGINE_VERSION != expected_engine:
            raise RuntimeError(
                "Neočekávaný ENGINE_VERSION: "
                f"{module.ENGINE_VERSION}"
            )

        reference_identity = {
            "document_id": "MM-STD-1000",
            "prefix": "MM-STD",
        }
        reference_result = module.validate_location(
            project_root,
            (
                "docs/10_REFERENCE/"
                "MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md"
            ),
            reference_identity,
            {},
        )

        standard_identity = {
            "document_id": "MM-STD-003",
            "prefix": "MM-STD",
        }
        standard_result = module.validate_location(
            project_root,
            (
                "docs/12_STANDARD/"
                "MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_"
                "DOKUMENTACE_A_VERZOVANI.md"
            ),
            standard_identity,
            {},
        )

        if reference_result != "PREFIX_REGISTRY":
            raise RuntimeError(
                "MM-STD-1000 nebyl ověřen registrem "
                "kanonických cest."
            )
        if standard_result != "PREFIX_REGISTRY":
            raise RuntimeError(
                "Obecná trasa MM-STD přestala fungovat."
            )

    except Exception:
        if not already_patched:
            a24_path.write_bytes(original_bytes)
        raise

    print("KONTROLA")
    print("-" * 79)
    print(f"ENGINE VERSION    : {module.ENGINE_VERSION}")
    print("MM-STD-1000 ROUTE : docs/10_REFERENCE – OK")
    print("MM-STD ROUTE      : docs/12_STANDARD – OK")
    print("PYTHON SYNTAX     : OK")
    print()

    if already_patched:
        print(
            "ROLLBACK ZÁLOHA   : nevytvořena – "
            "A24 již byl opraven"
        )
    else:
        print(f"ROLLBACK ZÁLOHA   : {backup_path}")

    print("DATABASE WRITE    : NEPROVEDEN")
    print("GIT COMMIT        : NEPROVEDEN")
    print("=" * 79)
    print("A37 PATCH A24 ROUTE OK")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # noqa: BLE001
        print()
        print("=" * 79)
        print("A37 PATCH A24 ROUTE FAILED")
        print(f"{type(exc).__name__}: {exc}")
        raise SystemExit(1)
