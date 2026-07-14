#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví nový standardizovaný Markdown dokument z potvrzeného mapování A19. U hlavních a dalších řízených dokumentů zachová původní strukturu a aplikuje pouze výslovně potvrzené strukturální opravy.

K ČEMU:
- načte potvrzený revizní kontrakt A19,
- ověří zdrojový dokument a jeho SHA-256,
- ověří úplnost všech mapovacích rozhodnutí,
- použije potvrzené a přesunuté bloky,
- použije bezpečně rozdělené části bloků,
- automatické bloky ve stavu NOT_REQUIRED vloží podle návrhu A18,
- vynechá pouze bloky výslovně potvrzené jako EXCLUDE_AS_NOISE,
- sestaví kapitoly podle category_catalog,
- načte existující metadata z první Markdown tabulky zdrojového dokumentu,
- doplní standardní metadata a schvalovací checklist,
- počítá pouze skutečné placeholdery a nezapočítává kontrolní checklist,
- vytvoří nový Markdown kandidát, diff a úplný build report,
- původní dokument ani databázi nemění.

KDE:
tools/documentation/25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py

JAK:
Výchozí potvrzená revize A19:
    py -3.14 .\\tools\\documentation\\25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py

Explicitní revize:
    py -3.14 .\\tools\\documentation\\25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py `
      --review reports\\documentation\\standardization\\reviews\\document_standardization_panel_review_latest.json

Volitelná metadata:
    --document-id "MM-HIS-123"
    --title "MATCHMATRIX – DENNÍ ZÁPIS – 2026-06-30"
    --version "1.0"
    --date "2026-06-30"
    --author "Jméno"
    --working-area "Dokumentace"

Pouze validace:
    py -3.14 .\\tools\\documentation\\25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py `
      --validate-only

BEZPEČNOST:
- vstup musí mít review_status MAPPING_CONFIRMED,
- vstup musí mít final_status
  DOCUMENT_STANDARDIZATION_PANEL_REVIEW_CONFIRMED,
- zdrojový SHA-256 musí stále odpovídat,
- každý blok musí být potvrzený, automatický, rozdělený nebo výslovně vyloučený,
- rozdělené části se musí po spojení přesně rovnat původnímu textu,
- každý nevyloučený blok se vloží právě jednou,
- původní dokument se nikdy nepřepisuje,
- databáze se nemění,
- výsledný dokument zůstává kandidátem do dalšího auditu A17.

PODPOROVANÉ TYPY:
- DAILY_LOG
- CHAT_CONTINUATION
- PROJECT_SNAPSHOT
- MAIN_DOCUMENT
- REFERENCE_DOCUMENT
- GENERIC_DOCUMENT

V4 – UNIVERZÁLNÍ STRUCTURE-PRESERVING BUILD:
- denní zápisy a NAV zůstávají sestavovány podle potvrzených kategorií,
- hlavní, snapshotové, referenční a obecné dokumenty nejsou přeskládány,
- u těchto dokumentů se použijí pouze opravy potvrzené v A19,
- syntetické kontrolní bloky se nikdy nevkládají jako běžný obsah,
- nepodporovaný přesun, rozdělení nebo vyloučení původní sekce build zablokuje,
- kandidát zachová celý původní obsah a změní pouze potvrzené strukturální body.

VÝSTUP:
reports/documentation/standardization/final_candidates/
- document_standardized_candidate_YYYYMMDD_HHMMSS.md
- document_standardized_candidate_diff_YYYYMMDD_HHMMSS.diff
- document_standardized_candidate_build_YYYYMMDD_HHMMSS.json
- document_standardized_candidate_build_YYYYMMDD_HHMMSS.csv
- document_standardized_candidate_build_YYYYMMDD_HHMMSS.md
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
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


REVIEW_DEFAULT = Path(
    "reports/documentation/standardization/reviews/"
    "document_standardization_panel_review_latest.json"
)
OUTPUT_DEFAULT = Path(
    "reports/documentation/standardization/final_candidates"
)

SUPPORTED_CONTRACT_VERSIONS = {"1.0"}
TEMPLATE_DOCUMENT_TYPES = {"DAILY_LOG", "CHAT_CONTINUATION"}
STRUCTURE_PRESERVING_DOCUMENT_TYPES = {
    "PROJECT_SNAPSHOT",
    "MAIN_DOCUMENT",
    "REFERENCE_DOCUMENT",
    "GENERIC_DOCUMENT",
}
SUPPORTED_DOCUMENT_TYPES = {
    *TEMPLATE_DOCUMENT_TYPES,
    *STRUCTURE_PRESERVING_DOCUMENT_TYPES,
}
EXPECTED_REVIEW_STATUS = "MAPPING_CONFIRMED"
EXPECTED_FINAL_STATUS = "DOCUMENT_STANDARDIZATION_PANEL_REVIEW_CONFIRMED"
ENGINE_VERSION = "A20_STANDARDIZED_DOCUMENT_BUILDER_V4_UNIVERSAL_STRUCTURE_PRESERVING"
OUTPUT_CONTRACT_VERSION = "1.0"

DOCUMENT_ID_RE = re.compile(r"\bMM-[A-Z]{2,10}-\d{3,8}(?:-\d{1,4})?[A-Z]?\b")
VERSION_RE = re.compile(r"\b(?:v|verze\s*)?(\d+\.\d+)\b", re.IGNORECASE)
DATE_RE = re.compile(
    r"\b("
    r"20\d{2}[-./]\d{1,2}[-./]\d{1,2}"
    r"|"
    r"\d{1,2}[.\-/]\d{1,2}[.\-/]20\d{2}"
    r")\b"
)
MARKDOWN_HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$")

ACTION_CONFIRM = "CONFIRM"
ACTION_MOVE = "MOVE"
ACTION_SPLIT = "SPLIT"
ACTION_EXCLUDE = "EXCLUDE_AS_NOISE"

STATUS_CONFIRMED = "CONFIRMED"
STATUS_SPLIT = "SPLIT_CONFIRMED"
STATUS_EXCLUDED = "EXCLUDED"
STATUS_AUTOMATIC = "NOT_REQUIRED"

PLACEHOLDER_PREFIX = "[DOPLNIT UŽIVATELEM"


@dataclass(frozen=True)
class Category:
    code: str
    order: int
    label_cs: str


@dataclass(frozen=True)
class Piece:
    piece_id: str
    source_block_id: str
    source_order: int
    source_start_line: int
    source_end_line: int
    part_order: int
    category: str
    text: str
    decision_status: str
    decision_action: str
    approved_by: str | None
    approved_at: str | None
    note: str | None


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Sestaví standardizovaný Markdown z potvrzeného mapování A19."
        )
    )
    parser.add_argument(
        "--review",
        help="Cesta k potvrzenému JSON kontraktu A19.",
    )
    parser.add_argument(
        "--output-dir",
        help="Volitelná výstupní složka.",
    )
    parser.add_argument("--document-id")
    parser.add_argument("--title")
    parser.add_argument("--version")
    parser.add_argument("--date")
    parser.add_argument("--author")
    parser.add_argument(
        "--working-area",
        help="Pracovní oblast nebo větev projektu.",
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Pouze ověří vstup a nevytvoří kandidáta.",
    )
    parser.add_argument(
        "--no-trace-comments",
        action="store_true",
        help="Nevkládat neviditelné HTML komentáře s block_id.",
    )
    return parser.parse_args()


def resolve_path(root: Path, value: str | None, default: Path) -> Path:
    path = Path(value) if value else default
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def read_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"JSON musí být objekt: {path}")
    return payload


def read_source_text(path: Path) -> tuple[str, bytes]:
    raw = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-8", "cp1250", "latin-1"):
        try:
            return raw.decode(encoding), raw
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace"), raw


def sha256_bytes(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def normalize_date(value: str | None) -> str | None:
    if not value:
        return None
    raw = value.strip()
    for fmt in (
        "%Y-%m-%d",
        "%Y.%m.%d",
        "%Y/%m/%d",
        "%d.%m.%Y",
        "%d-%m-%Y",
        "%d/%m/%Y",
    ):
        try:
            return datetime.strptime(raw, fmt).date().isoformat()
        except ValueError:
            pass
    return raw


def first_match(pattern: re.Pattern[str], text: str) -> str | None:
    match = pattern.search(text)
    if not match:
        return None
    if match.lastindex:
        return match.group(1)
    return match.group(0)



def parse_markdown_metadata_table(text: str) -> dict[str, str]:
    """
    Načte první dvousloupcovou Markdown tabulku metadat.

    Podporuje běžné názvy polí používané v dokumentech MatchMatrix,
    například Dokument / Document ID, Název, Verze, Datum, Autor projektu
    a Hlavní oblast.
    """
    aliases = {
        "document id": "document_id",
        "dokument": "document_id",
        "id dokumentu": "document_id",
        "název": "title",
        "nazev": "title",
        "název dokumentu": "title",
        "nazev dokumentu": "title",
        "verze": "version",
        "datum": "date",
        "autor": "author",
        "autor projektu": "author",
        "pracovní oblast": "working_area",
        "pracovni oblast": "working_area",
        "hlavní oblast": "working_area",
        "hlavni oblast": "working_area",
    }

    result: dict[str, str] = {}
    in_table = False

    for raw_line in text.splitlines():
        line = raw_line.strip()

        if not line.startswith("|"):
            if in_table and result:
                break
            continue

        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) < 2:
            continue

        if all(set(cell) <= {"-", ":"} for cell in cells if cell):
            in_table = True
            continue

        key_raw = re.sub(r"[*_`]", "", cells[0]).strip().casefold()
        value = cells[1].strip().strip("`").strip()

        if key_raw in {"položka", "polozka"}:
            in_table = True
            continue

        mapped = aliases.get(key_raw)
        if mapped and value:
            result.setdefault(mapped, value)
            in_table = True

    return result


def infer_source_title(text: str, source_path: Path) -> str | None:
    for raw_line in text.splitlines():
        line = raw_line.strip().strip("\ufeff")
        if not line:
            continue
        heading = MARKDOWN_HEADING_RE.match(line)
        candidate = heading.group(1).strip() if heading else line
        candidate = candidate.strip("=-–— ")
        if 3 <= len(candidate) <= 180:
            return candidate
    stem = source_path.stem.strip()
    return stem or None


def placeholder(label: str) -> str:
    return f"[DOPLNIT UŽIVATELEM – {label}]"


def validate_split_parts(
    block_id: str,
    original_text: str,
    parts: Sequence[Mapping[str, Any]],
    category_codes: set[str],
) -> None:
    if len(parts) < 2:
        raise RuntimeError(
            f"Rozdělený blok {block_id} musí obsahovat alespoň dvě části."
        )

    reconstructed = "".join(str(part.get("text") or "") for part in parts)
    if reconstructed != original_text:
        raise RuntimeError(
            f"Rozdělený blok {block_id}: spojené části neodpovídají "
            "původnímu textu."
        )

    for index, part in enumerate(parts, start=1):
        part_text = str(part.get("text") or "")
        category = str(part.get("selected_category") or "")
        if not part_text:
            raise RuntimeError(
                f"Rozdělený blok {block_id}, část {index}: prázdný text."
            )
        if category not in category_codes:
            raise RuntimeError(
                f"Rozdělený blok {block_id}, část {index}: "
                f"neplatná kategorie {category!r}."
            )


def parse_categories(payload: Mapping[str, Any]) -> list[Category]:
    raw_catalog = payload.get("category_catalog")
    if not isinstance(raw_catalog, list) or not raw_catalog:
        raise RuntimeError("Revize A19 neobsahuje category_catalog.")

    result: list[Category] = []
    seen: set[str] = set()

    for raw in raw_catalog:
        if not isinstance(raw, dict):
            raise RuntimeError("Neplatná položka category_catalog.")
        code = str(raw.get("code") or "").strip()
        label = str(raw.get("label_cs") or code).strip()
        order = int(raw.get("order") or 999)
        if not code or code in seen:
            raise RuntimeError(
                f"Neplatná nebo duplicitní kategorie: {code!r}"
            )
        seen.add(code)
        result.append(Category(code=code, order=order, label_cs=label))

    result.sort(key=lambda item: (item.order, item.code))
    return result


def validate_review(
    payload: Mapping[str, Any],
) -> tuple[Path, str, list[Category], str]:
    contract_version = str(payload.get("contract_version") or "")
    if contract_version not in SUPPORTED_CONTRACT_VERSIONS:
        raise RuntimeError(
            f"Nepodporovaná verze kontraktu {contract_version!r}."
        )

    review_status = str(payload.get("review_status") or "")
    final_status = str(payload.get("final_status") or "")
    if review_status != EXPECTED_REVIEW_STATUS:
        raise RuntimeError(
            f"Revize A19 ještě není uzavřená. "
            f"review_status={review_status!r}; očekáváno "
            f"{EXPECTED_REVIEW_STATUS!r}."
        )
    if final_status != EXPECTED_FINAL_STATUS:
        raise RuntimeError(
            f"Revize A19 nemá očekávaný final_status "
            f"{EXPECTED_FINAL_STATUS!r}."
        )

    document_type = str(payload.get("document_type") or "")
    if document_type not in SUPPORTED_DOCUMENT_TYPES:
        raise RuntimeError(
            f"Nepodporovaný typ dokumentu: {document_type!r}."
        )

    source_value = str(payload.get("source_document_path") or "").strip()
    expected_hash = str(payload.get("source_hash_sha256") or "").strip()
    if not source_value:
        raise RuntimeError("Revize A19 neobsahuje source_document_path.")
    if not re.fullmatch(r"[0-9a-f]{64}", expected_hash):
        raise RuntimeError("Revize A19 neobsahuje platný SHA-256.")

    source_path = Path(source_value)
    if not source_path.is_file():
        raise FileNotFoundError(
            f"Zdrojový dokument nebyl nalezen: {source_path}"
        )

    _, raw = read_source_text(source_path)
    current_hash = sha256_bytes(raw)
    if current_hash != expected_hash:
        raise RuntimeError(
            "Zdrojový dokument se od uzavření A19 změnil. "
            "Spusť znovu A17, A18 a A19."
        )

    categories = parse_categories(payload)
    return source_path, document_type, categories, current_hash


def build_pieces(
    payload: Mapping[str, Any],
    categories: Sequence[Category],
) -> tuple[list[Piece], list[dict[str, Any]], dict[str, Any]]:
    blocks = payload.get("blocks")
    if not isinstance(blocks, list) or not blocks:
        raise RuntimeError("Revize A19 neobsahuje bloky.")

    category_codes = {item.code for item in categories}
    pieces: list[Piece] = []
    excluded: list[dict[str, Any]] = []
    seen_block_ids: set[str] = set()

    counts = Counter()
    source_characters = 0
    included_characters = 0
    excluded_characters = 0

    for source_order, item in enumerate(blocks, start=1):
        if not isinstance(item, dict):
            raise RuntimeError("Neplatný blok v revizi A19.")

        block_id = str(item.get("block_id") or "").strip()
        if not block_id or block_id in seen_block_ids:
            raise RuntimeError(
                f"Neplatný nebo duplicitní block_id: {block_id!r}"
            )
        seen_block_ids.add(block_id)

        source = item.get("source")
        proposal = item.get("proposal")
        decision = item.get("user_decision")
        if not all(
            isinstance(value, dict)
            for value in (source, proposal, decision)
        ):
            raise RuntimeError(
                f"Blok {block_id} nemá source/proposal/user_decision."
            )

        text = str(source.get("text") or "")
        if not text:
            raise RuntimeError(f"Blok {block_id} nemá text.")

        source_characters += len(text)
        status = str(decision.get("status") or "PENDING")
        action = str(decision.get("action") or "")
        approved_by = (
            str(decision.get("approved_by"))
            if decision.get("approved_by")
            else None
        )
        approved_at = (
            str(decision.get("approved_at"))
            if decision.get("approved_at")
            else None
        )
        note = (
            str(decision.get("note"))
            if decision.get("note")
            else None
        )

        start_line = int(source.get("start_line") or 0)
        end_line = int(source.get("end_line") or start_line)

        if status == STATUS_AUTOMATIC:
            category = str(proposal.get("category") or "")
            if category not in category_codes:
                raise RuntimeError(
                    f"Automatický blok {block_id} má neplatnou kategorii."
                )
            pieces.append(
                Piece(
                    piece_id=block_id,
                    source_block_id=block_id,
                    source_order=source_order,
                    source_start_line=start_line,
                    source_end_line=end_line,
                    part_order=1,
                    category=category,
                    text=text,
                    decision_status=status,
                    decision_action="AUTO_ACCEPT",
                    approved_by=None,
                    approved_at=None,
                    note=None,
                )
            )
            included_characters += len(text)
            counts["automatic"] += 1
            continue

        if status == STATUS_CONFIRMED:
            category = str(
                decision.get("selected_category")
                or proposal.get("category")
                or ""
            )
            if category not in category_codes:
                raise RuntimeError(
                    f"Potvrzený blok {block_id} má neplatnou kategorii "
                    f"{category!r}."
                )
            if action not in {ACTION_CONFIRM, ACTION_MOVE}:
                raise RuntimeError(
                    f"Potvrzený blok {block_id} má neplatnou akci "
                    f"{action!r}."
                )
            pieces.append(
                Piece(
                    piece_id=block_id,
                    source_block_id=block_id,
                    source_order=source_order,
                    source_start_line=start_line,
                    source_end_line=end_line,
                    part_order=1,
                    category=category,
                    text=text,
                    decision_status=status,
                    decision_action=action,
                    approved_by=approved_by,
                    approved_at=approved_at,
                    note=note,
                )
            )
            included_characters += len(text)
            counts["confirmed"] += 1
            if action == ACTION_MOVE:
                counts["moved"] += 1
            continue

        if status == STATUS_SPLIT:
            if action != ACTION_SPLIT:
                raise RuntimeError(
                    f"Rozdělený blok {block_id} nemá akci SPLIT."
                )
            parts = decision.get("split_parts")
            if not isinstance(parts, list):
                raise RuntimeError(
                    f"Rozdělený blok {block_id} nemá split_parts."
                )
            validate_split_parts(
                block_id,
                text,
                parts,
                category_codes,
            )
            for part_order, part in enumerate(parts, start=1):
                part_text = str(part["text"])
                category = str(part["selected_category"])
                part_id = str(
                    part.get("part_id")
                    or f"{block_id}-PART-{part_order:02d}"
                )
                pieces.append(
                    Piece(
                        piece_id=f"{block_id}:{part_id}",
                        source_block_id=block_id,
                        source_order=source_order,
                        source_start_line=start_line,
                        source_end_line=end_line,
                        part_order=part_order,
                        category=category,
                        text=part_text,
                        decision_status=status,
                        decision_action=action,
                        approved_by=approved_by,
                        approved_at=approved_at,
                        note=note,
                    )
                )
                included_characters += len(part_text)
            counts["split_blocks"] += 1
            counts["split_parts"] += len(parts)
            continue

        if status == STATUS_EXCLUDED:
            if action != ACTION_EXCLUDE:
                raise RuntimeError(
                    f"Vyloučený blok {block_id} nemá akci "
                    f"{ACTION_EXCLUDE}."
                )
            excluded.append(
                {
                    "block_id": block_id,
                    "start_line": start_line,
                    "end_line": end_line,
                    "text": text,
                    "note": note,
                    "approved_by": approved_by,
                    "approved_at": approved_at,
                }
            )
            excluded_characters += len(text)
            counts["excluded"] += 1
            continue

        raise RuntimeError(
            f"Blok {block_id} není uzavřený. status={status!r}, "
            f"action={action!r}."
        )

    if included_characters + excluded_characters != source_characters:
        raise RuntimeError(
            "Integritní chyba: součet vloženého a vyloučeného obsahu "
            "neodpovídá zdrojovým blokům."
        )

    piece_ids = [piece.piece_id for piece in pieces]
    if len(piece_ids) != len(set(piece_ids)):
        raise RuntimeError("Duplicitní piece_id ve výsledném sestavení.")

    summary = {
        "source_blocks": len(blocks),
        "output_pieces": len(pieces),
        "source_characters": source_characters,
        "included_characters": included_characters,
        "excluded_characters": excluded_characters,
        "included_percent": round(
            included_characters * 100.0 / source_characters,
            2,
        )
        if source_characters
        else 100.0,
        "automatic_blocks": counts["automatic"],
        "confirmed_blocks": counts["confirmed"],
        "moved_blocks": counts["moved"],
        "split_blocks": counts["split_blocks"],
        "split_parts": counts["split_parts"],
        "excluded_blocks": counts["excluded"],
        "content_integrity_verified": True,
    }
    return pieces, excluded, summary



def _block_method(item: Mapping[str, Any]) -> str:
    proposal = item.get("proposal")
    if not isinstance(proposal, dict):
        return ""
    return str(proposal.get("method") or "").strip()


def _block_decision(item: Mapping[str, Any]) -> tuple[str, str]:
    decision = item.get("user_decision")
    if not isinstance(decision, dict):
        raise RuntimeError(
            f"Blok {item.get('block_id')!r} nemá user_decision."
        )
    return (
        str(decision.get("status") or "PENDING").strip(),
        str(decision.get("action") or "").strip(),
    )


def _fix_identity(fix: Mapping[str, Any]) -> tuple[int, str, str]:
    return (
        int(fix.get("line_number") or 0),
        str(fix.get("before") or ""),
        str(fix.get("action") or ""),
    )


def _match_structural_fix(
    item: Mapping[str, Any],
    fixes: Sequence[Mapping[str, Any]],
    used_indexes: set[int],
) -> tuple[int, Mapping[str, Any]]:
    source = item.get("source")
    if not isinstance(source, dict):
        raise RuntimeError(
            f"Strukturální blok {item.get('block_id')!r} nemá source."
        )

    start_line = int(source.get("start_line") or 0)
    source_text = str(source.get("text") or "")
    candidates: list[tuple[int, Mapping[str, Any]]] = []

    for index, fix in enumerate(fixes):
        if index in used_indexes:
            continue
        line_number = int(fix.get("line_number") or 0)
        before = str(fix.get("before") or "")
        if line_number == start_line and before == source_text:
            candidates.append((index, fix))

    if not candidates:
        for index, fix in enumerate(fixes):
            if index in used_indexes:
                continue
            before = str(fix.get("before") or "")
            if before and before == source_text:
                candidates.append((index, fix))

    if len(candidates) != 1:
        raise RuntimeError(
            f"Strukturální blok {item.get('block_id')!r} nelze "
            "jednoznačně spojit s applied_fixes A18."
        )

    return candidates[0]


def validate_structure_preserving_review(
    payload: Mapping[str, Any],
) -> dict[str, Any]:
    blocks = payload.get("blocks")
    if not isinstance(blocks, list) or not blocks:
        raise RuntimeError("Revize A19 neobsahuje bloky.")

    raw_fixes = payload.get("applied_fixes") or []
    if not isinstance(raw_fixes, list):
        raise RuntimeError("Revize A19 má neplatné applied_fixes.")

    fixes: list[Mapping[str, Any]] = []
    for fix in raw_fixes:
        if not isinstance(fix, dict):
            raise RuntimeError("Neplatná položka applied_fixes.")
        fixes.append(fix)

    raw_unresolved = payload.get("unresolved_findings") or []
    if not isinstance(raw_unresolved, list):
        raise RuntimeError("Revize A19 má neplatné unresolved_findings.")

    seen_blocks: set[str] = set()
    used_fix_indexes: set[int] = set()
    accepted_fixes: list[dict[str, Any]] = []
    skipped_fixes: list[dict[str, Any]] = []
    unresolved_excluded = 0
    regular_blocks = 0
    synthetic_blocks = 0

    for item in blocks:
        if not isinstance(item, dict):
            raise RuntimeError("Neplatný blok v revizi A19.")

        block_id = str(item.get("block_id") or "").strip()
        if not block_id or block_id in seen_blocks:
            raise RuntimeError(
                f"Neplatný nebo duplicitní block_id: {block_id!r}"
            )
        seen_blocks.add(block_id)

        method = _block_method(item)
        status, action = _block_decision(item)

        if method == "synthetic_structural_fix_review":
            synthetic_blocks += 1
            fix_index, fix = _match_structural_fix(
                item,
                fixes,
                used_fix_indexes,
            )
            used_fix_indexes.add(fix_index)

            if (
                status == STATUS_CONFIRMED
                and action in {ACTION_CONFIRM, ACTION_MOVE}
            ):
                accepted = dict(fix)
                accepted["review_block_id"] = block_id
                accepted["review_status"] = status
                accepted["review_action"] = action
                accepted_fixes.append(accepted)
                continue

            if status == STATUS_EXCLUDED and action == ACTION_EXCLUDE:
                skipped = dict(fix)
                skipped["review_block_id"] = block_id
                skipped["review_status"] = status
                skipped["review_action"] = action
                skipped_fixes.append(skipped)
                continue

            raise RuntimeError(
                f"Strukturální blok {block_id} není uzavřen platným "
                f"rozhodnutím. status={status!r}, action={action!r}."
            )

        if method == "synthetic_unresolved_finding_review":
            synthetic_blocks += 1
            if status == STATUS_EXCLUDED and action == ACTION_EXCLUDE:
                unresolved_excluded += 1
                continue
            raise RuntimeError(
                f"Blok {block_id} představuje obsahově nevyřešený nález. "
                "A20 nesmí chybějící odborný obsah vymyslet. "
                "Nález musí být v A19 výslovně vyloučen jako nerelevantní, "
                "nebo musí být dokument ručně doplněn a znovu auditován."
            )

        regular_blocks += 1

        # V režimu zachování struktury se původní sekce nevkládají znovu.
        # Jsou pouze důkazem 100% pokrytí zdroje.
        if status == STATUS_AUTOMATIC:
            continue
        if status == STATUS_CONFIRMED and action == ACTION_CONFIRM:
            continue

        raise RuntimeError(
            f"Blok {block_id} mění původní strukturu akcí "
            f"{status!r}/{action!r}. Pro typ dokumentu "
            f"{payload.get('document_type')!r} A20 povoluje u původních "
            "sekcí pouze NOT_REQUIRED nebo potvrzení bez přesunu."
        )

    # Opravy bez ručního potvrzení jsou povoleny pouze jako no-op.
    for index, fix in enumerate(fixes):
        if index in used_fix_indexes:
            continue
        if not bool(fix.get("requires_review", True)):
            accepted = dict(fix)
            accepted["review_block_id"] = None
            accepted["review_status"] = "NOT_REQUIRED"
            accepted["review_action"] = "AUTO_ACCEPT_NO_REVIEW"
            accepted_fixes.append(accepted)
            continue
        raise RuntimeError(
            "A18 obsahuje strukturální opravu vyžadující revizi, "
            "ale v A19 pro ni neexistuje odpovídající kontrolní blok: "
            f"{_fix_identity(fix)!r}."
        )

    unresolved_count = len(raw_unresolved)
    if unresolved_count != unresolved_excluded:
        raise RuntimeError(
            "Revize obsahuje nevyřešené nálezy, které nebyly všechny "
            "výslovně vyloučeny jako nerelevantní."
        )

    return {
        "proposal_mode": str(
            payload.get("proposal_mode")
            or "STRUCTURE_PRESERVING_PATCH"
        ),
        "regular_source_blocks": regular_blocks,
        "synthetic_review_blocks": synthetic_blocks,
        "accepted_fixes": accepted_fixes,
        "accepted_fixes_count": len(accepted_fixes),
        "skipped_fixes": skipped_fixes,
        "skipped_fixes_count": len(skipped_fixes),
        "unresolved_findings_count": unresolved_count,
        "unresolved_findings_excluded": unresolved_excluded,
        "structure_preserving_review_verified": True,
    }


def _replace_exact_line(
    text: str,
    *,
    line_number: int,
    before: str,
    after: str,
) -> str:
    had_trailing_newline = text.endswith("\n")
    lines = text.splitlines()

    if line_number > 0 and line_number <= len(lines):
        index = line_number - 1
        if lines[index] == before:
            replacement_lines = after.splitlines()
            lines[index:index + 1] = replacement_lines
            result = "\n".join(lines)
            return result + ("\n" if had_trailing_newline else "")

    occurrence_indexes = [
        index
        for index, line in enumerate(lines)
        if line == before
    ]
    if len(occurrence_indexes) != 1:
        raise RuntimeError(
            "Potvrzenou strukturální opravu nelze bezpečně aplikovat: "
            f"očekáván právě jeden řádek {before!r}, nalezeno "
            f"{len(occurrence_indexes)}."
        )

    index = occurrence_indexes[0]
    lines[index:index + 1] = after.splitlines()
    result = "\n".join(lines)
    return result + ("\n" if had_trailing_newline else "")


def _append_structural_section(text: str, addition: str) -> str:
    clean_addition = addition.strip()
    if not clean_addition:
        raise RuntimeError("Strukturální oprava obsahuje prázdný doplněk.")

    if clean_addition in text:
        return text

    stripped = text.rstrip()
    end_marker = re.search(
        r"(?m)^\*Konec dokumentu[^\n]*\*\s*$",
        stripped,
    )
    if end_marker:
        result = (
            stripped[:end_marker.start()].rstrip()
            + "\n\n"
            + clean_addition
            + "\n\n"
            + stripped[end_marker.start():].lstrip()
        )
    else:
        result = stripped + "\n\n" + clean_addition

    return result.rstrip() + "\n"


def apply_confirmed_structural_fixes(
    source_text: str,
    accepted_fixes: Sequence[Mapping[str, Any]],
) -> tuple[str, list[dict[str, Any]]]:
    candidate = source_text
    applied_records: list[dict[str, Any]] = []

    replacements = [
        dict(fix)
        for fix in accepted_fixes
        if fix.get("before") is not None
    ]
    additions = [
        dict(fix)
        for fix in accepted_fixes
        if fix.get("before") is None
    ]

    # Nahrazování probíhá od nejnižší části dokumentu, aby případná
    # víceřádková změna neposunula řádky dřívějších oprav.
    replacements.sort(
        key=lambda fix: int(fix.get("line_number") or 0),
        reverse=True,
    )

    for fix in replacements:
        before = str(fix.get("before") or "")
        after = str(fix.get("after") or "")
        action = str(fix.get("action") or "")

        if action == "ALREADY_PRESENT" or before == after:
            record = dict(fix)
            record["build_result"] = "NO_CHANGE_REQUIRED"
            applied_records.append(record)
            continue

        if not before or not after:
            raise RuntimeError(
                f"Neplatná potvrzená strukturální oprava: {fix!r}"
            )

        candidate = _replace_exact_line(
            candidate,
            line_number=int(fix.get("line_number") or 0),
            before=before,
            after=after,
        )
        record = dict(fix)
        record["build_result"] = "APPLIED"
        applied_records.append(record)

    for fix in additions:
        after = str(fix.get("after") or "")
        candidate = _append_structural_section(candidate, after)
        record = dict(fix)
        record["build_result"] = "APPLIED"
        applied_records.append(record)

    if not candidate.endswith("\n"):
        candidate += "\n"

    return candidate, applied_records


def count_real_placeholders(text: str) -> int:
    patterns = (
        r"\[DOPLNIT UŽIVATELEM[^\]]*\]",
        r">\s*\*\*DOPLNIT UŽIVATELEM:\*\*",
    )
    return sum(
        len(re.findall(pattern, text))
        for pattern in patterns
    )


def build_structure_preserving_report_markdown(
    payload: Mapping[str, Any],
) -> str:
    integrity = payload["content_integrity"]
    build = payload["document_build"]
    lines = [
        "# MATCHMATRIX – BUILD DOKUMENTU SE ZACHOVÁNÍM STRUKTURY",
        "",
        f"- Výsledek: **{payload['final_status']}**",
        f"- Zdrojový dokument: `{payload['source_document_path']}`",
        f"- Revize A19: `{payload['review_path']}`",
        f"- Kandidát: `{payload['candidate_path']}`",
        f"- Typ dokumentu: **{payload['document_type']}**",
        f"- Režim: **{payload['proposal_mode']}**",
        f"- Mapování schválil: **{payload.get('reviewer') or 'NEUVEDEN'}**",
        "",
        "## Integrita",
        "",
        f"- Zdrojových znaků: **{integrity['source_characters']}**",
        f"- Strukturálně zachováno: **{integrity['structure_preserved']}**",
        f"- Potvrzených oprav: **{integrity['accepted_fixes_count']}**",
        f"- Přeskočených oprav: **{integrity['skipped_fixes_count']}**",
        f"- Nevyřešených nálezů: **{integrity['unresolved_findings_count']}**",
        f"- Integrita ověřena: **{integrity['content_integrity_verified']}**",
        "",
        "## Stav kandidáta",
        "",
        f"- Placeholderů: **{build['placeholder_count']}**",
        f"- Připraven pro A17: **{build['ready_for_compliance_audit']}**",
        f"- Připraven ke kanonickému schválení: "
        f"**{build['ready_for_canonical_approval']}**",
        "",
        "## Aplikované opravy",
        "",
    ]

    applied = payload.get("applied_fixes") or []
    if applied:
        for fix in applied:
            lines.append(
                f"- `{fix.get('rule_id')}` / `{fix.get('action')}`: "
                f"{fix.get('before')!r} → {fix.get('after')!r}"
            )
    else:
        lines.append("- Žádná změna nebyla nutná.")

    lines.extend(
        [
            "",
            "## Další krok",
            "",
            "1. Otevřít kandidáta.",
            "2. Spustit nad kandidátem finální A17.",
            "3. Po úspěšném auditu pokračovat ke kanonickému schválení.",
            "",
            f"**FINAL STATUS:** `{payload['final_status']}`",
            "",
        ]
    )
    return "\n".join(lines)


def write_structure_preserving_csv(
    path: Path,
    applied_fixes: Sequence[Mapping[str, Any]],
    skipped_fixes: Sequence[Mapping[str, Any]],
) -> None:
    fields = [
        "record_type",
        "rule_id",
        "action",
        "line_number",
        "before",
        "after",
        "requires_review",
        "review_block_id",
        "review_status",
        "review_action",
        "build_result",
        "reason",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record_type, records in (
            ("APPLIED_FIX", applied_fixes),
            ("SKIPPED_FIX", skipped_fixes),
        ):
            for fix in records:
                writer.writerow(
                    {
                        "record_type": record_type,
                        "rule_id": fix.get("rule_id") or "",
                        "action": fix.get("action") or "",
                        "line_number": fix.get("line_number") or "",
                        "before": fix.get("before") or "",
                        "after": fix.get("after") or "",
                        "requires_review": fix.get("requires_review"),
                        "review_block_id": fix.get("review_block_id") or "",
                        "review_status": fix.get("review_status") or "",
                        "review_action": fix.get("review_action") or "",
                        "build_result": fix.get("build_result") or "",
                        "reason": fix.get("reason") or "",
                    }
                )


def write_structure_preserving_outputs(
    *,
    output_dir: Path,
    candidate_text: str,
    source_text: str,
    source_path: Path,
    report_payload: dict[str, Any],
    applied_fixes: Sequence[Mapping[str, Any]],
    skipped_fixes: Sequence[Mapping[str, Any]],
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths = {
        "candidate": output_dir
        / f"document_standardized_candidate_{stamp}.md",
        "diff": output_dir
        / f"document_standardized_candidate_diff_{stamp}.diff",
        "json": output_dir
        / f"document_standardized_candidate_build_{stamp}.json",
        "csv": output_dir
        / f"document_standardized_candidate_build_{stamp}.csv",
        "markdown": output_dir
        / f"document_standardized_candidate_build_{stamp}.md",
    }

    paths["candidate"].write_text(candidate_text, encoding="utf-8")
    paths["diff"].write_text(
        build_diff(
            source_text,
            candidate_text,
            source_path,
            paths["candidate"],
        ),
        encoding="utf-8",
    )

    report_payload.update(
        {
            "candidate_path": str(paths["candidate"]),
            "diff_path": str(paths["diff"]),
            "build_json_path": str(paths["json"]),
            "build_csv_path": str(paths["csv"]),
            "build_markdown_path": str(paths["markdown"]),
            "candidate_hash_sha256": hashlib.sha256(
                candidate_text.encode("utf-8")
            ).hexdigest(),
        }
    )

    paths["json"].write_text(
        json.dumps(report_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_structure_preserving_csv(
        paths["csv"],
        applied_fixes,
        skipped_fixes,
    )
    paths["markdown"].write_text(
        build_structure_preserving_report_markdown(report_payload),
        encoding="utf-8",
    )

    latest = {
        "candidate": output_dir
        / "document_standardized_candidate_latest.md",
        "diff": output_dir
        / "document_standardized_candidate_diff_latest.diff",
        "json": output_dir
        / "document_standardized_candidate_build_latest.json",
        "csv": output_dir
        / "document_standardized_candidate_build_latest.csv",
        "markdown": output_dir
        / "document_standardized_candidate_build_latest.md",
    }
    for key in paths:
        shutil.copyfile(paths[key], latest[key])

    return paths

def infer_metadata(
    *,
    args: argparse.Namespace,
    source_text: str,
    source_path: Path,
    document_type: str,
) -> dict[str, str]:
    table_metadata = parse_markdown_metadata_table(source_text)

    source_id = (
        table_metadata.get("document_id")
        or first_match(DOCUMENT_ID_RE, source_text)
    )
    source_version = (
        table_metadata.get("version")
        or first_match(VERSION_RE, source_text)
    )
    source_date = normalize_date(
        table_metadata.get("date")
        or first_match(DATE_RE, source_text)
    )
    source_title = (
        table_metadata.get("title")
        or infer_source_title(source_text, source_path)
    )

    date_value = (
        normalize_date(args.date)
        or source_date
        or placeholder("DATUM")
    )
    document_id = (
        args.document_id
        or source_id
        or placeholder("DOCUMENT ID")
    )
    version = (
        args.version
        or source_version
        or placeholder("VERZE")
    )
    author = (
        args.author
        or table_metadata.get("author")
        or placeholder("AUTOR")
    )
    working_area = (
        args.working_area
        or table_metadata.get("working_area")
        or placeholder("PRACOVNÍ OBLAST")
    )

    if args.title:
        title = args.title
    elif source_title:
        title = source_title
    elif document_type == "DAILY_LOG":
        title = f"MATCHMATRIX – DENNÍ ZÁPIS – {date_value}"
    elif document_type == "CHAT_CONTINUATION":
        title = f"MATCHMATRIX – NAVÁZÁNÍ – {date_value}"
    else:
        title = source_path.stem

    return {
        "document_id": document_id,
        "title": title,
        "version": version,
        "date": date_value,
        "author": author,
        "working_area": working_area,
        "source_title": source_title or "",
    }


def metadata_table(
    metadata: Mapping[str, str],
    *,
    document_type: str,
    source_path: Path,
    source_hash: str,
    review_path: Path,
    reviewer: str,
    built_at: str,
    document_status: str,
) -> str:
    return "\n".join(
        [
            "| Položka | Hodnota |",
            "|---|---|",
            f"| Document ID | {metadata['document_id']} |",
            f"| Název dokumentu | {metadata['title']} |",
            f"| Typ dokumentu | {document_type} |",
            f"| Verze | {metadata['version']} |",
            f"| Stav | {document_status} |",
            f"| Datum | {metadata['date']} |",
            f"| Autor | {metadata['author']} |",
            f"| Pracovní oblast | {metadata['working_area']} |",
            f"| Původní soubor | `{source_path}` |",
            f"| SHA-256 původního souboru | `{source_hash}` |",
            f"| Potvrzená revize A19 | `{review_path}` |",
            f"| Mapování schválil | {reviewer or 'NEUVEDEN'} |",
            f"| Kandidát sestaven | {built_at} |",
            f"| Build engine | {ENGINE_VERSION} |",
        ]
    )


def trace_comment(piece: Piece) -> str:
    return (
        "<!-- "
        f"MM-SOURCE piece_id={piece.piece_id}; "
        f"block_id={piece.source_block_id}; "
        f"lines={piece.source_start_line}-{piece.source_end_line}; "
        f"decision={piece.decision_status}/{piece.decision_action}"
        " -->"
    )


def build_markdown(
    *,
    metadata: Mapping[str, str],
    document_type: str,
    categories: Sequence[Category],
    pieces: Sequence[Piece],
    source_path: Path,
    source_hash: str,
    review_path: Path,
    reviewer: str,
    built_at: str,
    include_trace_comments: bool,
) -> tuple[str, dict[str, Any]]:
    by_category: dict[str, list[Piece]] = defaultdict(list)
    for piece in pieces:
        by_category[piece.category].append(piece)

    for category_pieces in by_category.values():
        category_pieces.sort(
            key=lambda item: (
                item.source_order,
                item.part_order,
                item.piece_id,
            )
        )

    metadata_placeholder_count = sum(
        1
        for key in (
            "document_id",
            "version",
            "date",
            "author",
            "working_area",
        )
        if metadata[key].startswith(PLACEHOLDER_PREFIX)
    )

    content_placeholder_count = sum(
        piece.text.count("DOPLNIT UŽIVATELEM")
        for piece in pieces
    )
    placeholder_count = (
        metadata_placeholder_count + content_placeholder_count
    )

    document_status = (
        "DRAFT – READY_FOR_COMPLIANCE_AUDIT"
        if placeholder_count == 0
        else "DRAFT – NEEDS_USER_COMPLETION"
    )

    lines: list[str] = [
        f"# {metadata['title']}",
        "",
        "## Informace o dokumentu",
        "",
        metadata_table(
            metadata,
            document_type=document_type,
            source_path=source_path,
            source_hash=source_hash,
            review_path=review_path,
            reviewer=reviewer,
            built_at=built_at,
            document_status=document_status,
        ),
        "",
        "> **Bezpečnostní stav:** Toto je nově sestavený kandidát. "
        "Původní dokument nebyl změněn.",
        "> Mapování obsahu bylo potvrzeno v A19. "
        "Před kanonickým uložením musí následovat audit A17.",
        "",
    ]

    rendered_categories = 0
    empty_categories: list[str] = []
    category_piece_counts: dict[str, int] = {}

    for category in categories:
        category_pieces = by_category.get(category.code, [])
        category_piece_counts[category.code] = len(category_pieces)
        lines.append(f"## {category.order}. {category.label_cs}")
        lines.append("")

        if not category_pieces:
            empty_categories.append(category.code)
            lines.append(
                f"> **DOPLNIT UŽIVATELEM:** "
                f"Kapitola „{category.label_cs}“ nemá po mapování obsah."
            )
            lines.append("")
            continue

        rendered_categories += 1
        for piece in category_pieces:
            if include_trace_comments:
                lines.append(trace_comment(piece))
            lines.append(piece.text)
            lines.append("")

    lines.extend(
        [
            "## Schválení standardizovaného kandidáta",
            "",
            "- [ ] Byla zkontrolována správnost všech kapitol.",
            "- [ ] Byla doplněna všechna pole `DOPLNIT UŽIVATELEM`.",
            "- [ ] Byla ověřena terminologie podle MM-REF-001.",
            "- [ ] Byl spuštěn audit A17 nad tímto kandidátem.",
            "- [ ] Audit A17 dosáhl požadovaného stavu.",
            "- [ ] Uživatel schválil vytvoření nové kanonické verze.",
            "",
        ]
    )

    markdown = "\n".join(lines).rstrip() + "\n"

    # Počítají se pouze skutečné nedoplněné hodnoty a prázdné kapitoly.
    # Text kontrolního checklistu nesmí být považován za placeholder.
    total_placeholder_count = (
        metadata_placeholder_count
        + content_placeholder_count
        + len(empty_categories)
    )

    build_summary = {
        "document_status": document_status,
        "metadata_placeholder_count": metadata_placeholder_count,
        "content_placeholder_count_before_empty_sections": (
            content_placeholder_count
        ),
        "placeholder_count": total_placeholder_count,
        "rendered_categories": rendered_categories,
        "empty_categories": empty_categories,
        "empty_categories_count": len(empty_categories),
        "category_piece_counts": category_piece_counts,
        "ready_for_compliance_audit": True,
        "ready_for_canonical_approval": total_placeholder_count == 0,
    }
    return markdown, build_summary


def build_diff(source_text: str, candidate_text: str, source: Path, target: Path) -> str:
    diff = "\n".join(
        difflib.unified_diff(
            source_text.splitlines(),
            candidate_text.splitlines(),
            fromfile=str(source),
            tofile=str(target),
            lineterm="",
        )
    )
    return diff + "\n" if diff else ""


def write_csv(
    path: Path,
    pieces: Sequence[Piece],
    excluded: Sequence[Mapping[str, Any]],
) -> None:
    fields = [
        "record_type",
        "piece_id",
        "source_block_id",
        "source_order",
        "source_start_line",
        "source_end_line",
        "part_order",
        "category",
        "decision_status",
        "decision_action",
        "approved_by",
        "approved_at",
        "note",
        "text_preview",
    ]

    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()

        for piece in pieces:
            writer.writerow(
                {
                    "record_type": "INCLUDED",
                    "piece_id": piece.piece_id,
                    "source_block_id": piece.source_block_id,
                    "source_order": piece.source_order,
                    "source_start_line": piece.source_start_line,
                    "source_end_line": piece.source_end_line,
                    "part_order": piece.part_order,
                    "category": piece.category,
                    "decision_status": piece.decision_status,
                    "decision_action": piece.decision_action,
                    "approved_by": piece.approved_by or "",
                    "approved_at": piece.approved_at or "",
                    "note": piece.note or "",
                    "text_preview": piece.text.replace("\n", " ")[:500],
                }
            )

        for item in excluded:
            writer.writerow(
                {
                    "record_type": "EXCLUDED",
                    "piece_id": item["block_id"],
                    "source_block_id": item["block_id"],
                    "source_order": "",
                    "source_start_line": item["start_line"],
                    "source_end_line": item["end_line"],
                    "part_order": "",
                    "category": "",
                    "decision_status": STATUS_EXCLUDED,
                    "decision_action": ACTION_EXCLUDE,
                    "approved_by": item.get("approved_by") or "",
                    "approved_at": item.get("approved_at") or "",
                    "note": item.get("note") or "",
                    "text_preview": str(item["text"]).replace("\n", " ")[:500],
                }
            )


def build_report_markdown(payload: Mapping[str, Any]) -> str:
    integrity = payload["content_integrity"]
    build = payload["document_build"]
    lines = [
        "# MATCHMATRIX – BUILD STANDARDIZOVANÉHO DOKUMENTU",
        "",
        f"- Výsledek: **{payload['final_status']}**",
        f"- Zdrojový dokument: `{payload['source_document_path']}`",
        f"- Revize A19: `{payload['review_path']}`",
        f"- Kandidát: `{payload['candidate_path']}`",
        f"- Typ dokumentu: **{payload['document_type']}**",
        f"- Mapování schválil: **{payload.get('reviewer') or 'NEUVEDEN'}**",
        "",
        "## Integrita obsahu",
        "",
        f"- Zdrojových bloků: **{integrity['source_blocks']}**",
        f"- Výstupních částí: **{integrity['output_pieces']}**",
        f"- Vložených znaků: **{integrity['included_characters']}**",
        f"- Vyloučených znaků: **{integrity['excluded_characters']}**",
        f"- Zachovaný obsah: **{integrity['included_percent']} %**",
        f"- Rozdělených bloků: **{integrity['split_blocks']}**",
        f"- Vzniklých částí: **{integrity['split_parts']}**",
        f"- Vyloučených bloků: **{integrity['excluded_blocks']}**",
        f"- Integrita ověřena: **{integrity['content_integrity_verified']}**",
        "",
        "## Stav kandidáta",
        "",
        f"- Stav dokumentu: **{build['document_status']}**",
        f"- Placeholderů: **{build['placeholder_count']}**",
        f"- Prázdných kapitol: **{build['empty_categories_count']}**",
        f"- Připraven pro A17: **{build['ready_for_compliance_audit']}**",
        f"- Připraven ke kanonickému schválení: "
        f"**{build['ready_for_canonical_approval']}**",
        "",
        "## Další krok",
        "",
        "1. Otevřít nový Markdown kandidát.",
        "2. Doplnit označená pole a prázdné kapitoly.",
        "3. Spustit A17 nad novým kandidátem.",
        "4. Zkontrolovat diff a teprve potom rozhodnout o nové kanonické verzi.",
        "",
        f"**FINAL STATUS:** `{payload['final_status']}`",
        "",
    ]
    return "\n".join(lines)


def write_outputs(
    *,
    output_dir: Path,
    candidate_text: str,
    source_text: str,
    source_path: Path,
    pieces: Sequence[Piece],
    excluded: Sequence[Mapping[str, Any]],
    report_payload: dict[str, Any],
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths = {
        "candidate": output_dir
        / f"document_standardized_candidate_{stamp}.md",
        "diff": output_dir
        / f"document_standardized_candidate_diff_{stamp}.diff",
        "json": output_dir
        / f"document_standardized_candidate_build_{stamp}.json",
        "csv": output_dir
        / f"document_standardized_candidate_build_{stamp}.csv",
        "markdown": output_dir
        / f"document_standardized_candidate_build_{stamp}.md",
    }

    paths["candidate"].write_text(candidate_text, encoding="utf-8")
    paths["diff"].write_text(
        build_diff(
            source_text,
            candidate_text,
            source_path,
            paths["candidate"],
        ),
        encoding="utf-8",
    )

    report_payload.update(
        {
            "candidate_path": str(paths["candidate"]),
            "diff_path": str(paths["diff"]),
            "build_json_path": str(paths["json"]),
            "build_csv_path": str(paths["csv"]),
            "build_markdown_path": str(paths["markdown"]),
            "candidate_hash_sha256": hashlib.sha256(
                candidate_text.encode("utf-8")
            ).hexdigest(),
        }
    )

    paths["json"].write_text(
        json.dumps(report_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_csv(paths["csv"], pieces, excluded)
    paths["markdown"].write_text(
        build_report_markdown(report_payload),
        encoding="utf-8",
    )

    latest = {
        "candidate": output_dir
        / "document_standardized_candidate_latest.md",
        "diff": output_dir
        / "document_standardized_candidate_diff_latest.diff",
        "json": output_dir
        / "document_standardized_candidate_build_latest.json",
        "csv": output_dir
        / "document_standardized_candidate_build_latest.csv",
        "markdown": output_dir
        / "document_standardized_candidate_build_latest.md",
    }

    for key in paths:
        shutil.copyfile(paths[key], latest[key])

    return paths


def main() -> int:
    args = parse_args()
    root = project_root()
    review_path = resolve_path(
        root,
        args.review,
        REVIEW_DEFAULT,
    )
    output_dir = resolve_path(
        root,
        args.output_dir,
        OUTPUT_DEFAULT,
    )

    print("MATCHMATRIX STANDARDIZED DOCUMENT BUILD")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"REVIEW             : {review_path}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("DATABASE WRITES    : DISABLED")
    print("SOURCE WRITES      : DISABLED")
    print()

    try:
        if not review_path.is_file():
            raise FileNotFoundError(
                f"Potvrzená revize A19 nebyla nalezena: {review_path}"
            )

        payload = read_json(review_path)
        source_path, document_type, categories, source_hash = (
            validate_review(payload)
        )
        source_text, _ = read_source_text(source_path)

        if document_type in STRUCTURE_PRESERVING_DOCUMENT_TYPES:
            review_summary = validate_structure_preserving_review(payload)
            candidate_text, applied_records = (
                apply_confirmed_structural_fixes(
                    source_text,
                    review_summary["accepted_fixes"],
                )
            )
            skipped_fixes = review_summary["skipped_fixes"]
            placeholder_count = count_real_placeholders(candidate_text)
            changed = candidate_text != source_text
            reviewer = str(payload.get("reviewer") or "")
            built_at = utc_now().isoformat()

            integrity = {
                "source_blocks": review_summary[
                    "regular_source_blocks"
                ],
                "synthetic_review_blocks": review_summary[
                    "synthetic_review_blocks"
                ],
                "output_pieces": review_summary[
                    "regular_source_blocks"
                ],
                "source_characters": len(source_text),
                "included_characters": len(source_text),
                "excluded_characters": 0,
                "included_percent": 100.0,
                "accepted_fixes_count": len(applied_records),
                "skipped_fixes_count": len(skipped_fixes),
                "unresolved_findings_count": review_summary[
                    "unresolved_findings_count"
                ],
                "unresolved_findings_excluded": review_summary[
                    "unresolved_findings_excluded"
                ],
                "structure_preserved": True,
                "content_integrity_verified": True,
            }
            build_summary = {
                "document_status": (
                    "DRAFT – READY_FOR_COMPLIANCE_AUDIT"
                ),
                "placeholder_count": placeholder_count,
                "rendered_categories": len(categories),
                "empty_categories": [],
                "empty_categories_count": 0,
                "structure_preserving_mode": True,
                "candidate_changed": changed,
                "ready_for_compliance_audit": True,
                "ready_for_canonical_approval": (
                    placeholder_count == 0
                ),
            }

            print("VSTUP")
            print("-" * 79)
            print(f"DOCUMENT           : {source_path}")
            print(f"DOCUMENT TYPE      : {document_type}")
            print(
                "PROPOSAL MODE      : "
                f"{review_summary['proposal_mode']}"
            )
            print("SHA-256 VERIFIED  : True")
            print(
                "SOURCE BLOCKS      : "
                f"{integrity['source_blocks']}"
            )
            print(
                "SYNTHETIC BLOCKS   : "
                f"{integrity['synthetic_review_blocks']}"
            )
            print(
                "ACCEPTED FIXES     : "
                f"{integrity['accepted_fixes_count']}"
            )
            print(
                "SKIPPED FIXES      : "
                f"{integrity['skipped_fixes_count']}"
            )
            print("CONTENT INCLUDED   : 100.0 %")
            print("STRUCTURE PRESERVED: True")
            print("CONTENT INTEGRITY  : VERIFIED")
            print()

            if args.validate_only:
                print("VALIDACE")
                print("-" * 79)
                print("MAPPING CONFIRMED  : True")
                print("SOURCE MODIFIED    : False")
                print("DATABASE MODIFIED  : False")
                print(
                    "FINAL STATUS       : "
                    "STANDARDIZED_DOCUMENT_BUILD_VALIDATED"
                )
                return 0

            final_status = (
                "STANDARDIZED_DOCUMENT_CANDIDATE_READY_FOR_AUDIT"
            )
            report_payload: dict[str, Any] = {
                "contract_version": OUTPUT_CONTRACT_VERSION,
                "generated_at": built_at,
                "build_engine_version": ENGINE_VERSION,
                "project_root": str(root),
                "review_path": str(review_path),
                "source_document_path": str(source_path),
                "source_hash_sha256": source_hash,
                "document_type": document_type,
                "proposal_mode": review_summary["proposal_mode"],
                "reviewer": reviewer,
                "metadata": parse_markdown_metadata_table(source_text),
                "content_integrity": integrity,
                "document_build": build_summary,
                "applied_fixes": applied_records,
                "skipped_fixes": skipped_fixes,
                "source_modified": False,
                "database_modified": False,
                "requires_compliance_audit": True,
                "final_status": final_status,
            }

            paths = write_structure_preserving_outputs(
                output_dir=output_dir,
                candidate_text=candidate_text,
                source_text=source_text,
                source_path=source_path,
                report_payload=report_payload,
                applied_fixes=applied_records,
                skipped_fixes=skipped_fixes,
            )

            print("SESTAVENÍ")
            print("-" * 79)
            print(
                f"DOCUMENT STATUS    : "
                f"{build_summary['document_status']}"
            )
            print(
                f"PLACEHOLDERS       : "
                f"{build_summary['placeholder_count']}"
            )
            print(
                "STRUCTURAL FIXES   : "
                f"{integrity['accepted_fixes_count']}"
            )
            print(
                "CANDIDATE CHANGED  : "
                f"{build_summary['candidate_changed']}"
            )
            print("READY FOR A17      : True")
            print(
                "CANONICAL APPROVAL : "
                f"{build_summary['ready_for_canonical_approval']}"
            )
            print()

            print("VÝSTUP")
            print("-" * 79)
            print(f"CANDIDATE          : {paths['candidate']}")
            print(f"DIFF               : {paths['diff']}")
            print(f"BUILD JSON         : {paths['json']}")
            print(f"BUILD CSV          : {paths['csv']}")
            print(f"BUILD MARKDOWN     : {paths['markdown']}")
            print("SOURCE MODIFIED    : False")
            print("DATABASE MODIFIED  : False")
            print(
                "FINAL STATUS       : "
                "STANDARDIZED_DOCUMENT_CANDIDATE_READY_FOR_AUDIT"
            )
            return 0

        # Původní šablonový režim pro DAILY_LOG a CHAT_CONTINUATION.
        pieces, excluded, integrity = build_pieces(
            payload,
            categories,
        )

        print("VSTUP")
        print("-" * 79)
        print(f"DOCUMENT           : {source_path}")
        print(f"DOCUMENT TYPE      : {document_type}")
        print("PROPOSAL MODE      : TEMPLATE_REBUILD")
        print("SHA-256 VERIFIED  : True")
        print(f"CATEGORIES         : {len(categories)}")
        print(f"SOURCE BLOCKS      : {integrity['source_blocks']}")
        print(f"OUTPUT PIECES      : {integrity['output_pieces']}")
        print(f"EXCLUDED BLOCKS    : {integrity['excluded_blocks']}")
        print(f"CONTENT INCLUDED   : {integrity['included_percent']} %")
        print("CONTENT INTEGRITY  : VERIFIED")
        print()

        if args.validate_only:
            print("VALIDACE")
            print("-" * 79)
            print("MAPPING CONFIRMED  : True")
            print("SOURCE MODIFIED    : False")
            print("DATABASE MODIFIED  : False")
            print(
                "FINAL STATUS       : "
                "STANDARDIZED_DOCUMENT_BUILD_VALIDATED"
            )
            return 0

        metadata = infer_metadata(
            args=args,
            source_text=source_text,
            source_path=source_path,
            document_type=document_type,
        )
        reviewer = str(payload.get("reviewer") or "")
        built_at = utc_now().isoformat()

        candidate_text, build_summary = build_markdown(
            metadata=metadata,
            document_type=document_type,
            categories=categories,
            pieces=pieces,
            source_path=source_path,
            source_hash=source_hash,
            review_path=review_path,
            reviewer=reviewer,
            built_at=built_at,
            include_trace_comments=not args.no_trace_comments,
        )

        final_status = (
            "STANDARDIZED_DOCUMENT_CANDIDATE_READY_FOR_AUDIT"
        )
        report_payload = {
            "contract_version": OUTPUT_CONTRACT_VERSION,
            "generated_at": built_at,
            "build_engine_version": ENGINE_VERSION,
            "project_root": str(root),
            "review_path": str(review_path),
            "source_document_path": str(source_path),
            "source_hash_sha256": source_hash,
            "document_type": document_type,
            "proposal_mode": "TEMPLATE_REBUILD",
            "reviewer": reviewer,
            "metadata": metadata,
            "content_integrity": integrity,
            "document_build": build_summary,
            "excluded_blocks": list(excluded),
            "source_modified": False,
            "database_modified": False,
            "requires_compliance_audit": True,
            "final_status": final_status,
        }

        paths = write_outputs(
            output_dir=output_dir,
            candidate_text=candidate_text,
            source_text=source_text,
            source_path=source_path,
            pieces=pieces,
            excluded=excluded,
            report_payload=report_payload,
        )

        print("SESTAVENÍ")
        print("-" * 79)
        print(
            f"DOCUMENT STATUS    : "
            f"{build_summary['document_status']}"
        )
        print(
            f"PLACEHOLDERS       : "
            f"{build_summary['placeholder_count']}"
        )
        print(
            f"EMPTY CATEGORIES   : "
            f"{build_summary['empty_categories_count']}"
        )
        print("READY FOR A17      : True")
        print(
            "CANONICAL APPROVAL : "
            f"{build_summary['ready_for_canonical_approval']}"
        )
        print()

        print("VÝSTUP")
        print("-" * 79)
        print(f"CANDIDATE          : {paths['candidate']}")
        print(f"DIFF               : {paths['diff']}")
        print(f"BUILD JSON         : {paths['json']}")
        print(f"BUILD CSV          : {paths['csv']}")
        print(f"BUILD MARKDOWN     : {paths['markdown']}")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "STANDARDIZED_DOCUMENT_CANDIDATE_READY_FOR_AUDIT"
        )
        return 0

    except Exception as exc:
        print("STANDARDIZED DOCUMENT BUILD ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "STANDARDIZED_DOCUMENT_BUILD_BLOCKED"
        )
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
