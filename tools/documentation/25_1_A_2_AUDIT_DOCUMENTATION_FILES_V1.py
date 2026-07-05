# =============================================================================
# MATCHMATRIX
# SOUBOR: 25_1_A_2_AUDIT_DOCUMENTATION_FILES_V1.py
# SEKCE: 25 – DOCUMENTATION MANAGEMENT SYSTEM
# VERZE: V1
# DATUM: 2026-06-30
#
# CO:
# Provádí audit aktivních Markdown dokumentů v Git repozitáři MatchMatrix.
#
# K ČEMU:
# - porovnat Document ID v názvu souboru s ID uvnitř dokumentu,
# - zjistit duplicitní aktivní Document ID,
# - rozlišit původní a REVIEW verze,
# - určit kandidáty pro první databázový import,
# - zabránit importu chybných nebo archivních dokumentů.
#
# KDE:
# C:\MatchMatrix-platform\tools\documentation\
# 25_1_A_2_AUDIT_DOCUMENTATION_FILES_V1.py
#
# JAK:
# C:\Python314\python.exe ^
#   C:\MatchMatrix-platform\tools\documentation\
#   25_1_A_2_AUDIT_DOCUMENTATION_FILES_V1.py
#
# BEZPEČNOST:
# - skript nemění dokumenty,
# - skript nezapisuje do PostgreSQL,
# - skript pouze čte Markdown soubory,
# - výstup ukládá do reports\documentation.
# =============================================================================

from __future__ import annotations

import csv
import json
import re
import sys
import unicodedata
from collections import defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable


from pathlib import Path


def find_project_root() -> Path:
    """
    Najde kořen repozitáře MatchMatrix podle umístění tohoto skriptu.

    Kořen musí obsahovat:
    - složku .git
    - složku docs
    - složku db

    Funguje nezávisle na:
    - PC1 nebo PC2,
    - uživatelském účtu,
    - písmenu disku,
    - konkrétní absolutní cestě projektu.
    """

    script_path = Path(__file__).resolve()

    candidates = (
        script_path.parent,
        *script_path.parents,
    )

    for candidate in candidates:
        if (
            (candidate / ".git").exists()
            and (candidate / "docs").is_dir()
            and (candidate / "db").is_dir()
        ):
            return candidate

    raise RuntimeError(
        "Kořen projektu MatchMatrix nebyl nalezen. "
        "Skript musí být uložen uvnitř Git repozitáře, "
        "který obsahuje složky docs a db."
    )


PROJECT_ROOT = find_project_root()
DOCS_ROOT = PROJECT_ROOT / "docs"
REPORT_ROOT = PROJECT_ROOT / "reports" / "documentation"

EXCLUDED_DIRECTORY_NAMES = {
    "99_ARCHIVE",
    "ARCHIVE",
    "templates",
    "TEMPLATES",
    ".git",
    ".history",
    "__pycache__",
}

DOCUMENT_ID_PATTERN = re.compile(
    r"(?<![A-Z0-9-])"
    r"(MM-[A-Z]{2,10}-(?:[0-9]{8}(?:-[0-9]{2})?|[0-9]{3,4}[A-Z]?))"
    r"(?![A-Z0-9-])",
    re.IGNORECASE,
)

FILENAME_ID_PATTERN = re.compile(
    r"^(MM-[A-Z]{2,10}-(?:[0-9]{8}(?:-[0-9]{2})?|[0-9]{3,4}[A-Z]?))"
    r"(?:_|$)",
    re.IGNORECASE,
)

VERSION_PATTERN = re.compile(
    r"(?<!\d)(\d+(?:\.\d+){0,3})(?!\d)"
)


@dataclass
class DocumentAuditRecord:
    canonical_file_id: str | None
    declared_document_id: str | None
    document_type: str | None
    title: str | None
    version: str | None
    status: str | None
    edition: str | None
    is_review_file: bool
    relative_path: str
    filename: str
    file_size_bytes: int
    modified_at: str
    id_match: bool | None
    selection_status: str
    issues: list[str]


def normalize_text(value: str | None) -> str:
    if value is None:
        return ""

    result = value.strip()

    result = result.replace("`", "")
    result = result.replace("**", "")
    result = result.replace("__", "")
    result = result.replace("*", "")
    result = result.replace("_", " ")

    return " ".join(result.split())


def normalize_key(value: str) -> str:
    value = normalize_text(value).lower()

    value = unicodedata.normalize("NFKD", value)
    value = "".join(
        character
        for character in value
        if not unicodedata.combining(character)
    )

    return value.strip()


def normalize_document_id(value: str | None) -> str | None:
    if not value:
        return None

    match = DOCUMENT_ID_PATTERN.search(value)

    if not match:
        return None

    return match.group(1).upper()


def extract_filename_document_id(filename: str) -> str | None:
    match = FILENAME_ID_PATTERN.match(filename)

    if not match:
        return None

    return match.group(1).upper()


def extract_document_type(document_id: str | None) -> str | None:
    if not document_id:
        return None

    parts = document_id.split("-")

    if len(parts) < 3:
        return None

    return parts[1].upper()


def is_excluded_path(path: Path) -> bool:
    relative_parts = path.relative_to(DOCS_ROOT).parts

    return any(
        part in EXCLUDED_DIRECTORY_NAMES
        for part in relative_parts
    )


def collect_markdown_files() -> list[Path]:
    if not DOCS_ROOT.exists():
        raise FileNotFoundError(
            f"Složka dokumentace neexistuje: {DOCS_ROOT}"
        )

    files: list[Path] = []

    for path in DOCS_ROOT.rglob("*.md"):
        if not path.is_file():
            continue

        if is_excluded_path(path):
            continue

        files.append(path)

    return sorted(
        files,
        key=lambda item: str(item).lower(),
    )


def parse_markdown_table(lines: Iterable[str]) -> dict[str, str]:
    metadata: dict[str, str] = {}

    for line in lines:
        stripped = line.strip()

        if not stripped.startswith("|"):
            continue

        cells = [
            normalize_text(cell)
            for cell in stripped.strip("|").split("|")
        ]

        if len(cells) < 2:
            continue

        key = normalize_key(cells[0])
        value = normalize_text(cells[1])

        if not key or not value:
            continue

        if set(key) <= {"-", ":"}:
            continue

        if set(value) <= {"-", ":"}:
            continue

        if key in {
            "polozka",
            "hodnota",
            "field",
            "value",
        }:
            continue

        metadata.setdefault(key, value)

    return metadata


def first_metadata_value(
    metadata: dict[str, str],
    possible_keys: tuple[str, ...],
) -> str | None:
    for key in possible_keys:
        normalized_key = normalize_key(key)

        if normalized_key in metadata:
            value = normalize_text(metadata[normalized_key])

            if value:
                return value

    return None


def extract_heading_document_ids(lines: list[str]) -> list[str]:
    identifiers: list[str] = []

    for line in lines[:60]:
        stripped = line.strip()

        if not stripped.startswith("#"):
            continue

        match = DOCUMENT_ID_PATTERN.search(stripped)

        if match:
            value = match.group(1).upper()

            if value not in identifiers:
                identifiers.append(value)

    return identifiers


def extract_first_title_heading(
    lines: list[str],
    document_id: str | None,
) -> str | None:
    for line in lines[:100]:
        stripped = line.strip()

        if not stripped.startswith("#"):
            continue

        title = normalize_text(stripped.lstrip("#").strip())

        if not title:
            continue

        if normalize_document_id(title) == document_id:
            continue

        if title.upper() in {
            "TECH EDITION",
            "BOOK EDITION",
            "INFORMACE O DOKUMENTU",
        }:
            continue

        return title

    return None


def parse_version_tuple(value: str | None) -> tuple[int, ...]:
    if not value:
        return tuple()

    match = VERSION_PATTERN.search(value)

    if not match:
        return tuple()

    try:
        return tuple(
            int(part)
            for part in match.group(1).split(".")
        )
    except ValueError:
        return tuple()


def audit_file(path: Path) -> DocumentAuditRecord:
    content = path.read_text(
        encoding="utf-8-sig",
        errors="replace",
    )

    lines = content.splitlines()
    metadata = parse_markdown_table(lines[:150])

    filename_id = extract_filename_document_id(path.name)

    declared_id_value = first_metadata_value(
        metadata,
        (
            "Dokument",
            "Označení",
            "Označení dokumentu",
            "Document ID",
            "ID dokumentu",
        ),
    )

    declared_id = normalize_document_id(declared_id_value)

    heading_ids = extract_heading_document_ids(lines)

    if declared_id is None and heading_ids:
        declared_id = heading_ids[0]

    title = first_metadata_value(
        metadata,
        (
            "Název",
            "Název dokumentu",
            "Document title",
        ),
    )

    if title is None:
        title = extract_first_title_heading(
            lines,
            declared_id or filename_id,
        )

    version = first_metadata_value(
        metadata,
        (
            "Verze",
            "Version",
        ),
    )

    status = first_metadata_value(
        metadata,
        (
            "Stav",
            "Status",
        ),
    )

    if status:
        status = status.upper()

    edition = first_metadata_value(
        metadata,
        (
            "Edice",
            "Edition",
        ),
    )

    issues: list[str] = []

    if filename_id is None:
        issues.append("FILENAME_DOCUMENT_ID_MISSING")

    if declared_id is None:
        issues.append("DECLARED_DOCUMENT_ID_MISSING")

    id_match: bool | None = None

    if filename_id and declared_id:
        id_match = filename_id == declared_id

        if not id_match:
            issues.append(
                f"DOCUMENT_ID_MISMATCH:"
                f"{filename_id}!={declared_id}"
            )

    unique_heading_ids = sorted(set(heading_ids))

    if len(unique_heading_ids) > 1:
        issues.append(
            "MULTIPLE_HEADING_DOCUMENT_IDS:"
            + ",".join(unique_heading_ids)
        )

    if not title:
        issues.append("TITLE_MISSING")

    if not version:
        issues.append("VERSION_MISSING")

    if not status:
        issues.append("STATUS_MISSING")

    relative_path = path.relative_to(PROJECT_ROOT)
    stat = path.stat()

    return DocumentAuditRecord(
        canonical_file_id=filename_id,
        declared_document_id=declared_id,
        document_type=extract_document_type(filename_id),
        title=title,
        version=version,
        status=status,
        edition=edition,
        is_review_file="_REVIEW" in path.stem.upper(),
        relative_path=str(relative_path),
        filename=path.name,
        file_size_bytes=stat.st_size,
        modified_at=datetime.fromtimestamp(
            stat.st_mtime
        ).astimezone().isoformat(timespec="seconds"),
        id_match=id_match,
        selection_status="NOT_EVALUATED",
        issues=issues,
    )


def choose_import_candidates(
    records: list[DocumentAuditRecord],
) -> None:
    grouped: dict[str, list[DocumentAuditRecord]] = defaultdict(list)

    for record in records:
        if record.canonical_file_id:
            grouped[record.canonical_file_id].append(record)
        else:
            record.selection_status = "MANUAL_REVIEW_REQUIRED"

    for document_id, group in grouped.items():
        if len(group) == 1:
            group[0].selection_status = "SELECTED_SINGLE"
            continue

        review_files = [
            record
            for record in group
            if record.is_review_file
        ]

        if len(review_files) == 1:
            selected = review_files[0]
            selected.selection_status = "SELECTED_REVIEW"

            for record in group:
                if record is selected:
                    continue

                record.selection_status = "NOT_SELECTED_OLDER_COPY"
                record.issues.append(
                    f"DUPLICATE_ACTIVE_DOCUMENT_ID:{document_id}"
                )

            continue

        if len(review_files) > 1:
            for record in group:
                record.selection_status = "MANUAL_REVIEW_REQUIRED"
                record.issues.append(
                    f"MULTIPLE_REVIEW_FILES_FOR_ID:{document_id}"
                )

            continue

        versioned_group = sorted(
            group,
            key=lambda record: (
                parse_version_tuple(record.version),
                record.modified_at,
            ),
            reverse=True,
        )

        highest_version = parse_version_tuple(
            versioned_group[0].version
        )

        same_highest = [
            record
            for record in versioned_group
            if parse_version_tuple(record.version) == highest_version
        ]

        if highest_version and len(same_highest) == 1:
            selected = versioned_group[0]
            selected.selection_status = "SELECTED_HIGHEST_VERSION"

            for record in group:
                if record is selected:
                    continue

                record.selection_status = "NOT_SELECTED_OLDER_VERSION"
                record.issues.append(
                    f"DUPLICATE_ACTIVE_DOCUMENT_ID:{document_id}"
                )

            continue

        for record in group:
            record.selection_status = "MANUAL_REVIEW_REQUIRED"
            record.issues.append(
                f"UNRESOLVED_DUPLICATE_DOCUMENT_ID:{document_id}"
            )


def write_csv(
    records: list[DocumentAuditRecord],
    output_path: Path,
) -> None:
    fieldnames = [
        "canonical_file_id",
        "declared_document_id",
        "document_type",
        "title",
        "version",
        "status",
        "edition",
        "is_review_file",
        "relative_path",
        "filename",
        "file_size_bytes",
        "modified_at",
        "id_match",
        "selection_status",
        "issues",
    ]

    with output_path.open(
        "w",
        encoding="utf-8-sig",
        newline="",
    ) as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            delimiter=";",
        )

        writer.writeheader()

        for record in records:
            row = asdict(record)
            row["issues"] = " | ".join(record.issues)
            writer.writerow(row)


def write_json(
    records: list[DocumentAuditRecord],
    output_path: Path,
) -> None:
    payload = {
        "project_root": str(PROJECT_ROOT),
        "docs_root": str(DOCS_ROOT),
        "generated_at": datetime.now()
        .astimezone()
        .isoformat(timespec="seconds"),
        "records": [
            asdict(record)
            for record in records
        ],
    }

    output_path.write_text(
        json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )


def print_summary(
    records: list[DocumentAuditRecord],
    csv_path: Path,
    json_path: Path,
) -> None:
    selected_statuses = {
        "SELECTED_SINGLE",
        "SELECTED_REVIEW",
        "SELECTED_HIGHEST_VERSION",
    }

    selected = [
        record
        for record in records
        if record.selection_status in selected_statuses
    ]

    mismatches = [
        record
        for record in records
        if record.id_match is False
    ]

    manual_review = [
        record
        for record in records
        if record.selection_status == "MANUAL_REVIEW_REQUIRED"
    ]

    active_duplicates = [
        record
        for record in records
        if any(
            issue.startswith(
                (
                    "DUPLICATE_ACTIVE_DOCUMENT_ID",
                    "MULTIPLE_REVIEW_FILES_FOR_ID",
                    "UNRESOLVED_DUPLICATE_DOCUMENT_ID",
                )
            )
            for issue in record.issues
        )
    ]

    print()
    print("=" * 79)
    print("MATCHMATRIX DOCUMENTATION FILE AUDIT")
    print("=" * 79)
    print(f"Markdown souborů nalezeno : {len(records)}")
    print(f"Kandidátů pro import       : {len(selected)}")
    print(f"Neshod Document ID         : {len(mismatches)}")
    print(f"Záznamů s duplicitou       : {len(active_duplicates)}")
    print(f"Ruční kontrola             : {len(manual_review)}")
    print()

    if mismatches:
        print("NESHODY DOCUMENT ID")
        print("-" * 79)

        for record in mismatches:
            print(
                f"{record.canonical_file_id or '-':<15} | "
                f"{record.declared_document_id or '-':<15} | "
                f"{record.relative_path}"
            )

        print()

    if manual_review:
        print("SOUBORY VYŽADUJÍCÍ RUČNÍ ROZHODNUTÍ")
        print("-" * 79)

        for record in manual_review:
            print(
                f"{record.canonical_file_id or '-':<15} | "
                f"{record.selection_status:<24} | "
                f"{record.relative_path}"
            )

        print()

    print("KANDIDÁTI PRO PRVNÍ IMPORT")
    print("-" * 79)

    for record in selected:
        print(
            f"{record.canonical_file_id or '-':<15} | "
            f"{record.version or '-':<8} | "
            f"{record.status or '-':<10} | "
            f"{record.selection_status:<24} | "
            f"{record.relative_path}"
        )

    print()
    print(f"CSV report  : {csv_path}")
    print(f"JSON report : {json_path}")
    print()

    if mismatches or manual_review:
        print("FINAL STATUS: DOCUMENTATION_FILE_REVIEW_REQUIRED")
    else:
        print("FINAL STATUS: DOCUMENTATION_FILES_READY_FOR_IMPORT")

    print("=" * 79)


def main() -> int:
    try:
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(encoding="utf-8")

        REPORT_ROOT.mkdir(
            parents=True,
            exist_ok=True,
        )

        markdown_files = collect_markdown_files()

        records = [
            audit_file(path)
            for path in markdown_files
        ]

        choose_import_candidates(records)

        timestamp = datetime.now().strftime(
            "%Y%m%d_%H%M%S"
        )

        csv_path = (
            REPORT_ROOT
            / f"documentation_file_audit_{timestamp}.csv"
        )

        json_path = (
            REPORT_ROOT
            / f"documentation_file_audit_{timestamp}.json"
        )

        write_csv(records, csv_path)
        write_json(records, json_path)
        print_summary(records, csv_path, json_path)

        return 0

    except Exception as exc:
        print(
            f"FATAL: {type(exc).__name__}: {exc}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())