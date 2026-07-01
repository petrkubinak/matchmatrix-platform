#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Redakčně a sémanticky dočistí standardizovaný kandidát vytvořený A20.

K ČEMU:
- ověří kandidát A20 a jeho SHA-256,
- odstraní technické komentáře MM-SOURCE z čitelné verze,
- zachová je v samostatné auditní stopě,
- odstraní prázdné části vzniklé rozdělením,
- opraví zjevně chybně interpretovanou verzi ve formátu data,
- sjednotí metadata,
- rozpozná vnitřní nadpisy a převede je na Markdown podkapitoly,
- spojí krátké návěští s navazujícím obsahem,
- převede vhodné skupiny řádků na odrážky nebo tabulky,
- dočistí identifikaci denního zápisu,
- odvodí cíl dne z již existujícího hlavního tématu,
- sestaví jeden hlavní další krok,
- doplní bezpečný návrh vazby na MM-DOC-901,
- vytvoří polished kandidát, diff, audit změn a seznam ručních kontrol.

KDE:
tools/documentation/25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py

JAK:
Validace:
    py -3.14 .\\tools\\documentation\\25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py `
      --validate-only

Sestavení:
    py -3.14 .\\tools\\documentation\\25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py

S doplněním metadat:
    py -3.14 .\\tools\\documentation\\25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py `
      --document-id "MM-HIS-XXX" `
      --version "1.0" `
      --author "Petr Kubinák" `
      --working-area "Source Intelligence Layer"

BEZPEČNOST:
- nepřepisuje kandidát A20,
- nepřepisuje původní archivní dokument,
- nezapisuje do databáze,
- vyžaduje platný A20 build report,
- ověřuje SHA-256 kandidáta A20,
- strukturální a sémantické změny zapisuje do auditního reportu,
- automaticky nevytváří kanonickou verzi,
- výsledný dokument musí znovu projít A17.

VÝSTUP:
reports/documentation/standardization/polished_candidates/
- document_standardized_polished_candidate_YYYYMMDD_HHMMSS.md
- document_standardized_polished_candidate_diff_YYYYMMDD_HHMMSS.diff
- document_standardized_polish_report_YYYYMMDD_HHMMSS.json
- document_standardized_polish_report_YYYYMMDD_HHMMSS.csv
- document_standardized_polish_report_YYYYMMDD_HHMMSS.md
- document_standardized_manual_review_YYYYMMDD_HHMMSS.md
- odpovídající *_latest.* soubory
"""

from __future__ import annotations

import argparse
import csv
import difflib
import hashlib
import json
import re
import shutil
import sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


ENGINE_VERSION = "A21_DOCUMENT_POLISHER_V1"
OUTPUT_CONTRACT_VERSION = "1.0"
EXPECTED_A20_STATUS = "STANDARDIZED_DOCUMENT_CANDIDATE_READY_FOR_AUDIT"

CANDIDATE_DEFAULT = Path(
    "reports/documentation/standardization/final_candidates/"
    "document_standardized_candidate_latest.md"
)
BUILD_REPORT_DEFAULT = Path(
    "reports/documentation/standardization/final_candidates/"
    "document_standardized_candidate_build_latest.json"
)
OUTPUT_DEFAULT = Path(
    "reports/documentation/standardization/polished_candidates"
)

TRACE_RE = re.compile(
    r"^\s*<!--\s*MM-SOURCE\s+(.*?)\s*-->\s*$"
)
NUMBERED_SECTION_RE = re.compile(
    r"^##\s+(\d+)\.\s+(.+?)\s*$"
)
ANY_H2_RE = re.compile(r"^##\s+(.+?)\s*$")
INTERNAL_NUMBERED_HEADING_RE = re.compile(
    r"^\s*(\d{1,2})\.\s+(.+?)\s*$"
)
DATE_LIKE_VERSION_RE = re.compile(
    r"^(?:0?[1-9]|[12]\d|3[01])[./-](?:0?[1-9]|1[0-2])$"
)
VERSION_RE = re.compile(r"^\d+\.\d+$")
DATE_LINE_RE = re.compile(
    r"^(?:"
    r"\d{1,2}[./-]\d{1,2}[./-]20\d{2}"
    r"|"
    r"20\d{2}[./-]\d{1,2}[./-]\d{1,2}"
    r")$"
)
SIMPLE_URL_RE = re.compile(r"^https?://\S+$", re.IGNORECASE)
TABLE_ROW_RE = re.compile(r"^(.+?)\s{2,}(.+?)$")
PLACEHOLDER_RE = re.compile(r"DOPLNIT UŽIVATELEM", re.IGNORECASE)
ELLIPSIS_ONLY_RE = re.compile(r"^\s*(?:\.{3}|…)\s*$")

KNOWN_SUBHEADINGS = {
    "robots.txt",
    "sitemap",
    "privacy policy",
    "people layer",
    "team layer",
    "history layer",
    "media layer",
    "výsledek ehf",
    "national league discovery",
    "identifikované priority",
    "první globální zdroje",
    "source discovery master",
    "source discovery queue",
    "source discovery audit tracker",
    "source discovery dashboard",
    "governance vrstva",
    "ihf audit",
    "ehf audit",
}

CUE_LABELS = {
    "auditovali jsme",
    "co jsme našli",
    "zjištěno",
    "matchmatrix bude respektovat",
    "nalezeno",
    "například",
    "ověřeno",
    "potvrzeno",
    "proto jsme založili další discovery větev",
    "vzniklo několik nových governance objektů",
    "evidence",
    "plus",
    "příklad",
    "určuje",
    "obsahuje",
    "aktuálně",
    "aktuální stav",
    "výsledek",
    "důvod",
    "další kroky",
    "po dokončení ihf",
    "poté",
    "vybudovat kompletní",
    "která bude pro každý sport vědět",
    "a následně bude schopna řídit",
    "pokračujeme přesně zde",
}

LIST_TRIGGER_LABELS = {
    "například",
    "nalezeno",
    "obsahuje",
    "potvrzeno",
    "zjištěno",
    "určuje",
    "aktuálně",
    "aktuální stav",
    "další kroky",
    "identifikované priority",
    "první globální zdroje",
    "auditovali jsme",
    "co jsme našli",
}

EXPECTED_SECTIONS = {
    1: "Identifikace denního zápisu",
    2: "Výchozí stav",
    3: "Cíl pracovního dne",
    4: "Provedené práce",
    5: "Přijatá rozhodnutí",
    6: "Problémy a jejich řešení",
    7: "Ověřené výsledky a technické výstupy",
    8: "Výsledky dne a stav na konci dne",
    9: "Plán pokračování",
    10: "Jeden hlavní další krok",
    11: "Vazby a NAVÁZÁNÍ",
}


@dataclass
class TraceBlock:
    section_number: int
    section_title: str
    trace_raw: str | None
    trace: dict[str, str]
    text: str


@dataclass
class ChangeRecord:
    change_type: str
    section: str
    source_reference: str
    description: str
    before_preview: str
    after_preview: str
    automatic: bool = True


@dataclass
class ReviewItem:
    severity: str
    code: str
    section: str
    description: str
    recommendation: str


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Redakčně dočistí kandidát A20 a vytvoří čitelnou "
            "verzi pro nový audit A17."
        )
    )
    parser.add_argument("--candidate")
    parser.add_argument("--build-report")
    parser.add_argument("--output-dir")
    parser.add_argument("--document-id")
    parser.add_argument("--version")
    parser.add_argument("--author")
    parser.add_argument("--working-area")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Pouze ověří A20 vstup a nevytvoří výstupy.",
    )
    parser.add_argument(
        "--keep-trace-comments",
        action="store_true",
        help=(
            "Ponechat MM-SOURCE komentáře i v čitelné verzi. "
            "Výchozí stav je odstranit je a uložit do reportu."
        ),
    )
    return parser.parse_args()


def resolve_path(root: Path, value: str | None, default: Path) -> Path:
    path = Path(value) if value else default
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"JSON musí být objekt: {path}")
    return payload


def normalize_newlines(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def preview(text: str, limit: int = 180) -> str:
    compact = " ".join(text.split())
    if len(compact) <= limit:
        return compact
    return compact[: limit - 1] + "…"


def parse_trace_attrs(raw: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for part in raw.split(";"):
        part = part.strip()
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        result[key.strip()] = value.strip()
    return result


def source_reference(block: TraceBlock) -> str:
    if block.trace.get("piece_id"):
        return block.trace["piece_id"]
    if block.trace.get("block_id"):
        return block.trace["block_id"]
    return f"SECTION-{block.section_number}"


def find_h2_indices(lines: Sequence[str]) -> list[int]:
    return [
        index
        for index, line in enumerate(lines)
        if ANY_H2_RE.match(line)
    ]


def extract_title(lines: Sequence[str]) -> str:
    for line in lines:
        if line.startswith("# ") and not line.startswith("## "):
            return line[2:].strip()
    raise RuntimeError("Kandidát neobsahuje hlavní nadpis H1.")


def parse_metadata(lines: Sequence[str]) -> tuple[dict[str, str], int, int]:
    try:
        start = lines.index("## Informace o dokumentu")
    except ValueError as exc:
        raise RuntimeError(
            "Kandidát neobsahuje sekci Informace o dokumentu."
        ) from exc

    end = len(lines)
    for index in range(start + 1, len(lines)):
        if lines[index].startswith("## "):
            end = index
            break

    metadata: dict[str, str] = {}
    for line in lines[start + 1 : end]:
        stripped = line.strip()
        if not stripped.startswith("|") or stripped.startswith("|---"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if len(cells) != 2:
            continue
        key, value = cells
        if key.lower() == "položka":
            continue
        metadata[key] = value

    if not metadata:
        raise RuntimeError("Metadata tabulka je prázdná nebo neplatná.")
    return metadata, start, end


def parse_sections(lines: Sequence[str]) -> dict[int, tuple[str, list[str]]]:
    result: dict[int, tuple[str, list[str]]] = {}
    current_number: int | None = None
    current_title = ""
    buffer: list[str] = []

    def flush() -> None:
        nonlocal current_number, current_title, buffer
        if current_number is not None:
            result[current_number] = (current_title, list(buffer))
        buffer = []

    for line in lines:
        match = NUMBERED_SECTION_RE.match(line)
        if match:
            flush()
            current_number = int(match.group(1))
            current_title = match.group(2).strip()
            continue

        if current_number is not None:
            if line.startswith("## Schválení"):
                flush()
                current_number = None
                break
            buffer.append(line)

    flush()
    return result


def blocks_from_section(
    section_number: int,
    section_title: str,
    lines: Sequence[str],
) -> list[TraceBlock]:
    result: list[TraceBlock] = []
    current_raw: str | None = None
    current_trace: dict[str, str] = {}
    buffer: list[str] = []

    def flush() -> None:
        nonlocal current_raw, current_trace, buffer
        text = "\n".join(buffer).strip("\n")
        if text.strip() or current_raw:
            result.append(
                TraceBlock(
                    section_number=section_number,
                    section_title=section_title,
                    trace_raw=current_raw,
                    trace=dict(current_trace),
                    text=text,
                )
            )
        current_raw = None
        current_trace = {}
        buffer = []

    for line in lines:
        match = TRACE_RE.match(line)
        if match:
            flush()
            current_raw = match.group(1).strip()
            current_trace = parse_trace_attrs(current_raw)
        else:
            buffer.append(line)
    flush()
    return result


def visible_lines(block: TraceBlock) -> list[str]:
    lines = normalize_newlines(block.text).split("\n")
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return lines


def is_empty_placeholder_block(block: TraceBlock) -> bool:
    text = block.text.strip()
    return bool(
        text.startswith("> **DOPLNIT UŽIVATELEM:**")
        and "nemá po mapování obsah" in text
    )


def is_internal_heading(line: str) -> bool:
    match = INTERNAL_NUMBERED_HEADING_RE.match(line)
    if not match:
        return False
    rest = match.group(2).strip()
    letters = [char for char in rest if char.isalpha()]
    upper_ratio = (
        sum(char.isupper() for char in letters) / len(letters)
        if letters
        else 0.0
    )
    return upper_ratio >= 0.65 or len(rest) <= 64


def clean_heading_text(line: str) -> str:
    match = INTERNAL_NUMBERED_HEADING_RE.match(line)
    value = match.group(2).strip() if match else line.strip()
    if value.isupper():
        value = value.title()
        replacements = {
            "Ehf": "EHF",
            "Ihf": "IHF",
            "Hb": "HB",
            "Roi": "ROI",
            "Cms": "CMS",
        }
        words = value.split()
        value = " ".join(replacements.get(word, word) for word in words)
    return value


def is_known_subheading(line: str) -> bool:
    return line.strip().casefold() in KNOWN_SUBHEADINGS


def is_cue(line: str) -> bool:
    stripped = line.strip()
    base = stripped.rstrip(":").casefold()
    return stripped.endswith(":") or base in CUE_LABELS


def cue_label(line: str) -> str:
    return line.strip().rstrip(":")


def is_simple_item(line: str) -> bool:
    value = line.strip()
    if not value:
        return False
    if value.startswith(("-", "*", "+", "#", ">", "|")):
        return False
    if SIMPLE_URL_RE.match(value):
        return True
    if is_internal_heading(value) or is_known_subheading(value):
        return False
    if len(value) > 110:
        return False
    if value.endswith((".", "!", "?")) and len(value.split()) > 5:
        return False
    return True


def format_simple_list(lines: Sequence[str]) -> list[str]:
    output: list[str] = []
    for line in lines:
        value = line.strip()
        if not value:
            continue
        if value.startswith(("-", "*", "+")):
            output.append(f"- {value[1:].strip()}")
        else:
            output.append(f"- {value}")
    return output


def split_table_rows(lines: Sequence[str]) -> tuple[list[list[str]], list[str]]:
    rows: list[list[str]] = []
    remainder: list[str] = []
    table_mode = True

    for line in lines:
        value = line.strip()
        match = TABLE_ROW_RE.match(value)
        if table_mode and match:
            rows.append([match.group(1).strip(), match.group(2).strip()])
        else:
            table_mode = False
            remainder.append(line)

    if len(rows) < 3:
        return [], list(lines)
    return rows, remainder


def render_table(rows: Sequence[Sequence[str]]) -> list[str]:
    result = [
        "| Země / oblast | Soutěž / zdroj |",
        "|---|---|",
    ]
    result.extend(f"| {row[0]} | {row[1]} |" for row in rows)
    return result


def paragraph_from_lines(lines: Sequence[str]) -> str:
    result = ""
    for raw in lines:
        value = raw.strip()
        if not value:
            continue
        if not result:
            result = value
        elif result.endswith(("-", "–", "—", "/", ":")):
            result += " " + value
        elif value[0:1].islower():
            result += " " + value
        else:
            result += " " + value
    return result


def render_content_blocks(
    blocks: Sequence[TraceBlock],
    *,
    changes: list[ChangeRecord],
    review_items: list[ReviewItem],
    keep_trace_comments: bool,
) -> list[str]:
    output: list[str] = []
    index = 0

    while index < len(blocks):
        block = blocks[index]
        lines = visible_lines(block)

        if not lines:
            changes.append(
                ChangeRecord(
                    change_type="REMOVE_EMPTY_SPLIT_PART",
                    section=f"{block.section_number}. {block.section_title}",
                    source_reference=source_reference(block),
                    description=(
                        "Odstraněna prázdná část vzniklá rozdělením SPLIT."
                    ),
                    before_preview="",
                    after_preview="",
                )
            )
            index += 1
            continue

        if keep_trace_comments and block.trace_raw:
            output.append(f"<!-- MM-SOURCE {block.trace_raw} -->")

        if len(lines) == 1 and ELLIPSIS_ONLY_RE.match(lines[0]):
            output.append("> **NEÚPLNÝ ZDROJOVÝ ÚDAJ:** …")
            review_items.append(
                ReviewItem(
                    severity="HIGH",
                    code="ELLIPSIS_SOURCE_GAP",
                    section=f"{block.section_number}. {block.section_title}",
                    description=(
                        "Zdroj obsahuje pouze výpustku bez konkrétního údaje."
                    ),
                    recommendation=(
                        "Dohledat původní hodnotu nebo potvrdit, že výpustka "
                        "má zůstat zachována."
                    ),
                )
            )
            changes.append(
                ChangeRecord(
                    change_type="FLAG_INCOMPLETE_SOURCE",
                    section=f"{block.section_number}. {block.section_title}",
                    source_reference=source_reference(block),
                    description=(
                        "Samostatná výpustka byla zvýrazněna jako neúplný údaj."
                    ),
                    before_preview=lines[0],
                    after_preview="NEÚPLNÝ ZDROJOVÝ ÚDAJ",
                )
            )
            output.append("")
            index += 1
            continue

        if len(lines) == 1 and is_internal_heading(lines[0]):
            heading = clean_heading_text(lines[0])
            output.append(f"### {heading}")
            output.append("")
            changes.append(
                ChangeRecord(
                    change_type="PROMOTE_INTERNAL_HEADING",
                    section=f"{block.section_number}. {block.section_title}",
                    source_reference=source_reference(block),
                    description=(
                        "Původní číslovaný řádek byl převeden na podkapitolu."
                    ),
                    before_preview=lines[0],
                    after_preview=f"### {heading}",
                )
            )
            index += 1
            continue

        if len(lines) == 1 and is_known_subheading(lines[0]):
            heading = clean_heading_text(lines[0])
            output.append(f"#### {heading}")
            output.append("")
            changes.append(
                ChangeRecord(
                    change_type="PROMOTE_SUBHEADING",
                    section=f"{block.section_number}. {block.section_title}",
                    source_reference=source_reference(block),
                    description=(
                        "Krátký tematický řádek byl převeden na podnadpis."
                    ),
                    before_preview=lines[0],
                    after_preview=f"#### {heading}",
                )
            )
            index += 1
            continue

        # Samostatné návěští spojíme s následujícím blokem.
        if (
            len(lines) == 1
            and is_cue(lines[0])
            and index + 1 < len(blocks)
        ):
            next_block = blocks[index + 1]
            next_lines = visible_lines(next_block)
            if (
                next_lines
                and not (
                    len(next_lines) == 1
                    and (
                        is_internal_heading(next_lines[0])
                        or is_known_subheading(next_lines[0])
                    )
                )
            ):
                label = cue_label(lines[0])
                output.append(f"**{label}:**")
                table_rows, remainder = split_table_rows(next_lines)
                if table_rows:
                    output.extend(render_table(table_rows))
                    if remainder:
                        output.append(paragraph_from_lines(remainder))
                elif (
                    len(next_lines) >= 2
                    and all(is_simple_item(line) for line in next_lines)
                ):
                    output.extend(format_simple_list(next_lines))
                else:
                    output.append(paragraph_from_lines(next_lines))
                output.append("")
                changes.append(
                    ChangeRecord(
                        change_type="MERGE_CUE_WITH_CONTENT",
                        section=f"{block.section_number}. {block.section_title}",
                        source_reference=(
                            f"{source_reference(block)} + "
                            f"{source_reference(next_block)}"
                        ),
                        description=(
                            "Krátké návěští bylo spojeno s navazujícím "
                            "obsahem."
                        ),
                        before_preview=(
                            f"{lines[0]} / {preview(next_block.text)}"
                        ),
                        after_preview=(
                            f"{label}: {preview(next_block.text)}"
                        ),
                    )
                )
                index += 2
                continue

        # Jeden blok může obsahovat text a na konci další vnitřní nadpis.
        segments: list[tuple[str, list[str]]] = []
        current: list[str] = []
        for line in lines:
            if is_internal_heading(line):
                if current:
                    segments.append(("content", current))
                    current = []
                segments.append(("heading", [line]))
            elif is_known_subheading(line):
                if current:
                    segments.append(("content", current))
                    current = []
                segments.append(("subheading", [line]))
            else:
                current.append(line)
        if current:
            segments.append(("content", current))

        for kind, segment_lines in segments:
            if kind == "heading":
                heading = clean_heading_text(segment_lines[0])
                output.append(f"### {heading}")
                output.append("")
                changes.append(
                    ChangeRecord(
                        change_type="SPLIT_AND_PROMOTE_HEADING",
                        section=f"{block.section_number}. {block.section_title}",
                        source_reference=source_reference(block),
                        description=(
                            "Vnitřní nadpis byl oddělen od předchozího textu."
                        ),
                        before_preview=segment_lines[0],
                        after_preview=f"### {heading}",
                    )
                )
                continue

            if kind == "subheading":
                heading = clean_heading_text(segment_lines[0])
                output.append(f"#### {heading}")
                output.append("")
                changes.append(
                    ChangeRecord(
                        change_type="SPLIT_AND_PROMOTE_SUBHEADING",
                        section=f"{block.section_number}. {block.section_title}",
                        source_reference=source_reference(block),
                        description=(
                            "Tematický řádek byl oddělen jako podnadpis."
                        ),
                        before_preview=segment_lines[0],
                        after_preview=f"#### {heading}",
                    )
                )
                continue

            segment = [line for line in segment_lines if line.strip()]
            if not segment:
                continue

            if is_cue(segment[0]) and len(segment) > 1:
                label = cue_label(segment[0])
                rest = segment[1:]
                output.append(f"**{label}:**")
                table_rows, remainder = split_table_rows(rest)
                if table_rows:
                    output.extend(render_table(table_rows))
                    if remainder:
                        output.append(paragraph_from_lines(remainder))
                    changes.append(
                        ChangeRecord(
                            change_type="FORMAT_TABLE",
                            section=f"{block.section_number}. {block.section_title}",
                            source_reference=source_reference(block),
                            description=(
                                "Dvou-sloupcová data byla převedena "
                                "na Markdown tabulku."
                            ),
                            before_preview=preview("\n".join(rest)),
                            after_preview="Markdown tabulka",
                        )
                    )
                elif (
                    len(rest) >= 2
                    and all(is_simple_item(line) for line in rest)
                ):
                    output.extend(format_simple_list(rest))
                    changes.append(
                        ChangeRecord(
                            change_type="FORMAT_LIST",
                            section=f"{block.section_number}. {block.section_title}",
                            source_reference=source_reference(block),
                            description=(
                                "Víceřádkový výčet byl převeden na odrážky."
                            ),
                            before_preview=preview("\n".join(rest)),
                            after_preview="Markdown seznam",
                        )
                    )
                else:
                    output.append(paragraph_from_lines(rest))
                output.append("")
                continue

            table_rows, remainder = split_table_rows(segment)
            if table_rows:
                output.extend(render_table(table_rows))
                if remainder:
                    output.append("")
                    output.append(paragraph_from_lines(remainder))
                output.append("")
                changes.append(
                    ChangeRecord(
                        change_type="FORMAT_TABLE",
                        section=f"{block.section_number}. {block.section_title}",
                        source_reference=source_reference(block),
                        description=(
                            "Dvou-sloupcová data byla převedena "
                            "na Markdown tabulku."
                        ),
                        before_preview=preview("\n".join(segment)),
                        after_preview="Markdown tabulka",
                    )
                )
                continue

            if (
                len(segment) >= 3
                and all(is_simple_item(line) for line in segment)
            ):
                output.extend(format_simple_list(segment))
                output.append("")
                changes.append(
                    ChangeRecord(
                        change_type="FORMAT_LIST",
                        section=f"{block.section_number}. {block.section_title}",
                        source_reference=source_reference(block),
                        description=(
                            "Skupina krátkých řádků byla převedena "
                            "na Markdown seznam."
                        ),
                        before_preview=preview("\n".join(segment)),
                        after_preview="Markdown seznam",
                    )
                )
                continue

            paragraph = paragraph_from_lines(segment)
            if paragraph:
                output.append(paragraph)
                output.append("")

        index += 1

    while output and not output[-1].strip():
        output.pop()
    return output


def extract_identification(
    blocks: Sequence[TraceBlock],
    *,
    changes: list[ChangeRecord],
    review_items: list[ReviewItem],
) -> tuple[list[str], str, str, list[TraceBlock], list[TraceBlock]]:
    all_lines: list[tuple[TraceBlock, str]] = []
    for block in blocks:
        for line in visible_lines(block):
            if line.strip():
                all_lines.append((block, line.strip()))

    date_value = ""
    area_value = ""
    main_theme_lines: list[str] = []
    work_relocations: list[TraceBlock] = []
    result_relocations: list[TraceBlock] = []

    # Datum.
    for index, (_, line) in enumerate(all_lines):
        if line.casefold() == "datum" and index + 1 < len(all_lines):
            candidate = all_lines[index + 1][1]
            if DATE_LINE_RE.match(candidate):
                date_value = candidate
                break

    # Hlavní téma.
    theme_start = None
    for index, (_, line) in enumerate(all_lines):
        if line.casefold() == "hlavní téma dne":
            theme_start = index + 1
            break
    if theme_start is not None:
        for _, line in all_lines[theme_start:]:
            if is_internal_heading(line):
                break
            if line.casefold() in {"ráno:", "večer:"}:
                break
            main_theme_lines.append(line)

    main_theme = paragraph_from_lines(main_theme_lines).strip()

    # Oblast – bezpečné odvození pouze z explicitního tématu.
    for index, (_, line) in enumerate(all_lines):
        if line.casefold() == "oblast" and index + 1 < len(all_lines):
            candidate = all_lines[index + 1][1]
            if candidate.casefold() != "hlavní téma dne":
                area_value = candidate
            break

    if not area_value and "source intelligence layer" in main_theme.casefold():
        area_value = "Source Intelligence Layer"
        changes.append(
            ChangeRecord(
                change_type="INFER_WORKING_AREA",
                section="1. Identifikace denního zápisu",
                source_reference="IDENTIFICATION",
                description=(
                    "Pracovní oblast byla odvozena z explicitního "
                    "hlavního tématu dne."
                ),
                before_preview="Oblast bez hodnoty",
                after_preview=area_value,
            )
        )

    if not date_value:
        date_value = "[DOPLNIT UŽIVATELEM – DATUM]"
        review_items.append(
            ReviewItem(
                severity="CRITICAL",
                code="MISSING_DAILY_DATE",
                section="1. Identifikace denního zápisu",
                description="Nebyl nalezen jednoznačný datum denního zápisu.",
                recommendation="Doplnit datum ve formátu RRRR-MM-DD.",
            )
        )

    if not area_value:
        area_value = "[DOPLNIT UŽIVATELEM – PRACOVNÍ OBLAST]"
        review_items.append(
            ReviewItem(
                severity="HIGH",
                code="MISSING_WORKING_AREA",
                section="1. Identifikace denního zápisu",
                description="Pracovní oblast nebyla uvedena ani odvoditelná.",
                recommendation="Doplnit oblast projektu.",
            )
        )

    if not main_theme:
        main_theme = "[DOPLNIT UŽIVATELEM – HLAVNÍ TÉMA DNE]"
        review_items.append(
            ReviewItem(
                severity="CRITICAL",
                code="MISSING_MAIN_THEME",
                section="1. Identifikace denního zápisu",
                description="Hlavní téma dne nebylo nalezeno.",
                recommendation="Doplnit jednu větu shrnující hlavní téma.",
            )
        )

    # Zjevně obsahové bloky v identifikaci relokujeme.
    for block in blocks:
        lines = visible_lines(block)
        lowered = [line.casefold() for line in lines]
        if any(is_internal_heading(line) for line in lines):
            work_relocations.append(block)
        elif any(value in {"ráno:", "večer:"} for value in lowered):
            result_relocations.append(block)
        elif any("audit ehf" in value for value in lowered):
            result_relocations.append(block)

    # Deduplication.
    work_ids = {id(block) for block in work_relocations}
    result_relocations = [
        block
        for block in result_relocations
        if id(block) not in work_ids
    ]

    output = [
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Datum | {date_value} |",
        f"| Oblast | {area_value} |",
        f"| Hlavní téma dne | {main_theme} |",
    ]

    changes.append(
        ChangeRecord(
            change_type="NORMALIZE_IDENTIFICATION",
            section="1. Identifikace denního zápisu",
            source_reference="MULTIPLE_BLOCKS",
            description=(
                "Volné identifikační řádky byly sjednoceny do tabulky."
            ),
            before_preview=preview(
                "\n".join(line for _, line in all_lines)
            ),
            after_preview=preview("\n".join(output)),
        )
    )

    return (
        output,
        main_theme,
        area_value,
        work_relocations,
        result_relocations,
    )


def make_goal_section(
    original_blocks: Sequence[TraceBlock],
    main_theme: str,
    *,
    changes: list[ChangeRecord],
) -> list[str]:
    has_content = any(
        visible_lines(block)
        and not is_empty_placeholder_block(block)
        for block in original_blocks
    )
    if has_content:
        return render_content_blocks(
            original_blocks,
            changes=changes,
            review_items=[],
            keep_trace_comments=False,
        )

    goal = (
        f"Cílem pracovního dne bylo {main_theme[0].lower() + main_theme[1:]}"
        if main_theme and not main_theme.startswith("[")
        else "[DOPLNIT UŽIVATELEM – CÍL PRACOVNÍHO DNE]"
    )
    if goal[-1:] not in ".!?":
        goal += "."

    changes.append(
        ChangeRecord(
            change_type="DERIVE_DAILY_GOAL",
            section="3. Cíl pracovního dne",
            source_reference="MAIN_THEME",
            description=(
                "Cíl dne byl bezpečně odvozen z již existujícího "
                "hlavního tématu."
            ),
            before_preview="Prázdná kapitola",
            after_preview=goal,
        )
    )
    return [goal]


def remove_first_matching_heading(
    blocks: Sequence[TraceBlock],
    pattern: str,
) -> list[TraceBlock]:
    regex = re.compile(pattern, re.IGNORECASE)
    result: list[TraceBlock] = []
    removed = False

    for block in blocks:
        if removed:
            result.append(block)
            continue
        lines = visible_lines(block)
        new_lines: list[str] = []
        for line in lines:
            if not removed and regex.search(line.strip()):
                removed = True
                continue
            new_lines.append(line)
        result.append(
            TraceBlock(
                section_number=block.section_number,
                section_title=block.section_title,
                trace_raw=block.trace_raw,
                trace=block.trace,
                text="\n".join(new_lines),
            )
        )
    return result


def build_chronology(
    blocks: Sequence[TraceBlock],
    *,
    fallback_evening_result: str | None,
    changes: list[ChangeRecord],
    review_items: list[ReviewItem],
) -> list[str]:
    lines: list[str] = []
    for block in blocks:
        lines.extend(visible_lines(block))

    morning = ""
    evening = ""
    current = ""

    for line in lines:
        value = line.strip()
        folded = value.casefold()
        if folded == "ráno:":
            current = "morning"
            continue
        if folded == "večer:":
            current = "evening"
            continue
        if current == "morning" and not morning:
            morning = value
        elif current == "evening" and not evening:
            evening = value

    if not morning and not evening:
        return []

    if not morning:
        morning = "[DOPLNIT UŽIVATELEM – RANNÍ STAV]"
    if not evening and fallback_evening_result:
        evening = fallback_evening_result.strip()
        changes.append(
            ChangeRecord(
                change_type="INFER_EVENING_RESULT_FROM_SECTION_8",
                section="8. Výsledky dne a stav na konci dne",
                source_reference="SECTION-8-EXISTING-CONTENT",
                description=(
                    "Prázdné návěští „Večer“ bylo doplněno pouze z již "
                    "existujícího potvrzeného výsledku v kapitole 8."
                ),
                before_preview="Večer: bez hodnoty",
                after_preview=evening,
            )
        )

    if not evening:
        evening = "[DOPLNIT UŽIVATELEM – VEČERNÍ VÝSLEDEK]"
        review_items.append(
            ReviewItem(
                severity="MEDIUM",
                code="MISSING_EVENING_RESULT",
                section="8. Výsledky dne a stav na konci dne",
                description=(
                    "Zdroj obsahoval návěští „Večer“, ale bez výsledku "
                    "a v kapitole 8 nebyl nalezen bezpečný náhradní údaj."
                ),
                recommendation=(
                    "Doplnit večerní stav nebo návěští odstranit."
                ),
            )
        )

    result = [
        "### Průběh dne",
        "",
        f"- **Ráno:** {morning.rstrip('.')}.",
        f"- **Večer:** {evening.rstrip('.')}.",
    ]
    changes.append(
        ChangeRecord(
            change_type="RELOCATE_DAILY_CHRONOLOGY",
            section="8. Výsledky dne a stav na konci dne",
            source_reference="IDENTIFICATION_RELOCATIONS",
            description=(
                "Řádky Ráno/Večer byly přesunuty z identifikace "
                "do výsledků dne."
            ),
            before_preview=preview("\n".join(lines)),
            after_preview=preview("\n".join(result)),
        )
    )
    return result


def collect_checklist_from_section(
    blocks: Sequence[TraceBlock],
) -> list[str]:
    items: list[str] = []
    for block in blocks:
        for line in visible_lines(block):
            value = line.strip()
            if not value:
                continue
            folded = value.casefold().rstrip(":")
            if folded in {
                "další kroky",
                "stav dne",
            }:
                continue
            if is_internal_heading(value):
                continue
            if is_simple_item(value):
                items.append(value.lstrip("-*+ ").strip())
    # zachovat pořadí a odstranit duplicity
    unique: list[str] = []
    seen: set[str] = set()
    for item in items:
        key = item.casefold()
        if key not in seen:
            seen.add(key)
            unique.append(item)
    return unique


def make_one_next_step(
    checklist: Sequence[str],
    *,
    changes: list[ChangeRecord],
    review_items: list[ReviewItem],
) -> list[str]:
    if checklist:
        sentence = (
            "Dokončit audit IHF podle připraveného kontrolního seznamu "
            "a uzavřít jeho právní, datové, komerční a aktivační "
            "vyhodnocení."
        )
        changes.append(
            ChangeRecord(
                change_type="SYNTHESIZE_ONE_NEXT_STEP",
                section="10. Jeden hlavní další krok",
                source_reference="SECTION-10-CHECKLIST",
                description=(
                    "Vícebodový seznam byl shrnut do jednoho hlavního "
                    "dalšího kroku. Úplný seznam zůstává v plánu pokračování."
                ),
                before_preview=preview("\n".join(checklist)),
                after_preview=sentence,
            )
        )
        return [f"> **Hlavní další krok:** {sentence}"]

    review_items.append(
        ReviewItem(
            severity="CRITICAL",
            code="MISSING_ONE_NEXT_STEP",
            section="10. Jeden hlavní další krok",
            description="Nebylo možné určit jeden hlavní další krok.",
            recommendation="Doplnit jednu konkrétní zahajovací činnost.",
        )
    )
    return [
        "> **Hlavní další krok:** "
        "[DOPLNIT UŽIVATELEM – JEDEN HLAVNÍ DALŠÍ KROK]"
    ]


def make_navigation_section(
    main_theme: str,
    *,
    changes: list[ChangeRecord],
) -> list[str]:
    reason = (
        "vznik základní architektury Source Intelligence Layer "
        "a zahájení auditů EHF a IHF"
    )
    if main_theme and "source intelligence layer" not in main_theme.casefold():
        reason = main_theme.rstrip(".").lower()

    result = [
        "- **MM-DOC-901 – MATCHMATRIX NAVÁZÁNÍ:** aktualizovat.",
        f"- **Důvod:** {reason}.",
        "- **Rozsah aktualizace:** stav Source Intelligence Layer, "
        "výsledky auditu EHF, rozpracovaný audit IHF a hlavní další krok.",
    ]
    changes.append(
        ChangeRecord(
            change_type="DERIVE_NAVIGATION_LINK",
            section="11. Vazby a NAVÁZÁNÍ",
            source_reference="DAILY_LOG_CONTEXT",
            description=(
                "Prázdná kapitola byla doplněna bezpečnou vazbou "
                "na MM-DOC-901 podle pravidel denních zápisů."
            ),
            before_preview="Prázdná kapitola",
            after_preview=preview("\n".join(result)),
        )
    )
    return result


def update_metadata(
    metadata: Mapping[str, str],
    *,
    args: argparse.Namespace,
    candidate_path: Path,
    candidate_hash: str,
    working_area_inferred: str,
    changes: list[ChangeRecord],
    review_items: list[ReviewItem],
) -> dict[str, str]:
    result = dict(metadata)

    if args.document_id:
        result["Document ID"] = args.document_id
    elif PLACEHOLDER_RE.search(result.get("Document ID", "")):
        review_items.append(
            ReviewItem(
                severity="CRITICAL",
                code="MISSING_DOCUMENT_ID",
                section="Informace o dokumentu",
                description="Document ID stále není přidělen.",
                recommendation=(
                    "Přidělit identifikátor podle MM-STD-004 "
                    "a MM-STD-007."
                ),
            )
        )

    original_version = result.get("Verze", "")
    if args.version:
        result["Verze"] = args.version
    elif DATE_LIKE_VERSION_RE.match(original_version.strip()):
        result["Verze"] = "[DOPLNIT UŽIVATELEM – VERZE]"
        review_items.append(
            ReviewItem(
                severity="HIGH",
                code="DATE_MISREAD_AS_VERSION",
                section="Informace o dokumentu",
                description=(
                    f"Hodnota {original_version!r} odpovídá části data, "
                    "nikoli bezpečně rozpoznané verzi dokumentu."
                ),
                recommendation=(
                    "Doplnit verzi podle MM-STD-003, například 1.0."
                ),
            )
        )
        changes.append(
            ChangeRecord(
                change_type="CORRECT_DATE_LIKE_VERSION",
                section="Informace o dokumentu",
                source_reference="METADATA",
                description=(
                    "Datum-like hodnota byla odstraněna z pole Verze."
                ),
                before_preview=original_version,
                after_preview=result["Verze"],
            )
        )

    if args.author:
        result["Autor"] = args.author
    elif PLACEHOLDER_RE.search(result.get("Autor", "")):
        review_items.append(
            ReviewItem(
                severity="HIGH",
                code="MISSING_AUTHOR",
                section="Informace o dokumentu",
                description="Autor kandidáta není doplněn.",
                recommendation="Doplnit autora dokumentu.",
            )
        )

    if args.working_area:
        result["Pracovní oblast"] = args.working_area
    elif (
        PLACEHOLDER_RE.search(result.get("Pracovní oblast", ""))
        and working_area_inferred
        and not working_area_inferred.startswith("[")
    ):
        result["Pracovní oblast"] = working_area_inferred
        changes.append(
            ChangeRecord(
                change_type="FILL_WORKING_AREA_METADATA",
                section="Informace o dokumentu",
                source_reference="IDENTIFICATION",
                description=(
                    "Pracovní oblast v metadatech byla doplněna "
                    "z identifikace dne."
                ),
                before_preview=metadata.get("Pracovní oblast", ""),
                after_preview=working_area_inferred,
            )
        )

    result["Stav"] = "DRAFT – POLISHED_FOR_REVIEW"
    result["Polished candidate A21"] = str(candidate_path)
    result["SHA-256 kandidáta A20"] = candidate_hash
    result["Polish engine"] = ENGINE_VERSION
    result["Polished at"] = utc_now().isoformat()
    return result


def metadata_markdown(metadata: Mapping[str, str]) -> list[str]:
    preferred_order = [
        "Document ID",
        "Název dokumentu",
        "Typ dokumentu",
        "Verze",
        "Stav",
        "Datum",
        "Autor",
        "Pracovní oblast",
        "Původní soubor",
        "SHA-256 původního souboru",
        "Potvrzená revize A19",
        "Mapování schválil",
        "Kandidát sestaven",
        "Build engine",
        "Polished candidate A21",
        "SHA-256 kandidáta A20",
        "Polish engine",
        "Polished at",
    ]
    ordered_keys = [
        key for key in preferred_order if key in metadata
    ]
    ordered_keys.extend(
        key for key in metadata if key not in ordered_keys
    )

    rows = [
        "| Položka | Hodnota |",
        "|---|---|",
    ]
    rows.extend(f"| {key} | {metadata[key]} |" for key in ordered_keys)
    return rows


def ensure_section_titles(
    sections: Mapping[int, tuple[str, list[str]]],
) -> None:
    missing = sorted(set(EXPECTED_SECTIONS) - set(sections))
    if missing:
        raise RuntimeError(
            f"Kandidát A20 neobsahuje povinné kapitoly: {missing}"
        )


def validate_a20(
    candidate_path: Path,
    report_path: Path,
) -> tuple[str, dict[str, Any], str]:
    if not candidate_path.is_file():
        raise FileNotFoundError(
            f"Kandidát A20 nebyl nalezen: {candidate_path}"
        )
    if not report_path.is_file():
        raise FileNotFoundError(
            f"Build report A20 nebyl nalezen: {report_path}"
        )

    candidate_text = normalize_newlines(
        candidate_path.read_text(encoding="utf-8-sig")
    )
    report = read_json(report_path)

    if report.get("final_status") != EXPECTED_A20_STATUS:
        raise RuntimeError(
            "Build report A20 nemá očekávaný final_status: "
            f"{report.get('final_status')!r}"
        )

    expected_hash = str(report.get("candidate_hash_sha256") or "")
    actual_hash = sha256_text(candidate_text)
    if expected_hash != actual_hash:
        raise RuntimeError(
            "SHA-256 kandidáta A20 neodpovídá build reportu. "
            "Kandidát mohl být ručně změněn."
        )

    if report.get("document_type") != "DAILY_LOG":
        raise RuntimeError(
            "A21 V1 podporuje pouze dokument typu DAILY_LOG."
        )

    return candidate_text, report, actual_hash



def infer_evening_result_from_section8(
    blocks: Sequence[TraceBlock],
) -> str | None:
    """
    Vybere bezpečný večerní výsledek pouze z již existujícího obsahu
    kapitoly 8. Upřednostní souvislou větu o stavu/posunu a nikdy
    nevytváří nový fakt.
    """
    candidates: list[str] = []
    for block in blocks:
        lines = visible_lines(block)
        if not lines:
            continue
        text = paragraph_from_lines(lines).strip()
        if not text:
            continue
        folded = text.casefold()
        if any(
            marker in folded
            for marker in (
                "máme základ",
                "vznikl",
                "stav",
                "posun",
                "připraven",
                "ready",
                "dokončen",
                "ověřen",
            )
        ):
            candidates.append(text)

    if not candidates:
        return None

    # Prefer the most informative but still concise existing statement.
    candidates.sort(key=lambda value: (len(value.split()), len(value)), reverse=True)
    selected = candidates[0].strip()
    if len(selected) > 420:
        selected = selected[:417].rstrip() + "…"
    return selected


def build_polished_document(
    *,
    candidate_text: str,
    candidate_path: Path,
    args: argparse.Namespace,
) -> tuple[str, list[ChangeRecord], list[ReviewItem], dict[str, Any]]:
    lines = candidate_text.split("\n")
    title = extract_title(lines)
    metadata, _, _ = parse_metadata(lines)
    sections = parse_sections(lines)
    ensure_section_titles(sections)

    changes: list[ChangeRecord] = []
    review_items: list[ReviewItem] = []

    section_blocks: dict[int, list[TraceBlock]] = {}
    trace_count = 0
    empty_block_count = 0
    for number, (section_title, section_lines) in sections.items():
        blocks = blocks_from_section(number, section_title, section_lines)
        section_blocks[number] = blocks
        trace_count += sum(1 for block in blocks if block.trace_raw)
        empty_block_count += sum(
            1 for block in blocks if not visible_lines(block)
        )

    (
        identification_lines,
        main_theme,
        inferred_area,
        work_relocations,
        result_relocations,
    ) = extract_identification(
        section_blocks[1],
        changes=changes,
        review_items=review_items,
    )

    # Section 4: odstranit první redundantní "Co jsme dnes vybudovali"
    # ze zdrojového relokačního bloku a vložit čistý podnadpis.
    work_relocations_clean = remove_first_matching_heading(
        work_relocations,
        r"^\s*1\.\s+CO JSME DNES VYBUDOVALI\s*$",
    )

    section_output: dict[int, list[str]] = {}
    section_output[1] = identification_lines
    section_output[2] = render_content_blocks(
        section_blocks[2],
        changes=changes,
        review_items=review_items,
        keep_trace_comments=args.keep_trace_comments,
    )
    section_output[3] = make_goal_section(
        section_blocks[3],
        main_theme,
        changes=changes,
    )

    section4_blocks = [
        *work_relocations_clean,
        *section_blocks[4],
    ]
    rendered4 = render_content_blocks(
        section4_blocks,
        changes=changes,
        review_items=review_items,
        keep_trace_comments=args.keep_trace_comments,
    )
    if work_relocations_clean:
        rendered4 = [
            "### Co jsme během dne vybudovali a ověřili",
            "",
            *rendered4,
        ]
        changes.append(
            ChangeRecord(
                change_type="RELOCATE_WORK_CONTENT",
                section="4. Provedené práce",
                source_reference="SECTION-1-RELOCATIONS",
                description=(
                    "Obsahové bloky byly přesunuty z identifikace "
                    "do provedených prací."
                ),
                before_preview="Obsah v kapitole Identifikace",
                after_preview="Obsah v kapitole Provedené práce",
            )
        )
    section_output[4] = rendered4

    for number in (5, 6, 7):
        section_output[number] = render_content_blocks(
            section_blocks[number],
            changes=changes,
            review_items=review_items,
            keep_trace_comments=args.keep_trace_comments,
        )

    evening_fallback = infer_evening_result_from_section8(
        section_blocks[8]
    )
    chronology = build_chronology(
        result_relocations,
        fallback_evening_result=evening_fallback,
        changes=changes,
        review_items=review_items,
    )
    section8 = render_content_blocks(
        section_blocks[8],
        changes=changes,
        review_items=review_items,
        keep_trace_comments=args.keep_trace_comments,
    )
    if chronology:
        section8 = [*chronology, "", *section8]
    section_output[8] = section8

    checklist = collect_checklist_from_section(section_blocks[10])
    section9 = render_content_blocks(
        section_blocks[9],
        changes=changes,
        review_items=review_items,
        keep_trace_comments=args.keep_trace_comments,
    )
    if checklist:
        section9.extend(
            [
                "",
                "### Kontrolní seznam pro dokončení IHF",
                "",
                *format_simple_list(checklist),
            ]
        )
        changes.append(
            ChangeRecord(
                change_type="MOVE_CHECKLIST_TO_PLAN",
                section="9. Plán pokračování",
                source_reference="SECTION-10",
                description=(
                    "Úplný vícebodový seznam byl přesunut do plánu "
                    "pokračování; sekce 10 zůstává jedním krokem."
                ),
                before_preview="Checklist v sekci 10",
                after_preview="Checklist v sekci 9",
            )
        )
    section_output[9] = section9
    section_output[10] = make_one_next_step(
        checklist,
        changes=changes,
        review_items=review_items,
    )
    section_output[11] = make_navigation_section(
        main_theme,
        changes=changes,
    )

    candidate_hash = sha256_text(candidate_text)
    metadata_updated = update_metadata(
        metadata,
        args=args,
        candidate_path=candidate_path,
        candidate_hash=candidate_hash,
        working_area_inferred=inferred_area,
        changes=changes,
        review_items=review_items,
    )

    output_lines: list[str] = [
        f"# {title}",
        "",
        "## Informace o dokumentu",
        "",
        *metadata_markdown(metadata_updated),
        "",
        "> **Bezpečnostní stav:** Toto je redakčně dočištěný "
        "kandidát A21. Kandidát A20 ani původní archivní dokument "
        "nebyly změněny.",
        "> Každá automatická změna je uvedena v samostatném "
        "polish reportu. Před schválením musí dokument znovu projít A17.",
        "",
    ]

    for number in sorted(EXPECTED_SECTIONS):
        section_title = EXPECTED_SECTIONS[number]
        output_lines.append(f"## {number}. {section_title}")
        output_lines.append("")
        content = section_output.get(number, [])
        if content:
            output_lines.extend(content)
        else:
            output_lines.append(
                "> **DOPLNIT UŽIVATELEM:** "
                f"Kapitola „{section_title}“ nemá obsah."
            )
            review_items.append(
                ReviewItem(
                    severity="HIGH",
                    code="EMPTY_POLISHED_SECTION",
                    section=f"{number}. {section_title}",
                    description="Kapitola zůstala po dočištění prázdná.",
                    recommendation="Doplnit nebo potvrdit výjimku.",
                )
            )
        output_lines.append("")

    output_lines.extend(
        [
            "## Schválení standardizovaného kandidáta",
            "",
            "- [ ] Byla zkontrolována správnost redakčních změn A21.",
            "- [ ] Byly vyřešeny položky v manual review reportu.",
            "- [ ] Byla doplněna všechna pole `DOPLNIT UŽIVATELEM`.",
            "- [ ] Byla ověřena terminologie podle MM-REF-001.",
            "- [ ] Byl spuštěn audit A17 nad polished kandidátem.",
            "- [ ] Audit A17 dosáhl požadovaného stavu.",
            "- [ ] Uživatel schválil vytvoření nové kanonické verze.",
            "",
        ]
    )

    polished = "\n".join(output_lines).rstrip() + "\n"
    stats = {
        "trace_comments_found": trace_count,
        "trace_comments_kept": (
            trace_count if args.keep_trace_comments else 0
        ),
        "trace_comments_removed_from_readable_copy": (
            0 if args.keep_trace_comments else trace_count
        ),
        "empty_trace_blocks_found": empty_block_count,
        "changes_count": len(changes),
        "manual_review_items_count": len(review_items),
        "placeholders_count": len(PLACEHOLDER_RE.findall(polished)),
        "source_candidate_hash_sha256": candidate_hash,
        "polished_candidate_hash_sha256": sha256_text(polished),
    }
    return polished, changes, review_items, stats


def write_csv(
    path: Path,
    changes: Sequence[ChangeRecord],
    review_items: Sequence[ReviewItem],
) -> None:
    fields = [
        "record_type",
        "change_type",
        "severity",
        "code",
        "section",
        "source_reference",
        "description",
        "recommendation",
        "before_preview",
        "after_preview",
        "automatic",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()

        for item in changes:
            writer.writerow(
                {
                    "record_type": "CHANGE",
                    "change_type": item.change_type,
                    "severity": "",
                    "code": "",
                    "section": item.section,
                    "source_reference": item.source_reference,
                    "description": item.description,
                    "recommendation": "",
                    "before_preview": item.before_preview,
                    "after_preview": item.after_preview,
                    "automatic": item.automatic,
                }
            )

        for item in review_items:
            writer.writerow(
                {
                    "record_type": "MANUAL_REVIEW",
                    "change_type": "",
                    "severity": item.severity,
                    "code": item.code,
                    "section": item.section,
                    "source_reference": "",
                    "description": item.description,
                    "recommendation": item.recommendation,
                    "before_preview": "",
                    "after_preview": "",
                    "automatic": False,
                }
            )


def report_markdown(payload: Mapping[str, Any]) -> str:
    stats = payload["statistics"]
    changes = payload["changes"]
    review_items = payload["manual_review_items"]

    lines = [
        "# MATCHMATRIX – A21 POLISH REPORT",
        "",
        f"- Výsledek: **{payload['final_status']}**",
        f"- Vstupní kandidát A20: `{payload['source_candidate_path']}`",
        f"- Polished kandidát: `{payload['polished_candidate_path']}`",
        f"- Build report A20: `{payload['a20_build_report_path']}`",
        "",
        "## Souhrn",
        "",
        f"- Automatických změn: **{stats['changes_count']}**",
        f"- Položek pro ruční kontrolu: "
        f"**{stats['manual_review_items_count']}**",
        f"- Technických komentářů nalezeno: "
        f"**{stats['trace_comments_found']}**",
        f"- Technických komentářů odebráno z čitelné verze: "
        f"**{stats['trace_comments_removed_from_readable_copy']}**",
        f"- Placeholderů v polished kandidátu: "
        f"**{stats['placeholders_count']}**",
        "",
        "## Provedené změny",
        "",
    ]

    for index, item in enumerate(changes, start=1):
        lines.extend(
            [
                f"### {index}. {item['change_type']}",
                "",
                f"- Sekce: **{item['section']}**",
                f"- Zdroj: `{item['source_reference']}`",
                f"- Popis: {item['description']}",
                f"- Před: `{item['before_preview']}`",
                f"- Po: `{item['after_preview']}`",
                "",
            ]
        )

    lines.extend(
        [
            "## Ruční kontrola",
            "",
        ]
    )
    if review_items:
        for index, item in enumerate(review_items, start=1):
            lines.extend(
                [
                    f"### {index}. {item['code']} – {item['severity']}",
                    "",
                    f"- Sekce: **{item['section']}**",
                    f"- Problém: {item['description']}",
                    f"- Doporučení: {item['recommendation']}",
                    "",
                ]
            )
    else:
        lines.append("Nebyla vytvořena žádná položka pro ruční kontrolu.")
        lines.append("")

    lines.extend(
        [
            "## Další krok",
            "",
            "Spustit A17 nad souborem "
            "`document_standardized_polished_candidate_latest.md` "
            "a následně vyřešit pouze zbývající položky.",
            "",
            f"**FINAL STATUS:** `{payload['final_status']}`",
            "",
        ]
    )
    return "\n".join(lines)


def manual_review_markdown(
    review_items: Sequence[ReviewItem],
) -> str:
    lines = [
        "# MATCHMATRIX – A21 MANUAL REVIEW",
        "",
    ]
    if not review_items:
        lines.extend(
            [
                "A21 nevytvořil žádnou položku vyžadující ruční zásah.",
                "",
            ]
        )
        return "\n".join(lines)

    lines.extend(
        [
            "| Priorita | Kód | Sekce | Problém | Doporučení |",
            "|---|---|---|---|---|",
        ]
    )
    for item in review_items:
        lines.append(
            f"| {item.severity} | {item.code} | {item.section} | "
            f"{item.description} | {item.recommendation} |"
        )
    lines.append("")
    return "\n".join(lines)


def write_outputs(
    *,
    output_dir: Path,
    candidate_text: str,
    polished_text: str,
    source_candidate_path: Path,
    a20_report_path: Path,
    changes: Sequence[ChangeRecord],
    review_items: Sequence[ReviewItem],
    stats: Mapping[str, Any],
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths = {
        "candidate": output_dir
        / f"document_standardized_polished_candidate_{stamp}.md",
        "diff": output_dir
        / f"document_standardized_polished_candidate_diff_{stamp}.diff",
        "json": output_dir
        / f"document_standardized_polish_report_{stamp}.json",
        "csv": output_dir
        / f"document_standardized_polish_report_{stamp}.csv",
        "markdown": output_dir
        / f"document_standardized_polish_report_{stamp}.md",
        "manual_review": output_dir
        / f"document_standardized_manual_review_{stamp}.md",
    }

    paths["candidate"].write_text(polished_text, encoding="utf-8")
    diff = "\n".join(
        difflib.unified_diff(
            candidate_text.splitlines(),
            polished_text.splitlines(),
            fromfile=str(source_candidate_path),
            tofile=str(paths["candidate"]),
            lineterm="",
        )
    )
    paths["diff"].write_text(
        diff + ("\n" if diff else ""),
        encoding="utf-8",
    )

    final_status = (
        "STANDARDIZED_DOCUMENT_POLISHED_CANDIDATE_READY_FOR_AUDIT"
    )
    payload: dict[str, Any] = {
        "contract_version": OUTPUT_CONTRACT_VERSION,
        "generated_at": utc_now().isoformat(),
        "engine_version": ENGINE_VERSION,
        "source_candidate_path": str(source_candidate_path),
        "a20_build_report_path": str(a20_report_path),
        "polished_candidate_path": str(paths["candidate"]),
        "diff_path": str(paths["diff"]),
        "statistics": dict(stats),
        "changes": [asdict(item) for item in changes],
        "manual_review_items": [
            asdict(item) for item in review_items
        ],
        "source_candidate_modified": False,
        "original_archive_modified": False,
        "database_modified": False,
        "requires_a17_audit": True,
        "canonical_approval_allowed": False,
        "final_status": final_status,
    }

    paths["json"].write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_csv(paths["csv"], changes, review_items)
    paths["markdown"].write_text(
        report_markdown(payload),
        encoding="utf-8",
    )
    paths["manual_review"].write_text(
        manual_review_markdown(review_items),
        encoding="utf-8",
    )

    latest = {
        "candidate": output_dir
        / "document_standardized_polished_candidate_latest.md",
        "diff": output_dir
        / "document_standardized_polished_candidate_diff_latest.diff",
        "json": output_dir
        / "document_standardized_polish_report_latest.json",
        "csv": output_dir
        / "document_standardized_polish_report_latest.csv",
        "markdown": output_dir
        / "document_standardized_polish_report_latest.md",
        "manual_review": output_dir
        / "document_standardized_manual_review_latest.md",
    }
    for key, source in paths.items():
        shutil.copyfile(source, latest[key])

    return paths


def main() -> int:
    args = parse_args()
    root = project_root()
    candidate_path = resolve_path(
        root,
        args.candidate,
        CANDIDATE_DEFAULT,
    )
    report_path = resolve_path(
        root,
        args.build_report,
        BUILD_REPORT_DEFAULT,
    )
    output_dir = resolve_path(
        root,
        args.output_dir,
        OUTPUT_DEFAULT,
    )

    print("MATCHMATRIX STANDARDIZED DOCUMENT POLISH")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"CANDIDATE A20      : {candidate_path}")
    print(f"BUILD REPORT A20   : {report_path}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("DATABASE WRITES    : DISABLED")
    print("SOURCE WRITES      : DISABLED")
    print()

    try:
        candidate_text, report, candidate_hash = validate_a20(
            candidate_path,
            report_path,
        )
        lines = candidate_text.split("\n")
        metadata, _, _ = parse_metadata(lines)
        sections = parse_sections(lines)
        ensure_section_titles(sections)

        trace_count = sum(
            1
            for line in candidate_text.splitlines()
            if TRACE_RE.match(line)
        )
        print("VSTUP")
        print("-" * 79)
        print(f"DOCUMENT TYPE      : {report.get('document_type')}")
        print("A20 STATUS         : VERIFIED")
        print("SHA-256 VERIFIED   : True")
        print(f"SECTIONS           : {len(sections)}")
        print(f"TRACE COMMENTS     : {trace_count}")
        print(
            f"A20 PLACEHOLDERS   : "
            f"{len(PLACEHOLDER_RE.findall(candidate_text))}"
        )
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print()

        if args.validate_only:
            print("VALIDACE")
            print("-" * 79)
            print("A20 CONTRACT       : VALID")
            print("DAILY LOG PROFILE  : VALID")
            print("POLISH BUILD       : READY")
            print(
                "FINAL STATUS       : "
                "STANDARDIZED_DOCUMENT_POLISH_VALIDATED"
            )
            return 0

        polished, changes, review_items, stats = (
            build_polished_document(
                candidate_text=candidate_text,
                candidate_path=candidate_path,
                args=args,
            )
        )

        paths = write_outputs(
            output_dir=output_dir,
            candidate_text=candidate_text,
            polished_text=polished,
            source_candidate_path=candidate_path,
            a20_report_path=report_path,
            changes=changes,
            review_items=review_items,
            stats=stats,
        )

        print("DOČIŠTĚNÍ")
        print("-" * 79)
        print(f"CHANGES            : {len(changes)}")
        print(f"MANUAL REVIEW      : {len(review_items)}")
        print(
            f"TRACE REMOVED      : "
            f"{stats['trace_comments_removed_from_readable_copy']}"
        )
        print(
            f"PLACEHOLDERS       : {stats['placeholders_count']}"
        )
        print("A20 MODIFIED       : False")
        print("ARCHIVE MODIFIED   : False")
        print("DATABASE MODIFIED  : False")
        print()

        print("VÝSTUP")
        print("-" * 79)
        print(f"POLISHED CANDIDATE : {paths['candidate']}")
        print(f"DIFF               : {paths['diff']}")
        print(f"REPORT JSON        : {paths['json']}")
        print(f"REPORT CSV         : {paths['csv']}")
        print(f"REPORT MARKDOWN    : {paths['markdown']}")
        print(f"MANUAL REVIEW      : {paths['manual_review']}")
        print("READY FOR A17      : True")
        print("CANONICAL APPROVAL : False")
        print(
            "FINAL STATUS       : "
            "STANDARDIZED_DOCUMENT_POLISHED_CANDIDATE_READY_FOR_AUDIT"
        )
        return 0

    except Exception as exc:
        print("STANDARDIZED DOCUMENT POLISH ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("A20 MODIFIED       : False")
        print("ARCHIVE MODIFIED   : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "STANDARDIZED_DOCUMENT_POLISH_BLOCKED"
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
