#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Normalizuje metadata tří kanonických dokumentů před prvním importem
do databázové dokumentační vrstvy MatchMatrix.

K ČEMU:
Doplní jednotný blok „Informace o dokumentu“ a odstraní nejednotný
inline zápis verze/stavu. Opravuje pouze:
- MM-REF-001
- MM-STD-003
- MM-STD-008

KDE:
tools/documentation/25_1_A_4_NORMALIZE_DOCUMENT_METADATA_V1.py

JAK:
Výchozí režim je DRY_RUN:
    py -3.14 .\tools\documentation\25_1_A_4_NORMALIZE_DOCUMENT_METADATA_V1.py

Skutečný zápis:
    py -3.14 .\tools\documentation\25_1_A_4_NORMALIZE_DOCUMENT_METADATA_V1.py --apply
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


@dataclass(frozen=True)
class DocumentSpec:
    relative_path: str
    document_id: str
    title: str
    edition: str
    version: str
    status: str


DOCUMENTS = (
    DocumentSpec(
        relative_path="docs/10_REFERENCE/MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md",
        document_id="MM-REF-001",
        title="Slovník pojmů MatchMatrix",
        edition="MM-REF",
        version="1.3",
        status="ACTIVE",
    ),
    DocumentSpec(
        relative_path="docs/12_STANDARD/MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md",
        document_id="MM-STD-003",
        title="Standard životního cyklu dokumentace a verzování",
        edition="MM-STD",
        version="1.1",
        status="ACTIVE",
    ),
    DocumentSpec(
        relative_path="docs/12_STANDARD/MM-STD-008_SPRAVA_TERMINOLOGIE_A_REFERENCNIHO_SLOVNIKU.md",
        document_id="MM-STD-008",
        title="Správa terminologie a referenčního slovníku",
        edition="MM-STD",
        version="1.0",
        status="REVIEW",
    ),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Normalizace metadat vybraných dokumentů MatchMatrix."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Zapíše změny. Bez přepínače probíhá pouze DRY_RUN.",
    )
    return parser.parse_args()


def project_root() -> Path:
    script_path = Path(__file__).resolve()
    return script_path.parents[2]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def decode_markdown(data: bytes) -> tuple[str, bool, str]:
    has_bom = data.startswith(b"\xef\xbb\xbf")
    raw = data[3:] if has_bom else data
    text = raw.decode("utf-8")
    newline = "\r\n" if "\r\n" in text else "\n"
    return text, has_bom, newline


def encode_markdown(text: str, has_bom: bool) -> bytes:
    raw = text.encode("utf-8")
    return (b"\xef\xbb\xbf" + raw) if has_bom else raw


def metadata_block(spec: DocumentSpec, newline: str) -> str:
    lines = [
        "---",
        "",
        "## Informace o dokumentu",
        "",
        "| Položka | Hodnota |",
        "|---------|---------|",
        f"| Dokument | {spec.document_id} |",
        f"| Název | {spec.title} |",
        f"| Edice | {spec.edition} |",
        f"| Verze | {spec.version} |",
        f"| Stav | {spec.status} |",
        "",
        "---",
    ]
    return newline.join(lines)


def remove_existing_metadata_block(text: str) -> str:
    pattern = re.compile(
        r"(?ms)^---\s*\n+## Informace o dokumentu\s*\n+"
        r"\| Položka \| Hodnota \|\s*\n"
        r"\|[-| ]+\|\s*\n"
        r"(?:\|.*\|\s*\n)+?"
        r"\s*---\s*\n*"
    )
    return pattern.sub("", text, count=1)


def remove_inline_version_status(text: str) -> str:
    pattern = re.compile(
        r"(?mi)^[ \t]*Verze:\s*\*\*[^*\r\n]+\*\*"
        r"\s*\|\s*Stav:\s*\*\*[^*\r\n]+\*\*[ \t]*\r?\n?"
    )
    return pattern.sub("", text, count=1)


def find_insertion_offset(text: str) -> int:
    """
    Vloží metadata za úvodní nadpisovou část:
    - pokud první dva neprázdné řádky začínají '#', za druhý nadpis,
    - jinak za první nadpis.
    """
    lines = text.splitlines(keepends=True)
    heading_indexes = [
        index for index, line in enumerate(lines)
        if line.lstrip().startswith("#")
    ]

    if not heading_indexes:
        raise ValueError("Dokument neobsahuje žádný Markdown nadpis.")

    first = heading_indexes[0]
    target = first

    for index in heading_indexes[1:]:
        between = "".join(lines[first + 1:index]).strip()
        if not between:
            target = index
        break

    return sum(len(line) for line in lines[: target + 1])


def normalize_document(text: str, spec: DocumentSpec, newline: str) -> str:
    normalized = remove_existing_metadata_block(text)
    normalized = remove_inline_version_status(normalized)

    # Odstranění nadbytečných prázdných řádků bez globálního formátování.
    normalized = normalized.lstrip("\r\n")
    offset = find_insertion_offset(normalized)

    before = normalized[:offset].rstrip("\r\n")
    after = normalized[offset:].lstrip("\r\n")

    block = metadata_block(spec, newline)
    result = before + newline * 2 + block + newline * 2 + after

    if not result.endswith(("\n", "\r\n")):
        result += newline

    return result


def main() -> int:
    args = parse_args()
    root = project_root()
    mode = "APPLY" if args.apply else "DRY_RUN"

    report_rows: list[dict[str, object]] = []
    errors: list[str] = []

    print("MATCHMATRIX DOCUMENT METADATA NORMALIZATION")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"MODE               : {mode}")
    print()

    for spec in DOCUMENTS:
        path = root / spec.relative_path

        if not path.is_file():
            errors.append(f"Soubor nebyl nalezen: {path}")
            continue

        before_bytes = path.read_bytes()

        try:
            before_text, has_bom, newline = decode_markdown(before_bytes)
            after_text = normalize_document(before_text, spec, newline)
            after_bytes = encode_markdown(after_text, has_bom)
        except (UnicodeDecodeError, ValueError) as exc:
            errors.append(f"{path}: {exc}")
            continue

        changed = before_bytes != after_bytes

        if args.apply and changed:
            path.write_bytes(after_bytes)

        row = {
            "path": spec.relative_path,
            "document_id": spec.document_id,
            "version": spec.version,
            "status": spec.status,
            "changed": changed,
            "applied": bool(args.apply and changed),
            "sha256_before": sha256_bytes(before_bytes),
            "sha256_after": sha256_bytes(after_bytes),
        }
        report_rows.append(row)

        print(spec.relative_path)
        print(f"  document_id : {spec.document_id}")
        print(f"  version     : {spec.version}")
        print(f"  status      : {spec.status}")
        print(f"  result      : {'UPDATED' if args.apply and changed else 'CHANGE_READY' if changed else 'NO_CHANGE'}")
        print(f"  sha256 before: {row['sha256_before']}")
        print(f"  sha256 after : {row['sha256_after']}")
        print()

    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_path = reports_dir / f"document_metadata_normalization_{timestamp}.json"

    payload = {
        "generated_at": datetime.now().astimezone().isoformat(),
        "mode": mode,
        "project_root": str(root),
        "documents": report_rows,
        "errors": errors,
        "final_status": (
            "ERROR"
            if errors
            else "DOCUMENT_METADATA_NORMALIZED"
            if args.apply
            else "DRY_RUN_READY_FOR_APPLY"
        ),
    }
    report_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if errors:
        print("CHYBY")
        print("-" * 79)
        for error in errors:
            print(f"- {error}")
        print()
        print(f"REPORT             : {report_path}")
        print("FINAL STATUS       : ERROR")
        return 1

    changed_count = sum(1 for row in report_rows if row["changed"])
    print(f"FILES PROCESSED    : {len(report_rows)}")
    print(f"FILES WITH CHANGES : {changed_count}")
    print(f"REPORT             : {report_path}")
    print(
        "FINAL STATUS       : "
        + (
            "DOCUMENT_METADATA_NORMALIZED"
            if args.apply
            else "DRY_RUN_READY_FOR_APPLY"
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
