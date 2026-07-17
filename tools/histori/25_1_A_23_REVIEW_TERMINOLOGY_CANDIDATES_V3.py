#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MATCHMATRIX A23 – REVIEW TERMINOLOGY CANDIDATES V2
=================================================

CO:
- Read-only analyzátor terminologických kandidátů z jednoho Markdown dokumentu.

K ČEMU:
- Najde explicitně uvedené kandidáty v tabulce terminologického workflow.
- Porovná je s MM-REF-001 a MM-REF-002.
- Označí NOVÝ / EXISTUJE / KONFLIKT / REVIEW.
- Vytvoří JSON a Markdown report pro panel.

KDE:
- tools/documentation/25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py

JAK:
- Nikdy nepřepisuje zdrojový dokument ani referenční slovníky.
- Pracuje pouze s textovými vstupy a zapisuje report do --output-dir.
- Zápis do MM-REF-001 a MM-REF-002 bude samostatný schvalovaný krok.

ENGINE:
- A23_TERMINOLOGY_CANDIDATE_REVIEW_V2_READ_ONLY
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


ENGINE_VERSION = "A23_TERMINOLOGY_CANDIDATE_REVIEW_V2_READ_ONLY"
FINAL_STATUS_OK = "TERMINOLOGY_CANDIDATES_REVIEWED"
FINAL_STATUS_EMPTY = "NO_EXPLICIT_TERMINOLOGY_CANDIDATES"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def sha256_path(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def normalize_term(value: str) -> str:
    text = re.sub(r"\s+", " ", str(value or "").strip())
    return text.casefold()


def split_markdown_row(line: str) -> list[str]:
    stripped = line.strip()
    if not stripped.startswith("|"):
        return []
    return [cell.strip() for cell in stripped.strip("|").split("|")]


def is_separator_row(cells: list[str]) -> bool:
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", cell.replace(" ", "")) for cell in cells)


def parse_translation_glossary(text: str) -> dict[str, dict[str, str]]:
    entries: dict[str, dict[str, str]] = {}
    lines = text.splitlines()
    for index, line in enumerate(lines):
        cells = split_markdown_row(line)
        if len(cells) < 2:
            continue
        header = [normalize_term(c) for c in cells[:2]]
        if header not in (
            ["cizí výraz", "český překlad"],
            ["cizi vyraz", "cesky preklad"],
        ):
            continue
        row_index = index + 2
        while row_index < len(lines):
            row_cells = split_markdown_row(lines[row_index])
            if len(row_cells) < 2 or is_separator_row(row_cells):
                if not lines[row_index].strip():
                    break
                row_index += 1
                continue
            foreign, czech = row_cells[0].strip(), row_cells[1].strip()
            if not foreign:
                break
            entries[normalize_term(foreign)] = {
                "foreign": foreign,
                "czech": czech,
            }
            row_index += 1
        break
    return entries


def parse_explanation_terms(text: str) -> set[str]:
    terms: set[str] = set()
    for line in text.splitlines():
        heading = re.match(r"^\s{0,3}#{2,6}\s+(.+?)\s*$", line)
        if heading:
            raw = re.sub(r"[`*_]", "", heading.group(1)).strip()
            raw = re.sub(r"^\d+(?:\.\d+)*\s*[-–—.:)]?\s*", "", raw)
            if raw and len(raw) <= 120:
                terms.add(normalize_term(raw))
        cells = split_markdown_row(line)
        if len(cells) >= 1 and cells[0] and not is_separator_row(cells):
            first = normalize_term(cells[0])
            if first not in {"pojem", "cizí výraz", "cizi vyraz"} and len(first) <= 120:
                terms.add(first)
    return terms


def extract_explicit_candidates(text: str) -> list[dict[str, str]]:
    """
    Bezpečně čte pouze explicitní tabulku kandidátů.
    Tím nevkládá názvy sloupců, kód ani běžná anglická slova bez záměru autora.
    """
    lines = text.splitlines()
    candidates: list[dict[str, str]] = []

    for index, line in enumerate(lines):
        cells = split_markdown_row(line)
        if len(cells) < 4:
            continue
        normalized = [normalize_term(c) for c in cells[:4]]
        expected_a = ["cizí nebo technický pojem", "český význam", "cílový dokument", "výklad"]
        expected_b = ["cizi nebo technicky pojem", "cesky vyznam", "cilovy dokument", "vyklad"]
        if normalized not in (expected_a, expected_b):
            continue

        row_index = index + 2
        while row_index < len(lines):
            row = split_markdown_row(lines[row_index])
            if len(row) < 4:
                if not lines[row_index].strip():
                    break
                row_index += 1
                continue
            if is_separator_row(row):
                row_index += 1
                continue

            foreign, czech, target, explanation = [cell.strip() for cell in row[:4]]
            if not foreign:
                break
            candidates.append(
                {
                    "foreign": foreign,
                    "czech": czech,
                    "target_document": target,
                    "explanation": explanation,
                }
            )
            row_index += 1
        break

    dedup: dict[str, dict[str, str]] = {}
    for item in candidates:
        key = normalize_term(item["foreign"])
        if key and key not in dedup:
            dedup[key] = item
    return list(dedup.values())


def classify_candidates(
    candidates: list[dict[str, str]],
    translations: dict[str, dict[str, str]],
    explanations: set[str],
) -> list[dict[str, Any]]:
    reviewed: list[dict[str, Any]] = []

    for item in candidates:
        key = normalize_term(item["foreign"])
        existing_translation = translations.get(key)
        exists_in_explanation = key in explanations

        if existing_translation:
            existing_czech = existing_translation.get("czech", "")
            if normalize_term(existing_czech) == normalize_term(item["czech"]):
                status = "EXISTS"
                reason = "Pojem i doporučený český překlad již existují v MM-REF-001."
            else:
                status = "CONFLICT"
                reason = (
                    "Pojem existuje v MM-REF-001, ale navržený český překlad se liší "
                    f"od schválené hodnoty „{existing_czech}“."
                )
        else:
            status = "NEW"
            reason = "Pojem není v MM-REF-001."

        if status == "EXISTS" and not exists_in_explanation and "MM-REF-002" in item["target_document"]:
            status = "REVIEW"
            reason = "Překlad existuje, ale podrobný výklad nebyl jednoznačně nalezen v MM-REF-002."

        reviewed.append(
            {
                **item,
                "normalized_term": key,
                "status": status,
                "reason": reason,
                "existing_translation": existing_translation.get("czech", "") if existing_translation else "",
                "exists_in_mm_ref_001": bool(existing_translation),
                "exists_in_mm_ref_002": bool(exists_in_explanation),
                "selected_for_update": status in {"NEW", "REVIEW"},
            }
        )
    return reviewed


def markdown_report(payload: dict[str, Any]) -> str:
    lines = [
        "# A23 – Terminologičtí kandidáti",
        "",
        f"- Engine: `{payload['engine_version']}`",
        f"- Zdroj: `{payload['source_document']}`",
        f"- Document ID: `{payload.get('document_id') or '-'}`",
        f"- Vygenerováno: `{payload['generated_at']}`",
        f"- Kandidáti: **{payload['summary']['total']}**",
        f"- NEW: **{payload['summary']['new']}**",
        f"- EXISTS: **{payload['summary']['exists']}**",
        f"- REVIEW: **{payload['summary']['review']}**",
        f"- CONFLICT: **{payload['summary']['conflict']}**",
        "",
        "| Stav | Cizí výraz | Český překlad | Existující překlad | MM-REF-002 | Cíl | Důvod |",
        "|---|---|---|---|---|---|---|",
    ]
    for item in payload["candidates"]:
        def e(value: Any) -> str:
            return str(value or "").replace("|", r"\|").replace("\n", " ")
        lines.append(
            f"| {e(item['status'])} | {e(item['foreign'])} | {e(item['czech'])} | "
            f"{e(item['existing_translation'])} | "
            f"{'ANO' if item['exists_in_mm_ref_002'] else 'NE'} | "
            f"{e(item['target_document'])} | {e(item['reason'])} |"
        )

    lines += [
        "",
        "## Bezpečnostní pravidlo",
        "",
        "Tento report je pouze návrh. A23 nepřepsal MM-REF-001 ani MM-REF-002.",
        "Zápis smí vzniknout až po uživatelském potvrzení a samostatném řízeném workflow.",
        "",
        f"FINAL STATUS: {payload['final_status']}",
        "",
    ]
    return "\n".join(lines)


def extract_document_id(text: str) -> str | None:
    patterns = [
        r"^\|\s*Document ID\s*\|\s*([^|]+?)\s*\|",
        r"^\*\*Document ID:\*\*\s*`?([^`\s]+)`?\s*$",
    ]
    for pattern in patterns:
        match = re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE)
        if match:
            return match.group(1).strip()
    return None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--document", required=True)
    parser.add_argument("--translation-glossary", required=True)
    parser.add_argument("--explanation-glossary", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    source = Path(args.document).resolve()
    translation_path = Path(args.translation_glossary).resolve()
    explanation_path = Path(args.explanation_glossary).resolve()
    output_dir = Path(args.output_dir).resolve()

    for path in (source, translation_path, explanation_path):
        if not path.is_file():
            raise FileNotFoundError(f"Soubor nebyl nalezen: {path}")

    output_dir.mkdir(parents=True, exist_ok=True)

    source_text = read_text(source)
    translation_text = read_text(translation_path)
    explanation_text = read_text(explanation_path)

    candidates = extract_explicit_candidates(source_text)
    translations = parse_translation_glossary(translation_text)
    explanations = parse_explanation_terms(explanation_text)
    reviewed = classify_candidates(candidates, translations, explanations)

    counts = {
        "total": len(reviewed),
        "new": sum(item["status"] == "NEW" for item in reviewed),
        "exists": sum(item["status"] == "EXISTS" for item in reviewed),
        "review": sum(item["status"] == "REVIEW" for item in reviewed),
        "conflict": sum(item["status"] == "CONFLICT" for item in reviewed),
    }

    final_status = FINAL_STATUS_OK if reviewed else FINAL_STATUS_EMPTY
    payload: dict[str, Any] = {
        "engine_version": ENGINE_VERSION,
        "generated_at": datetime.now().astimezone().isoformat(),
        "final_status": final_status,
        "document_id": extract_document_id(source_text),
        "source_document": str(source),
        "source_sha256": sha256_path(source),
        "translation_glossary": str(translation_path),
        "translation_glossary_sha256": sha256_path(translation_path),
        "explanation_glossary": str(explanation_path),
        "explanation_glossary_sha256": sha256_path(explanation_path),
        "summary": counts,
        "candidates": reviewed,
        "write_operations": [],
        "source_modified": False,
        "glossaries_modified": False,
    }

    json_path = output_dir / "terminology_candidates_latest.json"
    markdown_path = output_dir / "terminology_candidates_latest.md"
    json_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    markdown_path.write_text(markdown_report(payload), encoding="utf-8")

    print(f"ENGINE_VERSION={ENGINE_VERSION}")
    print(f"DOCUMENT_ID={payload.get('document_id') or '-'}")
    print(f"CANDIDATES_TOTAL={counts['total']}")
    print(f"CANDIDATES_NEW={counts['new']}")
    print(f"CANDIDATES_EXISTS={counts['exists']}")
    print(f"CANDIDATES_REVIEW={counts['review']}")
    print(f"CANDIDATES_CONFLICT={counts['conflict']}")
    print(f"JSON_REPORT={json_path}")
    print(f"MARKDOWN_REPORT={markdown_path}")
    print("SOURCE_MODIFIED=False")
    print("GLOSSARIES_MODIFIED=False")
    print(f"FINAL STATUS: {final_status}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"FINAL STATUS: TERMINOLOGY_CANDIDATE_REVIEW_FAILED", file=sys.stderr)
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
