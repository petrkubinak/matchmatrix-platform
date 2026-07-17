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
- A23_TERMINOLOGY_WORKFLOW_V3_PROPOSAL_BUILDER
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from datetime import datetime
from pathlib import Path
from typing import Any


ENGINE_VERSION = "A23_TERMINOLOGY_WORKFLOW_V4_STRUCTURE_AWARE_PROPOSAL_BUILDER"
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




def _replace_metadata_value(text: str, field_name: str, new_value: str) -> str:
    pattern = re.compile(
        rf"(^\|\s*{re.escape(field_name)}\s*\|\s*)([^|]*?)(\s*\|)",
        flags=re.IGNORECASE | re.MULTILINE,
    )
    match = pattern.search(text)
    if not match:
        raise ValueError(f"V metadatech nebylo nalezeno pole „{field_name}“.")
    return text[:match.start()] + match.group(1) + new_value + match.group(3) + text[match.end():]


def _read_metadata_value(text: str, field_name: str) -> str | None:
    pattern = re.compile(
        rf"^\|\s*{re.escape(field_name)}\s*\|\s*([^|]*?)\s*\|",
        flags=re.IGNORECASE | re.MULTILINE,
    )
    match = pattern.search(text)
    return match.group(1).strip() if match else None


def _bump_version(text: str) -> tuple[str, str]:
    current = _read_metadata_value(text, "Verze")
    if not current:
        raise ValueError("V metadatech nebyla nalezena verze dokumentu.")
    match = re.fullmatch(r"(\d+)\.(\d+)", current)
    if not match:
        raise ValueError(f"Nepodporovaný formát verze: {current}")
    version = f"{int(match.group(1))}.{int(match.group(2)) + 1}"
    return _replace_metadata_value(text, "Verze", version), version


def _draft_status(text: str) -> str:
    return _replace_metadata_value(text, "Stav", "DRAFT – NEEDS_USER_APPROVAL")


def _escape_md_cell(value: str) -> str:
    return str(value or "").replace("\\", "\\\\").replace("|", r"\|").replace("\n", " ").strip()


def _find_heading_index(lines: list[str], heading_pattern: str, start: int = 0) -> int | None:
    regex = re.compile(heading_pattern, flags=re.IGNORECASE)
    for index in range(start, len(lines)):
        if regex.match(lines[index].strip()):
            return index
    return None


def _update_mm_ref_001_summary(text: str, total_count: int, added_count: int, version: str) -> str:
    text = re.sub(
        r"(?im)^#\s*3\.\s*Souhrn verze\s+[^\n]+$",
        f"# 3. Souhrn verze {version}",
        text,
        count=1,
    )
    text = re.sub(
        r"(?im)(^\|\s*Nové pojmy[^|]*\|\s*)\d+(\s*\|)",
        lambda m: f"{m.group(1)}{added_count}{m.group(2)}",
        text,
        count=1,
    )
    text = re.sub(
        r"(?im)(^\|\s*Celkový počet pojmů\s*\|\s*)\d+(\s*\|)",
        lambda m: f"{m.group(1)}{total_count}{m.group(2)}",
        text,
        count=1,
    )
    return text


def _append_history_row(text: str, version: str, description: str) -> str:
    """
    Doplní nebo aktualizuje řádek v tabulce historie verzí.

    Podporuje libovolné číslování kapitoly, například:
    - # 4. Historie verzí
    - # 7. Historie verzí
    - # Historie verzí

    Pokud sekce chybí, vytvoří ji bezpečně před závěrem dokumentu.
    """
    lines = text.splitlines()

    history_heading = _find_heading_index(
        lines,
        r"^#{1,6}\s*(?:\d+(?:\.\d+)*\.?\s*)?Historie verzí\s*$",
    )

    if history_heading is None:
        conclusion_index = _find_heading_index(
            lines,
            r"^#{1,6}\s*(?:Závěr|Zaver)\s*$",
        )
        insert_at = conclusion_index if conclusion_index is not None else len(lines)

        block = [
            "# Historie verzí",
            "",
            "| Verze | Datum | Popis |",
            "|---|---|---|",
            "",
        ]
        if insert_at > 0 and lines[insert_at - 1].strip():
            block.insert(0, "")
        lines[insert_at:insert_at] = block

        history_heading = insert_at + (1 if block and block[0] == "" else 0)

    table_header = None
    section_end = len(lines)

    for index in range(history_heading + 1, len(lines)):
        stripped = lines[index].strip()

        if re.match(r"^#{1,6}\s+", stripped):
            section_end = index
            break

        cells = split_markdown_row(lines[index])
        if len(cells) >= 3 and normalize_term(cells[0]) == "verze":
            table_header = index
            break

    if table_header is None:
        insertion = history_heading + 1
        table = [
            "",
            "| Verze | Datum | Popis |",
            "|---|---|---|",
        ]
        lines[insertion:insertion] = table
        table_header = insertion + 1
        section_end += len(table)

    today = datetime.now().astimezone().date().isoformat()
    new_row = f"| {version} | {today} | {_escape_md_cell(description)} |"

    # Opakovaný běh aktualizuje stejnou verzi místo vytvoření duplicity.
    scan_end = section_end if section_end <= len(lines) else len(lines)
    for index in range(table_header + 2, scan_end):
        cells = split_markdown_row(lines[index])
        if len(cells) >= 3 and normalize_term(cells[0]) == normalize_term(version):
            lines[index] = new_row
            return "\n".join(lines).rstrip() + "\n"

    insert_at = table_header + 2
    while insert_at < scan_end:
        cells = split_markdown_row(lines[insert_at])
        if len(cells) < 3 or is_separator_row(cells):
            break
        insert_at += 1

    lines.insert(insert_at, new_row)
    return "\n".join(lines).rstrip() + "\n"


def _insert_mm_ref_001(text: str, selected: list[dict[str, Any]]) -> tuple[str, int, int]:
    lines = text.splitlines()
    header = None
    for index, line in enumerate(lines):
        cells = split_markdown_row(line)
        if len(cells) >= 2:
            normalized = [normalize_term(cell) for cell in cells[:2]]
            if normalized in (
                ["cizí výraz", "český překlad"],
                ["cizi vyraz", "cesky preklad"],
            ):
                header = index
                break
    if header is None:
        raise ValueError("MM-REF-001 neobsahuje tabulku Cizí výraz / Český překlad.")

    existing = parse_translation_glossary(text)
    new_rows: list[tuple[str, str]] = []
    seen = set(existing)
    for item in selected:
        foreign = str(item.get("foreign") or "").strip()
        czech = str(item.get("czech") or "").strip()
        key = normalize_term(foreign)
        if foreign and czech and key not in seen:
            new_rows.append((foreign, czech))
            seen.add(key)

    if not new_rows:
        return text, 0, len(existing)

    all_rows = [(entry["foreign"], entry["czech"]) for entry in existing.values()]
    all_rows.extend(new_rows)
    all_rows.sort(key=lambda pair: normalize_term(pair[0]))

    table_end = header + 2
    while table_end < len(lines):
        row_cells = split_markdown_row(lines[table_end])
        if len(row_cells) < 2 or lines[table_end].lstrip().startswith("#"):
            break
        table_end += 1

    replacement = [
        f"| {_escape_md_cell(foreign)} | {_escape_md_cell(czech)} |"
        for foreign, czech in all_rows
    ]
    lines[header + 2:table_end] = replacement

    result = "\n".join(lines).rstrip() + "\n"
    return result, len(new_rows), len(all_rows)


def _slugify_anchor(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    ascii_text = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    ascii_text = ascii_text.casefold()
    ascii_text = re.sub(r"[^a-z0-9]+", "-", ascii_text).strip("-")
    return ascii_text or "pojem"


def _unique_anchor(base: str, used: set[str]) -> str:
    candidate = base
    counter = 2
    while candidate in used:
        candidate = f"{base}-{counter}"
        counter += 1
    used.add(candidate)
    return candidate


def _insert_before_final_conclusion(text: str, block: str) -> str:
    lines = text.splitlines()
    conclusion_index = None
    for index, line in enumerate(lines):
        if re.match(r"^#\s+Závěr\s*$", line.strip(), flags=re.IGNORECASE):
            conclusion_index = index
    if conclusion_index is None:
        return text.rstrip() + "\n\n" + block.strip() + "\n"
    lines[conclusion_index:conclusion_index] = ["", block.strip(), "", "---", ""]
    return "\n".join(lines).rstrip() + "\n"


def _append_mm_ref_002(
    text: str,
    selected: list[dict[str, Any]],
    source_id: str,
) -> tuple[str, int]:
    known = parse_explanation_terms(text)
    candidates = [
        item for item in selected
        if "MM-REF-002" in str(item.get("target_document") or "")
        and normalize_term(item.get("foreign", "")) not in known
    ]
    if not candidates:
        return text, 0

    used_anchors = set(re.findall(r'<a\s+id="([^"]+)"', text, flags=re.IGNORECASE))
    today = datetime.now().astimezone().date().isoformat()
    parts = [
        f"## Návrh doplnění pojmů ze zdroje {source_id}",
        "",
        f"**Datum návrhu:** {today}  ",
        "**Stav kapitoly:** DRAFT – NEEDS_USER_APPROVAL",
        "",
        "### Klikací rejstřík nových pojmů",
        "",
        "| Cizí výraz | Český překlad | Odkaz |",
        "|---|---|---|",
    ]

    prepared: list[tuple[dict[str, Any], str]] = []
    for item in sorted(candidates, key=lambda x: normalize_term(x.get("foreign", ""))):
        foreign = str(item.get("foreign") or "").strip()
        anchor = _unique_anchor(_slugify_anchor(foreign), used_anchors)
        prepared.append((item, anchor))
        parts.append(
            f"| {_escape_md_cell(foreign)} | {_escape_md_cell(item.get('czech', ''))} | "
            f"[Přejít na výklad](#{anchor}) |"
        )

    for item, anchor in prepared:
        foreign = str(item.get("foreign") or "").strip()
        czech = str(item.get("czech") or "").strip()
        explanation = str(item.get("explanation") or "").strip()
        target_chapter = str(item.get("source_chapter") or item.get("chapter") or "Terminologičtí kandidáti").strip()
        parts += [
            "",
            f'<a id="{anchor}"></a>',
            f"### {foreign}",
            "",
            "| Položka | Hodnota |",
            "|---|---|",
            f"| Cizí výraz | {_escape_md_cell(foreign)} |",
            f"| Doporučený český překlad | {_escape_md_cell(czech)} |",
            f"| Zdrojový dokument | `{_escape_md_cell(source_id)}` |",
            f"| Zdrojová kapitola | {_escape_md_cell(target_chapter)} |",
            "| Governance stav | NÁVRH K UŽIVATELSKÉMU SCHVÁLENÍ |",
            "",
            "#### Význam a použití",
            "",
            explanation or "Výklad musí být doplněn před schválením.",
        ]

    parts += [
        "",
        "### Závěr kapitoly",
        "",
        "Kapitola obsahuje návrhy nových výkladů. Přínosem je řízené doplnění terminologie bez přepsání schválených záznamů. Návaznost pokračuje uživatelským schválením a samostatným A17.",
    ]
    return _insert_before_final_conclusion(text, "\n".join(parts)), len(candidates)


def _update_generic_count(text: str, labels: tuple[str, ...], increment: int) -> str:
    if increment <= 0:
        return text
    for label in labels:
        pattern = re.compile(
            rf"(^\|\s*{re.escape(label)}\s*\|\s*)(\d+)(\s*\|)",
            flags=re.IGNORECASE | re.MULTILINE,
        )
        match = pattern.search(text)
        if match:
            new_value = int(match.group(2)) + increment
            return text[:match.start()] + match.group(1) + str(new_value) + match.group(3) + text[match.end():]
    return text


def build_proposals(
    source: Path,
    translation_path: Path,
    explanation_path: Path,
    output_dir: Path,
    selection_path: Path,
) -> dict[str, Any]:
    selection = json.loads(read_text(selection_path))
    selected = list(selection.get("selected_candidates") or [])
    if not selected:
        raise ValueError("Nebyl vybrán žádný kandidát.")

    source_id = extract_document_id(read_text(source)) or source.stem

    translation_text, added_translation, total_translation = _insert_mm_ref_001(
        read_text(translation_path),
        selected,
    )
    translation_text, translation_version = _bump_version(translation_text)
    translation_text = _draft_status(translation_text)
    translation_text = _update_mm_ref_001_summary(
        translation_text,
        total_count=total_translation,
        added_count=added_translation,
        version=translation_version,
    )
    translation_text = _append_history_row(
        translation_text,
        translation_version,
        f"Doplněno {added_translation} terminologických kandidátů ze zdroje {source_id}.",
    )

    explanation_text, added_explanations = _append_mm_ref_002(
        read_text(explanation_path),
        selected,
        source_id,
    )
    explanation_text, explanation_version = _bump_version(explanation_text)
    explanation_text = _draft_status(explanation_text)
    explanation_text = _update_generic_count(
        explanation_text,
        ("Celkový počet výkladů", "Počet výkladů", "Celkový počet pojmů"),
        added_explanations,
    )
    explanation_text = _append_history_row(
        explanation_text,
        explanation_version,
        f"Doplněno {added_explanations} výkladových položek ze zdroje {source_id}.",
    )

    proposal_dir = output_dir / "proposals"
    proposal_dir.mkdir(parents=True, exist_ok=True)

    translation_output = proposal_dir / "MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX_PROPOSAL.md"
    explanation_output = proposal_dir / "MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX_PROPOSAL.md"

    translation_output.write_text(translation_text, encoding="utf-8")
    explanation_output.write_text(explanation_text, encoding="utf-8")

    payload = {
        "engine_version": ENGINE_VERSION,
        "generated_at": datetime.now().astimezone().isoformat(),
        "final_status": "TERMINOLOGY_GLOSSARY_PROPOSALS_CREATED",
        "source_document_id": source_id,
        "selected_count": len(selected),
        "translation_added_count": added_translation,
        "explanation_added_count": added_explanations,
        "translation_candidate": str(translation_output),
        "translation_candidate_version": translation_version,
        "translation_candidate_sha256": sha256_path(translation_output),
        "explanation_candidate": str(explanation_output),
        "explanation_candidate_version": explanation_version,
        "explanation_candidate_sha256": sha256_path(explanation_output),
        "canonical_files_modified": False,
        "database_modified": False,
        "git_modified": False,
    }

    (proposal_dir / "terminology_proposals_latest.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (proposal_dir / "terminology_proposals_latest.md").write_text(
        "\n".join(
            [
                "# A23 – Návrhy aktualizace slovníků",
                "",
                f"- Zdroj: `{source_id}`",
                f"- Vybraných kandidátů: **{len(selected)}**",
                f"- Do MM-REF-001 skutečně doplněno: **{added_translation}**",
                f"- Do MM-REF-002 skutečně doplněno: **{added_explanations}**",
                f"- MM-REF-001: `{translation_version}`",
                f"- MM-REF-002: `{explanation_version}`",
                "",
                "Kanonické soubory, Git ani databáze nebyly změněny.",
                "",
                "FINAL STATUS: TERMINOLOGY_GLOSSARY_PROPOSALS_CREATED",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--document", required=True)
    parser.add_argument("--translation-glossary", required=True)
    parser.add_argument("--explanation-glossary", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--mode", choices=["analyze", "build-proposals"], default="analyze")
    parser.add_argument("--selection-json")
    args = parser.parse_args()

    source = Path(args.document).resolve()
    translation_path = Path(args.translation_glossary).resolve()
    explanation_path = Path(args.explanation_glossary).resolve()
    output_dir = Path(args.output_dir).resolve()

    if args.mode == "build-proposals":
        if not args.selection_json:
            raise ValueError("--selection-json je povinný pro build-proposals.")
        selection_path = Path(args.selection_json).resolve()
        for path in (source, translation_path, explanation_path, selection_path):
            if not path.is_file():
                raise FileNotFoundError(f"Soubor nebyl nalezen: {path}")
        output_dir.mkdir(parents=True, exist_ok=True)
        payload = build_proposals(source, translation_path, explanation_path, output_dir, selection_path)
        print(f"SELECTED_COUNT={payload['selected_count']}")
        print(f"TRANSLATION_PROPOSAL={payload['translation_candidate']}")
        print(f"EXPLANATION_PROPOSAL={payload['explanation_candidate']}")
        print("CANONICAL_FILES_MODIFIED=False")
        print("DATABASE_MODIFIED=False")
        print("GIT_MODIFIED=False")
        print("FINAL STATUS: TERMINOLOGY_GLOSSARY_PROPOSALS_CREATED")
        return 0

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
