#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví deterministický importní manifest kanonické dokumentace MatchMatrix.

K ČEMU:
- vybere přesně 21 schválených kandidátů prvního importu,
- ověří cestu, Document ID, verzi, stav, titul a UTF-8,
- vypočítá SHA-256 a technické parametry zdrojového souboru,
- označí deset starších dokumentů jako SUPERSEDED_SOURCE,
- vyloučí dva provozní záznamy a dvě historické šablony jako nekanonické zdroje,
- vytvoří JSON a CSV podklad pro následný databázový importer.

KDE:
tools/documentation/25_1_A_5_BUILD_DOCUMENT_IMPORT_MANIFEST_V1.py

JAK:
    py -3.14 .\\tools\\documentation\\25_1_A_5_BUILD_DOCUMENT_IMPORT_MANIFEST_V1.py

Skript zdrojové dokumenty nemění. Výstupy zapisuje do:
    reports/documentation/
"""

from __future__ import annotations

import csv
import hashlib
import json
import re
import sys
import unicodedata
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


MANIFEST_VERSION = "1.1"
EXPECTED_CANDIDATE_COUNT = 21
EXPECTED_SUPERSEDED_COUNT = 10
EXPECTED_EXCLUDED_COUNT = 4


@dataclass(frozen=True)
class CandidateSpec:
    document_id: str
    relative_path: str
    selection_reason: str


@dataclass(frozen=True)
class SupersededSpec:
    relative_path: str
    canonical_document_id: str
    canonical_relative_path: str
    expected_legacy_document_id: str


@dataclass(frozen=True)
class ExcludedSpec:
    relative_path: str
    classification: str
    reason: str


CANDIDATES = (
    CandidateSpec(
        "MM-DOC-000",
        "docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-100",
        "docs/01_MASTER/MM-DOC-100_MATCHMATRIX_MASTER_TECH_REVIEW_v1.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-200",
        "docs/02_GOVERNANCE/MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-300",
        "docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-800",
        "docs/08_DEVELOPMENT/MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-900",
        "docs/09_HISTORY/MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-901",
        "docs/09_HISTORY/MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-902",
        "docs/09_HISTORY/MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-903",
        "docs/09_HISTORY/MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH_REVIEW.md",
        "SELECTED_REVIEW",
    ),
    CandidateSpec(
        "MM-DOC-1000",
        "docs/10_REFERENCE/MM-DOC-1000_MATCHMATRIX_DOCUMENT_INDEX_TECH.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-REF-001",
        "docs/10_REFERENCE/MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-1000",
        "docs/10_REFERENCE/MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-001",
        "docs/12_STANDARD/MM-STD-001_STANDARD_TVORBY_HLAVNÍCH_DOKUMENTŮ.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-002",
        "docs/12_STANDARD/MM-STD-002_STANDARD_TVORBY_ROZSÁHLÝCH_DOKUMENTŮ.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-003",
        "docs/12_STANDARD/MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-004",
        "docs/12_STANDARD/MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-005",
        "docs/12_STANDARD/MM-STD-005_STANDARD_VIZUÁLNÍ_IDENTITY_DOKUMENTACE.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-006",
        "docs/12_STANDARD/MM-STD-006_STANDARD_TERMINOLOGIE_A_SLOVNIKU_POJMU.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-007",
        "docs/12_STANDARD/MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-008",
        "docs/12_STANDARD/MM-STD-008_SPRAVA_TERMINOLOGIE_A_REFERENCNIHO_SLOVNIKU.md",
        "SELECTED_SINGLE",
    ),
    CandidateSpec(
        "MM-STD-009",
        "docs/12_STANDARD/MM-STD-009_AI_CONTEXT_A_PROJECT_SNAPSHOT.md",
        "SELECTED_SINGLE",
    ),
)


SUPERSEDED = (
    SupersededSpec(
        "docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md",
        "MM-DOC-000",
        "docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK_TECH_REVIEW.md",
        "MM-DOC-000",
    ),
    SupersededSpec(
        "docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_STANDARD_TECH.md",
        "MM-DOC-000",
        "docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK_TECH_REVIEW.md",
        "MM-DOC-000",
    ),
    SupersededSpec(
        "docs/01_MASTER/MM-DOC-100_MATCHMATRIX_MASTER_TECH.md",
        "MM-DOC-100",
        "docs/01_MASTER/MM-DOC-100_MATCHMATRIX_MASTER_TECH_REVIEW_v1.md",
        "MM-DOC-001",
    ),
    SupersededSpec(
        "docs/02_GOVERNANCE/MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md",
        "MM-DOC-200",
        "docs/02_GOVERNANCE/MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH_REVIEW.md",
        "MM-DOC-002",
    ),
    SupersededSpec(
        "docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md",
        "MM-DOC-300",
        "docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_REVIEW.md",
        "MM-DOC-003",
    ),
    SupersededSpec(
        "docs/08_DEVELOPMENT/MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md",
        "MM-DOC-800",
        "docs/08_DEVELOPMENT/MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH_REVIEW.md",
        "MM-DOC-004",
    ),
    SupersededSpec(
        "docs/09_HISTORY/MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md",
        "MM-DOC-900",
        "docs/09_HISTORY/MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH_REVIEW.md",
        "MM-DOC-005",
    ),
    SupersededSpec(
        "docs/09_HISTORY/MM-DOC-901_MATCHMATRIX_NAVÁZÁNÍ_TECH.md",
        "MM-DOC-901",
        "docs/09_HISTORY/MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH_REVIEW.md",
        "MM-DOC-006",
    ),
    SupersededSpec(
        "docs/09_HISTORY/MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH.md",
        "MM-DOC-902",
        "docs/09_HISTORY/MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH_REVIEW.md",
        "MM-DOC-007",
    ),
    SupersededSpec(
        "docs/09_HISTORY/MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH.md",
        "MM-DOC-903",
        "docs/09_HISTORY/MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH_REVIEW.md",
        "MM-DOC-008",
    ),
)


EXCLUDED = (
    ExcludedSpec(
        "docs/99_ARCHIVE/09_HISTORY/historie 25062026/Denní zápisy/2026-06-29_MATCHMATRIX_DENNI_ZAPIS.md",
        "NON_CANONICAL_OPERATIONAL_RECORD",
        "Konkrétní denní pracovní záznam není hlavním řídicím dokumentem prvního importu.",
    ),
    ExcludedSpec(
        "docs/99_ARCHIVE/09_HISTORY/historie 25062026/Denní zápisy/2026-06-29_MATCHMATRIX_NAVAZANI_PRO_NOVY_CHAT.md",
        "NON_CANONICAL_OPERATIONAL_RECORD",
        "Konkrétní navazovací záznam není hlavním řídicím dokumentem prvního importu.",
    ),
    ExcludedSpec(
        "docs/00_DOCUMENTATION/templates/00_MATCHMATRIX_DOCUMENTATION_STANDARD_v0.9.md",
        "NON_CANONICAL_TEMPLATE_REFERENCE",
        "Historická šablona v0.9 je referenční podklad, nikoli samostatný kanonický dokument.",
    ),
    ExcludedSpec(
        "docs/00_DOCUMENTATION/templates/MM-DOC-000_00_MATCHMATRIX_DOCUMENTATION_STANDARD_v0.9.md",
        "NON_CANONICAL_TEMPLATE_REFERENCE",
        "Alternativně pojmenovaná historická šablona v0.9 je referenční podklad, nikoli samostatný kanonický dokument.",
    ),
)


DOCUMENT_ID_PATTERN = re.compile(r"(?<![A-Z0-9])MM-(?:DOC|STD|REF)-\d{3,4}(?![A-Z0-9])", re.IGNORECASE)
VERSION_PATTERN = re.compile(r"\b\d+(?:\.\d+){1,2}\b")
MARKDOWN_DECORATION_PATTERN = re.compile(r"[`*_]+")


STATUS_MAP = {
    "ACTIVE": "ACTIVE",
    "AKTIVNI": "ACTIVE",
    "REVIEW": "REVIEW",
    "DRAFT": "DRAFT",
    "PRACOVNI": "DRAFT",
    "APPROVED": "APPROVED",
    "SCHVALENO": "APPROVED",
    "ARCHIVED": "ARCHIVED",
    "ARCHIVOVANO": "ARCHIVED",
    "DEPRECATED": "DEPRECATED",
    "ZASTARALE": "DEPRECATED",
    "SUPERSEDED": "SUPERSEDED",
    "NAHRAZENO": "SUPERSEDED",
}


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def normalize_ascii(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    return "".join(character for character in decomposed if not unicodedata.combining(character))


def normalize_key(value: str) -> str:
    value = MARKDOWN_DECORATION_PATTERN.sub("", value)
    value = normalize_ascii(value).strip().lower()
    value = re.sub(r"\s+", " ", value)
    return value


def clean_cell(value: str) -> str:
    value = MARKDOWN_DECORATION_PATTERN.sub("", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def decode_utf8(data: bytes) -> str:
    if data.startswith(b"\xef\xbb\xbf"):
        data = data[3:]
    return data.decode("utf-8")


def extract_metadata_section(text: str) -> str:
    lines = text.splitlines()
    start: int | None = None

    for index, line in enumerate(lines):
        normalized = normalize_ascii(line).lower()
        if "informace o dokumentu" in normalized:
            start = index + 1
            break

    if start is None:
        return "\n".join(lines[:80])

    section: list[str] = []
    for line in lines[start:]:
        stripped = line.strip()
        if stripped.startswith("#") and section:
            break
        if stripped == "---" and section:
            break
        section.append(line)
        if len(section) >= 80:
            break

    return "\n".join(section)


def parse_markdown_table(section: str) -> dict[str, str]:
    metadata: dict[str, str] = {}

    for raw_line in section.splitlines():
        line = raw_line.strip()
        if not (line.startswith("|") and line.endswith("|")):
            continue

        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 2:
            continue

        first = cells[0]
        second = cells[1]
        if not first or not second:
            continue
        if re.fullmatch(r"[:\- ]+", first) or re.fullmatch(r"[:\- ]+", second):
            continue

        key = normalize_key(first)
        value = clean_cell(second)
        if key in {"polozka", "hodnota"}:
            continue
        metadata.setdefault(key, value)

    return metadata


def first_value(metadata: dict[str, str], aliases: tuple[str, ...]) -> str | None:
    for alias in aliases:
        value = metadata.get(normalize_key(alias))
        if value:
            return value
    return None


def extract_inline_value(text: str, label: str) -> str | None:
    pattern = re.compile(
        rf"(?mi)^\s*{re.escape(label)}\s*:\s*(?:\*\*)?([^|\r\n*]+)(?:\*\*)?"
    )
    match = pattern.search(text[:5000])
    return clean_cell(match.group(1)) if match else None


def extract_heading_document_id(text: str) -> str | None:
    for line in text.splitlines()[:30]:
        if not line.lstrip().startswith("#"):
            continue
        match = DOCUMENT_ID_PATTERN.search(line)
        if match:
            return match.group(0).upper()
    return None


def extract_title(text: str, metadata: dict[str, str], document_id: str) -> str | None:
    metadata_title = first_value(metadata, ("Název", "Název dokumentu"))
    if metadata_title:
        return metadata_title

    for line in text.splitlines()[:60]:
        stripped = line.strip()
        if not stripped.startswith("#"):
            continue
        title = stripped.lstrip("#").strip()
        if not title:
            continue
        if title.upper() == document_id.upper():
            continue
        if DOCUMENT_ID_PATTERN.fullmatch(title):
            continue
        return clean_cell(title)

    return None


def normalize_status(raw_status: str | None) -> str | None:
    if not raw_status:
        return None

    candidate = normalize_ascii(raw_status).upper().strip()
    candidate = re.sub(r"[^A-Z]+", "_", candidate).strip("_")

    for token, normalized in STATUS_MAP.items():
        if token in candidate:
            return normalized
    return candidate or None


def parse_version(raw_version: str | None) -> tuple[str | None, str | None]:
    if not raw_version:
        return None, None

    match = VERSION_PATTERN.search(raw_version)
    if not match:
        return None, clean_cell(raw_version)

    version = match.group(0)
    note = (raw_version[: match.start()] + raw_version[match.end() :]).strip()
    note = note.strip(" ()-–—") or None
    return version, note


def filename_document_id(path: Path) -> str | None:
    match = DOCUMENT_ID_PATTERN.search(path.name)
    return match.group(0).upper() if match else None


def inspect_candidate(root: Path, spec: CandidateSpec) -> dict[str, Any]:
    path = root / spec.relative_path
    blockers: list[str] = []
    warnings: list[str] = []

    row: dict[str, Any] = {
        "document_id": spec.document_id,
        "source_path": spec.relative_path,
        "selection_reason": spec.selection_reason,
        "classification": "CANONICAL_IMPORT_CANDIDATE",
        "import_eligible": False,
        "blockers": blockers,
        "warnings": warnings,
    }

    if not path.is_file():
        blockers.append("SOURCE_FILE_MISSING")
        return row

    data = path.read_bytes()
    try:
        text = decode_utf8(data)
    except UnicodeDecodeError as exc:
        blockers.append(f"INVALID_UTF8:{exc.start}")
        return row

    metadata = parse_markdown_table(extract_metadata_section(text))
    filename_id = filename_document_id(path)
    heading_id = extract_heading_document_id(text)
    metadata_id_raw = first_value(metadata, ("Dokument", "Označení", "ID dokumentu"))
    metadata_id_match = DOCUMENT_ID_PATTERN.search(metadata_id_raw or "")
    metadata_id = metadata_id_match.group(0).upper() if metadata_id_match else None

    raw_version = first_value(metadata, ("Verze",)) or extract_inline_value(text, "Verze")
    version, version_note = parse_version(raw_version)
    raw_status = first_value(metadata, ("Stav",)) or extract_inline_value(text, "Stav")
    status = normalize_status(raw_status)
    title = extract_title(text, metadata, spec.document_id)
    edition = first_value(metadata, ("Edice",))

    row.update(
        {
            "filename_document_id": filename_id,
            "heading_document_id": heading_id,
            "metadata_document_id": metadata_id,
            "title": title,
            "edition": edition,
            "version_raw": raw_version,
            "version": version,
            "version_note": version_note,
            "status_raw": raw_status,
            "status": status,
            "sha256": sha256_bytes(data),
            "byte_size": len(data),
            "line_count": len(text.splitlines()),
        }
    )

    if filename_id != spec.document_id:
        blockers.append("FILENAME_DOCUMENT_ID_MISMATCH")
    if heading_id != spec.document_id:
        blockers.append("HEADING_DOCUMENT_ID_MISMATCH")
    if metadata_id != spec.document_id:
        blockers.append("METADATA_DOCUMENT_ID_MISMATCH")
    if not title:
        blockers.append("TITLE_MISSING")
    if not version:
        blockers.append("VERSION_MISSING_OR_INVALID")
    if not status:
        blockers.append("STATUS_MISSING_OR_INVALID")
    elif status not in {"ACTIVE", "REVIEW", "DRAFT", "APPROVED"}:
        warnings.append(f"UNUSUAL_IMPORT_STATUS:{status}")

    row["import_eligible"] = not blockers
    return row


def inspect_superseded(root: Path, spec: SupersededSpec) -> dict[str, Any]:
    path = root / spec.relative_path
    row: dict[str, Any] = {
        **asdict(spec),
        "classification": "SUPERSEDED_SOURCE",
        "import_eligible": False,
        "exists": path.is_file(),
        "reason": "Starší nerevidovaná varianta byla nahrazena vybraným REVIEW dokumentem.",
        "warnings": [],
    }

    if not path.is_file():
        row["warnings"].append("SUPERSEDED_SOURCE_NOT_PRESENT")
        return row

    data = path.read_bytes()
    row["sha256"] = sha256_bytes(data)
    row["byte_size"] = len(data)

    try:
        text = decode_utf8(data)
        metadata = parse_markdown_table(extract_metadata_section(text))
        metadata_id_raw = first_value(metadata, ("Dokument", "Označení", "ID dokumentu"))
        metadata_match = DOCUMENT_ID_PATTERN.search(metadata_id_raw or "")
        metadata_id = metadata_match.group(0).upper() if metadata_match else None
        heading_id = extract_heading_document_id(text)
        row["metadata_document_id"] = metadata_id
        row["heading_document_id"] = heading_id
        if spec.expected_legacy_document_id not in {metadata_id, heading_id}:
            row["warnings"].append("EXPECTED_LEGACY_ID_NOT_CONFIRMED")
    except UnicodeDecodeError:
        row["warnings"].append("INVALID_UTF8_IN_SUPERSEDED_SOURCE")

    return row


def inspect_excluded(root: Path, spec: ExcludedSpec) -> dict[str, Any]:
    path = root / spec.relative_path
    row: dict[str, Any] = {
        **asdict(spec),
        "import_eligible": False,
        "exists": path.is_file(),
        "warnings": [],
    }

    if path.is_file():
        data = path.read_bytes()
        row["sha256"] = sha256_bytes(data)
        row["byte_size"] = len(data)
    else:
        row["warnings"].append("EXCLUDED_SOURCE_NOT_PRESENT")

    return row


def validate_duplicate_ids(documents: list[dict[str, Any]]) -> None:
    counts: dict[str, int] = {}
    for document in documents:
        document_id = str(document["document_id"])
        counts[document_id] = counts.get(document_id, 0) + 1

    duplicates = {document_id for document_id, count in counts.items() if count > 1}
    if not duplicates:
        return

    for document in documents:
        if document["document_id"] in duplicates:
            document["blockers"].append("DUPLICATE_CANONICAL_DOCUMENT_ID")
            document["import_eligible"] = False


def write_csv(path: Path, documents: list[dict[str, Any]]) -> None:
    fieldnames = [
        "document_id",
        "title",
        "edition",
        "version",
        "version_note",
        "status",
        "source_path",
        "selection_reason",
        "classification",
        "sha256",
        "byte_size",
        "line_count",
        "import_eligible",
        "blockers",
        "warnings",
    ]

    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for document in documents:
            row = dict(document)
            row["blockers"] = ";".join(document.get("blockers", []))
            row["warnings"] = ";".join(document.get("warnings", []))
            writer.writerow(row)


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def main() -> int:
    root = project_root()
    generated_at = utc_now()

    documents = [inspect_candidate(root, spec) for spec in CANDIDATES]
    validate_duplicate_ids(documents)
    superseded = [inspect_superseded(root, spec) for spec in SUPERSEDED]
    excluded = [inspect_excluded(root, spec) for spec in EXCLUDED]

    eligible_count = sum(1 for document in documents if document["import_eligible"])
    blocker_count = sum(len(document.get("blockers", [])) for document in documents)
    warning_count = (
        sum(len(document.get("warnings", [])) for document in documents)
        + sum(len(item.get("warnings", [])) for item in superseded)
        + sum(len(item.get("warnings", [])) for item in excluded)
    )

    structural_blockers: list[str] = []
    if len(CANDIDATES) != EXPECTED_CANDIDATE_COUNT:
        structural_blockers.append("INVALID_CONFIGURED_CANDIDATE_COUNT")
    if len(SUPERSEDED) != EXPECTED_SUPERSEDED_COUNT:
        structural_blockers.append("INVALID_CONFIGURED_SUPERSEDED_COUNT")
    if len(EXCLUDED) != EXPECTED_EXCLUDED_COUNT:
        structural_blockers.append("INVALID_CONFIGURED_EXCLUDED_COUNT")

    ready = (
        not structural_blockers
        and blocker_count == 0
        and eligible_count == EXPECTED_CANDIDATE_COUNT
    )
    final_status = (
        "DOCUMENT_IMPORT_MANIFEST_READY"
        if ready
        else "DOCUMENT_IMPORT_MANIFEST_BLOCKED"
    )

    payload: dict[str, Any] = {
        "manifest_version": MANIFEST_VERSION,
        "generated_at": generated_at.isoformat(),
        "project_root": str(root),
        "source_of_truth": "HYBRID",
        "selection_policy": {
            "canonical_candidates": "Výslovně vybraných 21 aktivních nebo REVIEW dokumentů.",
            "superseded_sources": "Starší nerevidované varianty se neimportují jako samostatné kanonické dokumenty.",
            "operational_records": "Konkrétní denní a navazovací záznamy nejsou součástí prvního kanonického importu.",
            "template_references": "Historické šablony jsou referenční podklady a neimportují se jako samostatné dokumenty.",
        },
        "summary": {
            "configured_candidates": len(CANDIDATES),
            "eligible_candidates": eligible_count,
            "candidate_blockers": blocker_count,
            "warnings": warning_count,
            "superseded_sources": len(superseded),
            "excluded_sources": len(excluded),
            "excluded_operational_records": sum(
                1
                for item in excluded
                if item.get("classification") == "NON_CANONICAL_OPERATIONAL_RECORD"
            ),
            "excluded_template_references": sum(
                1
                for item in excluded
                if item.get("classification") == "NON_CANONICAL_TEMPLATE_REFERENCE"
            ),
            "structural_blockers": structural_blockers,
        },
        "documents": documents,
        "superseded_sources": superseded,
        "excluded_sources": excluded,
        "final_status": final_status,
    }

    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)
    timestamp = generated_at.astimezone().strftime("%Y%m%d_%H%M%S")

    json_path = reports_dir / f"document_import_manifest_{timestamp}.json"
    csv_path = reports_dir / f"document_import_manifest_{timestamp}.csv"
    latest_json_path = reports_dir / "document_import_manifest_latest.json"
    latest_csv_path = reports_dir / "document_import_manifest_latest.csv"

    write_json(json_path, payload)
    write_csv(csv_path, documents)
    write_json(latest_json_path, payload)
    write_csv(latest_csv_path, documents)

    print("MATCHMATRIX DOCUMENT IMPORT MANIFEST")
    print("=" * 79)
    print(f"PROJECT_ROOT                  : {root}")
    print(f"KANDIDÁTŮ KONFIGUROVÁNO      : {len(CANDIDATES)}")
    print(f"KANDIDÁTŮ PŘIPRAVENO         : {eligible_count}")
    print(f"BLOKÁTORŮ KANDIDÁTŮ          : {blocker_count}")
    print(f"STARŠÍCH VARIANT VYLOUČENO   : {len(superseded)}")
    print(f"NEKANONICKÝCH ZDROJŮ VYLOUČENO: {len(excluded)}")
    print(f"VAROVÁNÍ                     : {warning_count}")
    print()

    blocked_documents = [document for document in documents if not document["import_eligible"]]
    if blocked_documents:
        print("BLOKOVANÍ KANDIDÁTI")
        print("-" * 79)
        for document in blocked_documents:
            blockers = ", ".join(document.get("blockers", [])) or "UNKNOWN"
            print(f"{document['document_id']:<15} | {blockers:<40} | {document['source_path']}")
        print()

    print("KANDIDÁTI PRO IMPORT")
    print("-" * 79)
    for document in documents:
        state = "READY" if document["import_eligible"] else "BLOCKED"
        print(
            f"{document['document_id']:<15} | "
            f"{str(document.get('version') or '-'):<8} | "
            f"{str(document.get('status') or '-'):<10} | "
            f"{state:<7} | {document['source_path']}"
        )

    print()
    print(f"JSON MANIFEST       : {json_path}")
    print(f"CSV MANIFEST        : {csv_path}")
    print(f"LATEST JSON         : {latest_json_path}")
    print(f"LATEST CSV          : {latest_csv_path}")
    print(f"FINAL STATUS        : {final_status}")

    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
