#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Připraví redakčně dočištěný denní zápis A21 jako správně identifikovaný
a pojmenovaný kandidát ke kanonickému schválení.

K ČEMU:
- ověří kontrakt a SHA-256 polished kandidáta A21,
- načte datum dokumentovaného dne,
- vytvoří Document ID ve formátu MM-DL-YYYYMMDD,
- vytvoří název MM-DL-YYYYMMDD_MATCHMATRIX_DENNI_ZAPIS.md,
- doplní nebo ověří verzi, autora a pracovní oblast,
- zablokuje výstup při zbývajícím placeholderu,
- načte referenční slovník MM-REF-001,
- vytvoří terminologický audit a kandidáty nových pojmů,
- slovník automaticky nemění,
- automaticky spustí aktualizovaný A17,
- vytvoří diff, auditní balíček a stabilní kanonický kandidát,
- nepřepisuje A21, původní archiv ani databázi.

KDE:
tools/documentation/25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py

JAK:
Validace:
    py -3.14 .\\tools\\documentation\\25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py `
      --validate-only

Sestavení:
    py -3.14 .\\tools\\documentation\\25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py

Volitelná metadata:
    --version "1.0"
    --author "Petr Kubinák"
    --working-area "Source Intelligence Layer"

Explicitní slovník:
    --glossary "C:\\MatchMatrix-platform\\docs\\...\\MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md"

BEZPEČNOST:
- podporuje pouze DAILY_LOG,
- datum musí být platné kalendářní datum,
- Document ID se vždy odvozuje z data,
- pro daný den vzniká MM-DL-YYYYMMDD,
- nepovolí zbývající DOPLNIT UŽIVATELEM,
- slovník MM-REF-001 pouze čte,
- terminologické kandidáty musí schválit uživatel,
- kanonické publikování neprovádí,
- A21, archiv a databázi nemění.

VÝSTUP:
reports/documentation/standardization/canonical_candidates/
- MM-DL-YYYYMMDD_MATCHMATRIX_DENNI_ZAPIS.md
- MM-DL-YYYYMMDD_MATCHMATRIX_DENNI_ZAPIS_DIFF_FROM_A21.diff
- MM-DL-YYYYMMDD_PREPARATION_REPORT.json
- MM-DL-YYYYMMDD_PREPARATION_REPORT.md
- MM-DL-YYYYMMDD_TERMINOLOGY_REPORT.json
- MM-DL-YYYYMMDD_TERMINOLOGY_REPORT.csv
- MM-DL-YYYYMMDD_TERMINOLOGY_REPORT.md
- MM-DL-YYYYMMDD_A17_STDOUT.txt
- history/
- a17/
"""

from __future__ import annotations

import argparse
import csv
import difflib
import hashlib
import json
import locale
import os
import re
import shutil
import subprocess
import sys
import unicodedata
from collections import Counter
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


ENGINE_VERSION = "A22_DAILY_LOG_CANONICAL_PREPARATION_V1_1"
OUTPUT_CONTRACT_VERSION = "1.0"
EXPECTED_A21_STATUS = (
    "STANDARDIZED_DOCUMENT_POLISHED_CANDIDATE_READY_FOR_AUDIT"
)

CANDIDATE_DEFAULT = Path(
    "reports/documentation/standardization/polished_candidates/"
    "document_standardized_polished_candidate_latest.md"
)
POLISH_REPORT_DEFAULT = Path(
    "reports/documentation/standardization/polished_candidates/"
    "document_standardized_polish_report_latest.json"
)
A17_DEFAULT = Path(
    "tools/documentation/"
    "25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py"
)
OUTPUT_DEFAULT = Path(
    "reports/documentation/standardization/canonical_candidates"
)

PLACEHOLDER_RE = re.compile(
    r"\[(?:DOPLNIT UŽIVATELEM|DOPLNIT UZIVATELEM)[^\]]*\]",
    re.IGNORECASE,
)
DATE_PATTERNS = (
    ("%Y-%m-%d", re.compile(r"^20\d{2}-\d{2}-\d{2}$")),
    ("%Y.%m.%d", re.compile(r"^20\d{2}\.\d{2}\.\d{2}$")),
    ("%Y/%m/%d", re.compile(r"^20\d{2}/\d{2}/\d{2}$")),
    ("%d.%m.%Y", re.compile(r"^\d{1,2}\.\d{1,2}\.20\d{2}$")),
    ("%d-%m-%Y", re.compile(r"^\d{1,2}-\d{1,2}-20\d{2}$")),
    ("%d/%m/%Y", re.compile(r"^\d{1,2}/\d{1,2}/20\d{2}$")),
)
DATE_TOKEN_RE = re.compile(
    r"(?<!\d)("
    r"20\d{2}[-./]\d{1,2}[-./]\d{1,2}"
    r"|\d{1,2}[./-]\d{1,2}[./-]20\d{2}"
    r")(?!\d)"
)
VERSION_RE = re.compile(r"^\d+\.\d+$")
ACRONYM_RE = re.compile(r"\b[A-Z][A-Z0-9]{1,11}\b")
TITLE_PHRASE_RE = re.compile(
    r"\b(?:[A-Z][A-Za-z0-9-]{2,}"
    r"(?:\s+|/)){1,4}[A-Z][A-Za-z0-9-]{2,}\b"
)
MARKDOWN_HEADING_RE = re.compile(r"^#{1,6}\s+(.+?)\s*$", re.MULTILINE)
BOLD_RE = re.compile(r"\*\*(.+?)\*\*")
TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")

EXCLUDED_ACRONYMS = {
    "MM",
    "ID",
    "URL",
    "HTTP",
    "HTTPS",
    "JSON",
    "CSV",
    "SQL",
    "MD",
    "TXT",
    "UTF",
    "SHA",
    "READY",
    "REVIEW",
    "DRAFT",
    "ACTIVE",
    "PASS",
    "FAIL",
    "TRUE",
    "FALSE",
    "UTC",
    "YYYYMMDD",
}
TECHNICAL_MARKERS = {
    "source",
    "layer",
    "discovery",
    "dashboard",
    "queue",
    "master",
    "people",
    "team",
    "history",
    "media",
    "privacy",
    "policy",
    "terms",
    "conditions",
    "quality",
    "score",
    "commercial",
    "model",
    "activation",
    "roadmap",
    "national",
    "league",
    "documentation",
    "management",
    "system",
    "provider",
    "governance",
    "audit",
    "tracker",
}
IGNORED_PHRASES = {
    "matchmatrix denní zápis",
    "informace o dokumentu",
    "identifikace denního zápisu",
    "výchozí stav",
    "cíl pracovního dne",
    "provedené práce",
    "přijatá rozhodnutí",
    "problémy a jejich řešení",
    "ověřené výsledky a technické výstupy",
    "výsledky dne a stav na konci dne",
    "plán pokračování",
    "jeden hlavní další krok",
    "vazby a navázání",
    "schválení standardizovaného kandidáta",
}


@dataclass(frozen=True)
class TermRecord:
    term: str
    normalized_term: str
    status: str
    occurrences: int
    source: str
    contexts: tuple[str, ...]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Připraví DAILY_LOG kandidát s ID MM-DL-YYYYMMDD, "
            "terminologií a auditem A17."
        )
    )
    parser.add_argument("--candidate")
    parser.add_argument("--polish-report")
    parser.add_argument("--a17-script")
    parser.add_argument("--glossary")
    parser.add_argument("--output-dir")
    parser.add_argument(
        "--version",
        default="1.0",
        help="Verze kandidáta; výchozí 1.0.",
    )
    parser.add_argument("--author")
    parser.add_argument("--working-area")
    parser.add_argument(
        "--document-date",
        help=(
            "Explicitní datum dokumentovaného dne. Použije se pouze "
            "jako vědomé uživatelské rozhodnutí, například 2026-06-24."
        ),
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Pouze ověří vstupy a odvozenou identitu.",
    )
    return parser.parse_args()


def resolve_path(
    root: Path,
    value: str | None,
    default: Path,
) -> Path:
    path = Path(value) if value else default
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def normalize_term(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    without_marks = "".join(
        char for char in decomposed
        if not unicodedata.combining(char)
    )
    lowered = without_marks.casefold()
    lowered = re.sub(r"[`*_#>|]", " ", lowered)
    lowered = re.sub(r"[^a-z0-9]+", " ", lowered)
    return re.sub(r"\s+", " ", lowered).strip()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"JSON musí být objekt: {path}")
    return payload


def parse_date(value: str) -> datetime:
    raw = value.strip()
    for fmt, pattern in DATE_PATTERNS:
        if not pattern.fullmatch(raw):
            continue
        try:
            return datetime.strptime(raw, fmt)
        except ValueError:
            break
    raise RuntimeError(
        f"Neplatné nebo nepodporované datum denního zápisu: {value!r}"
    )



def extract_date_tokens(value: str) -> list[datetime]:
    result: list[datetime] = []
    for token in DATE_TOKEN_RE.findall(value or ""):
        try:
            parsed = parse_date(token)
        except RuntimeError:
            continue
        if parsed not in result:
            result.append(parsed)
    return result


def read_text_fallback(path: Path) -> str:
    raw = path.read_bytes()
    encodings = [
        "utf-8-sig",
        "utf-8",
        locale.getpreferredencoding(False),
        "cp1250",
        "cp852",
        "latin-1",
    ]
    seen: set[str] = set()
    for encoding in encodings:
        if not encoding or encoding.casefold() in seen:
            continue
        seen.add(encoding.casefold())
        try:
            return raw.decode(encoding)
        except (UnicodeDecodeError, LookupError):
            continue
    return raw.decode("utf-8", errors="replace")


def decode_process_stream(data: bytes | None) -> str:
    if not data:
        return ""
    encodings = [
        "utf-8-sig",
        "utf-8",
        locale.getpreferredencoding(False),
        "cp1250",
        "cp852",
        "latin-1",
    ]
    seen: set[str] = set()
    for encoding in encodings:
        if not encoding or encoding.casefold() in seen:
            continue
        seen.add(encoding.casefold())
        try:
            return data.decode(encoding)
        except (UnicodeDecodeError, LookupError):
            continue
    return data.decode("utf-8", errors="replace")


def daily_log_date_evidence(
    source_text: str,
    metadata: Mapping[str, str],
) -> list[dict[str, Any]]:
    evidence: list[dict[str, Any]] = []

    def add(label: str, value: str, weight: int) -> None:
        for parsed in extract_date_tokens(value):
            evidence.append(
                {
                    "source": label,
                    "raw_value": value.strip(),
                    "date": parsed.date().isoformat(),
                    "weight": weight,
                }
            )

    add("METADATA_DATUM", metadata.get("Datum", ""), 2)
    add(
        "METADATA_TITLE",
        metadata.get("Název dokumentu", ""),
        3,
    )

    for line in source_text.splitlines():
        if line.startswith("# ") and not line.startswith("## "):
            add("DOCUMENT_H1", line, 3)
            break

    lines = source_text.splitlines()
    section_start = None
    section_end = len(lines)
    for index, line in enumerate(lines):
        if line.startswith("## 1. Identifikace denního zápisu"):
            section_start = index + 1
            continue
        if section_start is not None and line.startswith("## "):
            section_end = index
            break
    if section_start is not None:
        add(
            "IDENTIFICATION_SECTION",
            "\n".join(lines[section_start:section_end]),
            4,
        )

    original_value = metadata.get("Původní soubor", "").strip().strip("`")
    if original_value:
        original_path = Path(original_value)
        if original_path.is_file():
            try:
                original_text = read_text_fallback(original_path)
                original_lines = original_text.splitlines()
                for index, line in enumerate(original_lines[:80]):
                    folded = line.strip().casefold().rstrip(":")
                    if folded == "datum":
                        following = "\n".join(
                            original_lines[index : index + 4]
                        )
                        add("ORIGINAL_SOURCE_DATUM", following, 6)
                        break
                    if folded.startswith("datum "):
                        add("ORIGINAL_SOURCE_DATUM", line, 6)
                        break
            except OSError:
                pass

    return evidence


def resolve_daily_log_date(
    source_text: str,
    metadata: Mapping[str, str],
    explicit_date: str | None,
) -> tuple[datetime, dict[str, Any]]:
    evidence = daily_log_date_evidence(source_text, metadata)

    if explicit_date:
        selected = parse_date(explicit_date)
        return selected, {
            "method": "EXPLICIT_USER_OVERRIDE",
            "selected_date": selected.date().isoformat(),
            "metadata_date": metadata.get("Datum", "").strip(),
            "corrected_metadata": (
                metadata.get("Datum", "").strip()
                != selected.date().isoformat()
            ),
            "evidence": evidence,
        }

    if not evidence:
        raise RuntimeError(
            "Datum denního zápisu nebylo nalezeno v metadatech, "
            "nadpisu, identifikační kapitole ani původním zdroji. "
            "Použij --document-date."
        )

    scores: dict[str, int] = {}
    sources_by_date: dict[str, set[str]] = {}
    for item in evidence:
        date_value = str(item["date"])
        scores[date_value] = scores.get(date_value, 0) + int(
            item["weight"]
        )
        sources_by_date.setdefault(date_value, set()).add(
            str(item["source"])
        )

    ranked = sorted(
        scores.items(),
        key=lambda item: (
            item[1],
            len(sources_by_date[item[0]]),
            item[0],
        ),
        reverse=True,
    )
    selected_date, selected_score = ranked[0]
    second_score = ranked[1][1] if len(ranked) > 1 else -1

    if (
        len(ranked) > 1
        and selected_score - second_score < 2
    ):
        detail = ", ".join(
            f"{date}={score}" for date, score in ranked
        )
        raise RuntimeError(
            "Datumové důkazy jsou v nerozhodném konfliktu: "
            f"{detail}. Použij --document-date."
        )

    selected = datetime.strptime(selected_date, "%Y-%m-%d")
    metadata_raw = metadata.get("Datum", "").strip()
    try:
        metadata_iso = parse_date(metadata_raw).date().isoformat()
    except RuntimeError:
        metadata_iso = metadata_raw

    return selected, {
        "method": (
            "CONSISTENT_EVIDENCE"
            if len(ranked) == 1
            else "WEIGHTED_EVIDENCE_CORRECTION"
        ),
        "selected_date": selected_date,
        "selected_score": selected_score,
        "metadata_date": metadata_raw,
        "corrected_metadata": metadata_iso != selected_date,
        "scores": scores,
        "sources_by_date": {
            key: sorted(value)
            for key, value in sources_by_date.items()
        },
        "evidence": evidence,
    }


def metadata_region(
    lines: Sequence[str],
) -> tuple[dict[str, str], int, int]:
    try:
        heading_index = lines.index("## Informace o dokumentu")
    except ValueError as exc:
        raise RuntimeError(
            "Kandidát A21 neobsahuje sekci Informace o dokumentu."
        ) from exc

    next_heading = len(lines)
    for index in range(heading_index + 1, len(lines)):
        if lines[index].startswith("## "):
            next_heading = index
            break

    metadata: dict[str, str] = {}
    for line in lines[heading_index + 1 : next_heading]:
        match = TABLE_ROW_RE.match(line.strip())
        if not match:
            continue
        cells = [cell.strip() for cell in match.group(1).split("|")]
        if len(cells) != 2:
            continue
        key, value = cells
        if key.casefold() == "položka" or set(key) == {"-"}:
            continue
        if key:
            metadata[key] = value

    if not metadata:
        raise RuntimeError("Metadata kandidáta A21 jsou prázdná.")
    return metadata, heading_index, next_heading


def render_metadata(metadata: Mapping[str, str]) -> list[str]:
    preferred = [
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
        "Kanonický kandidát",
        "Canonical preparation engine",
        "Canonical prepared at",
    ]
    keys = [key for key in preferred if key in metadata]
    keys.extend(key for key in metadata if key not in keys)

    result = [
        "| Položka | Hodnota |",
        "|---|---|",
    ]
    result.extend(f"| {key} | {metadata[key]} |" for key in keys)
    return result


def validate_a21(
    candidate_path: Path,
    report_path: Path,
) -> tuple[str, dict[str, Any], str]:
    if not candidate_path.is_file():
        raise FileNotFoundError(
            f"Polished kandidát A21 nebyl nalezen: {candidate_path}"
        )
    if not report_path.is_file():
        raise FileNotFoundError(
            f"Polish report A21 nebyl nalezen: {report_path}"
        )

    text = candidate_path.read_text(encoding="utf-8-sig")
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    report = read_json(report_path)

    if report.get("final_status") != EXPECTED_A21_STATUS:
        raise RuntimeError(
            "A21 report nemá očekávaný final_status: "
            f"{report.get('final_status')!r}"
        )

    stats = report.get("statistics")
    if not isinstance(stats, dict):
        raise RuntimeError("A21 report neobsahuje statistics.")

    expected_hash = str(
        stats.get("polished_candidate_hash_sha256") or ""
    )
    actual_hash = sha256_text(text)
    if expected_hash != actual_hash:
        raise RuntimeError(
            "SHA-256 polished kandidáta neodpovídá A21 reportu."
        )

    return text, report, actual_hash


def prepare_candidate(
    *,
    source_text: str,
    source_path: Path,
    version: str,
    author_override: str | None,
    working_area_override: str | None,
    explicit_document_date: str | None,
) -> tuple[
    str,
    dict[str, str],
    str,
    str,
    dict[str, Any],
]:
    lines = source_text.split("\n")
    metadata, heading_index, next_heading = metadata_region(lines)

    document_type = metadata.get("Typ dokumentu", "").strip()
    if document_type != "DAILY_LOG":
        raise RuntimeError(
            f"A22 podporuje pouze DAILY_LOG, nalezeno {document_type!r}."
        )

    date, date_resolution = resolve_daily_log_date(
        source_text,
        metadata,
        explicit_document_date,
    )
    date_iso = date.date().isoformat()
    date_token = date.strftime("%Y%m%d")
    document_id = f"MM-DL-{date_token}"
    canonical_filename = (
        f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"
    )

    if not VERSION_RE.fullmatch(version.strip()):
        raise RuntimeError(
            f"Verze musí mít formát major.minor, například 1.0: "
            f"{version!r}"
        )

    canonical_title = (
        f"MATCHMATRIX – DENNÍ ZÁPIS – {date_iso}"
    )
    metadata["Document ID"] = document_id
    metadata["Název dokumentu"] = canonical_title
    metadata["Verze"] = version.strip()
    metadata["Stav"] = "REVIEW"
    metadata["Datum"] = date_iso

    for index, line in enumerate(lines):
        if line.startswith("# ") and not line.startswith("## "):
            lines[index] = f"# {canonical_title}"
            break

    if author_override:
        metadata["Autor"] = author_override.strip()
    if working_area_override:
        metadata["Pracovní oblast"] = working_area_override.strip()

    for key in ("Autor", "Pracovní oblast", "Název dokumentu"):
        value = metadata.get(key, "").strip()
        if not value or PLACEHOLDER_RE.search(value):
            raise RuntimeError(
                f"Metadata {key!r} nejsou vyplněna. "
                f"Použij odpovídající parametr A22."
            )

    metadata["Kanonický kandidát"] = canonical_filename
    metadata["Canonical preparation engine"] = ENGINE_VERSION
    metadata["Canonical prepared at"] = utc_now().isoformat()

    replacement = [
        "## Informace o dokumentu",
        "",
        *render_metadata(metadata),
        "",
        "> **Bezpečnostní stav:** Toto je kandidát připravený "
        "k terminologické a uživatelské kontrole. A21 ani původní "
        "archivní dokument nebyly změněny.",
        "",
    ]

    # Replace entire A21 metadata/security preamble up to the next H2.
    output_lines = [
        *lines[:heading_index],
        *replacement,
        *lines[next_heading:],
    ]
    output = "\n".join(output_lines).rstrip() + "\n"

    placeholders = PLACEHOLDER_RE.findall(output)
    if placeholders:
        raise RuntimeError(
            "Po doplnění identity zůstaly v dokumentu placeholdery: "
            + ", ".join(sorted(set(placeholders)))
        )

    if document_id not in output:
        raise RuntimeError("Document ID nebyl vložen do kandidáta.")

    return (
        output,
        metadata,
        document_id,
        canonical_filename,
        date_resolution,
    )


def glossary_version(path: Path) -> tuple[int, ...]:
    try:
        text = path.read_text(encoding="utf-8-sig")
    except Exception:
        return (0,)
    match = re.search(
        r"(?:Verze\s*:\s*\**|"
        r"\|\s*Verze\s*\|\s*)(\d+(?:\.\d+)*)",
        text,
        re.IGNORECASE,
    )
    if not match:
        match = re.search(r"_v(\d+(?:\.\d+)*)", path.stem)
    if not match:
        return (0,)
    return tuple(int(part) for part in match.group(1).split("."))


def discover_glossary(
    root: Path,
    explicit: str | None,
) -> Path:
    if explicit:
        path = Path(explicit)
        if not path.is_absolute():
            path = root / path
        path = path.resolve()
        if not path.is_file():
            raise FileNotFoundError(
                f"Slovník MM-REF-001 nebyl nalezen: {path}"
            )
        return path

    candidates: list[Path] = []
    direct = [
        root / "MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md",
        root / "docs/MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md",
    ]
    candidates.extend(path for path in direct if path.is_file())

    docs = root / "docs"
    if docs.is_dir():
        candidates.extend(
            docs.rglob("MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX*.md")
        )
    candidates.extend(
        root.glob("MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX*.md")
    )

    unique = sorted(
        {path.resolve() for path in candidates if path.is_file()},
        key=lambda path: (glossary_version(path), path.stat().st_mtime),
        reverse=True,
    )
    if not unique:
        raise FileNotFoundError(
            "Nebyl nalezen MM-REF-001. Použij parametr --glossary."
        )
    return unique[0]


def parse_glossary(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8-sig")
    terms: dict[str, str] = {}

    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|") or stripped.startswith("|---"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if len(cells) < 2:
            continue
        term = cells[0]
        if term.casefold() in {"pojem", "term"}:
            continue
        normalized = normalize_term(term)
        if normalized:
            terms[normalized] = term

    if not terms:
        raise RuntimeError(
            f"Ve slovníku nebyly nalezeny žádné pojmy: {path}"
        )
    return terms


def line_contexts(text: str, term: str, limit: int = 3) -> tuple[str, ...]:
    result: list[str] = []
    normalized_term = normalize_term(term)
    for line in text.splitlines():
        if normalized_term in normalize_term(line):
            cleaned = line.strip()
            if cleaned and cleaned not in result:
                result.append(cleaned[:300])
            if len(result) >= limit:
                break
    return tuple(result)


def count_occurrences(text: str, term: str) -> int:
    if not term.strip():
        return 0
    return len(
        re.findall(
            re.escape(term),
            text,
            flags=re.IGNORECASE,
        )
    )


def candidate_terms(text: str) -> set[str]:
    result: set[str] = set()

    for acronym in ACRONYM_RE.findall(text):
        if acronym not in EXCLUDED_ACRONYMS and not acronym.isdigit():
            result.add(acronym)

    sources = [
        *MARKDOWN_HEADING_RE.findall(text),
        *BOLD_RE.findall(text),
        *TITLE_PHRASE_RE.findall(text),
    ]
    for value in sources:
        cleaned = re.sub(r"^\d+\.\s*", "", value).strip(" :–—-")
        normalized = normalize_term(cleaned)
        if not normalized or normalized in IGNORED_PHRASES:
            continue
        words = set(normalized.split())
        if words & TECHNICAL_MARKERS:
            result.add(cleaned)

    # Known English technical phrases can occur in plain lines.
    for line in text.splitlines():
        cleaned = line.strip().lstrip("-*+> ").strip()
        normalized = normalize_term(cleaned)
        if (
            2 <= len(normalized.split()) <= 8
            and set(normalized.split()) & TECHNICAL_MARKERS
            and len(cleaned) <= 120
            and not cleaned.startswith("|")
        ):
            result.add(cleaned.rstrip(".:"))

    return {item for item in result if 2 <= len(item) <= 120}


def terminology_audit(
    text: str,
    glossary_path: Path,
) -> tuple[list[TermRecord], list[TermRecord]]:
    glossary = parse_glossary(glossary_path)
    known: list[TermRecord] = []

    for normalized, canonical in sorted(glossary.items()):
        occurrences = count_occurrences(text, canonical)
        if occurrences:
            known.append(
                TermRecord(
                    term=canonical,
                    normalized_term=normalized,
                    status="IN_GLOSSARY",
                    occurrences=occurrences,
                    source=str(glossary_path),
                    contexts=line_contexts(text, canonical),
                )
            )

    candidates: list[TermRecord] = []
    for term in sorted(candidate_terms(text), key=str.casefold):
        normalized = normalize_term(term)
        if not normalized or normalized in glossary:
            continue

        # Exclude a candidate that is only a longer rendering of a known
        # exact term or an entire sentence.
        if len(normalized.split()) > 8:
            continue

        occurrences = count_occurrences(text, term)
        if occurrences <= 0:
            occurrences = 1
        candidates.append(
            TermRecord(
                term=term,
                normalized_term=normalized,
                status="CANDIDATE_REQUIRES_APPROVAL",
                occurrences=occurrences,
                source="A22_AUTO_DISCOVERY",
                contexts=line_contexts(text, term),
            )
        )

    return known, candidates


def write_terminology_csv(
    path: Path,
    known: Sequence[TermRecord],
    candidates: Sequence[TermRecord],
) -> None:
    fields = [
        "status",
        "term",
        "normalized_term",
        "occurrences",
        "source",
        "contexts",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in [*known, *candidates]:
            writer.writerow(
                {
                    "status": record.status,
                    "term": record.term,
                    "normalized_term": record.normalized_term,
                    "occurrences": record.occurrences,
                    "source": record.source,
                    "contexts": " || ".join(record.contexts),
                }
            )


def terminology_markdown(
    document_id: str,
    glossary_path: Path,
    known: Sequence[TermRecord],
    candidates: Sequence[TermRecord],
) -> str:
    lines = [
        f"# {document_id} – TERMINOLOGICKÝ REPORT",
        "",
        f"- Referenční slovník: `{glossary_path}`",
        f"- Použitých referenčních pojmů: **{len(known)}**",
        f"- Kandidátů ke schválení: **{len(candidates)}**",
        "",
        "## Pojmy nalezené v MM-REF-001",
        "",
    ]
    if known:
        lines.extend(
            [
                "| Pojem | Výskyty |",
                "|---|---:|",
            ]
        )
        for item in known:
            lines.append(f"| {item.term} | {item.occurrences} |")
    else:
        lines.append("Nebyl nalezen žádný přesný referenční pojem.")

    lines.extend(
        [
            "",
            "## Kandidáti nových nebo neověřených pojmů",
            "",
        ]
    )
    if candidates:
        lines.extend(
            [
                "| Pojem | Výskyty | Stav |",
                "|---|---:|---|",
            ]
        )
        for item in candidates:
            lines.append(
                f"| {item.term} | {item.occurrences} | "
                "ČEKÁ NA SCHVÁLENÍ |"
            )
    else:
        lines.append("Nebyl nalezen žádný nový terminologický kandidát.")

    lines.extend(
        [
            "",
            "> A22 slovník automaticky nemění. Každý kandidát musí "
            "schválit uživatel podle MM-STD-006 a MM-STD-008.",
            "",
        ]
    )
    return "\n".join(lines)


def run_a17(
    *,
    root: Path,
    a17_script: Path,
    candidate: Path,
    output_dir: Path,
) -> tuple[dict[str, Any], str]:
    if not a17_script.is_file():
        raise FileNotFoundError(
            f"Aktualizovaný A17 nebyl nalezen: {a17_script}"
        )

    output_dir.mkdir(parents=True, exist_ok=True)
    command = [
        sys.executable,
        str(a17_script),
        "--document",
        str(candidate),
        "--document-type",
        "DAILY_LOG",
        "--output-dir",
        str(output_dir),
    ]
    child_env = os.environ.copy()
    child_env["PYTHONUTF8"] = "1"
    child_env["PYTHONIOENCODING"] = "utf-8"

    result = subprocess.run(
        command,
        cwd=root,
        capture_output=True,
        text=False,
        env=child_env,
    )
    stdout_text = decode_process_stream(result.stdout)
    stderr_text = decode_process_stream(result.stderr)
    stdout = stdout_text + (
        ("\n" + stderr_text) if stderr_text else ""
    )
    if result.returncode != 0:
        raise RuntimeError(
            "A17 nad kanonickým kandidátem selhal:\n" + stdout
        )

    latest = output_dir / "document_compliance_audit_latest.json"
    if not latest.is_file():
        raise RuntimeError("A17 nevytvořil latest JSON report.")
    report = read_json(latest)
    return report, stdout


def diff_text(
    source: str,
    target: str,
    source_path: Path,
    target_path: Path,
) -> str:
    rendered = "\n".join(
        difflib.unified_diff(
            source.splitlines(),
            target.splitlines(),
            fromfile=str(source_path),
            tofile=str(target_path),
            lineterm="",
        )
    )
    return rendered + ("\n" if rendered else "")


def preparation_markdown(payload: Mapping[str, Any]) -> str:
    a17 = payload["a17"]
    terminology = payload["terminology"]
    lines = [
        f"# {payload['document_id']} – PŘÍPRAVA KE SCHVÁLENÍ",
        "",
        f"- Kandidát: `{payload['canonical_candidate_path']}`",
        f"- Verze: **{payload['version']}**",
        f"- Datum: **{payload['document_date']}**",
        f"- Terminologický slovník: `{payload['glossary_path']}`",
        "",
        "## Výsledek A17",
        "",
        f"- Compliance score: **{a17['compliance_score_percent']} %**",
        f"- Compliance status: **{a17['compliance_status']}**",
        f"- FAIL: **{a17['result_counts'].get('FAIL', 0)}**",
        f"- MANUAL REVIEW: "
        f"**{a17['result_counts'].get('MANUAL_REVIEW', 0)}**",
        f"- CRITICAL: **{a17['severity_counts'].get('CRITICAL', 0)}**",
        f"- HIGH: **{a17['severity_counts'].get('HIGH', 0)}**",
        "",
        "## Terminologie",
        "",
        f"- Referenčních pojmů v dokumentu: "
        f"**{terminology['known_terms_count']}**",
        f"- Kandidátů ke schválení: "
        f"**{terminology['candidate_terms_count']}**",
        "",
        "## Bezpečnost",
        "",
        f"- Placeholdery: **{payload['placeholder_count']}**",
        f"- A21 změněn: **{payload['a21_modified']}**",
        f"- Archiv změněn: **{payload['archive_modified']}**",
        f"- Databáze změněna: **{payload['database_modified']}**",
        f"- Kanonické publikování provedeno: "
        f"**{payload['canonical_publication_performed']}**",
        "",
        "## Další krok",
        "",
        "Zkontrolovat terminologické kandidáty a následně rozhodnout "
        "o schválení kanonické verze.",
        "",
        f"**FINAL STATUS:** `{payload['final_status']}`",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    root = project_root()
    candidate_path = resolve_path(
        root, args.candidate, CANDIDATE_DEFAULT
    )
    polish_report_path = resolve_path(
        root, args.polish_report, POLISH_REPORT_DEFAULT
    )
    a17_script = resolve_path(
        root, args.a17_script, A17_DEFAULT
    )
    output_dir = resolve_path(
        root, args.output_dir, OUTPUT_DEFAULT
    )

    print("MATCHMATRIX DAILY LOG CANONICAL PREPARATION")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"CANDIDATE A21      : {candidate_path}")
    print(f"POLISH REPORT A21  : {polish_report_path}")
    print(f"A17 SCRIPT         : {a17_script}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("DATABASE WRITES    : DISABLED")
    print("SOURCE WRITES      : DISABLED")
    print()

    try:
        source_text, polish_report, source_hash = validate_a21(
            candidate_path,
            polish_report_path,
        )
        glossary_path = discover_glossary(root, args.glossary)

        (
            prepared,
            metadata,
            document_id,
            filename,
            date_resolution,
        ) = prepare_candidate(
            source_text=source_text,
            source_path=candidate_path,
            version=args.version,
            author_override=args.author,
            working_area_override=args.working_area,
            explicit_document_date=args.document_date,
        )
        date_value = metadata["Datum"]
        placeholders = PLACEHOLDER_RE.findall(prepared)

        print("IDENTITA")
        print("-" * 79)
        print(f"DOCUMENT TYPE      : DAILY_LOG")
        print(f"DOCUMENT DATE      : {date_value}")
        print(
            f"DATE RESOLUTION    : "
            f"{date_resolution['method']}"
        )
        if date_resolution.get("corrected_metadata"):
            print(
                f"DATE CORRECTION    : "
                f"{date_resolution.get('metadata_date') or 'EMPTY'} "
                f"-> {date_value}"
            )
        print(f"DOCUMENT ID        : {document_id}")
        print(f"CANONICAL FILENAME : {filename}")
        print(f"VERSION            : {metadata['Verze']}")
        print(f"GLOSSARY           : {glossary_path}")
        print(f"PLACEHOLDERS       : {len(placeholders)}")
        print("A21 SHA-256        : VERIFIED")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print()

        if args.validate_only:
            if not a17_script.is_file():
                raise FileNotFoundError(
                    f"A17 nebyl nalezen: {a17_script}"
                )
            print("VALIDACE")
            print("-" * 79)
            print("DAILY LOG ID       : VALID")
            print("CALENDAR DATE      : VALID")
            print("CANONICAL NAME     : VALID")
            print("METADATA           : COMPLETE")
            print("TERMINOLOGY INPUT  : READY")
            print("A17 INPUT          : READY")
            print(
                "FINAL STATUS       : "
                "DAILY_LOG_CANONICAL_PREPARATION_VALIDATED"
            )
            return 0

        output_dir.mkdir(parents=True, exist_ok=True)
        history_dir = output_dir / "history"
        history_dir.mkdir(parents=True, exist_ok=True)
        a17_dir = output_dir / "a17"
        a17_dir.mkdir(parents=True, exist_ok=True)

        canonical_path = output_dir / filename
        stamp = datetime.now().astimezone().strftime(
            "%Y%m%d_%H%M%S"
        )
        history_path = history_dir / (
            f"{Path(filename).stem}_CANDIDATE_{stamp}.md"
        )

        canonical_path.write_text(prepared, encoding="utf-8")
        history_path.write_text(prepared, encoding="utf-8")

        diff_path = output_dir / (
            f"{document_id}_MATCHMATRIX_DENNI_ZAPIS_"
            "DIFF_FROM_A21.diff"
        )
        diff_path.write_text(
            diff_text(
                source_text,
                prepared,
                candidate_path,
                canonical_path,
            ),
            encoding="utf-8",
        )

        known_terms, candidates = terminology_audit(
            prepared,
            glossary_path,
        )
        terminology_payload = {
            "contract_version": OUTPUT_CONTRACT_VERSION,
            "generated_at": utc_now().isoformat(),
            "document_id": document_id,
            "document_path": str(canonical_path),
            "glossary_path": str(glossary_path),
            "known_terms": [asdict(item) for item in known_terms],
            "candidate_terms": [
                asdict(item) for item in candidates
            ],
            "known_terms_count": len(known_terms),
            "candidate_terms_count": len(candidates),
            "glossary_modified": False,
            "requires_user_approval": bool(candidates),
            "final_status": (
                "TERMINOLOGY_CANDIDATES_READY_FOR_REVIEW"
                if candidates
                else "TERMINOLOGY_AUDIT_NO_NEW_CANDIDATES"
            ),
        }

        term_json = output_dir / (
            f"{document_id}_TERMINOLOGY_REPORT.json"
        )
        term_csv = output_dir / (
            f"{document_id}_TERMINOLOGY_REPORT.csv"
        )
        term_md = output_dir / (
            f"{document_id}_TERMINOLOGY_REPORT.md"
        )
        term_json.write_text(
            json.dumps(
                terminology_payload,
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
        write_terminology_csv(
            term_csv,
            known_terms,
            candidates,
        )
        term_md.write_text(
            terminology_markdown(
                document_id,
                glossary_path,
                known_terms,
                candidates,
            ),
            encoding="utf-8",
        )

        a17_report, a17_stdout = run_a17(
            root=root,
            a17_script=a17_script,
            candidate=canonical_path,
            output_dir=a17_dir,
        )
        a17_stdout_path = output_dir / (
            f"{document_id}_A17_STDOUT.txt"
        )
        a17_stdout_path.write_text(
            a17_stdout,
            encoding="utf-8",
        )

        if (
            a17_report.get("document_hash_sha256")
            != hashlib.sha256(
                canonical_path.read_bytes()
            ).hexdigest()
        ):
            raise RuntimeError(
                "Hash v reportu A17 neodpovídá kandidátu."
            )

        findings = {
            item.get("rule_id"): item
            for item in a17_report.get("findings", [])
            if isinstance(item, dict)
        }
        filename_result = findings.get(
            "COMMON-FILENAME", {}
        ).get("result")
        placeholder_result = findings.get(
            "COMMON-PLACEHOLDERS", {}
        ).get("result")

        if filename_result != "PASS":
            raise RuntimeError(
                "Aktualizovaný A17 nepřijal kanonický název. "
                "Nahraď A17 dodanou verzí."
            )
        if placeholder_result != "PASS":
            raise RuntimeError(
                "A17 zjistil nevyplněný placeholder."
            )

        critical = int(
            a17_report.get("severity_counts", {}).get(
                "CRITICAL", 0
            )
        )
        high = int(
            a17_report.get("severity_counts", {}).get(
                "HIGH", 0
            )
        )
        failures = int(
            a17_report.get("result_counts", {}).get("FAIL", 0)
        )
        score = float(
            a17_report.get("compliance_score_percent", 0)
        )

        structural_ready = (
            critical == 0
            and high == 0
            and failures == 0
            and score >= 90.0
        )

        if not structural_ready:
            final_status = (
                "DAILY_LOG_CANONICAL_CANDIDATE_REQUIRES_FIX"
            )
        elif candidates:
            final_status = (
                "DAILY_LOG_CANONICAL_CANDIDATE_"
                "READY_FOR_TERMINOLOGY_REVIEW"
            )
        else:
            final_status = (
                "DAILY_LOG_CANONICAL_CANDIDATE_"
                "READY_FOR_USER_APPROVAL"
            )

        preparation_payload = {
            "contract_version": OUTPUT_CONTRACT_VERSION,
            "generated_at": utc_now().isoformat(),
            "engine_version": ENGINE_VERSION,
            "document_id": document_id,
            "document_date": date_value,
            "date_resolution": date_resolution,
            "version": metadata["Verze"],
            "canonical_filename": filename,
            "canonical_candidate_path": str(canonical_path),
            "history_candidate_path": str(history_path),
            "source_a21_path": str(candidate_path),
            "source_a21_hash_sha256": source_hash,
            "canonical_candidate_hash_sha256": (
                hashlib.sha256(
                    canonical_path.read_bytes()
                ).hexdigest()
            ),
            "diff_path": str(diff_path),
            "glossary_path": str(glossary_path),
            "terminology": {
                "known_terms_count": len(known_terms),
                "candidate_terms_count": len(candidates),
                "report_json": str(term_json),
                "report_csv": str(term_csv),
                "report_markdown": str(term_md),
                "requires_user_approval": bool(candidates),
            },
            "a17": {
                "compliance_score_percent": score,
                "compliance_status": a17_report.get(
                    "compliance_status"
                ),
                "result_counts": a17_report.get(
                    "result_counts", {}
                ),
                "severity_counts": a17_report.get(
                    "severity_counts", {}
                ),
                "report_json": str(
                    a17_dir
                    / "document_compliance_audit_latest.json"
                ),
                "report_markdown": str(
                    a17_dir
                    / "document_compliance_audit_latest.md"
                ),
                "stdout": str(a17_stdout_path),
            },
            "placeholder_count": 0,
            "structural_ready": structural_ready,
            "terminology_approved": False,
            "canonical_approval_allowed": (
                structural_ready and not candidates
            ),
            "canonical_publication_performed": False,
            "a21_modified": False,
            "archive_modified": False,
            "database_modified": False,
            "final_status": final_status,
        }

        prep_json = output_dir / (
            f"{document_id}_PREPARATION_REPORT.json"
        )
        prep_md = output_dir / (
            f"{document_id}_PREPARATION_REPORT.md"
        )
        prep_json.write_text(
            json.dumps(
                preparation_payload,
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
        prep_md.write_text(
            preparation_markdown(preparation_payload),
            encoding="utf-8",
        )

        print("VÝSLEDEK")
        print("-" * 79)
        print(f"CANONICAL CANDIDATE: {canonical_path}")
        print(f"HISTORY COPY       : {history_path}")
        print(f"DIFF               : {diff_path}")
        print(f"TERMINOLOGY TERMS  : {len(known_terms)}")
        print(f"TERM CANDIDATES    : {len(candidates)}")
        print(f"A17 SCORE          : {score:.2f} %")
        print(
            f"A17 STATUS         : "
            f"{a17_report.get('compliance_status')}"
        )
        print(f"A17 FAIL           : {failures}")
        print(f"A17 CRITICAL       : {critical}")
        print(f"A17 HIGH           : {high}")
        print(f"STRUCTURAL READY   : {structural_ready}")
        print("TERMINOLOGY OK     : False")
        print("CANONICAL PUBLISHED: False")
        print("A21 MODIFIED       : False")
        print("ARCHIVE MODIFIED   : False")
        print("DATABASE MODIFIED  : False")
        print(f"PREPARATION JSON   : {prep_json}")
        print(f"PREPARATION MD     : {prep_md}")
        print(f"FINAL STATUS       : {final_status}")
        return 0

    except Exception as exc:
        print("DAILY LOG CANONICAL PREPARATION ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("A21 MODIFIED       : False")
        print("ARCHIVE MODIFIED   : False")
        print("DATABASE MODIFIED  : False")
        print("CANONICAL PUBLISHED: False")
        print(
            "FINAL STATUS       : "
            "DAILY_LOG_CANONICAL_PREPARATION_BLOCKED"
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
