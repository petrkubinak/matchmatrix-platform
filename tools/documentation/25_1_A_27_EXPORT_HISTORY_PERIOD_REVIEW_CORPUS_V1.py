# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – EXPORT HISTORICKÉHO OBDOBÍ PRO ŘÍZENOU REKONSTRUKCI

Document ID skriptu:
25_1_A_26_EXPORT_HISTORY_PERIOD_REVIEW_CORPUS_V1

CO:
- Vybere historické dokumenty z CSV manifestu podle data.
- Načte jejich původní textový obsah.
- Vytvoří jeden souhrnný Markdown dokument a JSON index.

K ČEMU:
- Umožní řízeně rekonstruovat měsíční Project Snapshot po menších
  časových blocích bez ručního otevírání desítek souborů.
- Zachová Document ID, datum, název, zdrojovou cestu, formát,
  počet variant a celý zdrojový obsah.

KDE:
- Aktivní skript:
  tools/documentation/
  25_1_A_26_EXPORT_HISTORY_PERIOD_REVIEW_CORPUS_V1.py
- Výstupy:
  reports/documentation/history_review/

JAK:
- Zdrojové soubory pouze čte.
- Nic v archivu ani databázi neupravuje.
- Text čte prioritně jako UTF-8 a následně zkouší Windows-1250.
- Dokumenty řadí podle data, cesty a Document ID.

PŘÍKLAD:
C:\Python314\python.exe ^
  tools\documentation\25_1_A_26_EXPORT_HISTORY_PERIOD_REVIEW_CORPUS_V1.py ^
  --date-from 2026-04-01 ^
  --date-to 2026-04-07
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


SCRIPT_VERSION = "1.0"
DEFAULT_REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
DEFAULT_LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")


def resolve_project_root() -> Path:
    local_manifest = (
        DEFAULT_LOCAL_ROOT
        / "reports"
        / "documentation"
        / "history_corpus_manifest_latest.csv"
    )

    if local_manifest.is_file():
        return DEFAULT_LOCAL_ROOT

    return DEFAULT_REMOTE_ROOT


def build_parser() -> argparse.ArgumentParser:
    root = resolve_project_root()

    parser = argparse.ArgumentParser(
        description=(
            "Exportuje historické dokumenty z vybraného období "
            "do jednoho kontrolního Markdown souboru."
        )
    )

    parser.add_argument(
        "--date-from",
        required=True,
        help="Počáteční datum včetně, formát YYYY-MM-DD."
    )
    parser.add_argument(
        "--date-to",
        required=True,
        help="Koncové datum včetně, formát YYYY-MM-DD."
    )
    parser.add_argument(
        "--manifest",
        default=str(
            root
            / "reports"
            / "documentation"
            / "history_corpus_manifest_latest.csv"
        ),
        help="CSV manifest historického korpusu."
    )
    parser.add_argument(
        "--source-root",
        default=str(
            root
            / "docs"
            / "99_ARCHIVE"
            / "09_HISTORY"
            / "historie 25062026"
        ),
        help="Kořen původního historického archivu."
    )
    parser.add_argument(
        "--output-dir",
        default=str(
            root
            / "reports"
            / "documentation"
            / "history_review"
        ),
        help="Výstupní složka."
    )

    return parser


def parse_iso_date(value: str, label: str) -> str:
    try:
        parsed = datetime.strptime(value, "%Y-%m-%d")
    except ValueError as exc:
        raise ValueError(
            f"{label} musí mít formát YYYY-MM-DD: {value}"
        ) from exc

    return parsed.strftime("%Y-%m-%d")


def read_manifest(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(
            f"Manifest nebyl nalezen: {path}"
        )

    with path.open(
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as handle:
        rows = list(csv.DictReader(handle))

    required = {
        "document_id",
        "title",
        "canonical_relative_path",
        "detected_format",
        "document_date",
        "content_sha256",
        "variant_count",
        "section_count",
        "extraction_status",
        "warnings",
    }

    available = set(rows[0].keys()) if rows else set()
    missing = sorted(required - available)

    if missing:
        raise RuntimeError(
            "Manifest neobsahuje povinné sloupce: "
            + ", ".join(missing)
        )

    return rows


def decode_text_file(path: Path) -> tuple[str, str]:
    raw = path.read_bytes()

    candidates: list[tuple[str, str]] = []

    if raw.startswith(b"\xef\xbb\xbf"):
        candidates.append(("utf-8-sig", "UTF-8 BOM"))

    candidates.extend(
        [
            ("utf-8", "UTF-8"),
            ("cp1250", "Windows-1250"),
            ("cp1252", "Windows-1252"),
            ("latin-1", "Latin-1"),
        ]
    )

    tried: set[str] = set()

    for encoding, label in candidates:
        if encoding in tried:
            continue

        tried.add(encoding)

        try:
            text = raw.decode(encoding, errors="strict")
        except UnicodeDecodeError:
            continue

        normalized = (
            text
            .replace("\r\n", "\n")
            .replace("\r", "\n")
        )

        return normalized, label

    text = raw.decode("utf-8", errors="replace")
    normalized = (
        text
        .replace("\r\n", "\n")
        .replace("\r", "\n")
    )

    return normalized, "UTF-8 s náhradou chybných znaků"


def safe_int(value: Any) -> int:
    try:
        return int(str(value or "0").strip())
    except ValueError:
        return 0


def select_period(
    rows: list[dict[str, str]],
    date_from: str,
    date_to: str
) -> list[dict[str, str]]:
    selected = []

    for row in rows:
        document_date = str(
            row.get("document_date") or ""
        ).strip()

        if not document_date:
            continue

        if date_from <= document_date <= date_to:
            selected.append(row)

    selected.sort(
        key=lambda item: (
            str(item.get("document_date") or ""),
            str(
                item.get("canonical_relative_path") or ""
            ).casefold(),
            str(item.get("document_id") or "")
        )
    )

    return selected


def render_markdown(
    selected: list[dict[str, Any]],
    date_from: str,
    date_to: str,
    manifest_path: Path,
    source_root: Path
) -> str:
    created_at = datetime.now().astimezone().isoformat()

    lines = [
        (
            "# MATCHMATRIX – HISTORICKÝ KONTROLNÍ KORPUS "
            f"{date_from} AŽ {date_to}"
        ),
        "",
        "## Informace o exportu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Období od | {date_from} |",
        f"| Období do | {date_to} |",
        f"| Dokumentů | {len(selected)} |",
        f"| Vytvořeno | {created_at} |",
        f"| Verze exportéru | {SCRIPT_VERSION} |",
        f"| Manifest | `{manifest_path}` |",
        f"| Zdrojový archiv | `{source_root}` |",
        "| Úprava zdrojů | NE |",
        "",
        "## Přehled dokumentů",
        "",
        (
            "| Pořadí | Document ID | Datum | Název | "
            "Formát | Varianty | Stav načtení |"
        ),
        "|---:|---|---|---|---|---:|---|",
    ]

    for index, item in enumerate(selected, start=1):
        title = str(item.get("title") or "").replace("|", r"\|")
        lines.append(
            "| "
            f"{index} | "
            f"{item.get('document_id', '')} | "
            f"{item.get('document_date', '')} | "
            f"{title} | "
            f"{item.get('detected_format', '')} | "
            f"{item.get('variant_count', '')} | "
            f"{item.get('review_status', '')} |"
        )

    lines.extend(
        [
            "",
            "## Zdrojové dokumenty",
            "",
            (
                "> Tento soubor je pracovní důkazní export. "
                "Obsah jednotlivých zdrojů není automaticky "
                "považován za aktuální nebo pravdivý stav projektu."
            ),
            "",
        ]
    )

    for index, item in enumerate(selected, start=1):
        lines.extend(
            [
                "---",
                "",
                (
                    f"# {index}. "
                    f"{item.get('document_id', '')} – "
                    f"{item.get('title', '')}"
                ),
                "",
                "## Metadata zdroje",
                "",
                "| Položka | Hodnota |",
                "|---|---|",
                (
                    "| Document ID | "
                    f"{item.get('document_id', '')} |"
                ),
                (
                    "| Datum dokumentu | "
                    f"{item.get('document_date', '')} |"
                ),
                (
                    "| Název | "
                    f"{str(item.get('title') or '').replace('|', r'\|')} |"
                ),
                (
                    "| Relativní cesta | "
                    f"`{item.get('canonical_relative_path', '')}` |"
                ),
                (
                    "| Skutečná cesta | "
                    f"`{item.get('resolved_path', '')}` |"
                ),
                (
                    "| Detekovaný formát | "
                    f"{item.get('detected_format', '')} |"
                ),
                (
                    "| Počet variant | "
                    f"{item.get('variant_count', '')} |"
                ),
                (
                    "| Počet sekcí | "
                    f"{item.get('section_count', '')} |"
                ),
                (
                    "| Kódování při exportu | "
                    f"{item.get('encoding_used', '')} |"
                ),
                (
                    "| Stav načtení | "
                    f"{item.get('review_status', '')} |"
                ),
                (
                    "| SHA-256 z manifestu | "
                    f"`{item.get('content_sha256', '')}` |"
                ),
                (
                    "| SHA-256 načteného textu | "
                    f"`{item.get('export_text_sha256', '')}` |"
                ),
                "",
                "## Původní obsah",
                "",
                (
                    "<!-- BEGIN ORIGINAL CONTENT "
                    f"{item.get('document_id', '')} -->"
                ),
                "",
            ]
        )

        content = str(item.get("content") or "")

        if content:
            lines.append(content.rstrip())
        else:
            lines.append(
                "[OBSAH NEBYL NAČTEN – viz stav a varování]"
            )

        lines.extend(
            [
                "",
                (
                    "<!-- END ORIGINAL CONTENT "
                    f"{item.get('document_id', '')} -->"
                ),
                "",
            ]
        )

    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = build_parser().parse_args()

    try:
        date_from = parse_iso_date(
            args.date_from,
            "--date-from"
        )
        date_to = parse_iso_date(
            args.date_to,
            "--date-to"
        )

        if date_from > date_to:
            raise ValueError(
                "--date-from nesmí být později než --date-to."
            )

        manifest_path = Path(args.manifest)
        source_root = Path(args.source_root)
        output_dir = Path(args.output_dir)

        rows = read_manifest(manifest_path)
        selected_rows = select_period(
            rows,
            date_from,
            date_to
        )

        if not selected_rows:
            print(
                "ERROR: Pro vybrané období nebyl nalezen "
                "žádný dokument."
            )
            return 2

        output_dir.mkdir(
            parents=True,
            exist_ok=True
        )

        exported: list[dict[str, Any]] = []
        warnings: list[str] = []

        for row in selected_rows:
            relative_path = str(
                row.get("canonical_relative_path") or ""
            ).strip()

            source_path = source_root / Path(relative_path)
            item: dict[str, Any] = dict(row)
            item["resolved_path"] = str(source_path)
            item["content"] = ""
            item["encoding_used"] = ""
            item["review_status"] = "READY"
            item["export_text_sha256"] = ""

            detected_format = str(
                row.get("detected_format") or ""
            ).strip().lower()

            if detected_format not in {"md", "txt", "sql", "csv"}:
                item["review_status"] = (
                    "UNSUPPORTED_TEXT_EXPORT_FORMAT"
                )
                warning = (
                    f"{row.get('document_id')}: "
                    f"formát {detected_format} není v tomto "
                    "exportéru podporován."
                )
                warnings.append(warning)
                exported.append(item)
                continue

            if not source_path.is_file():
                item["review_status"] = "SOURCE_NOT_FOUND"
                warning = (
                    f"{row.get('document_id')}: "
                    f"zdroj nebyl nalezen: {source_path}"
                )
                warnings.append(warning)
                exported.append(item)
                continue

            try:
                content, encoding_used = decode_text_file(
                    source_path
                )
            except OSError as exc:
                item["review_status"] = "READ_ERROR"
                warning = (
                    f"{row.get('document_id')}: "
                    f"chyba čtení: {exc}"
                )
                warnings.append(warning)
                exported.append(item)
                continue

            item["content"] = content
            item["encoding_used"] = encoding_used
            item["export_text_sha256"] = hashlib.sha256(
                content.encode("utf-8")
            ).hexdigest()

            exported.append(item)

        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_name = (
            "history_period_review_"
            f"{date_from.replace('-', '')}_"
            f"{date_to.replace('-', '')}_"
            f"{stamp}"
        )

        markdown_path = output_dir / f"{base_name}.md"
        json_path = output_dir / f"{base_name}.json"
        latest_markdown_path = (
            output_dir
            / "history_period_review_latest.md"
        )
        latest_json_path = (
            output_dir
            / "history_period_review_latest.json"
        )

        markdown_text = render_markdown(
            exported,
            date_from,
            date_to,
            manifest_path,
            source_root
        )

        payload = {
            "generated_at": (
                datetime.now().astimezone().isoformat()
            ),
            "engine": (
                "25_1_A_26_EXPORT_HISTORY_PERIOD_"
                "REVIEW_CORPUS_V1"
            ),
            "engine_version": SCRIPT_VERSION,
            "date_from": date_from,
            "date_to": date_to,
            "manifest": str(manifest_path),
            "source_root": str(source_root),
            "document_count": len(exported),
            "ready_count": sum(
                1
                for item in exported
                if item.get("review_status") == "READY"
            ),
            "warning_count": len(warnings),
            "warnings": warnings,
            "documents": [
                {
                    key: value
                    for key, value in item.items()
                    if key != "content"
                }
                for item in exported
            ],
            "source_modified": False,
            "final_status": (
                "HISTORY_PERIOD_REVIEW_CORPUS_READY"
                if not warnings
                else
                "HISTORY_PERIOD_REVIEW_CORPUS_READY_WITH_WARNINGS"
            ),
        }

        encoded_json = json.dumps(
            payload,
            ensure_ascii=False,
            indent=2
        )

        for path in (
            markdown_path,
            latest_markdown_path
        ):
            path.write_text(
                markdown_text,
                encoding="utf-8"
            )

        for path in (
            json_path,
            latest_json_path
        ):
            path.write_text(
                encoded_json,
                encoding="utf-8"
            )

        print(
            "MATCHMATRIX HISTORY PERIOD REVIEW EXPORT"
        )
        print("=" * 72)
        print(f"DATE FROM      : {date_from}")
        print(f"DATE TO        : {date_to}")
        print(f"DOCUMENTS      : {len(exported)}")
        print(
            "READY          : "
            f"{payload['ready_count']}"
        )
        print(
            "WARNINGS       : "
            f"{payload['warning_count']}"
        )

        for item in exported:
            print(
                f"{item.get('document_id')} | "
                f"{item.get('document_date')} | "
                f"{item.get('review_status')} | "
                f"{item.get('title')}"
            )

        if warnings:
            print("-" * 72)
            print("WARNINGS")
            for warning in warnings:
                print(f"- {warning}")

        print("-" * 72)
        print(f"MARKDOWN       : {markdown_path}")
        print(f"JSON           : {json_path}")
        print(f"LATEST MD      : {latest_markdown_path}")
        print(f"LATEST JSON    : {latest_json_path}")
        print("SOURCE MODIFIED: False")
        print(
            "FINAL STATUS   : "
            f"{payload['final_status']}"
        )

        return 0

    except Exception as exc:
        print(f"ERROR: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
