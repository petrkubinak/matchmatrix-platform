#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
===============================================================================
MatchMatrix
25_1_A_38_EXTEND_A24_LEGACY_DOCUMENT_ID_ROUTES_V1.py
===============================================================================

CO:
    Rozšíří aktivní A24 o přesné kanonické trasy historicky stabilních
    Document ID MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800 a MM-DOC-900.

K ČEMU:
    Obecný prefix MM-DOC patří v registru A24 pod docs/00_DOCUMENTATION.
    Uvedené hlavní dokumenty však mají řízené stabilní identity a aktivní
    umístění v jiných dokumentačních oblastech. Přesné Document ID musí mít
    přednost před obecným směrováním prefixu.

BEZPEČNOST:
    - vyžaduje již opravený A24 V1_4 s registrem DOCUMENT_ID_DIRS,
    - neprovádí databázový import,
    - neprovádí Git commit ani push,
    - před změnou vytvoří rollback kopii pod reports/,
    - po změně provede syntax check,
    - funkčně ověří všech šest výjimek i obecné trasy MM-DOC a MM-STD,
    - při chybě obnoví původní A24.

KDE:
    tools/documentation/25_1_A_38_EXTEND_A24_LEGACY_DOCUMENT_ID_ROUTES_V1.py
===============================================================================
"""

from __future__ import annotations

import importlib.util
import sys
from datetime import datetime
from pathlib import Path


ENGINE = "A38_EXTEND_A24_LEGACY_DOCUMENT_ID_ROUTES_V1_0"

A24_RELATIVE = Path(
    "tools/documentation/"
    "25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py"
)

BACKUP_ROOT_RELATIVE = Path(
    "reports/documentation/standardization/"
    "20260728_A24_LEGACY_DOCUMENT_ID_ROUTES_BACKUP"
)

EXPECTED_OLD_ENGINE = (
    "A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_"
    "V1_4_DOCUMENT_ID_ROUTE_OVERRIDES"
)

EXPECTED_NEW_ENGINE = (
    "A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_"
    "V1_5_LEGACY_DOCUMENT_ID_ROUTES"
)

REQUIRED_ROUTES = {
    "MM-STD-1000": ("docs", "10_REFERENCE"),
    "MM-DOC-100": ("docs", "01_MASTER"),
    "MM-DOC-200": ("docs", "02_GOVERNANCE"),
    "MM-DOC-300": ("docs", "03_ARCHITECTURE"),
    "MM-DOC-800": ("docs", "08_DEVELOPMENT"),
    "MM-DOC-900": ("docs", "09_HISTORY"),
}

TEST_PATHS = {
    "MM-STD-1000": (
        "docs/10_REFERENCE/"
        "MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md"
    ),
    "MM-DOC-100": (
        "docs/01_MASTER/"
        "MM-DOC-100_MATCHMATRIX_MASTER_TECH.md"
    ),
    "MM-DOC-200": (
        "docs/02_GOVERNANCE/"
        "MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md"
    ),
    "MM-DOC-300": (
        "docs/03_ARCHITECTURE/"
        "MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md"
    ),
    "MM-DOC-800": (
        "docs/08_DEVELOPMENT/"
        "MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md"
    ),
    "MM-DOC-900": (
        "docs/09_HISTORY/"
        "MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md"
    ),
}


def format_registry(routes: dict[str, tuple[str, ...]]) -> str:
    lines = [
        "DOCUMENT_ID_DIRS: dict[str, tuple[str, ...]] = {"
    ]
    for document_id, parts in routes.items():
        rendered_parts = ", ".join(repr(part) for part in parts)
        lines.append(
            f'    "{document_id}": ({rendered_parts}),'
        )
    lines.append("}")
    return "\n".join(lines)


def load_a24(a24_path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(
        module_name,
        a24_path,
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(
            "Nelze načíst aktivní A24 pro funkční kontrolu."
        )

    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def validate_routes(module, project_root: Path) -> None:
    if module.ENGINE_VERSION != EXPECTED_NEW_ENGINE:
        raise RuntimeError(
            "Neočekávaný ENGINE_VERSION: "
            f"{module.ENGINE_VERSION}"
        )

    actual_routes = dict(module.DOCUMENT_ID_DIRS)
    for document_id, expected_parts in REQUIRED_ROUTES.items():
        actual_parts = actual_routes.get(document_id)
        if tuple(actual_parts or ()) != expected_parts:
            raise RuntimeError(
                f"Chybná trasa {document_id}: "
                f"{actual_parts!r} != {expected_parts!r}"
            )

        prefix = (
            "MM-STD"
            if document_id.startswith("MM-STD-")
            else "MM-DOC"
        )
        result = module.validate_location(
            project_root,
            TEST_PATHS[document_id],
            {
                "document_id": document_id,
                "prefix": prefix,
            },
            {},
        )
        if result != "PREFIX_REGISTRY":
            raise RuntimeError(
                f"Trasa {document_id} nebyla ověřena registrem."
            )

    # Obecné směrování musí zůstat zachováno.
    generic_doc_result = module.validate_location(
        project_root,
        (
            "docs/00_DOCUMENTATION/"
            "MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md"
        ),
        {
            "document_id": "MM-DOC-000",
            "prefix": "MM-DOC",
        },
        {},
    )
    if generic_doc_result != "PREFIX_REGISTRY":
        raise RuntimeError(
            "Obecná trasa MM-DOC přestala fungovat."
        )

    generic_std_result = module.validate_location(
        project_root,
        (
            "docs/12_STANDARD/"
            "MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_"
            "DOKUMENTACE_A_VERZOVANI.md"
        ),
        {
            "document_id": "MM-STD-003",
            "prefix": "MM-STD",
        },
        {},
    )
    if generic_std_result != "PREFIX_REGISTRY":
        raise RuntimeError(
            "Obecná trasa MM-STD přestala fungovat."
        )


def main() -> int:
    script_path = Path(__file__).resolve()
    project_root = script_path.parents[2]
    a24_path = project_root / A24_RELATIVE

    print()
    print("MATCHMATRIX – A38 ROZŠÍŘENÍ TRAS DOCUMENT ID V A24")
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

    already_patched = EXPECTED_NEW_ENGINE in original_text

    if already_patched:
        print(
            "Rozšířený registr již byl nalezen. "
            "Pokračuji funkční kontrolou."
        )
        patched_text = original_text
    else:
        if EXPECTED_OLD_ENGINE not in original_text:
            raise RuntimeError(
                "Aktivní A24 nemá očekávanou verzi V1_4. "
                "Nebyl změněn."
            )

        current_registry = (
            'DOCUMENT_ID_DIRS: dict[str, tuple[str, ...]] = {\n'
            '    "MM-STD-1000": ("docs", "10_REFERENCE"),\n'
            '}\n'
        )

        if current_registry not in original_text:
            raise RuntimeError(
                "Nebyl nalezen očekávaný registr "
                "DOCUMENT_ID_DIRS z A37."
            )

        expanded_registry = (
            format_registry(REQUIRED_ROUTES) + "\n"
        )

        patched_text = original_text.replace(
            EXPECTED_OLD_ENGINE,
            EXPECTED_NEW_ENGINE,
            1,
        )
        patched_text = patched_text.replace(
            current_registry,
            expanded_registry,
            1,
        )

        if patched_text == original_text:
            raise RuntimeError("A24 nebyl změněn.")

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
            a24_path.suffix + ".a38_new"
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
        module = load_a24(
            a24_path,
            "matchmatrix_a24_routes_v15_validation",
        )
        validate_routes(module, project_root)
    except Exception:
        if not already_patched:
            a24_path.write_bytes(original_bytes)
        raise

    print("KONTROLA PŘESNÝCH TRAS")
    print("-" * 79)
    for document_id, parts in REQUIRED_ROUTES.items():
        route = "/".join(parts)
        print(f"{document_id:<12}: {route} – OK")

    print()
    print("KONTROLA OBECNÝCH TRAS")
    print("-" * 79)
    print("MM-DOC        : docs/00_DOCUMENTATION – OK")
    print("MM-STD        : docs/12_STANDARD – OK")
    print("PYTHON SYNTAX : OK")
    print()

    if already_patched:
        print(
            "ROLLBACK ZÁLOHA: nevytvořena – "
            "A24 již obsahoval rozšířený registr"
        )
    else:
        print(f"ROLLBACK ZÁLOHA: {backup_path}")

    print("DATABASE WRITE : NEPROVEDEN")
    print("GIT COMMIT     : NEPROVEDEN")
    print("=" * 79)
    print("A38 EXTEND A24 ROUTES OK")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # noqa: BLE001
        print()
        print("=" * 79)
        print("A38 EXTEND A24 ROUTES FAILED")
        print(f"{type(exc).__name__}: {exc}")
        raise SystemExit(1)
