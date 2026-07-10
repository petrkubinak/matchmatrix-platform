# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – EXPORT NEDATOVANÝCH HISTORICKÝCH DOKUMENTŮ PRO ŘÍZENOU REKONSTRUKCI

Document ID skriptu:
25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1

CO:
- Vybere z CSV manifestu historické dokumenty bez hodnoty document_date.
- Standardně ponechá pouze dokumenty se stavem extraction_status = READY.
- Načte jejich původní textový obsah.
- Vyhledá kandidátní datumové stopy v názvu, cestě a obsahu.
- Vytvoří souhrnný Markdown dokument a JSON index.

K ČEMU:
- Umožní bezpečně určit datum dokumentů, které nebyly při prvním importu
  automaticky zařazeny do měsíce.
- Zabrání vynechání důležitých květnových a červnových zápisů,
  milestone dokumentů, navázání, People Layer a governance materiálů.
- Zachová původní Document ID, název, cestu, formát, varianty,
  nalezené datumové kandidáty a celý zdrojový obsah.

KDE:
- Aktivní skript:
  tools/documentation/
  25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1.py
- Výstupy:
  reports/documentation/history_review/

JAK:
- Zdrojové soubory pouze čte.
- Nic v archivu, manifestu ani databázi neupravuje.
- Text čte prioritně jako UTF-8 a následně zkouší Windows-1250.
- Dokumenty řadí podle relativní cesty a Document ID.
- Datumové kandidáty jsou pouze pracovní stopy, nikoli automaticky
  schválené datum dokumentu.

PŘÍKLAD:
py.exe -3.14 ^
  tools\documentation\25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1.py ^
  --manifest reports\documentation\history_corpus_manifest_latest.csv ^
  --source-root "docs\99_ARCHIVE\09_HISTORY\historie 25062026" ^
  --output-dir reports\documentation\history_review
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Any


SCRIPT_ID = "25_1_A_28_EXPORT_UNDATED_HISTORY_REVIEW_CORPUS_V1"
SCRIPT_VERSION = "1.0"

DEFAULT_REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
DEFAULT_LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")

SUPPORTED_TEXT_FORMATS = {"md", "txt", "sql", "csv"}

DATE_PATTERNS: tuple[tuple[str, re.Pattern[str]], ...] = (
    (
        "YYYY-MM-DD",
        re.compile(r"(?<!\d)(20\d{2})[-_.](0[1-9]|1[0-2])[-_.](0[1-9]|[12]\d|3[01])(?!\d)")
    ),
    (
        "YYYYMMDD",
        re.compile(r"(?<!\d)(20\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(?!\d)")
    ),
    (
        "DD.MM.YYYY",
        re.compile(r"(?<!\d)(0?[1-9]|[12]\d|3[01])[.](0?[1-9]|1[0-2])[.](20\d{2})(?!\d)")
    ),
    (
        "DD/MM/YYYY",
        re.compile(r"(?<!\d)(0?[1-9]|[12]\d|3[01])[/](0?[1-9]|1[0-2])[/](20\d{2})(?!\d)")
    ),
)


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
            "Exportuje READY historické dokumenty bez document_date "
            "do jednoho kontrolního Markdown souboru."
        )
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
    parser.add_argument(
        "--include-non-ready",
        action="store_true",
        help=(
            "Zahrne i nedatované dokumenty, které nemají "
            "extraction_status = READY."
        )
    )

    return parser


def read_manifest(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(f"Manifest nebyl nalezen: {path}")

    with path.open("r", encoding="utf-8-sig", newline="") as handle:
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


def select_undated(
    rows: list[dict[str, str]],
    include_non_ready: bool
) -> list[dict[str, str]]:
    selected: list[dict[str, str]] = []

    for row in rows:
        document_date = str(row.get("document_date") or "").strip()
        extraction_status = str(
            row.get("extraction_status") or ""
        ).strip().upper()

        if document_date:
            continue

        if not include_non_ready and extraction_status != "READY":
            continue

        selected.append(row)

    selected.sort(
        key=lambda item: (
            str(item.get("canonical_relative_path") or "").casefold(),
            str(item.get("document_id") or "")
        )
    )

    return selected


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

        normalized = text.replace("\r\n", "\n").replace("\r", "\n")
        return normalized, label

    text = raw.decode("utf-8", errors="replace")
    normalized = text.replace("\r\n", "\n").replace("\r", "\n")
    return normalized, "UTF-8 s náhradou chybných znaků"


def normalize_date_candidate(
    pattern_name: str,
    groups: tuple[str, ...]
) -> str | None:
    try:
        if pattern_name in {"YYYY-MM-DD", "YYYYMMDD"}:
            year, month, day = groups
        else:
            day, month, year = groups

        parsed = datetime(
            int(year),
            int(month),
            int(day)
        )
    except ValueError:
        return None

    return parsed.strftime("%Y-%m-%d")


def extract_date_candidates(
    title: str,
    relative_path: str,
    content: str
) -> list[dict[str, Any]]:
    sources = (
        ("TITLE", title),
        ("PATH", relative_path),
        ("CONTENT", content),
    )

    candidates: dict[str, dict[str, Any]] = {}

    for source_name, source_text in sources:
        if not source_text:
            continue

        for pattern_name, pattern in DATE_PATTERNS:
            for match in pattern.finditer(source_text):
                normalized = normalize_date_candidate(
                    pattern_name,
                    match.groups()
                )

                if not normalized:
                    continue

                record = candidates.setdefault(
                    normalized,
                    {
                        "date": normalized,
                        "sources": [],
                        "examples": [],
                    }
                )

                if source_name not in record["sources"]:
                    record["sources"].append(source_name)

                if len(record["examples"]) < 3:
                    start = max(0, match.start() - 45)
                    end = min(len(source_text), match.end() + 45)
                    snippet = (
                        source_text[start:end]
                        .replace("\n", " ")
                        .strip()
                    )

                    if snippet and snippet not in record["examples"]:
                        record["examples"].append(snippet)

    return sorted(
        candidates.values(),
        key=lambda item: item["date"]
    )


def escape_table(value: Any) -> str:
    return str(value or "").replace("|", r"\|").replace("\n", " ")


def render_candidates(candidates: list[dict[str, Any]]) -> str:
    if not candidates:
        return "NENALEZENO"

    return ", ".join(
        f"{item['date']} ({'+'.join(item['sources'])})"
        for item in candidates
    )


def render_markdown(
    exported: list[dict[str, Any]],
    manifest_path: Path,
    source_root: Path,
    include_non_ready: bool
) -> str:
    created_at = datetime.now().astimezone().isoformat()

    lines = [
        "# MATCHMATRIX – KONTROLNÍ KORPUS NEDATOVANÝCH HISTORICKÝCH DOKUMENTŮ",
        "",
        "## Informace o exportu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Dokumentů | {len(exported)} |",
        f"| Vytvořeno | {created_at} |",
        f"| Verze exportéru | {SCRIPT_VERSION} |",
        f"| Manifest | `{manifest_path}` |",
        f"| Zdrojový archiv | `{source_root}` |",
        (
            "| Filtr extraction_status | "
            + ("VŠECHNY" if include_non_ready else "READY")
            + " |"
        ),
        "| Úprava zdrojů | NE |",
        "",
        "## Význam datumových kandidátů",
        "",
        (
            "> Datumové kandidáty jsou pouze automaticky nalezené stopy "
            "v názvu, cestě nebo obsahu. Nejsou automaticky schváleným "
            "document_date. Finální datum musí být určeno řízenou kontrolou."
        ),
        "",
        "## Přehled dokumentů",
        "",
        (
            "| Pořadí | Document ID | Název | Formát | Varianty | "
            "Datumové kandidáty | Stav načtení |"
        ),
        "|---:|---|---|---|---:|---|---|",
    ]

    for index, item in enumerate(exported, start=1):
        lines.append(
            "| "
            f"{index} | "
            f"{escape_table(item.get('document_id'))} | "
            f"{escape_table(item.get('title'))} | "
            f"{escape_table(item.get('detected_format'))} | "
            f"{escape_table(item.get('variant_count'))} | "
            f"{escape_table(render_candidates(item.get('date_candidates', [])))} | "
            f"{escape_table(item.get('review_status'))} |"
        )

    lines.extend(
        [
            "",
            "## Zdrojové dokumenty",
            "",
            (
                "> Tento soubor je pracovní důkazní export. Obsah zdrojů "
                "není automaticky považován za aktuální nebo pravdivý stav "
                "projektu."
            ),
            "",
        ]
    )

    for index, item in enumerate(exported, start=1):
        lines.extend(
            [
                "---",
                "",
                (
                    f"# {index}. {item.get('document_id', '')} – "
                    f"{item.get('title', '')}"
                ),
                "",
                "## Metadata zdroje",
                "",
                "| Položka | Hodnota |",
                "|---|---|",
                f"| Document ID | {escape_table(item.get('document_id'))} |",
                "| Datum v manifestu | NEVYPLNĚNO |",
                f"| Název | {escape_table(item.get('title'))} |",
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
                    f"{escape_table(item.get('detected_format'))} |"
                ),
                (
                    "| Počet variant | "
                    f"{escape_table(item.get('variant_count'))} |"
                ),
                (
                    "| Počet sekcí | "
                    f"{escape_table(item.get('section_count'))} |"
                ),
                (
                    "| Extraction status | "
                    f"{escape_table(item.get('extraction_status'))} |"
                ),
                (
                    "| Stav načtení | "
                    f"{escape_table(item.get('review_status'))} |"
                ),
                (
                    "| Kódování při exportu | "
                    f"{escape_table(item.get('encoding_used'))} |"
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
                "## Nalezené datumové kandidáty",
                "",
            ]
        )

        candidates = item.get("date_candidates", [])

        if candidates:
            lines.extend(
                [
                    "| Datum | Zdroj stopy | Příklady kontextu |",
                    "|---|---|---|",
                ]
            )

            for candidate in candidates:
                examples = " / ".join(candidate.get("examples", []))
                lines.append(
                    "| "
                    f"{escape_table(candidate.get('date'))} | "
                    f"{escape_table(', '.join(candidate.get('sources', [])))} | "
                    f"{escape_table(examples)} |"
                )
        else:
            lines.append("Nebyla nalezena žádná jednoznačná datumová stopa.")

        lines.extend(
            [
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
            lines.append("[OBSAH NEBYL NAČTEN – viz stav a varování]")

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
        manifest_path = Path(args.manifest)
        source_root = Path(args.source_root)
        output_dir = Path(args.output_dir)

        rows = read_manifest(manifest_path)
        selected_rows = select_undated(
            rows,
            args.include_non_ready
        )

        if not selected_rows:
            print("ERROR: Nebyl nalezen žádný nedatovaný dokument.")
            return 2

        output_dir.mkdir(parents=True, exist_ok=True)

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
            item["date_candidates"] = []

            detected_format = str(
                row.get("detected_format") or ""
            ).strip().lower()

            if detected_format not in SUPPORTED_TEXT_FORMATS:
                item["review_status"] = (
                    "UNSUPPORTED_TEXT_EXPORT_FORMAT"
                )
                warnings.append(
                    f"{row.get('document_id')}: "
                    f"formát {detected_format} není podporován."
                )
                exported.append(item)
                continue

            if not source_path.is_file():
                item["review_status"] = "SOURCE_NOT_FOUND"
                warnings.append(
                    f"{row.get('document_id')}: "
                    f"zdroj nebyl nalezen: {source_path}"
                )
                exported.append(item)
                continue

            try:
                content, encoding_used = decode_text_file(source_path)
            except OSError as exc:
                item["review_status"] = "READ_ERROR"
                warnings.append(
                    f"{row.get('document_id')}: chyba čtení: {exc}"
                )
                exported.append(item)
                continue

            item["content"] = content
            item["encoding_used"] = encoding_used
            item["export_text_sha256"] = hashlib.sha256(
                content.encode("utf-8")
            ).hexdigest()
            item["date_candidates"] = extract_date_candidates(
                str(row.get("title") or ""),
                relative_path,
                content
            )

            exported.append(item)

        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_name = f"history_undated_review_{stamp}"

        markdown_path = output_dir / f"{base_name}.md"
        json_path = output_dir / f"{base_name}.json"
        latest_markdown_path = (
            output_dir / "history_undated_review_latest.md"
        )
        latest_json_path = (
            output_dir / "history_undated_review_latest.json"
        )

        markdown_text = render_markdown(
            exported,
            manifest_path,
            source_root,
            args.include_non_ready
        )

        payload = {
            "generated_at": datetime.now().astimezone().isoformat(),
            "engine": SCRIPT_ID,
            "engine_version": SCRIPT_VERSION,
            "manifest": str(manifest_path),
            "source_root": str(source_root),
            "include_non_ready": bool(args.include_non_ready),
            "document_count": len(exported),
            "ready_count": sum(
                1
                for item in exported
                if item.get("review_status") == "READY"
            ),
            "with_date_candidate_count": sum(
                1
                for item in exported
                if item.get("date_candidates")
            ),
            "without_date_candidate_count": sum(
                1
                for item in exported
                if not item.get("date_candidates")
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
                "UNDATED_HISTORY_REVIEW_CORPUS_READY"
                if not warnings
                else
                "UNDATED_HISTORY_REVIEW_CORPUS_READY_WITH_WARNINGS"
            ),
        }

        encoded_json = json.dumps(
            payload,
            ensure_ascii=False,
            indent=2
        )

        for path in (markdown_path, latest_markdown_path):
            path.write_text(markdown_text, encoding="utf-8")

        for path in (json_path, latest_json_path):
            path.write_text(encoded_json, encoding="utf-8")

        print("MATCHMATRIX UNDATED HISTORY REVIEW EXPORT")
        print("=" * 72)
        print(f"DOCUMENTS           : {len(exported)}")
        print(
            "READY               : "
            + str(
                sum(
                    1
                    for item in exported
                    if item.get("review_status") == "READY"
                )
            )
        )
        print(
            "WITH DATE CANDIDATE : "
            + str(
                sum(
                    1
                    for item in exported
                    if item.get("date_candidates")
                )
            )
        )
        print(
            "WITHOUT CANDIDATE   : "
            + str(
                sum(
                    1
                    for item in exported
                    if not item.get("date_candidates")
                )
            )
        )
        print(f"WARNINGS            : {len(warnings)}")

        for item in exported:
            candidates = render_candidates(
                item.get("date_candidates", [])
            )
            print(
                f"{item.get('document_id', '')} | "
                f"{item.get('review_status', '')} | "
                f"{candidates} | "
                f"{item.get('title', '')}"
            )

        print("-" * 72)
        print(f"MARKDOWN            : {markdown_path}")
        print(f"JSON                : {json_path}")
        print(f"LATEST MD           : {latest_markdown_path}")
        print(f"LATEST JSON         : {latest_json_path}")
        print("SOURCE MODIFIED     : False")
        print(f"FINAL STATUS        : {payload['final_status']}")

        return 0

    except Exception as exc:
        print(f"FATAL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    import sys
    raise SystemExit(main())
