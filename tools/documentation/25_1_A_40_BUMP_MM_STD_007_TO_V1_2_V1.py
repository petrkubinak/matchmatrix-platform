#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CO:
    Zvýší verzi aktivního dokumentu MM-STD-007 z 1.1 na 1.2 a doplní
    odpovídající řádek do historie verzí.

K ČEMU:
    A6 správně zablokoval import, protože obsah dokumentu se změnil bez
    zvýšení verze. Tento nástroj provede pouze řízenou opravu verze dokumentu.

KDE:
    C:\\MatchMatrix-platform\\tools\\documentation\\
    25_1_A_40_BUMP_MM_STD_007_TO_V1_2_V1.py

JAK:
    python 25_1_A_40_BUMP_MM_STD_007_TO_V1_2_V1.py

BEZPEČNOST:
    - nevykonává databázový zápis,
    - nevytváří Git commit,
    - před změnou vytváří rollback zálohu,
    - končí chybou, pokud struktura dokumentu neodpovídá očekávání.
"""

from __future__ import annotations

import re
import shutil
import sys
from datetime import datetime
from pathlib import Path


ENGINE = "A40_BUMP_MM_STD_007_TO_V1_2_V1_0"
OLD_VERSION = "1.1"
NEW_VERSION = "1.2"
CHANGE_DATE = "2026-07-29"
CHANGE_DESCRIPTION = (
    "Doplněny závěry hlavních kapitol a sjednocena struktura dokumentu "
    "pro kontrolu A17; obsahová změna je oddělena novou verzí."
)


class PatchBlocked(RuntimeError):
    """Bezpečnostní blokace změny dokumentu."""


def detect_project_root(script_path: Path) -> Path:
    candidate = script_path.resolve().parents[2]
    if (candidate / "docs").is_dir() and (candidate / "tools").is_dir():
        return candidate

    fallback = Path(r"C:\MatchMatrix-platform")
    if (fallback / "docs").is_dir() and (fallback / "tools").is_dir():
        return fallback

    raise PatchBlocked("Nelze určit PROJECT_ROOT.")


def split_markdown_row(line: str) -> list[str]:
    stripped = line.strip()
    if not (stripped.startswith("|") and stripped.endswith("|")):
        raise PatchBlocked(f"Neplatný řádek Markdown tabulky: {line!r}")
    return [cell.strip() for cell in stripped[1:-1].split("|")]


def build_history_row(headers: list[str]) -> str:
    values: list[str] = []

    for header in headers:
        normalized = header.strip().lower()

        if normalized in {"verze", "version"}:
            values.append(NEW_VERSION)
        elif normalized in {"datum", "date"}:
            values.append(CHANGE_DATE)
        elif normalized in {"popis", "změna", "change", "description", "souhrn změny"}:
            values.append(CHANGE_DESCRIPTION)
        elif normalized in {"autor", "author"}:
            values.append("Petr / OpenAI ChatGPT")
        elif normalized in {"stav", "status"}:
            values.append("REVIEW")
        else:
            values.append("—")

    return "| " + " | ".join(values) + " |"


def main() -> int:
    root = detect_project_root(Path(__file__))

    document = (
        root
        / "docs"
        / "12_STANDARD"
        / "MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md"
    )

    if not document.is_file():
        raise PatchBlocked(f"Dokument nebyl nalezen: {document}")

    raw = document.read_bytes()
    has_bom = raw.startswith(b"\xef\xbb\xbf")
    content = raw[3:] if has_bom else raw

    try:
        text = content.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise PatchBlocked(f"Dokument není platné UTF-8: {exc}") from exc

    newline = "\r\n" if "\r\n" in text else "\n"

    metadata_pattern = re.compile(
        r"(?mi)^(\|\s*(?:Verze|Verze dokumentu)\s*\|\s*)"
        + re.escape(OLD_VERSION)
        + r"(\s*\|[^\r\n]*)$"
    )

    matches = list(metadata_pattern.finditer(text))
    if len(matches) != 1:
        raise PatchBlocked(
            f"Očekáván právě jeden metadata řádek s verzí {OLD_VERSION}; "
            f"nalezeno: {len(matches)}."
        )

    updated = metadata_pattern.sub(rf"\g<1>{NEW_VERSION}\g<2>", text, count=1)
    lines = updated.splitlines()

    history_heading_index: int | None = None
    for index, line in enumerate(lines):
        if re.match(r"^#{1,6}\s+.*Historie verzí\s*$", line.strip(), re.IGNORECASE):
            history_heading_index = index
            break

    if history_heading_index is None:
        raise PatchBlocked("Sekce Historie verzí nebyla nalezena.")

    next_heading_index = len(lines)
    for index in range(history_heading_index + 1, len(lines)):
        if re.match(r"^#{1,6}\s+", lines[index].strip()):
            next_heading_index = index
            break

    header_index: int | None = None
    headers: list[str] | None = None
    for index in range(history_heading_index + 1, next_heading_index):
        line = lines[index]
        if line.strip().startswith("|") and line.strip().endswith("|"):
            cells = split_markdown_row(line)
            if any(cell.strip().lower() in {"verze", "version"} for cell in cells):
                header_index = index
                headers = cells
                break

    if header_index is None or headers is None:
        raise PatchBlocked("Tabulka historie verzí nebyla nalezena.")

    separator_index = header_index + 1
    if separator_index >= len(lines):
        raise PatchBlocked("Chybí oddělovací řádek tabulky historie verzí.")

    separator_cells = split_markdown_row(lines[separator_index])
    if len(separator_cells) != len(headers):
        raise PatchBlocked("Počet sloupců historie verzí není konzistentní.")

    for cell in separator_cells:
        if not re.fullmatch(r":?-{3,}:?", cell.replace(" ", "")):
            raise PatchBlocked("Oddělovací řádek historie verzí není platný.")

    version_column = next(
        (
            idx
            for idx, header in enumerate(headers)
            if header.strip().lower() in {"verze", "version"}
        ),
        None,
    )
    if version_column is None:
        raise PatchBlocked("V historii verzí chybí sloupec Verze.")

    table_end = separator_index + 1
    existing_versions: set[str] = set()
    while table_end < next_heading_index:
        candidate = lines[table_end].strip()
        if not (candidate.startswith("|") and candidate.endswith("|")):
            break

        cells = split_markdown_row(lines[table_end])
        if len(cells) != len(headers):
            raise PatchBlocked(
                f"Nekonzistentní počet sloupců na řádku {table_end + 1}."
            )

        existing_versions.add(cells[version_column])
        table_end += 1

    if NEW_VERSION in existing_versions:
        raise PatchBlocked(f"Historie verzí již obsahuje verzi {NEW_VERSION}.")

    if OLD_VERSION not in existing_versions:
        raise PatchBlocked(
            f"Historie verzí neobsahuje očekávanou předchozí verzi {OLD_VERSION}."
        )

    lines.insert(table_end, build_history_row(headers))
    final_text = newline.join(lines).rstrip(" \t\r\n") + newline

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup = (
        root
        / "reports"
        / "documentation"
        / "standardization"
        / "20260729_MM_STD_007_VERSION_BUMP_BACKUP"
        / timestamp
        / document.relative_to(root)
    )
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(document, backup)

    prefix = b"\xef\xbb\xbf" if has_bom else b""
    document.write_bytes(prefix + final_text.encode("utf-8"))

    print("MATCHMATRIX – A40 OPRAVA VERZE MM-STD-007")
    print("=" * 79)
    print(f"ENGINE          : {ENGINE}")
    print(f"PROJECT_ROOT    : {root}")
    print(f"DOKUMENT        : {document}")
    print(f"PŮVODNÍ VERZE   : {OLD_VERSION}")
    print(f"NOVÁ VERZE      : {NEW_VERSION}")
    print("HISTORIE VERZÍ  : DOPLNĚNA")
    print(f"ROLLBACK ZÁLOHA : {backup}")
    print("DATABASE WRITE  : NEPROVEDEN")
    print("GIT COMMIT      : NEPROVEDEN")
    print("=" * 79)
    print("A40 MM-STD-007 VERSION BUMP OK")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except PatchBlocked as exc:
        print("A40 PATCH BLOCKED", file=sys.stderr)
        print("-" * 79, file=sys.stderr)
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
