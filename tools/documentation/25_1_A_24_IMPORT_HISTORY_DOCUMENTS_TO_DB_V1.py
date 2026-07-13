#!/usr/bin/env python3
# -*- coding: utf-8 -*-

r"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví přírůstkový databázový manifest pro všechny řízené kanonické
Markdown dokumenty MatchMatrix a bezpečně je importuje do schématu
`documentation`.

K ČEMU:
- podporuje datumové Document ID:
  - `MM-DL-YYYYMMDD`,
  - `MM-NAV-YYYYMMDD-PP`,
  - `MM-PS-YYYYMMDD`,
- podporuje všechny standardní oblastní Document ID:
  - `MM-DOC`, `MM-MST`, `MM-GOV`, `MM-ARC`, `MM-DB`, `MM-PRV`,
  - `MM-LAY`, `MM-OPS`, `MM-DEV`, `MM-HIS`, `MM-REF`, `MM-VIS`,
  - `MM-STD`, `MM-TPL`, `MM-EXP`, `MM-DRF`, `MM-ARCV`,
- podporuje další budoucí prefixy odpovídající formátu
  `MM-<PREFIX>-NNN/NNNN[A]`; pro jejich import vyžaduje bezpečné metadata
  cílového umístění pod `docs` a do databáze je zapisuje jako typ `OTHER`,
- podporuje libovolnou řízenou verzi dokumentu ve formátu `N.N[.N...]`,
- zachovává stejné Document ID pro všechny verze téhož dokumentu,
- ověří umístění, název, metadata, verzi, stav, typ a SHA-256,
- datumové řady navíc ověří kalendářní datum a pořadí NAV,
- každý dokument před manifestem povinně prověří read-only auditem A17,
- vytvoří samostatný přírůstkový manifest,
- použije existující produkční importer A6 bez jeho přepsání,
- v režimu DRY_RUN provede databázovou transakci s rollbackem,
- v režimu APPLY provede import a následně spustí read-only ověření A7,
- chrání před importem z necommitnutého nebo nečistého Git stromu,
- databázový zápis je povolen pouze explicitním přepínačem `--apply`.

KDE:
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py

JAK:
Pouze validace jednoho nebo více dokumentů:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py `
      --document "docs/00_DOCUMENTATION/MM-DOC-001_....md" `
      --validate-only

Bezpečný databázový dry run s rollbackem:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py `
      --document "docs/00_DOCUMENTATION/MM-DOC-001_....md"

Skutečný import a následné ověření A7:
    py -3.14 .\tools\documentation\25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py `
      --document "docs/00_DOCUMENTATION/MM-DOC-001_....md" `
      --apply

Volitelné PostgreSQL DSN:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Povolení nečistého Git stromu je možné pouze pro VALIDATE_ONLY nebo DRY_RUN:
    --allow-dirty

Bez parametru `--document` zůstává zachována historická zpětná kompatibilita
se dvěma výchozími dokumenty 2026-06-30.

BEZPEČNOST:
- A6, A7 ani A17 nepřepisuje,
- při APPLY vyžaduje čistý Git strom a existující commit,
- při APPLY nepovolí `--allow-dirty`,
- dokument musí být uvnitř projektového kořene a pod `docs`,
- před importem ověří hash všech zdrojových souborů,
- u všech dokumentů vyžaduje úspěšný A17 bez FAIL a PARTIAL,
- MANUAL_REVIEW je povolen pouze se závažností MEDIUM, LOW nebo INFO,
- známé prefixy musí být v předepsané dokumentační oblasti,
- budoucí neznámé prefixy musí mít ověřitelné cílové umístění pod `docs`,
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

POZNÁMKA KE KOMPATIBILITĚ:
Názvy reportů a finální stavové kódy zůstávají zachovány, aby nebyly
rozbity návaznosti panelu Q3.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import traceback
import unicodedata
from datetime import date, datetime, timezone
from pathlib import Path, PureWindowsPath
from typing import Any, Mapping, Sequence


ENGINE_VERSION = "A24_CANONICAL_DOCUMENT_DATABASE_IMPORT_V1_3_UNIVERSAL_IDS"
MANIFEST_VERSION = "1.2"

# Stavové kódy jsou záměrně zachovány kvůli kompatibilitě panelu Q3.
FINAL_VALIDATED = "HISTORY_DOCUMENT_IMPORT_VALIDATED"
FINAL_DRY_RUN = "HISTORY_DOCUMENT_IMPORT_DRY_RUN_READY"
FINAL_APPLIED = "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED"
FINAL_APPLIED_VERIFICATION_FAILED = (
    "HISTORY_DOCUMENT_IMPORT_APPLIED_VERIFICATION_FAILED"
)
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
A17_NAME = "25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py"

CANONICAL_PREFIX_DIRS: dict[str, tuple[str, ...]] = {
    "MM-DOC": ("docs", "00_DOCUMENTATION"),
    "MM-MST": ("docs", "01_MASTER"),
    "MM-GOV": ("docs", "02_GOVERNANCE"),
    "MM-ARC": ("docs", "03_ARCHITECTURE"),
    "MM-DB": ("docs", "04_DATABASE"),
    "MM-PRV": ("docs", "05_PROVIDERS"),
    "MM-LAY": ("docs", "06_LAYERS"),
    "MM-OPS": ("docs", "07_OPERATOR"),
    "MM-DEV": ("docs", "08_DEVELOPMENT"),
    "MM-HIS": ("docs", "09_HISTORY"),
    "MM-REF": ("docs", "10_REFERENCE"),
    "MM-VIS": ("docs", "11_VISUAL"),
    "MM-STD": ("docs", "12_STANDARD"),
    "MM-TPL": ("docs", "13_TEMPLATES"),
    "MM-EXP": ("docs", "14_EXPORT"),
    "MM-DRF": ("docs", "15_DRAFT"),
    "MM-ARCV": ("docs", "99_ARCHIVE"),
}

SPECIAL_PREFIX_DIRS: dict[str, tuple[str, ...]] = {
    "MM-DL": ("docs", "09_HISTORY", "DENNÍ_ZÁPISY"),
    "MM-NAV": ("docs", "09_HISTORY", "NAVÁZÁNÍ_NA_CHAT"),
    "MM-PS": ("docs", "09_HISTORY", "PROJECT_SNAPSHOTS"),
}

DB_DOCUMENT_TYPES = {
    "DOC",
    "STD",
    "REF",
    "BOOK",
    "MST",
    "GOV",
    "ARC",
    "DB",
    "PRV",
    "LAY",
    "OPS",
    "DEV",
    "HIS",
    "VIS",
    "TPL",
    "EXP",
    "DRF",
    "ARCV",
    "DL",
    "NAV",
    "PS",
    "OTHER",
}

DOCUMENT_ID_RE = re.compile(
    r"^(?:"
    r"MM-DL-\d{8}"
    r"|MM-NAV-\d{8}-\d{2}"
    r"|MM-PS-\d{8}"
    r"|MM-[A-Z]{2,10}-\d{3,4}[A-Z]?"
    r")$",
    re.IGNORECASE,
)
DOCUMENT_ID_ANY_RE = re.compile(
    r"(?<![A-Z0-9])(?:"
    r"MM-DL-\d{8}"
    r"|MM-NAV-\d{8}-\d{2}"
    r"|MM-PS-\d{8}"
    r"|MM-[A-Z]{2,10}-\d{3,4}[A-Z]?"
    r")(?![A-Z0-9])",
    re.IGNORECASE,
)
VERSION_RE = re.compile(r"^\d+(?:\.\d+)*$")
TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
PLACEHOLDER_RE = re.compile(
    r"(?:"
    r"\[(?:DOPLNIT UŽIVATELEM|DOPLNIT UZIVATELEM)[^\]]*\]"
    r"|\{\{(?!NAZEV_PROMENNE\}\})[^{}]+\}\}"
    r")",
    re.IGNORECASE,
)

SUPPORTED_STATUSES = {
    "DRAFT",
    "IN_PROGRESS",
    "REVIEW",
    "APPROVED",
    "ACTIVE",
    "DEPRECATED",
    "ARCHIVED",
    "CANCELLED",
}


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validuje a importuje všechny řízené kanonické Markdown "
            "dokumenty MatchMatrix."
        )
    )
    parser.add_argument(
        "--document",
        action="append",
        dest="documents",
        help=(
            "Relativní nebo absolutní cesta ke kanonickému Markdown dokumentu. "
            "Lze zadat opakovaně. Podporovány jsou datumové řady i všechny "
            "oblastní Document ID MatchMatrix."
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
            "Povolí nečistý Git strom pouze pro VALIDATE_ONLY nebo DRY_RUN. "
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


def normalize_label(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", str(value or ""))
    without_marks = "".join(
        char
        for char in decomposed
        if not unicodedata.combining(char)
    )
    return re.sub(
        r"\s+",
        " ",
        re.sub(r"[^a-z0-9]+", " ", without_marks.casefold()),
    ).strip()


def metadata_value(
    metadata: Mapping[str, str],
    *aliases: str,
) -> str:
    normalized = {
        normalize_label(key): str(value or "").strip()
        for key, value in metadata.items()
    }
    for alias in aliases:
        value = normalized.get(normalize_label(alias))
        if value is not None:
            return value.strip().strip("`")
    return ""


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
    start: int | None = None
    heading_level: int | None = None
    end = len(lines)

    for index, line in enumerate(lines):
        match = HEADING_RE.match(line.strip())
        if not match:
            continue
        if normalize_label(match.group(2)) == "informace o dokumentu":
            start = index + 1
            heading_level = len(match.group(1))
            break

    if start is None or heading_level is None:
        raise RuntimeError(
            "Chybí sekce 'Informace o dokumentu'."
        )

    for index in range(start, len(lines)):
        match = HEADING_RE.match(lines[index].strip())
        if match and len(match.group(1)) <= heading_level:
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
        if not key or normalize_label(key) == "polozka":
            continue
        if set(key) <= {"-", ":"}:
            continue
        result[key] = value
    return result


def parse_calendar_token(value: str) -> date:
    try:
        return datetime.strptime(value, "%Y%m%d").date()
    except ValueError as exc:
        raise RuntimeError(
            f"Neplatné kalendářní datum v Document ID: {value}"
        ) from exc


def parse_iso_date(value: str, label: str) -> str | None:
    raw = str(value or "").strip().strip("`")
    if not raw:
        return None
    try:
        return date.fromisoformat(raw).isoformat()
    except ValueError as exc:
        raise RuntimeError(
            f"{label} musí být ve formátu YYYY-MM-DD: {raw!r}"
        ) from exc


def document_prefix(document_id: str) -> str:
    normalized = document_id.upper()
    for prefix in SPECIAL_PREFIX_DIRS:
        if normalized.startswith(prefix + "-"):
            return prefix
    match = re.fullmatch(
        r"MM-([A-Z]{2,10})-\d{3,4}[A-Z]?",
        normalized,
    )
    if not match:
        raise RuntimeError(
            f"Nelze určit prefix Document ID: {document_id}"
        )
    return f"MM-{match.group(1)}"


def document_identity(document_id: str) -> dict[str, Any]:
    normalized = str(document_id or "").strip().strip("`").upper()
    if not DOCUMENT_ID_RE.fullmatch(normalized):
        raise RuntimeError(
            f"Nepodporovaný nebo neplatný Document ID: {normalized!r}"
        )

    date_token: str | None = None
    sequence: str | None = None

    daily = re.fullmatch(r"MM-DL-(\d{8})", normalized)
    continuation = re.fullmatch(
        r"MM-NAV-(\d{8})-(\d{2})",
        normalized,
    )
    snapshot = re.fullmatch(r"MM-PS-(\d{8})", normalized)

    if daily:
        prefix = "MM-DL"
        date_token = daily.group(1)
        a17_type = "DAILY_LOG"
    elif continuation:
        prefix = "MM-NAV"
        date_token = continuation.group(1)
        sequence = continuation.group(2)
        if int(sequence) < 1:
            raise RuntimeError(
                f"Pořadí NAVÁZÁNÍ musí být alespoň 01: {normalized}"
            )
        a17_type = "CHAT_CONTINUATION"
    elif snapshot:
        prefix = "MM-PS"
        date_token = snapshot.group(1)
        a17_type = "PROJECT_SNAPSHOT"
    else:
        prefix = document_prefix(normalized)
        a17_type = (
            "REFERENCE_DOCUMENT"
            if prefix == "MM-REF"
            else "MAIN_DOCUMENT"
        )

    type_code = prefix.removeprefix("MM-")
    db_document_type = (
        type_code if type_code in DB_DOCUMENT_TYPES else "OTHER"
    )

    return {
        "document_id": normalized,
        "prefix": prefix,
        "type_code": type_code,
        "db_document_type": db_document_type,
        "a17_document_type": a17_type,
        "date_token": date_token,
        "daily_sequence": sequence,
        "is_date_based": date_token is not None,
    }


def expected_filename_description(document_id: str) -> str:
    if document_id.startswith("MM-DL-"):
        return f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"
    if document_id.startswith("MM-NAV-"):
        return f"{document_id}_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
    if document_id.startswith("MM-PS-"):
        return (
            f"{document_id}_MATCHMATRIX_PROJECT_SNAPSHOT.md nebo "
            f"{document_id}_MATCHMATRIX_PROJECT_SNAPSHOT_<POPIS>.md"
        )
    return f"{document_id}_<STANDARDIZOVANY_NAZEV>.md"


def validate_filename(filename: str, document_id: str) -> None:
    if Path(filename).suffix.casefold() != ".md":
        valid = False
    elif document_id.startswith("MM-DL-"):
        valid = filename == f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"
    elif document_id.startswith("MM-NAV-"):
        valid = filename == f"{document_id}_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
    elif document_id.startswith("MM-PS-"):
        valid = re.fullmatch(
            re.escape(document_id)
            + r"_MATCHMATRIX_PROJECT_SNAPSHOT"
            + r"(?:_[A-Z0-9_ÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]+)?\.md",
            filename,
            re.IGNORECASE,
        ) is not None
    else:
        stem_upper = Path(filename).stem.upper()
        valid = (
            stem_upper == document_id
            or stem_upper.startswith(document_id + "_")
        )

    if not valid:
        raise RuntimeError(
            "Název souboru neodpovídá Document ID.\n"
            f"Aktuální : {filename}\n"
            f"Očekáván : {expected_filename_description(document_id)}"
        )


def normalize_relative_path(value: str) -> str:
    return str(value or "").replace("\\", "/").strip().strip("/")


def path_is_under(relative_path: str, required_path: str) -> bool:
    actual = normalize_relative_path(relative_path).casefold()
    required = normalize_relative_path(required_path).casefold()
    return actual == required or actual.startswith(required + "/")


def target_location_from_metadata(
    root: Path,
    metadata: Mapping[str, str],
) -> tuple[str | None, bool]:
    raw = metadata_value(
        metadata,
        "Cílové umístění",
        "Doporučené umístění",
        "Umístění",
        "Cilove umisteni",
        "Doporucene umisteni",
    )
    if not raw:
        return None, False

    cleaned = raw.strip().strip("`").replace("\\", "/")
    lowered = cleaned.casefold()
    docs_position = lowered.find("docs/")
    if lowered == "docs":
        relative = "docs"
    elif docs_position >= 0:
        relative = cleaned[docs_position:]
    else:
        # PureWindowsPath bezpečně zpracuje i cestu C:\...
        windows_parts = list(PureWindowsPath(raw.strip().strip("`")).parts)
        docs_indexes = [
            index
            for index, part in enumerate(windows_parts)
            if str(part).casefold() == "docs"
        ]
        if not docs_indexes:
            raise RuntimeError(
                "Metadata cílového umístění musí mířit pod složku docs: "
                f"{raw}"
            )
        relative = "/".join(windows_parts[docs_indexes[0]:])

    relative = normalize_relative_path(relative)
    if not path_is_under(relative, "docs"):
        raise RuntimeError(
            "Metadata cílového umístění míří mimo povolený kořen docs: "
            f"{raw}"
        )

    is_file = Path(relative).suffix.casefold() in {
        ".md",
        ".markdown",
        ".txt",
    }
    return relative, is_file


def validate_location(
    root: Path,
    relative_path: str,
    identity: Mapping[str, Any],
    metadata: Mapping[str, str],
) -> str:
    normalized = normalize_relative_path(relative_path)
    if not path_is_under(normalized, "docs"):
        raise RuntimeError(
            f"Dokument musí být uložen pod docs: {relative_path}"
        )

    prefix = str(identity["prefix"])
    route_parts = (
        SPECIAL_PREFIX_DIRS.get(prefix)
        or CANONICAL_PREFIX_DIRS.get(prefix)
    )

    if route_parts:
        required_parent = "/".join(route_parts)
        parent_path = normalize_relative_path(
            str(Path(normalized).parent).replace("\\", "/")
        )
        if not path_is_under(parent_path, required_parent):
            raise RuntimeError(
                f"{identity['document_id']} je v nesprávné složce. "
                f"Očekáváno pod: {required_parent}/"
            )
        return "PREFIX_REGISTRY"

    target, target_is_file = target_location_from_metadata(root, metadata)
    if not target:
        raise RuntimeError(
            f"Pro budoucí prefix {prefix!r} není definována kanonická složka. "
            "Doplň prefix do registru A24 nebo do metadat dokumentu uveď "
            "bezpečné Cílové umístění pod docs."
        )

    if target_is_file:
        if normalized.casefold() != target.casefold():
            raise RuntimeError(
                "Skutečná cesta dokumentu neodpovídá metadatu "
                f"Cílové umístění: {normalized!r} != {target!r}"
            )
    else:
        parent_path = normalize_relative_path(
            str(Path(normalized).parent).replace("\\", "/")
        )
        if not path_is_under(parent_path, target):
            raise RuntimeError(
                "Dokument neleží v oblasti určené metadatem "
                f"Cílové umístění: {target}"
            )
    return "DOCUMENT_METADATA"


def normalize_edition(
    raw_edition: str,
    identity: Mapping[str, Any],
) -> str:
    normalized = normalize_label(raw_edition)
    type_code = str(identity["type_code"])

    if type_code in {"DL", "NAV", "PS", "HIS", "ARCV"}:
        return "HISTORY"
    if "book" in normalized:
        return "BOOK"
    if "history" in normalized or "histor" in normalized:
        return "HISTORY"
    return "TECH"


def validate_special_metadata_type(
    identity: Mapping[str, Any],
    raw_type: str,
) -> None:
    if not identity["is_date_based"]:
        return
    if not raw_type:
        raise RuntimeError(
            f"Chybí Typ dokumentu pro {identity['document_id']}."
        )

    normalized = normalize_label(raw_type)
    type_code = str(identity["type_code"])

    if type_code == "DL":
        valid = (
            ("daily" in normalized and "log" in normalized)
            or ("denni" in normalized and "zapis" in normalized)
        )
        expected = "DAILY_LOG nebo popis denního zápisu"
    elif type_code == "NAV":
        valid = (
            ("chat" in normalized and "continuation" in normalized)
            or "navazani" in normalized
            or "navazujici" in normalized
        )
        expected = "CHAT_CONTINUATION nebo popis dokumentu NAVÁZÁNÍ"
    else:
        valid = "project" in normalized and "snapshot" in normalized
        expected = "PROJECT_SNAPSHOT nebo popis Project Snapshotu"

    if not valid:
        raise RuntimeError(
            f"Typ dokumentu neodpovídá ID {identity['document_id']}: "
            f"{raw_type!r}. Očekáváno: {expected}."
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

    placeholder_match = PLACEHOLDER_RE.search(text)
    if placeholder_match:
        raise RuntimeError(
            f"Dokument obsahuje nevyplněný placeholder "
            f"{placeholder_match.group(0)!r}: {path.name}"
        )

    metadata = parse_metadata(text)
    document_id = metadata_value(
        metadata,
        "Document ID",
        "Dokument",
        "Označení",
        "ID dokumentu",
    )
    identity = document_identity(document_id)
    document_id = str(identity["document_id"])

    validate_filename(path.name, document_id)
    location_source = validate_location(
        root,
        relative_path,
        identity,
        metadata,
    )

    date_value: str | None = None
    if identity["date_token"]:
        derived_date = parse_calendar_token(
            str(identity["date_token"])
        ).isoformat()
        raw_date = metadata_value(
            metadata,
            "Datum snapshotu",
            "Datum dokumentu",
            "Datum",
        )
        metadata_date = parse_iso_date(
            raw_date,
            "Datum snapshotu / Datum",
        )
        if metadata_date != derived_date:
            raise RuntimeError(
                "Datum v metadatech neodpovídá Document ID "
                f"{document_id}: {metadata_date!r} != {derived_date!r}"
            )
        date_value = derived_date
    else:
        raw_date = metadata_value(
            metadata,
            "Datum dokumentu",
            "Datum",
        )
        date_value = parse_iso_date(raw_date, "Datum")

    sequence = identity["daily_sequence"]
    if sequence is not None:
        metadata_sequence = metadata_value(
            metadata,
            "Pořadí v rámci dne",
            "Poradi v ramci dne",
        )
        if metadata_sequence and metadata_sequence.zfill(2) != sequence:
            raise RuntimeError(
                "Pořadí v metadatech neodpovídá ID: "
                f"{metadata_sequence!r} != {sequence!r}"
            )

    version = metadata_value(
        metadata,
        "Verze",
        "Verze dokumentu",
        "Verze návrhu",
        "Číslo verze",
    )
    if not VERSION_RE.fullmatch(version):
        raise RuntimeError(
            f"Neplatná verze dokumentu {document_id}: {version!r}. "
            "Povolen je formát N.N nebo N.N.N."
        )

    status = metadata_value(metadata, "Stav", "Status").upper()
    if status not in SUPPORTED_STATUSES:
        raise RuntimeError(
            f"Nepodporovaný stav dokumentu {document_id}: {status!r}. "
            f"Povoleno: {', '.join(sorted(SUPPORTED_STATUSES))}."
        )

    title = metadata_value(
        metadata,
        "Název dokumentu",
        "Název",
        "Title",
    )
    if not title:
        raise RuntimeError(
            f"Chybí Název dokumentu: {document_id}"
        )

    raw_document_type = metadata_value(
        metadata,
        "Typ dokumentu",
        "Typ",
        "Charakter dokumentu",
    )
    validate_special_metadata_type(identity, raw_document_type)

    raw_edition = metadata_value(metadata, "Edice", "Edition")
    edition = normalize_edition(raw_edition, identity)

    return {
        "document_id": document_id,
        "source_path": relative_path,
        "selection": "A24_CANONICAL_DOCUMENT",
        "selection_reason": "SELECTED_CANONICAL_RECORD",
        "classification": "CANONICAL_DOCUMENT_IMPORT_CANDIDATE",
        "import_eligible": True,
        "blockers": [],
        "warnings": [],
        "title": title,
        "edition": edition,
        "edition_raw": raw_edition or None,
        "document_type": identity["db_document_type"],
        "document_type_raw": raw_document_type or None,
        "document_family": identity["prefix"],
        "a17_document_type": identity["a17_document_type"],
        "document_date": date_value,
        "daily_sequence": sequence,
        "version_raw": version,
        "version": version,
        "version_note": None,
        "status_raw": status,
        "status": status,
        "canonical_location_source": location_source,
        "sha256": sha256_bytes(data),
        "byte_size": len(data),
        "line_count": len(text.splitlines()),
    }


def validate_document_with_a17(
    root: Path,
    path: Path,
    document_id: str,
    a17_document_type: str,
) -> dict[str, Any]:
    a17_path = root / "tools/documentation" / A17_NAME
    if not a17_path.is_file():
        raise FileNotFoundError(
            f"A17 audit nebyl nalezen: {a17_path}"
        )

    output_dir = (
        root
        / "reports/documentation/standardization/a24_preflight"
        / document_id
    )
    command = [
        sys.executable,
        str(a17_path),
        "--document",
        str(path),
        "--document-type",
        a17_document_type,
        "--output-dir",
        str(output_dir),
    ]
    result = subprocess.run(
        command,
        cwd=root,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"A17 audit dokumentu {document_id} selhal.\n"
            f"STDOUT:\n{result.stdout}\n"
            f"STDERR:\n{result.stderr}"
        )

    report_path = output_dir / "document_compliance_audit_latest.json"
    if not report_path.is_file():
        raise RuntimeError(
            f"A17 nevytvořil očekávaný report: {report_path}"
        )
    payload = json.loads(report_path.read_text(encoding="utf-8"))

    blockers: list[str] = []
    if (
        payload.get("final_status")
        != "DOCUMENT_STANDARD_COMPLIANCE_AUDIT_READY"
    ):
        blockers.append(
            f"final_status={payload.get('final_status')!r}"
        )
    if payload.get("document_type") != a17_document_type:
        blockers.append(
            f"document_type={payload.get('document_type')!r}"
        )

    findings = payload.get("findings") or []
    for finding in findings:
        if not isinstance(finding, dict):
            continue
        result_name = str(finding.get("result") or "").upper()
        severity = str(finding.get("severity") or "").upper()
        rule_id = str(finding.get("rule_id") or "UNKNOWN")
        if result_name in {"FAIL", "PARTIAL"}:
            blockers.append(
                f"{rule_id}:{result_name}/{severity or '-'}"
            )
        elif (
            result_name == "MANUAL_REVIEW"
            and severity in {"CRITICAL", "HIGH"}
        ):
            blockers.append(
                f"{rule_id}:MANUAL_REVIEW/{severity}"
            )

    if blockers:
        raise RuntimeError(
            f"A17 zablokoval {document_id}: "
            + ", ".join(blockers)
        )

    return {
        "report_path": relative_to_root(root, report_path),
        "engine_version": payload.get("engine_version"),
        "requested_document_type": a17_document_type,
        "reported_document_type": payload.get("document_type"),
        "compliance_score_percent": payload.get(
            "compliance_score_percent"
        ),
        "compliance_status": payload.get("compliance_status"),
        "result_counts": payload.get("result_counts") or {},
        "severity_counts": payload.get("severity_counts") or {},
        "manual_review_count": sum(
            1
            for finding in findings
            if isinstance(finding, dict)
            and str(finding.get("result") or "").upper()
            == "MANUAL_REVIEW"
        ),
        "final_status": payload.get("final_status"),
    }


def manifest_payload(
    root: Path,
    documents: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    generated = utc_now()
    return {
        "manifest_version": MANIFEST_VERSION,
        # Zachováno kvůli zpětné kompatibilitě A6/A7.
        "manifest_type": "HISTORY_DOCUMENT_INCREMENTAL_IMPORT",
        "generated_at": generated.isoformat(),
        "project_root": str(root),
        "source_of_truth": "HYBRID",
        "selection_policy": {
            "scope": (
                "Všechny explicitně vybrané řízené kanonické Markdown "
                "dokumenty uložené pod docs."
            ),
            "document_id_formats": [
                "MM-DL-YYYYMMDD",
                "MM-NAV-YYYYMMDD-PP",
                "MM-PS-YYYYMMDD",
                "MM-<PREFIX>-NNN/NNNN[A]",
            ],
            "known_prefix_routes": {
                **{
                    key: "/".join(value)
                    for key, value in CANONICAL_PREFIX_DIRS.items()
                },
                **{
                    key: "/".join(value)
                    for key, value in SPECIAL_PREFIX_DIRS.items()
                },
            },
            "future_prefix_policy": (
                "Bezpečné metadata Cílové umístění pod docs; "
                "DB document_type=OTHER do rozšíření DB constraintu."
            ),
            "import_mode": "INCREMENTAL_CANONICAL",
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
        "matchmatrix_a6_canonical_runtime",
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
        "matchmatrix_a7_canonical_runtime",
    )
    module.DOCUMENT_ID_PATTERN = DOCUMENT_ID_ANY_RE

    argv = [
        "--mode",
        "incremental",
        "--manifest",
        str(manifest_path),
    ]
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

    print("MATCHMATRIX CANONICAL DOCUMENT DATABASE IMPORT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print(f"MODE               : {mode}")
    print("A6/A7/A17 WRITE    : DISABLED")
    print()

    report: dict[str, Any] = {
        "engine_version": ENGINE_VERSION,
        "started_at": started.isoformat(),
        "mode": mode,
        "project_root": str(root),
        "a6_apply_succeeded": False,
        "a7_verified": False,
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
                "dokumenty a skripty, nebo pro VALIDATE_ONLY/DRY_RUN "
                "použij --allow-dirty."
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

        for item, path in zip(documents, paths, strict=True):
            item["standard_compliance"] = validate_document_with_a17(
                root,
                path,
                str(item["document_id"]),
                str(item["a17_document_type"]),
            )

        ids = [str(item["document_id"]) for item in documents]
        if len(ids) != len(set(ids)):
            raise RuntimeError(
                "Seznam obsahuje duplicitní Document ID. "
                "Jedna verze jednoho Document ID se importuje v jednom běhu."
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
                f"{item['version']:<8} | "
                f"{item['status']:<11} | "
                f"{item['document_type']:<5} | "
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
            print("VERSIONS           : VALID")
            print("STATUSES           : VALID")
            print("CALENDAR DATES     : VALID WHEN DATE-BASED")
            print("A17                : VERIFIED FOR ALL DOCUMENTS")
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

        report["a6_apply_succeeded"] = bool(args.apply)

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
            report["a7_verified"] = True
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
        print("A17 MODIFIED       : False")
        print(f"REPORT             : {report_path}")
        print(f"FINAL STATUS       : {final_status}")
        return 0

    except Exception as exc:
        report["error"] = {
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        }
        failure_status = (
            FINAL_APPLIED_VERIFICATION_FAILED
            if report.get("a6_apply_succeeded")
            and not report.get("a7_verified")
            else FINAL_BLOCKED
        )
        report["final_status"] = failure_status
        report["finished_at"] = utc_now().isoformat()
        try:
            report_path = write_pipeline_report(root, report)
        except Exception:
            report_path = None

        print("CANONICAL DOCUMENT IMPORT ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        if report_path:
            print(f"REPORT             : {report_path}")
        print(f"FINAL STATUS       : {failure_status}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
