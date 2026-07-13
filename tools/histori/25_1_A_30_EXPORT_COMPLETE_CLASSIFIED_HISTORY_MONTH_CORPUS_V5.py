# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – EXPORT COMPLETE CLASSIFIED HISTORY MONTH CORPUS V1

Document ID:
25_1_A_30_EXPORT_COMPLETE_CLASSIFIED_HISTORY_MONTH_CORPUS_V1

CO:
- Spojí dokumenty datované přímo v historickém manifestu
  s dokumenty doplněnými řízenou klasifikační mapou.
- Vytvoří úplný měsíční korpus bez duplicitních Document ID.
- Zachová metadata, datumovou klasifikaci, chronologickou roli,
  vazby a celý původní obsah.

K ČEMU:
- Připraví úplný zdrojový korpus pro měsíční rekonstrukci.
- Zahrne i dokumenty uložené mimo složku Denní zápisy
  nebo dokumenty bez data v názvu.

KDE:
- tools/documentation/
  25_1_A_30_EXPORT_COMPLETE_CLASSIFIED_HISTORY_MONTH_CORPUS_V1.py
- Výstupy:
  reports/documentation/history_review/

JAK:
- Načte manifest, klasifikační mapu a původní historický archiv.
- Přesně datované dokumenty vybere podle document_date.
- Další dokumenty vybere podle recommended_month.
- TIMELESS_REFERENCE a DATE_UNRESOLVED nezařazuje.
- Ověřuje integritu stejnou normalizací jako A25: CRLF/CR → LF, strip a jeden koncový LF.
- Raw SHA-256 původního souboru eviduje samostatně pouze pro audit.
- Nic v archivu, manifestu, klasifikační mapě ani databázi neupravuje.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Any


SCRIPT_ID = "25_1_A_30_EXPORT_COMPLETE_CLASSIFIED_HISTORY_MONTH_CORPUS_V1"
SCRIPT_VERSION = "1.2"

REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")

SUPPORTED_FORMATS = {"md", "txt", "sql", "csv"}
INCLUDED_CLASSIFICATIONS = {
    "EXPLICIT_DATE",
    "INFERRED_DATE",
    "INFERRED_MONTH",
    "OTHER_PERIOD",
}


def project_root() -> Path:
    local_manifest = (
        LOCAL_ROOT
        / "reports"
        / "documentation"
        / "history_corpus_manifest_latest.csv"
    )
    return LOCAL_ROOT if local_manifest.is_file() else REMOTE_ROOT


def parser() -> argparse.ArgumentParser:
    root = project_root()
    result = argparse.ArgumentParser(
        description="Export úplného klasifikovaného měsíčního korpusu."
    )
    result.add_argument(
        "--manifest",
        default=str(
            root / "reports" / "documentation"
            / "history_corpus_manifest_latest.csv"
        ),
    )
    result.add_argument(
        "--classification-map",
        default=str(
            root / "reports" / "documentation" / "history_review"
            / "history_date_classification_map_latest.csv"
        ),
    )
    result.add_argument(
        "--source-root",
        default=str(
            root / "docs" / "99_ARCHIVE" / "09_HISTORY"
            / "historie 25062026"
        ),
    )
    result.add_argument("--month", required=True)
    result.add_argument(
        "--output-dir",
        default=str(
            root / "reports" / "documentation" / "history_review"
        ),
    )
    return result


def validate_month(value: str) -> str:
    if not re.fullmatch(r"20\d{2}-(0[1-9]|1[0-2])", value):
        raise ValueError(
            f"Neplatný měsíc '{value}'. Očekáván formát YYYY-MM."
        )
    datetime.strptime(value, "%Y-%m")
    return value


def read_csv(path: Path, label: str) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(f"{label} nebyl nalezen: {path}")
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        raise RuntimeError(f"{label} je prázdný.")
    return rows


def require_columns(
    rows: list[dict[str, str]],
    required: set[str],
    label: str,
) -> None:
    missing = sorted(required - set(rows[0].keys()))
    if missing:
        raise RuntimeError(
            f"{label} neobsahuje povinné sloupce: "
            + ", ".join(missing)
        )


def index_unique(
    rows: list[dict[str, str]],
    label: str,
) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {}
    for row in rows:
        document_id = str(row.get("document_id") or "").strip()
        if not document_id:
            raise RuntimeError(f"{label}: prázdné document_id.")
        if document_id in result:
            raise RuntimeError(
                f"{label}: duplicitní document_id {document_id}."
            )
        result[document_id] = row
    return result


def select_documents(
    manifest_rows: list[dict[str, str]],
    class_rows: list[dict[str, str]],
    month: str,
) -> tuple[list[dict[str, Any]], dict[str, int]]:
    manifest = index_unique(manifest_rows, "Manifest")
    classifications = index_unique(class_rows, "Klasifikační mapa")

    selected: dict[str, dict[str, Any]] = {}
    stats = {
        "manifest_dated": 0,
        "classification_added": 0,
        "overlap_deduplicated": 0,
    }

    for document_id, row in manifest.items():
        document_date = str(row.get("document_date") or "").strip()
        if not document_date.startswith(month):
            continue

        selected[document_id] = {
            "manifest": row,
            "selection_source": "MANIFEST_DOCUMENT_DATE",
            "effective_document_date": document_date,
            "effective_month": month,
            "date_classification": "MANIFEST_DATE",
            "date_confidence": "HIGH",
            "date_basis": "Datum je uvedeno přímo v historickém manifestu.",
            "chronology_role": "",
            "related_document_id": "",
            "review_note": "",
        }
        stats["manifest_dated"] += 1

    for document_id, row in classifications.items():
        if str(row.get("recommended_month") or "").strip() != month:
            continue

        classification = str(
            row.get("classification") or ""
        ).strip()

        if classification not in INCLUDED_CLASSIFICATIONS:
            continue

        manifest_row = manifest.get(document_id)
        if manifest_row is None:
            raise RuntimeError(
                f"Klasifikovaný dokument není v manifestu: {document_id}"
            )

        common = {
            "date_classification": classification,
            "date_confidence": str(
                row.get("date_confidence") or ""
            ).strip(),
            "date_basis": str(
                row.get("date_basis") or ""
            ).strip(),
            "chronology_role": str(
                row.get("chronology_role") or ""
            ).strip(),
            "related_document_id": str(
                row.get("related_document_id") or ""
            ).strip(),
            "review_note": str(
                row.get("review_note") or ""
            ).strip(),
        }

        if document_id in selected:
            selected[document_id].update(common)
            stats["overlap_deduplicated"] += 1
            continue

        selected[document_id] = {
            "manifest": manifest_row,
            "selection_source": "CLASSIFICATION_MAP",
            "effective_document_date": str(
                row.get("recommended_document_date") or ""
            ).strip(),
            "effective_month": month,
            **common,
        }
        stats["classification_added"] += 1

    result = list(selected.values())
    result.sort(
        key=lambda item: (
            0 if item["effective_document_date"] else 1,
            item["effective_document_date"] or f"{month}-99",
            str(
                item["manifest"].get("canonical_relative_path") or ""
            ).casefold(),
            str(item["manifest"].get("document_id") or ""),
        )
    )
    return result, stats


def normalize_manifest_text(text: str) -> str:
    """
    Použije stejnou normalizaci jako A25 při tvorbě content_sha256:
    - CRLF/CR -> LF
    - odstranění okrajových mezer a prázdných řádků
    - přesně jeden koncový LF
    """
    return (
        text.replace("\r\n", "\n")
        .replace("\r", "\n")
        .strip()
        + "\n"
    )


def decode(raw: bytes) -> tuple[str, str]:
    encodings = [
        ("utf-8-sig", "UTF-8 BOM"),
        ("utf-8", "UTF-8"),
        ("cp1250", "Windows-1250"),
        ("cp1252", "Windows-1252"),
        ("latin-1", "Latin-1"),
    ]
    for encoding, label in encodings:
        try:
            text = raw.decode(encoding, errors="strict")
            return (
                text.replace("\r\n", "\n").replace("\r", "\n"),
                label,
            )
        except UnicodeDecodeError:
            continue
    return (
        raw.decode("utf-8", errors="replace")
        .replace("\r\n", "\n")
        .replace("\r", "\n"),
        "UTF-8 s náhradou chybných znaků",
    )


def load_sources(
    selected: list[dict[str, Any]],
    source_root: Path,
) -> tuple[list[dict[str, Any]], list[str]]:
    exported: list[dict[str, Any]] = []
    warnings: list[str] = []

    for item in selected:
        row = item["manifest"]
        source_path = (
            source_root
            / Path(str(row.get("canonical_relative_path") or ""))
        )

        current = {
            **item,
            "resolved_path": str(source_path),
            "content": "",
            "encoding_used": "",
            "raw_file_sha256": "",
            "export_text_sha256": "",
            "hash_status": "",
            "review_status": "READY",
        }

        detected_format = str(
            row.get("detected_format") or ""
        ).lower().strip()

        if detected_format not in SUPPORTED_FORMATS:
            current["review_status"] = "UNSUPPORTED_FORMAT"
            warnings.append(
                f"{row.get('document_id')}: "
                f"nepodporovaný formát {detected_format}."
            )
            exported.append(current)
            continue

        if not source_path.is_file():
            current["review_status"] = "SOURCE_NOT_FOUND"
            warnings.append(
                f"{row.get('document_id')}: zdroj nenalezen."
            )
            exported.append(current)
            continue

        raw = source_path.read_bytes()
        decoded_text, encoding = decode(raw)
        manifest_text = normalize_manifest_text(decoded_text)

        raw_file_hash = hashlib.sha256(raw).hexdigest()
        export_text_hash = hashlib.sha256(
            manifest_text.encode("utf-8")
        ).hexdigest()

        manifest_hash = str(
            row.get("content_sha256") or ""
        ).strip().lower()

        if not manifest_hash:
            hash_status = "MANIFEST_HASH_EMPTY"
        elif export_text_hash.lower() == manifest_hash:
            hash_status = "MATCH"
        else:
            hash_status = "DIFFERENT"
            warnings.append(
                f"{row.get('document_id')}: "
                "normalizovaný textový SHA-256 se liší od manifestu."
            )

        current.update(
            {
                "content": manifest_text,
                "encoding_used": encoding,
                "raw_file_sha256": raw_file_hash,
                "export_text_sha256": export_text_hash,
                "hash_status": hash_status,
            }
        )
        exported.append(current)

    return exported, warnings


def esc(value: Any) -> str:
    return str(value or "").replace("|", r"\|").replace("\n", " ")


def markdown(
    month: str,
    exported: list[dict[str, Any]],
    stats: dict[str, int],
    warnings: list[str],
    manifest_path: Path,
    class_path: Path,
    source_root: Path,
) -> str:
    exact = sum(
        1 for item in exported
        if item["effective_document_date"]
    )
    month_only = len(exported) - exact

    lines = [
        f"# MATCHMATRIX – COMPLETE HISTORY MONTH CORPUS {month}",
        "",
        "## Informace o exportu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Měsíc | `{month}` |",
        f"| Vytvořeno | {datetime.now().astimezone().isoformat()} |",
        f"| Skript | `{SCRIPT_ID}` |",
        f"| Manifest | `{manifest_path}` |",
        f"| Klasifikační mapa | `{class_path}` |",
        f"| Zdrojový archiv | `{source_root}` |",
        f"| Unikátních dokumentů | {len(exported)} |",
        f"| Přesně datovaných | {exact} |",
        f"| Pouze měsíční klasifikace | {month_only} |",
        f"| Z manifestu | {stats['manifest_dated']} |",
        f"| Doplněno klasifikační mapou | {stats['classification_added']} |",
        f"| Odstraněné překryvy | {stats['overlap_deduplicated']} |",
        f"| Varování | {len(warnings)} |",
        "| Zdroj upraven | NE |",
        "| Manifest upraven | NE |",
        "| Klasifikační mapa upravena | NE |",
        "| Databáze upravena | NE |",
        "",
        "## Pravidlo interpretace",
        "",
        (
            "> Dokumenty bez přesného dne patří do uvedeného měsíce, "
            "ale nesmějí být prezentovány jako událost konkrétního dne."
        ),
        "",
        "## Přehled dokumentů",
        "",
        (
            "| # | Document ID | Efektivní datum | Klasifikace | "
            "Jistota | Zdroj výběru | Role | Název |"
        ),
        "|---:|---|---|---|---|---|---|---|",
    ]

    for number, item in enumerate(exported, 1):
        row = item["manifest"]
        lines.append(
            "| "
            f"{number} | {esc(row.get('document_id'))} | "
            f"{esc(item['effective_document_date'] or 'MONTH_ONLY')} | "
            f"{esc(item['date_classification'])} | "
            f"{esc(item['date_confidence'])} | "
            f"{esc(item['selection_source'])} | "
            f"{esc(item['chronology_role'])} | "
            f"{esc(row.get('title'))} |"
        )

    if warnings:
        lines.extend(["", "## Varování", ""])
        lines.extend(f"- {warning}" for warning in warnings)

    lines.extend(["", "## Zdrojové dokumenty", ""])

    for number, item in enumerate(exported, 1):
        row = item["manifest"]
        lines.extend(
            [
                "---",
                "",
                f"# {number}. {row.get('document_id')} – {row.get('title')}",
                "",
                "## Metadata",
                "",
                "| Položka | Hodnota |",
                "|---|---|",
                f"| Document ID | {esc(row.get('document_id'))} |",
                f"| Datum v manifestu | {esc(row.get('document_date') or 'NEVYPLNĚNO')} |",
                f"| Efektivní datum | {esc(item['effective_document_date'] or 'POUZE MĚSÍC')} |",
                f"| Efektivní měsíc | {esc(item['effective_month'])} |",
                f"| Klasifikace | {esc(item['date_classification'])} |",
                f"| Jistota | {esc(item['date_confidence'])} |",
                f"| Zdroj výběru | {esc(item['selection_source'])} |",
                f"| Chronologická role | {esc(item['chronology_role'])} |",
                f"| Související dokument | {esc(item['related_document_id'])} |",
                f"| Základ rozhodnutí | {esc(item['date_basis'])} |",
                f"| Review poznámka | {esc(item['review_note'])} |",
                f"| Relativní cesta | `{row.get('canonical_relative_path', '')}` |",
                f"| Skutečná cesta | `{item.get('resolved_path', '')}` |",
                f"| Formát | {esc(row.get('detected_format'))} |",
                f"| Varianty | {esc(row.get('variant_count'))} |",
                f"| Sekce | {esc(row.get('section_count'))} |",
                f"| Stav načtení | {esc(item['review_status'])} |",
                f"| Kódování | {esc(item['encoding_used'])} |",
                f"| SHA-256 manifestu | `{row.get('content_sha256', '')}` |",
                f"| SHA-256 normalizovaného exportního textu | `{item.get('export_text_sha256', '')}` |",
                f"| SHA-256 původních bajtů souboru | `{item.get('raw_file_sha256', '')}` |",
                f"| Hash status | {esc(item['hash_status'])} |",
                "",
                "## Původní obsah",
                "",
                f"<!-- BEGIN ORIGINAL CONTENT {row.get('document_id')} -->",
                "",
                (
                    item["content"].rstrip()
                    if item["content"]
                    else "[OBSAH NEBYL NAČTEN]"
                ),
                "",
                f"<!-- END ORIGINAL CONTENT {row.get('document_id')} -->",
                "",
            ]
        )

    return "\n".join(lines).rstrip() + "\n"


def index_rows(exported: list[dict[str, Any]]) -> list[dict[str, str]]:
    result = []
    for item in exported:
        row = item["manifest"]
        result.append(
            {
                "document_id": str(row.get("document_id") or ""),
                "title": str(row.get("title") or ""),
                "canonical_relative_path": str(
                    row.get("canonical_relative_path") or ""
                ),
                "manifest_document_date": str(
                    row.get("document_date") or ""
                ),
                "effective_document_date": str(
                    item.get("effective_document_date") or ""
                ),
                "effective_month": str(
                    item.get("effective_month") or ""
                ),
                "date_classification": str(
                    item.get("date_classification") or ""
                ),
                "date_confidence": str(
                    item.get("date_confidence") or ""
                ),
                "selection_source": str(
                    item.get("selection_source") or ""
                ),
                "chronology_role": str(
                    item.get("chronology_role") or ""
                ),
                "related_document_id": str(
                    item.get("related_document_id") or ""
                ),
                "review_status": str(
                    item.get("review_status") or ""
                ),
                "hash_status": str(
                    item.get("hash_status") or ""
                ),
            }
        )
    return result


def write_index_csv(
    path: Path,
    rows: list[dict[str, str]],
) -> None:
    fields = list(rows[0].keys())
    with path.open(
        "w",
        encoding="utf-8-sig",
        newline="",
    ) as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    args = parser().parse_args()

    try:
        month = validate_month(args.month.strip())
        manifest_path = Path(args.manifest)
        class_path = Path(args.classification_map)
        source_root = Path(args.source_root)
        output_dir = Path(args.output_dir)

        manifest_rows = read_csv(manifest_path, "Manifest")
        class_rows = read_csv(class_path, "Klasifikační mapa")

        require_columns(
            manifest_rows,
            {
                "document_id",
                "document_date",
                "title",
                "canonical_relative_path",
                "detected_format",
                "content_sha256",
                "variant_count",
                "section_count",
                "extraction_status",
            },
            "Manifest",
        )
        require_columns(
            class_rows,
            {
                "document_id",
                "classification",
                "recommended_document_date",
                "recommended_month",
                "date_confidence",
                "date_basis",
                "chronology_role",
                "related_document_id",
                "review_note",
            },
            "Klasifikační mapa",
        )

        selected, stats = select_documents(
            manifest_rows,
            class_rows,
            month,
        )

        if not selected:
            print(f"ERROR: Pro měsíc {month} nebyl nalezen žádný dokument.")
            return 2

        exported, warnings = load_sources(
            selected,
            source_root,
        )

        output_dir.mkdir(parents=True, exist_ok=True)

        token = month.replace("-", "_")
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base = f"history_complete_month_corpus_{token}_{stamp}"
        latest = f"history_complete_month_corpus_{token}_latest"

        md_path = output_dir / f"{base}.md"
        json_path = output_dir / f"{base}.json"
        csv_path = output_dir / f"{base}.csv"
        latest_md = output_dir / f"{latest}.md"
        latest_json = output_dir / f"{latest}.json"
        latest_csv = output_dir / f"{latest}.csv"

        md_text = markdown(
            month,
            exported,
            stats,
            warnings,
            manifest_path,
            class_path,
            source_root,
        )

        payload = {
            "generated_at": datetime.now().astimezone().isoformat(),
            "engine": SCRIPT_ID,
            "engine_version": SCRIPT_VERSION,
            "month": month,
            "document_count": len(exported),
            "exact_date_count": sum(
                1 for item in exported
                if item["effective_document_date"]
            ),
            "month_only_count": sum(
                1 for item in exported
                if not item["effective_document_date"]
            ),
            "selection_stats": stats,
            "warning_count": len(warnings),
            "warnings": warnings,
            "source_modified": False,
            "manifest_modified": False,
            "classification_modified": False,
            "database_modified": False,
            "documents": [
                {
                    **{
                        key: value
                        for key, value in item.items()
                        if key not in {"content", "manifest"}
                    },
                    "manifest": item["manifest"],
                }
                for item in exported
            ],
            "final_status": (
                "COMPLETE_HISTORY_MONTH_CORPUS_READY"
                if not warnings
                else "COMPLETE_HISTORY_MONTH_CORPUS_READY_WITH_WARNINGS"
            ),
        }
        json_text = json.dumps(
            payload,
            ensure_ascii=False,
            indent=2,
        )
        rows = index_rows(exported)

        for path in (md_path, latest_md):
            path.write_text(md_text, encoding="utf-8")

        for path in (json_path, latest_json):
            path.write_text(json_text, encoding="utf-8")

        for path in (csv_path, latest_csv):
            write_index_csv(path, rows)

        print("MATCHMATRIX COMPLETE CLASSIFIED HISTORY MONTH CORPUS")
        print("=" * 76)
        print(f"MONTH                  : {month}")
        print(f"DOCUMENTS              : {len(exported)}")
        print(
            "EXACT DATE             : "
            + str(sum(
                1 for item in exported
                if item["effective_document_date"]
            ))
        )
        print(
            "MONTH ONLY             : "
            + str(sum(
                1 for item in exported
                if not item["effective_document_date"]
            ))
        )
        print(f"FROM MANIFEST DATE     : {stats['manifest_dated']}")
        print(
            "ADDED BY CLASSIFICATION: "
            f"{stats['classification_added']}"
        )
        print(
            "OVERLAPS DEDUPLICATED  : "
            f"{stats['overlap_deduplicated']}"
        )
        print(f"WARNINGS               : {len(warnings)}")
        print("-" * 76)

        for item in exported:
            row = item["manifest"]
            display_date = (
                item["effective_document_date"]
                or f"{month}-MONTH_ONLY"
            )
            print(
                f"{row.get('document_id')} | "
                f"{display_date} | "
                f"{item['date_classification']} | "
                f"{item['selection_source']} | "
                f"{item['review_status']} | "
                f"{row.get('title')}"
            )

        print("-" * 76)
        print(f"MARKDOWN               : {md_path}")
        print(f"JSON                   : {json_path}")
        print(f"CSV                    : {csv_path}")
        print(f"LATEST MARKDOWN        : {latest_md}")
        print(f"LATEST JSON            : {latest_json}")
        print(f"LATEST CSV             : {latest_csv}")
        print("SOURCE MODIFIED        : False")
        print("MANIFEST MODIFIED      : False")
        print("CLASSIFICATION MODIFIED: False")
        print("DATABASE MODIFIED      : False")
        print(f"FINAL STATUS           : {payload['final_status']}")
        return 0

    except Exception as exc:
        print(f"FATAL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
