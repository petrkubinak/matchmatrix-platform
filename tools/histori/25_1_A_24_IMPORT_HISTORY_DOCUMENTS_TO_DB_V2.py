#!/usr/bin/env python3
# -*- coding: utf-8 -*-

r"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví doplňkový databázový manifest pro datumové dokumenty historie
MatchMatrix a bezpečně je importuje do schématu `documentation`.

K ČEMU:
- podporuje Document ID `MM-DL-YYYYMMDD`,
- podporuje Document ID `MM-NAV-YYYYMMDD-PP`,
- načte přesně určený denní zápis a dokument NAVÁZÁNÍ,
- ověří jejich umístění, název, metadata, datum, verzi, stav a SHA-256,
- vytvoří samostatný history import manifest,
- použije existující produkční importer A6 bez jeho přepsání,
- v režimu DRY_RUN provede databázovou transakci s rollbackem,
- v režimu APPLY provede import a následně spustí read-only ověření A7,
- chrání před importem z necommitnutého nebo nečistého Git stromu,
- databázový zápis je povolen pouze explicitním přepínačem `--apply`.

KDE:
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py

JAK:
Pouze validace souborů a manifestu:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py `
      --validate-only

Bezpečný databázový dry run s rollbackem:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py

Skutečný import a následné ověření A7:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py `
      --apply

Volitelné PostgreSQL DSN:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Povolení nečistého Git stromu je možné pouze pro DRY_RUN:
    --allow-dirty

Výchozí dokumenty:
- docs/09_HISTORY/DENNÍ_ZÁPISY/
  MM-DL-20260630_MATCHMATRIX_DENNI_ZAPIS.md
- docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
  MM-NAV-20260630-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md

BEZPEČNOST:
- A6 ani A7 nepřepisuje,
- při APPLY vyžaduje čistý Git strom a existující commit,
- při APPLY nepovolí `--allow-dirty`,
- před importem ověří hash obou zdrojových souborů,
- A7 se spouští pouze po úspěšném APPLY,
- při chybě se vrací nenulový exit code,
- reporty se zapisují pouze do reports/documentation/.

VÝSTUP:
- reports/documentation/history_document_import_manifest_*.json
- reports/documentation/history_document_import_manifest_latest.json
- standardní report A6
- standardní report A7 po APPLY
- reports/documentation/history_document_database_pipeline_*.json
- reports/documentation/history_document_database_pipeline_latest.json
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Mapping, Sequence


ENGINE_VERSION = "A24_HISTORY_DOCUMENT_DATABASE_IMPORT_V1"
MANIFEST_VERSION = "1.0"
FINAL_VALIDATED = "HISTORY_DOCUMENT_IMPORT_VALIDATED"
FINAL_DRY_RUN = "HISTORY_DOCUMENT_IMPORT_DRY_RUN_READY"
FINAL_APPLIED = "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED"
FINAL_BLOCKED = "HISTORY_DOCUMENT_IMPORT_BLOCKED"

DEFAULT_DOCUMENTS = (
    Path(
        "docs/09_HISTORY/DENNÍ_ZÁPISY/"
        "MM-DL-20260630_MATCHMATRIX_DENNI_ZAPIS.md"
    ),
    Path(
        "docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/"
        "MM-NAV-20260630-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
    ),
)

A6_NAME = "25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py"
A7_NAME = "25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py"

DOCUMENT_ID_RE = re.compile(
    r"^(?:MM-DL-(\d{8})|MM-NAV-(\d{8})-(\d{2}))$"
)
DOCUMENT_ID_ANY_RE = re.compile(
    r"(?<![A-Z0-9])(?:"
    r"MM-DL-\d{8}"
    r"|MM-NAV-\d{8}-\d{2}"
    r"|MM-(?:DOC|STD|REF)-\d{3,4}"
    r")(?![A-Z0-9])",
    re.IGNORECASE,
)
VERSION_RE = re.compile(r"^\d+(?:\.\d+)*$")
TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")
PLACEHOLDER_RE = re.compile(
    r"\[(?:DOPLNIT UŽIVATELEM|DOPLNIT UZIVATELEM)[^\]]*\]",
    re.IGNORECASE,
)


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Importuje datumové denní zápisy a NAVÁZÁNÍ "
            "do databáze MatchMatrix."
        )
    )
    parser.add_argument(
        "--document",
        action="append",
        dest="documents",
        help=(
            "Relativní nebo absolutní cesta k historii. "
            "Lze zadat opakovaně. Bez parametru se použijí "
            "dva výchozí dokumenty 2026-06-30."
        ),
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Pouze ověří dokumenty a vytvoří manifest.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Provede skutečný import a následné ověření A7.",
    )
    parser.add_argument(
        "--allow-dirty",
        action="store_true",
        help=(
            "Povolí nečistý Git strom pouze pro validaci nebo DRY_RUN. "
            "Pro APPLY je neplatný."
        ),
    )
    parser.add_argument(
        "--dsn",
        help="Volitelné PostgreSQL DSN předané A6 a A7.",
    )
    return parser.parse_args()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def run_git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"Git příkaz selhal: git {' '.join(args)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result.stdout.strip()


def git_state(root: Path) -> dict[str, Any]:
    commit = run_git(root, "rev-parse", "HEAD")
    branch = run_git(root, "branch", "--show-current")
    status = run_git(root, "status", "--porcelain")
    return {
        "commit": commit,
        "branch": branch,
        "dirty": bool(status),
        "dirty_lines": status.splitlines(),
    }


def resolve_path(root: Path, value: str | Path) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def relative_to_root(root: Path, path: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError as exc:
        raise RuntimeError(
            f"Dokument musí být uvnitř projektu: {path}"
        ) from exc


def parse_metadata(text: str) -> dict[str, str]:
    lines = text.splitlines()
    start = None
    end = len(lines)

    for index, line in enumerate(lines):
        if line.strip() == "## Informace o dokumentu":
            start = index + 1
            break
    if start is None:
        raise RuntimeError(
            "Chybí sekce '## Informace o dokumentu'."
        )

    for index in range(start, len(lines)):
        if lines[index].startswith("## ") or lines[index].startswith("# "):
            end = index
            break

    result: dict[str, str] = {}
    for line in lines[start:end]:
        match = TABLE_ROW_RE.match(line.strip())
        if not match:
            continue
        cells = [cell.strip() for cell in match.group(1).split("|")]
        if len(cells) != 2:
            continue
        key, value = cells
        if not key or key.casefold() == "položka":
            continue
        if set(key) <= {"-", ":"}:
            continue
        result[key] = value
    return result


def parse_calendar_token(value: str) -> datetime:
    try:
        return datetime.strptime(value, "%Y%m%d")
    except ValueError as exc:
        raise RuntimeError(
            f"Neplatné kalendářní datum v Document ID: {value}"
        ) from exc


def expected_filename(document_id: str) -> str:
    if document_id.startswith("MM-DL-"):
        return f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"
    if document_id.startswith("MM-NAV-"):
        return f"{document_id}_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
    raise RuntimeError(f"Nepodporovaný Document ID: {document_id}")


def validate_location(
    relative_path: str,
    document_id: str,
) -> None:
    normalized = relative_path.replace("\\", "/")
    if document_id.startswith("MM-DL-"):
        required_parent = "docs/09_HISTORY/DENNÍ_ZÁPISY/"
    else:
        required_parent = "docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/"
    if not normalized.startswith(required_parent):
        raise RuntimeError(
            f"{document_id} je v nesprávné složce. "
            f"Očekáváno: {required_parent}"
        )


def inspect_document(root: Path, path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(path)

    relative_path = relative_to_root(root, path)
    data = path.read_bytes()
    try:
        text = data.decode("utf-8-sig")
    except UnicodeDecodeError as exc:
        raise RuntimeError(
            f"Dokument není platný UTF-8: {path}: {exc}"
        ) from exc

    if PLACEHOLDER_RE.search(text):
        raise RuntimeError(
            f"Dokument obsahuje nevyplněný placeholder: {path.name}"
        )

    metadata = parse_metadata(text)
    document_id = (
        metadata.get("Document ID")
        or metadata.get("Dokument")
        or metadata.get("Označení")
        or ""
    ).strip()
    match = DOCUMENT_ID_RE.fullmatch(document_id)
    if not match:
        raise RuntimeError(
            f"Nepodporovaný nebo neplatný Document ID: "
            f"{document_id!r} v {path.name}"
        )

    date_token = match.group(1) or match.group(2)
    date_value = parse_calendar_token(date_token).date().isoformat()
    sequence = match.group(3)
    if sequence is not None and int(sequence) < 1:
        raise RuntimeError(
            f"Pořadí NAVÁZÁNÍ musí být alespoň 01: {document_id}"
        )

    if path.name != expected_filename(document_id):
        raise RuntimeError(
            f"Název souboru neodpovídá Document ID.\n"
            f"Aktuální : {path.name}\n"
            f"Očekáván : {expected_filename(document_id)}"
        )

    validate_location(relative_path, document_id)

    metadata_date = metadata.get("Datum", "").strip()
    if metadata_date != date_value:
        raise RuntimeError(
            f"Datum v metadatech neodpovídá Document ID "
            f"{document_id}: {metadata_date!r} != {date_value!r}"
        )

    if document_id.startswith("MM-NAV-"):
        metadata_sequence = (
            metadata.get("Pořadí v rámci dne", "").strip()
        )
        if metadata_sequence and metadata_sequence != sequence:
            raise RuntimeError(
                f"Pořadí v metadatech neodpovídá ID: "
                f"{metadata_sequence!r} != {sequence!r}"
            )

    version = metadata.get("Verze", "").strip()
    if not VERSION_RE.fullmatch(version):
        raise RuntimeError(
            f"Neplatná verze dokumentu {document_id}: {version!r}"
        )

    status = metadata.get("Stav", "").strip().upper()
    if status not in {"DRAFT", "REVIEW", "ACTIVE", "APPROVED"}:
        raise RuntimeError(
            f"Nepodporovaný stav dokumentu {document_id}: "
            f"{status!r}"
        )

    title = (
        metadata.get("Název dokumentu")
        or metadata.get("Název")
        or ""
    ).strip()
    if not title:
        raise RuntimeError(
            f"Chybí Název dokumentu: {document_id}"
        )

    document_type = metadata.get("Typ dokumentu", "").strip()
    expected_type = (
        "DAILY_LOG"
        if document_id.startswith("MM-DL-")
        else "CHAT_CONTINUATION"
    )
    if document_type != expected_type:
        raise RuntimeError(
            f"Typ dokumentu neodpovídá ID {document_id}: "
            f"{document_type!r} != {expected_type!r}"
        )

    return {
        "document_id": document_id,
        "source_path": relative_path,
        "selection": "A24_HISTORY_DOCUMENT",
        "selection_reason": "SELECTED_HISTORY_RECORD",
        "classification": "CANONICAL_HISTORY_IMPORT_CANDIDATE",
        "import_eligible": True,
        "blockers": [],
        "warnings": [],
        "title": title,
        "edition": "HISTORY",
        "document_type": document_type,
        "document_date": date_value,
        "daily_sequence": sequence,
        "version_raw": version,
        "version": version,
        "version_note": None,
        "status_raw": status,
        "status": status,
        "sha256": sha256_bytes(data),
        "byte_size": len(data),
        "line_count": len(text.splitlines()),
    }


def manifest_payload(
    root: Path,
    documents: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    generated = utc_now()
    return {
        "manifest_version": MANIFEST_VERSION,
        "manifest_type": "HISTORY_DOCUMENT_INCREMENTAL_IMPORT",
        "generated_at": generated.isoformat(),
        "project_root": str(root),
        "source_of_truth": "HYBRID",
        "selection_policy": {
            "scope": (
                "Datumové denní zápisy a NAVÁZÁNÍ uložené přímo "
                "v docs/09_HISTORY."
            ),
            "daily_logs": "MM-DL-YYYYMMDD",
            "chat_continuations": "MM-NAV-YYYYMMDD-PP",
            "import_mode": "INCREMENTAL_HISTORY",
        },
        "summary": {
            "configured_candidates": len(documents),
            "eligible_candidates": len(documents),
            "candidate_blockers": 0,
            "warnings": sum(
                len(item.get("warnings", []))
                for item in documents
            ),
            "structural_blockers": [],
        },
        "documents": list(documents),
        "superseded_sources": [],
        "excluded_sources": [],
        "final_status": "DOCUMENT_IMPORT_MANIFEST_READY",
    }


def write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
            default=str,
        ),
        encoding="utf-8",
    )


def write_manifest(
    root: Path,
    payload: Mapping[str, Any],
) -> Path:
    reports = root / "reports/documentation"
    reports.mkdir(parents=True, exist_ok=True)
    stamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    timestamped = (
        reports
        / f"history_document_import_manifest_{stamp}.json"
    )
    latest = (
        reports
        / "history_document_import_manifest_latest.json"
    )
    write_json(timestamped, payload)
    write_json(latest, payload)
    return latest


def load_module(path: Path, module_name: str) -> Any:
    if not path.is_file():
        raise FileNotFoundError(path)
    spec = importlib.util.spec_from_file_location(
        module_name,
        path,
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Nelze načíst modul: {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def call_module_main(
    module: Any,
    argv: Sequence[str],
) -> int:
    previous = sys.argv[:]
    try:
        sys.argv = [str(module.__file__), *argv]
        result = module.main()
        return int(result or 0)
    finally:
        sys.argv = previous


def run_a6(
    root: Path,
    manifest_path: Path,
    document_count: int,
    *,
    apply: bool,
    dsn: str | None,
) -> int:
    module = load_module(
        root / "tools/documentation" / A6_NAME,
        "matchmatrix_a6_history_runtime",
    )
    module.EXPECTED_DOCUMENTS = document_count
    module.DOCUMENT_ID_PATTERN = DOCUMENT_ID_ANY_RE

    argv = ["--manifest", str(manifest_path)]
    if apply:
        argv.append("--apply")
    if dsn:
        argv.extend(["--dsn", dsn])
    return call_module_main(module, argv)


def run_a7(
    root: Path,
    manifest_path: Path,
    *,
    dsn: str | None,
) -> int:
    module = load_module(
        root / "tools/documentation" / A7_NAME,
        "matchmatrix_a7_history_runtime",
    )
    module.DOCUMENT_ID_PATTERN = DOCUMENT_ID_ANY_RE

    argv = ["--mode", "incremental", "--manifest", str(manifest_path)]
    if dsn:
        argv.extend(["--dsn", dsn])
    return call_module_main(module, argv)


def write_pipeline_report(
    root: Path,
    payload: Mapping[str, Any],
) -> Path:
    reports = root / "reports/documentation"
    reports.mkdir(parents=True, exist_ok=True)
    stamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    timestamped = (
        reports
        / f"history_document_database_pipeline_{stamp}.json"
    )
    latest = (
        reports
        / "history_document_database_pipeline_latest.json"
    )
    write_json(timestamped, payload)
    write_json(latest, payload)
    return timestamped


def main() -> int:
    args = parse_args()
    root = project_root()
    started = utc_now()
    mode = (
        "VALIDATE_ONLY"
        if args.validate_only
        else ("APPLY" if args.apply else "DRY_RUN")
    )

    print("MATCHMATRIX HISTORY DOCUMENT DATABASE IMPORT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print(f"MODE               : {mode}")
    print("A6/A7 SOURCE WRITE : DISABLED")
    print()

    report: dict[str, Any] = {
        "engine_version": ENGINE_VERSION,
        "started_at": started.isoformat(),
        "mode": mode,
        "project_root": str(root),
        "final_status": "STARTING",
    }

    try:
        if args.apply and args.allow_dirty:
            raise RuntimeError(
                "--allow-dirty nelze použít společně s --apply."
            )

        git = git_state(root)
        report["git"] = git
        print("GIT")
        print("-" * 79)
        print(f"BRANCH             : {git['branch']}")
        print(f"COMMIT             : {git['commit']}")
        print(f"DIRTY              : {git['dirty']}")
        if git["dirty"]:
            for line in git["dirty_lines"][:30]:
                print(f"  {line}")
        print()

        if not git["commit"]:
            raise RuntimeError("Projekt nemá dostupný Git commit.")
        if git["dirty"] and not args.allow_dirty:
            raise RuntimeError(
                "Git strom není čistý. Nejprve commitni a pushni "
                "dokumenty a skripty, nebo pro DRY_RUN použij "
                "--allow-dirty."
            )
        if args.apply and git["dirty"]:
            raise RuntimeError(
                "APPLY vyžaduje čistý Git strom."
            )

        requested = (
            [Path(value) for value in args.documents]
            if args.documents
            else list(DEFAULT_DOCUMENTS)
        )
        paths = [resolve_path(root, value) for value in requested]
        documents = [inspect_document(root, path) for path in paths]

        ids = [item["document_id"] for item in documents]
        if len(ids) != len(set(ids)):
            raise RuntimeError(
                "Seznam obsahuje duplicitní Document ID."
            )

        payload = manifest_payload(root, documents)
        manifest_path = write_manifest(root, payload)
        report["manifest_path"] = str(manifest_path)
        report["manifest_sha256"] = sha256_bytes(
            manifest_path.read_bytes()
        )
        report["documents"] = documents

        print("DOKUMENTY")
        print("-" * 79)
        for item in documents:
            print(
                f"{item['document_id']:<22} | "
                f"{item['version']:<6} | "
                f"{item['status']:<8} | "
                f"{item['source_path']}"
            )
        print()
        print(f"MANIFEST           : {manifest_path}")
        print(f"MANIFEST SHA-256   : {report['manifest_sha256']}")
        print()

        if args.validate_only:
            final_status = FINAL_VALIDATED
            report["final_status"] = final_status
            report["finished_at"] = utc_now().isoformat()
            report_path = write_pipeline_report(root, report)
            print("VALIDACE")
            print("-" * 79)
            print("DOCUMENT IDS       : VALID")
            print("FILENAMES          : VALID")
            print("LOCATIONS          : VALID")
            print("METADATA           : VALID")
            print("CALENDAR DATES     : VALID")
            print("SHA-256            : READY")
            print(f"REPORT             : {report_path}")
            print(f"FINAL STATUS       : {final_status}")
            return 0

        print("A6 DATABASE IMPORT")
        print("-" * 79)
        a6_code = run_a6(
            root,
            manifest_path,
            len(documents),
            apply=args.apply,
            dsn=args.dsn,
        )
        report["a6_return_code"] = a6_code
        if a6_code != 0:
            raise RuntimeError(
                f"A6 skončil s návratovým kódem {a6_code}."
            )

        if not args.apply:
            final_status = FINAL_DRY_RUN
            report["a7_executed"] = False
        else:
            print()
            print("A7 POST-IMPORT VERIFICATION")
            print("-" * 79)
            a7_code = run_a7(
                root,
                manifest_path,
                dsn=args.dsn,
            )
            report["a7_return_code"] = a7_code
            report["a7_executed"] = True
            if a7_code != 0:
                raise RuntimeError(
                    f"A7 ověření skončilo s kódem {a7_code}."
                )
            final_status = FINAL_APPLIED

        report["final_status"] = final_status
        report["finished_at"] = utc_now().isoformat()
        report_path = write_pipeline_report(root, report)

        print()
        print("VÝSLEDEK")
        print("-" * 79)
        print(f"DOCUMENTS          : {len(documents)}")
        print(f"DB APPLY           : {args.apply}")
        print(f"A7 VERIFIED        : {bool(args.apply)}")
        print("A6 MODIFIED        : False")
        print("A7 MODIFIED        : False")
        print(f"REPORT             : {report_path}")
        print(f"FINAL STATUS       : {final_status}")
        return 0

    except Exception as exc:
        report["error"] = {
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        }
        report["final_status"] = FINAL_BLOCKED
        report["finished_at"] = utc_now().isoformat()
        try:
            report_path = write_pipeline_report(root, report)
        except Exception:
            report_path = None

        print("HISTORY DOCUMENT IMPORT ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        if report_path:
            print(f"REPORT             : {report_path}")
        print(f"FINAL STATUS       : {FINAL_BLOCKED}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
