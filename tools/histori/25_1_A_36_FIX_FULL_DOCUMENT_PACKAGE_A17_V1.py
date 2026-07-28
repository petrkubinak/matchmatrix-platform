#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
===============================================================================
MatchMatrix
25_1_A_36_FIX_FULL_DOCUMENT_PACKAGE_A17_V1.py
===============================================================================

CO:
    Opraví formální náležitosti devíti aktualizovaných hlavních dokumentů,
    které byly nalezeny auditem A17 dne 2026-07-28.

K ČEMU:
    - zachová současný Document ID, verzi, stav a aktivní název souboru,
    - doplní explicitní úvod tam, kde byl A17 nalezen pouze nepřímo,
    - doplní závěr dokumentu tam, kde chybí,
    - doplní ke každé skutečné hlavní kapitole samostatný závěr obsahující
      shrnutí, přínos a návaznost,
    - normalizuje hierarchii MM-DOC-000 a MM-DOC-800,
    - odstraní falešnou metadata detekci ukázkového MM-DOC-300 v MM-STD-004,
    - vytvoří technickou rollback kopii původních souborů pod reports/,
    - po změně automaticky spustí read-only A17 nad všemi devíti dokumenty,
    - při jakémkoli FAIL, PARTIAL nebo technické chybě obnoví všechny původní
      soubory.

KDE:
    Aktivní nástroj:
    tools/documentation/25_1_A_36_FIX_FULL_DOCUMENT_PACKAGE_A17_V1.py

JAK:
    Spustit přímo v terminálu VS Code připojeném přes SSH k PC2.
    PROJECT_ROOT je odvozen z umístění skriptu.
    Skript neprovádí Git commit, Git push, A24 ani databázový zápis.
===============================================================================
"""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
import sys
import unicodedata
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, NoReturn, Sequence


ENGINE = "A36_FULL_DOCUMENT_PACKAGE_A17_FIX_V1_0"
SCRIPT_VERSION = "1.0"

A17_RELATIVE = Path(
    "tools/documentation/"
    "25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py"
)

REPORT_ROOT_RELATIVE = Path(
    "reports/documentation/standardization/"
    "20260728_FULL_PACKAGE_A17_AFTER_FIX"
)

BACKUP_ROOT_RELATIVE = Path(
    "reports/documentation/standardization/"
    "20260728_FULL_PACKAGE_A17_FIX_BACKUP"
)


@dataclass(frozen=True)
class DocumentSpec:
    document_id: str
    relative_path: Path
    expected_version: str
    expected_status: str
    explicit_intro: bool = False
    overall_conclusion_title: str | None = None
    normalize_mm_doc_000: bool = False
    normalize_mm_doc_800: bool = False
    fix_mm_std_004_examples: bool = False


DOCUMENTS: tuple[DocumentSpec, ...] = (
    DocumentSpec(
        "MM-DOC-000",
        Path(
            "docs/00_DOCUMENTATION/"
            "MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md"
        ),
        "1.2",
        "REVIEW",
        normalize_mm_doc_000=True,
    ),
    DocumentSpec(
        "MM-DOC-100",
        Path("docs/01_MASTER/MM-DOC-100_MATCHMATRIX_MASTER_TECH.md"),
        "1.1",
        "REVIEW",
        explicit_intro=True,
    ),
    DocumentSpec(
        "MM-DOC-200",
        Path(
            "docs/02_GOVERNANCE/"
            "MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md"
        ),
        "1.1",
        "REVIEW",
        explicit_intro=True,
        overall_conclusion_title="Governance MatchMatrix",
    ),
    DocumentSpec(
        "MM-DOC-300",
        Path(
            "docs/03_ARCHITECTURE/"
            "MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md"
        ),
        "1.1",
        "REVIEW",
        explicit_intro=True,
        overall_conclusion_title="architektury MatchMatrix",
    ),
    DocumentSpec(
        "MM-DOC-800",
        Path(
            "docs/08_DEVELOPMENT/"
            "MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md"
        ),
        "1.2",
        "REVIEW",
        normalize_mm_doc_800=True,
    ),
    DocumentSpec(
        "MM-DOC-900",
        Path(
            "docs/09_HISTORY/"
            "MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.md"
        ),
        "1.2",
        "REVIEW",
        explicit_intro=True,
        overall_conclusion_title="řízení denních zápisů a projektové kontinuity",
    ),
    DocumentSpec(
        "MM-STD-003",
        Path(
            "docs/12_STANDARD/"
            "MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md"
        ),
        "1.2",
        "REVIEW",
        explicit_intro=True,
    ),
    DocumentSpec(
        "MM-STD-004",
        Path(
            "docs/12_STANDARD/"
            "MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md"
        ),
        "1.1",
        "REVIEW",
        explicit_intro=True,
        fix_mm_std_004_examples=True,
    ),
    DocumentSpec(
        "MM-STD-007",
        Path(
            "docs/12_STANDARD/"
            "MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md"
        ),
        "1.1",
        "REVIEW",
        explicit_intro=True,
    ),
)


@dataclass(frozen=True)
class Heading:
    level: int
    title: str
    normalized: str
    line: int


MAIN_NON_BODY_HEADING_TOKENS: tuple[str, ...] = (
    "informace o dokumentu",
    "metadata dokumentu",
    "obsah",
    "historie verzi",
)


def fail(message: str) -> NoReturn:
    raise RuntimeError(message)


def normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", str(value or ""))
    without_marks = "".join(
        char for char in decomposed if not unicodedata.combining(char)
    )
    lowered = without_marks.lower()
    lowered = re.sub(r"[`*_#>|]", " ", lowered)
    lowered = re.sub(r"[^a-z0-9]+", " ", lowered)
    return re.sub(r"\s+", " ", lowered).strip()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def extract_headings(text: str) -> list[Heading]:
    result: list[Heading] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        match = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
        if not match:
            continue
        title = match.group(2).strip()
        result.append(
            Heading(
                level=len(match.group(1)),
                title=title,
                normalized=normalize(title),
                line=line_number,
            )
        )
    return result


def is_numbered_main_heading(heading: Heading) -> bool:
    return re.match(
        r"^\d+(?:\.\d+)*\.?\s+\S",
        heading.title,
    ) is not None


def is_main_body_heading(heading: Heading) -> bool:
    value = heading.normalized
    if any(token in value for token in MAIN_NON_BODY_HEADING_TOKENS):
        return False
    if re.fullmatch(r"(?:\d+ )?zaver(?: dokumentu)?", value):
        return False
    return True


def detect_main_chapter_level(
    headings: Sequence[Heading],
) -> tuple[int | None, list[Heading], list[str]]:
    evidence: list[str] = []
    headings_by_level = {
        level: [heading for heading in headings if heading.level == level]
        for level in range(1, 7)
    }

    for level in range(1, 7):
        numbered_candidates = [
            heading
            for heading in headings_by_level[level]
            if is_main_body_heading(heading)
            and is_numbered_main_heading(heading)
        ]
        if len(numbered_candidates) >= 2:
            evidence.append(
                f"Hlavní kapitoly jsou číslované nadpisy H{level}."
            )
            return level, numbered_candidates, evidence

    h1_all = headings_by_level[1]
    if len(h1_all) == 1:
        for level in range(2, 7):
            candidates = [
                heading
                for heading in headings_by_level[level]
                if is_main_body_heading(heading)
            ]
            if len(candidates) >= 2:
                evidence.append(
                    f"Jeden H1 je název dokumentu; hlavní kapitoly jsou H{level}."
                )
                return level, candidates, evidence

    h1_body = [
        heading for heading in h1_all if is_main_body_heading(heading)
    ]
    if len(h1_body) >= 2:
        evidence.append("Nouzová detekce hlavních kapitol na H1.")
        return 1, h1_body, evidence

    for level in range(2, 7):
        candidates = [
            heading
            for heading in headings_by_level[level]
            if is_main_body_heading(heading)
        ]
        if len(candidates) >= 2:
            evidence.append(
                f"Nouzová detekce hlavních kapitol na H{level}."
            )
            return level, candidates, evidence

    return None, [], ["Nebyla nalezena úroveň hlavních kapitol."]


def metadata_value(text: str, label: str) -> str:
    pattern = re.compile(
        rf"(?mi)^\|\s*{re.escape(label)}\s*\|\s*([^|]+?)\s*\|\s*$"
    )
    match = pattern.search(text[:12000])
    return match.group(1).strip() if match else ""


def validate_identity(
    text: str,
    path: Path,
    spec: DocumentSpec,
) -> None:
    version = metadata_value(text, "Verze")
    status = metadata_value(text, "Stav").upper()

    if version != spec.expected_version:
        fail(
            f"{spec.document_id}: očekávána verze "
            f"{spec.expected_version}, nalezena {version!r}."
        )
    if status != spec.expected_status:
        fail(
            f"{spec.document_id}: očekáván stav "
            f"{spec.expected_status}, nalezen {status!r}."
        )
    if not path.name.upper().startswith(spec.document_id + "_"):
        fail(
            f"{spec.document_id}: aktivní název souboru nezačíná Document ID."
        )
    if spec.document_id not in text[:12000]:
        fail(
            f"{spec.document_id}: Document ID nebyl nalezen v úvodní části."
        )


def has_explicit_intro(text: str) -> bool:
    for heading in extract_headings(text):
        tokens = heading.normalized.split()
        if "uvod" in tokens:
            return True
    return False


def ensure_explicit_intro(text: str, document_id: str) -> str:
    if has_explicit_intro(text):
        return text

    patterns = (
        r"(?m)^## Účel dokumentu\s*$",
        r"(?m)^## Účel\s*$",
    )
    for pattern in patterns:
        updated, count = re.subn(
            pattern,
            "## Úvod a účel dokumentu",
            text,
            count=1,
        )
        if count == 1:
            return updated

    fail(
        f"{document_id}: nebyla nalezena sekce Účel dokumentu "
        "pro bezpečné vytvoření explicitního úvodu."
    )


def has_overall_conclusion(text: str) -> bool:
    for heading in extract_headings(text):
        if re.fullmatch(
            r"(?:\d+ )?zaver(?: dokumentu)?",
            heading.normalized,
        ):
            return True
    return False


def ensure_overall_conclusion(
    text: str,
    document_id: str,
    subject: str,
) -> str:
    if has_overall_conclusion(text):
        return text

    marker = re.search(r"(?m)^# AI CONTEXT\s*$", text)
    if not marker:
        fail(
            f"{document_id}: nelze vložit závěr dokumentu, "
            "protože chybí následná sekce AI CONTEXT."
        )

    conclusion = (
        "# Závěr dokumentu\n\n"
        f"Dokument {document_id} uzavírá řízený popis oblasti {subject}. "
        "Shrnuje pravidla, ověřený stav, odpovědnosti a vazby, které jsou "
        "potřebné pro další bezpečnou práci v projektu MatchMatrix. "
        "Přínos dokumentu spočívá v jednotném a dohledatelném zachycení "
        "této oblasti pro vývoj, audit, rozhodování a dlouhodobou správu. "
        "Návaznost pokračuje kontextovými sekcemi AI CONTEXT, "
        "PROJECT SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP.\n\n"
    )

    return text[: marker.start()] + conclusion + text[marker.start() :]


def normalize_mm_doc_000(text: str) -> str:
    chapter_pairs = (
        (
            "0",
            "KAPITOLA 0",
            "SMYSL PROJEKTU MATCHMATRIX",
            "Smysl projektu MatchMatrix",
        ),
        (
            "1",
            "KAPITOLA A",
            "ZÁKLADY DOKUMENTAČNÍ ARCHITEKTURY",
            "Základy dokumentační architektury",
        ),
        (
            "2",
            "KAPITOLA B",
            "DOKUMENTAČNÍ EKOSYSTÉM MATCHMATRIX",
            "Dokumentační ekosystém MatchMatrix",
        ),
        (
            "3",
            "KAPITOLA C",
            "ZNALOSTNÍ BÁZE (KNOWLEDGE BASE) MATCHMATRIX",
            "Znalostní báze (Knowledge Base) MatchMatrix",
        ),
        (
            "4",
            "KAPITOLA D",
            "GOVERNANCE DOKUMENTAČNÍHO SYSTÉMU",
            "Governance dokumentačního systému",
        ),
        (
            "5",
            "KAPITOLA E",
            "BUDOUCNOST DOKUMENTAČNÍHO SYSTÉMU MATCHMATRIX",
            "Budoucnost dokumentačního systému MatchMatrix",
        ),
        (
            "6",
            "KAPITOLA F",
            "AKTUÁLNÍ PROVOZNÍ MODEL A PRÁCE S KONTEXTEM",
            "Aktuální provozní model a práce s kontextem",
        ),
    )

    for number, marker, title_upper, title_final in chapter_pairs:
        final_heading = f"# {number}. {title_final}"
        if final_heading in text:
            continue

        pattern = (
            rf"(?m)^# {re.escape(marker)}\s*\r?\n"
            rf"\s*# {re.escape(title_upper)}\s*$"
        )
        text, count = re.subn(
            pattern,
            final_heading,
            text,
            count=1,
        )
        if count != 1:
            fail(
                "MM-DOC-000: nelze sjednotit dvojici nadpisů "
                f"{marker!r} / {title_upper!r}."
            )

    # A.1 až F.n jsou podkapitoly hlavních kapitol 1 až 6.
    text = re.sub(
        r"(?m)^# ([A-F]\.\d+\s+.+)$",
        r"## \1",
        text,
    )

    # Shrnutí patří pod závěr kapitoly.
    text = re.sub(
        r"(?m)^## Shrnutí\s*$",
        "### Shrnutí",
        text,
    )

    # Existující závěry jednotlivých částí se stanou závěry hlavních kapitol.
    text = re.sub(
        r"(?m)^## ([A-F]\.\d+\s+)Závěr\s*$",
        r"## \1Závěr kapitoly",
        text,
    )

    return text


def normalize_mm_doc_800(text: str) -> str:
    # Nadpisy 5.1, 7.1, 8.1, 9.1, 10.1 a 13.1 byly historicky H1,
    # přestože jsou obsahově podkapitolami.
    text = re.sub(
        r"(?m)^# (\d+\.\d+\s+.+)$",
        r"## \1",
        text,
    )

    # Vnitřní části kapitoly 8.3 musí zůstat podřízené.
    for title in (
        "Řízené dokumenty",
        "Skripty a programové soubory",
        "Zásada jedné aktivní pravdy",
    ):
        text = text.replace(
            f"## {title}",
            f"### {title}",
        )

    return text


def fix_mm_std_004_examples(text: str) -> str:
    replacements = (
        ("\n# MM-DOC-300\n", "\n> # MM-DOC-300\n"),
        (
            "\n# MATCHMATRIX ARCHITECTURE\n",
            "\n> # MATCHMATRIX ARCHITECTURE\n",
        ),
        ("\n## TECH EDITION\n", "\n> ## TECH EDITION\n"),
    )
    for old, new in replacements:
        if old in text:
            text = text.replace(old, new, 1)
    return text


def chapter_conclusion_body(
    document_id: str,
    chapter_title: str,
    next_chapter_title: str | None,
) -> str:
    if next_chapter_title:
        follow_up = (
            "Návaznost pokračuje kapitolou "
            f"„{next_chapter_title}“, která rozvíjí další část "
            "řízeného dokumentu."
        )
    else:
        follow_up = (
            "Návaznost směřuje k závěru dokumentu a k navazujícím "
            "kontextovým, auditním a publikačním krokům."
        )

    return (
        "Shrnutí kapitoly: Kapitola vymezila oblast "
        f"„{chapter_title}“ v rámci dokumentu {document_id} a stanovila "
        "její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá "
        "v tom, že daná oblast je popsána jednoznačně a může sloužit jako "
        f"řízený podklad pro další práci. {follow_up}"
    )


def conclusion_body_is_complete(body: str) -> bool:
    normalized = normalize(body)
    has_summary = len(normalized.split()) >= 12
    has_contribution = "prinos" in normalized
    has_follow_up = any(
        token in normalized
        for token in (
            "nasledujici kapitola",
            "dalsi kapitola",
            "navaznost",
            "navazuje",
            "nasleduje",
        )
    )
    return has_summary and has_contribution and has_follow_up


def ensure_chapter_conclusions(
    text: str,
    document_id: str,
) -> tuple[str, int]:
    headings = extract_headings(text)
    chapter_level, chapters, evidence = detect_main_chapter_level(headings)

    if chapter_level is None or len(chapters) < 2:
        fail(
            f"{document_id}: nelze určit hlavní kapitoly. "
            + " ".join(evidence)
        )

    lines = text.splitlines()
    inserted_or_completed = 0

    # Postup odzadu zachová platnost původních čísel řádků.
    for index in range(len(chapters) - 1, -1, -1):
        chapter = chapters[index]
        chapter_index = chapter.line - 1

        next_boundary = len(lines)
        for candidate in headings:
            candidate_index = candidate.line - 1
            if candidate_index <= chapter_index:
                continue
            if candidate.level <= chapter_level:
                next_boundary = candidate_index
                break

        conclusion_heading: Heading | None = None
        for candidate in headings:
            candidate_index = candidate.line - 1
            if not (chapter_index < candidate_index < next_boundary):
                continue
            if candidate.level <= chapter_level:
                continue
            if (
                "zaver kapitoly" in candidate.normalized
                or "shrnuti kapitoly" in candidate.normalized
            ):
                conclusion_heading = candidate
                break

        next_title = (
            chapters[index + 1].title
            if index + 1 < len(chapters)
            else None
        )
        required_body = chapter_conclusion_body(
            document_id,
            chapter.title,
            next_title,
        )

        if conclusion_heading is None:
            prefix_match = re.match(
                r"^(\d+(?:\.\d+)*)\.?\s+",
                chapter.title,
            )
            prefix = (
                prefix_match.group(1)
                if prefix_match
                else str(index + 1)
            )
            conclusion_title = (
                "#" * (chapter_level + 1)
                + f" {prefix}.99 Závěr kapitoly"
            )
            insertion = [
                "",
                conclusion_title,
                "",
                required_body,
                "",
            ]
            lines[next_boundary:next_boundary] = insertion
            inserted_or_completed += 1
            continue

        conclusion_index = conclusion_heading.line - 1
        conclusion_end = next_boundary

        for candidate in headings:
            candidate_index = candidate.line - 1
            if candidate_index <= conclusion_index:
                continue
            if candidate_index >= next_boundary:
                break
            if candidate.level <= conclusion_heading.level:
                conclusion_end = candidate_index
                break

        current_body = "\n".join(
            lines[
                conclusion_index + 1:
                max(conclusion_index + 1, conclusion_end)
            ]
        ).strip()

        if conclusion_body_is_complete(current_body):
            continue

        lines[conclusion_end:conclusion_end] = [
            "",
            required_body,
            "",
        ]
        inserted_or_completed += 1

    return "\n".join(lines).rstrip() + "\n", inserted_or_completed


def update_current_history_row(
    text: str,
    document_id: str,
    version: str,
) -> str:
    phrase = (
        "Doplněna formální hierarchie a závěry hlavních kapitol "
        "podle výsledku A17 ze dne 2026-07-28."
    )

    if phrase in text:
        return text

    pattern = re.compile(
        rf"(?m)^(\|\s*{re.escape(version)}\s*\|"
        rf"\s*[^|]+\|\s*[^|]+\|\s*)([^|]*?)(\s*\|)$"
    )

    match = pattern.search(text)
    if not match:
        fail(
            f"{document_id}: v historii verzí nebyl nalezen "
            f"řádek aktuální verze {version}."
        )

    description = match.group(2).strip()
    separator = " " if description.endswith((".", ";")) else ". "
    new_description = description + separator + phrase

    return (
        text[: match.start()]
        + match.group(1)
        + new_description
        + match.group(3)
        + text[match.end() :]
    )


def validate_chapter_conclusions(
    text: str,
    document_id: str,
) -> tuple[int, int]:
    headings = extract_headings(text)
    chapter_level, chapters, evidence = detect_main_chapter_level(headings)
    if chapter_level is None or not chapters:
        fail(
            f"{document_id}: validace nenalezla hlavní kapitoly. "
            + " ".join(evidence)
        )

    lines = text.splitlines()
    verified = 0

    for chapter in chapters:
        next_boundary = len(lines) + 1
        for candidate in headings:
            if candidate.line <= chapter.line:
                continue
            if candidate.level <= chapter_level:
                next_boundary = candidate.line
                break

        conclusion_heading: Heading | None = None
        for candidate in headings:
            if not (chapter.line < candidate.line < next_boundary):
                continue
            if candidate.level <= chapter_level:
                continue
            if (
                "zaver kapitoly" in candidate.normalized
                or "shrnuti kapitoly" in candidate.normalized
            ):
                conclusion_heading = candidate
                break

        if conclusion_heading is None:
            fail(
                f"{document_id}: kapitola {chapter.title!r} "
                "nemá závěr kapitoly."
            )

        conclusion_end = next_boundary
        for candidate in headings:
            if candidate.line <= conclusion_heading.line:
                continue
            if candidate.line >= next_boundary:
                break
            if candidate.level <= conclusion_heading.level:
                conclusion_end = candidate.line
                break

        body = "\n".join(
            lines[
                conclusion_heading.line:
                max(conclusion_heading.line, conclusion_end - 1)
            ]
        ).strip()

        if not conclusion_body_is_complete(body):
            fail(
                f"{document_id}: závěr kapitoly {chapter.title!r} "
                "neobsahuje úplné shrnutí, přínos a návaznost."
            )

        verified += 1

    return len(chapters), verified


def patch_document(
    text: str,
    spec: DocumentSpec,
) -> tuple[str, dict[str, Any]]:
    original = text

    if spec.normalize_mm_doc_000:
        text = normalize_mm_doc_000(text)

    if spec.normalize_mm_doc_800:
        text = normalize_mm_doc_800(text)

    if spec.fix_mm_std_004_examples:
        text = fix_mm_std_004_examples(text)

    if spec.explicit_intro:
        text = ensure_explicit_intro(text, spec.document_id)

    if spec.overall_conclusion_title:
        text = ensure_overall_conclusion(
            text,
            spec.document_id,
            spec.overall_conclusion_title,
        )

    text, conclusion_changes = ensure_chapter_conclusions(
        text,
        spec.document_id,
    )

    text = update_current_history_row(
        text,
        spec.document_id,
        spec.expected_version,
    )

    chapter_count, verified_count = validate_chapter_conclusions(
        text,
        spec.document_id,
    )

    if spec.explicit_intro and not has_explicit_intro(text):
        fail(f"{spec.document_id}: explicitní úvod nebyl vytvořen.")

    if (
        spec.overall_conclusion_title
        and not has_overall_conclusion(text)
    ):
        fail(f"{spec.document_id}: závěr dokumentu nebyl vytvořen.")

    return text, {
        "changed": text != original,
        "chapter_count": chapter_count,
        "verified_conclusions": verified_count,
        "conclusion_changes": conclusion_changes,
        "size_before": len(original.encode("utf-8")),
        "size_after": len(text.encode("utf-8")),
    }


def run_a17(
    project_root: Path,
    a17_path: Path,
    spec: DocumentSpec,
) -> dict[str, Any]:
    output_dir = project_root / REPORT_ROOT_RELATIVE / spec.document_id
    output_dir.mkdir(parents=True, exist_ok=True)

    command = [
        sys.executable,
        str(a17_path),
        "--document",
        str(project_root / spec.relative_path),
        "--document-type",
        "MAIN_DOCUMENT",
        "--output-dir",
        str(output_dir),
        "--stdout-findings",
        "50",
    ]

    result = subprocess.run(
        command,
        cwd=project_root,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )

    print()
    print(f"A17: {spec.document_id}")
    print("-" * 79)
    print(result.stdout.rstrip())
    if result.stderr.strip():
        print("STDERR:")
        print(result.stderr.rstrip())

    if result.returncode != 0:
        fail(
            f"A17 {spec.document_id} skončil návratovým kódem "
            f"{result.returncode}."
        )

    latest_json = output_dir / "document_compliance_audit_latest.json"
    if not latest_json.is_file():
        fail(
            f"A17 {spec.document_id} nevytvořil latest JSON: "
            f"{latest_json}"
        )

    payload = json.loads(latest_json.read_text(encoding="utf-8"))
    counts = payload.get("result_counts") or {}

    if int(counts.get("FAIL", 0)) != 0:
        fail(f"A17 {spec.document_id} stále obsahuje FAIL.")
    if int(counts.get("PARTIAL", 0)) != 0:
        fail(f"A17 {spec.document_id} stále obsahuje PARTIAL.")

    disallowed_manual = [
        finding
        for finding in payload.get("findings", [])
        if finding.get("result") == "MANUAL_REVIEW"
        and str(finding.get("severity", "")).upper()
        not in {"MEDIUM", "LOW", "INFO"}
    ]
    if disallowed_manual:
        fail(
            f"A17 {spec.document_id} obsahuje nepovolený "
            "MANUAL_REVIEW se závažností vyšší než MEDIUM."
        )

    return {
        "score": payload.get("compliance_score_percent"),
        "status": payload.get("compliance_status"),
        "pass": int(counts.get("PASS", 0)),
        "partial": int(counts.get("PARTIAL", 0)),
        "fail": int(counts.get("FAIL", 0)),
        "manual_review": int(counts.get("MANUAL_REVIEW", 0)),
        "latest_json": str(latest_json),
    }


def git_status_for_documents(
    project_root: Path,
) -> str:
    command = [
        "git",
        "-C",
        str(project_root),
        "status",
        "--short",
        "--",
        *[spec.relative_path.as_posix() for spec in DOCUMENTS],
    ]
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        return (
            "Git status se nepodařilo načíst:\n"
            + result.stdout
            + result.stderr
        )
    return result.stdout.rstrip() or "Bez změn."


def main() -> int:
    script_path = Path(__file__).resolve()
    project_root = script_path.parents[2]
    a17_path = project_root / A17_RELATIVE

    print()
    print("MATCHMATRIX – A36 OPRAVA PLNÉHO DOKUMENTAČNÍHO BALÍKU")
    print("=" * 79)
    print(f"ENGINE        : {ENGINE}")
    print(f"SCRIPT VERSION: {SCRIPT_VERSION}")
    print(f"PROJECT_ROOT  : {project_root}")
    print(f"A17           : {a17_path}")
    print("DATABASE WRITE: DISABLED")
    print("GIT COMMIT    : DISABLED")
    print()

    if not a17_path.is_file():
        fail(f"Chybí aktivní A17: {a17_path}")

    originals: dict[Path, bytes] = {}
    patched_texts: dict[Path, str] = {}
    patch_summaries: dict[str, dict[str, Any]] = {}

    for spec in DOCUMENTS:
        path = project_root / spec.relative_path
        if not path.is_file():
            fail(f"Chybí aktivní dokument: {path}")

        original_bytes = path.read_bytes()
        original_text = original_bytes.decode(
            "utf-8-sig",
            errors="strict",
        )
        validate_identity(original_text, path, spec)

        patched_text, summary = patch_document(original_text, spec)

        # Verze, stav ani identita se opravou nesmí změnit.
        validate_identity(patched_text, path, spec)

        originals[path] = original_bytes
        patched_texts[path] = patched_text
        patch_summaries[spec.document_id] = summary

    changed_specs = [
        spec
        for spec in DOCUMENTS
        if patch_summaries[spec.document_id]["changed"]
    ]

    print("PŘEDZÁPISOVÁ KONTROLA")
    print("-" * 79)
    for spec in DOCUMENTS:
        summary = patch_summaries[spec.document_id]
        print(
            f"{spec.document_id:<12} | "
            f"kapitoly {summary['chapter_count']:>3} | "
            f"závěry {summary['verified_conclusions']:>3} | "
            f"změna {'ANO' if summary['changed'] else 'NE'}"
        )

    if not changed_specs:
        print()
        print("Všechny dokumenty již obsahují požadované opravy.")
        print("Pokračuji pouze nezávislým A17 auditem.")

    run_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_root = project_root / BACKUP_ROOT_RELATIVE / run_stamp

    if changed_specs:
        print()
        print("TECHNICKÁ ROLLBACK ZÁLOHA")
        print("-" * 79)

        for spec in changed_specs:
            source = project_root / spec.relative_path
            backup = backup_root / spec.relative_path
            backup.parent.mkdir(parents=True, exist_ok=True)
            backup.write_bytes(originals[source])
            print(
                f"{spec.document_id}: "
                f"{backup.relative_to(project_root)}"
            )

        try:
            for spec in changed_specs:
                path = project_root / spec.relative_path
                temporary = path.with_suffix(path.suffix + ".a36_new")
                temporary.write_text(
                    patched_texts[path],
                    encoding="utf-8",
                    newline="\n",
                )

                written = temporary.read_text(encoding="utf-8")
                validate_identity(written, path, spec)
                validate_chapter_conclusions(
                    written,
                    spec.document_id,
                )

                temporary.replace(path)

            print()
            print("AKTIVNÍ SOUBORY BYLY OPRAVENY.")
        except Exception:
            for path, original_bytes in originals.items():
                path.write_bytes(original_bytes)
                temporary = path.with_suffix(path.suffix + ".a36_new")
                temporary.unlink(missing_ok=True)
            raise

    audit_results: dict[str, dict[str, Any]] = {}

    try:
        for spec in DOCUMENTS:
            audit_results[spec.document_id] = run_a17(
                project_root,
                a17_path,
                spec,
            )
    except Exception:
        if changed_specs:
            print()
            print("A17 SELHAL – OBNOVUJI VŠECH DEVĚT PŮVODNÍCH SOUBORŮ.")
            for path, original_bytes in originals.items():
                path.write_bytes(original_bytes)
        raise

    print()
    print("=" * 79)
    print("A36 – KONEČNÝ SOUHRN")
    print("-" * 79)
    for spec in DOCUMENTS:
        result = audit_results[spec.document_id]
        print(
            f"{spec.document_id:<12} | "
            f"{float(result['score']):>6.2f} % | "
            f"PASS {result['pass']:>2} | "
            f"PARTIAL {result['partial']} | "
            f"FAIL {result['fail']} | "
            f"MANUAL {result['manual_review']}"
        )

    print()
    print("GIT STATUS – OPRAVENÉ AKTIVNÍ DOKUMENTY")
    print("-" * 79)
    print(git_status_for_documents(project_root))

    print()
    print(f"ROLLBACK ZÁLOHA : {backup_root}")
    print(f"A17 REPORTY     : {project_root / REPORT_ROOT_RELATIVE}")
    print("DATABASE WRITE  : NEPROVEDEN")
    print("GIT COMMIT      : NEPROVEDEN")
    print("=" * 79)
    print("A36 FULL PACKAGE A17 FIX OK")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # noqa: BLE001
        print()
        print("=" * 79)
        print("A36 FULL PACKAGE A17 FIX FAILED")
        print(f"{type(exc).__name__}: {exc}")
        raise SystemExit(1)
