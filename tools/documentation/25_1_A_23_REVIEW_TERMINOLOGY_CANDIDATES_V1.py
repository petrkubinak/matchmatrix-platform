#!/usr/bin/env python3
# -*- coding: utf-8 -*-

r"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Načte terminologické kandidáty vytvořené A22, odstraní technický šum,
sloučí varianty stejných výrazů, navrhne jejich klasifikaci a otevře
řízený editor pro uživatelské potvrzení. Editor může běžet jako
lokální Tkinter okno nebo jako webový panel dostupný z PC1.

K ČEMU:
- odstraní Markdown značky, checkboxy, číslování a přebytečnou interpunkci,
- znovu ověří skutečné samostatné výskyty kandidátů v dokumentu,
- sloučí duplicitní a pravopisné varianty,
- porovná kandidáty s MM-REF-001,
- rozdělí položky do kategorií:
  EXISTING_TERM,
  NEW_TERM_CANDIDATE,
  ABBREVIATION,
  PROPER_NAME,
  TECHNICAL_IDENTIFIER,
  FALSE_POSITIVE,
- navrhne rozhodnutí, ale žádné rozhodnutí automaticky neschválí,
- umožní uživateli potvrdit, změnit nebo odmítnout každou položku,
- vytvoří návrh změn slovníku pouze z potvrzených rozhodnutí,
- MM-REF-001, denní zápis, A22 ani databázi nemění.

KDE:
tools/documentation/25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py

JAK:
Validace vstupu:
    py -3.14 .\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py `
      --validate-only

Automatická předklasifikace bez GUI:
    py -3.14 .\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py `
      --auto-only

Lokální Tkinter kontrola na stejném PC:
    py -3.14 .\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py

Webová kontrola z PC1 nad procesem běžícím na PC2:
    py -3.14 .\tools\documentation\25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py `
      --web --host 0.0.0.0 --port 8765

Explicitní report:
    --report "C:\...\MM-DL-20260624_TERMINOLOGY_REPORT.json"

BEZPEČNOST:
- zdrojový terminologický report pouze čte,
- referenční slovník pouze čte,
- denní zápis pouze čte,
- databázi nepoužívá,
- žádný termín automaticky nepřidává do MM-REF-001,
- potvrzení uživatele se ukládá do samostatného review state,
- návrh slovníku je pouze schvalovací podklad.

VÝSTUP:
reports/documentation/standardization/terminology_reviews/
- <DOCUMENT_ID>_TERMINOLOGY_AUTO_CLASSIFICATION.json
- <DOCUMENT_ID>_TERMINOLOGY_AUTO_CLASSIFICATION.csv
- <DOCUMENT_ID>_TERMINOLOGY_AUTO_CLASSIFICATION.md
- <DOCUMENT_ID>_TERMINOLOGY_REVIEW_STATE.json
- <DOCUMENT_ID>_TERMINOLOGY_REVIEW_STATE.csv
- <DOCUMENT_ID>_TERMINOLOGY_REVIEW_STATE.md
- <DOCUMENT_ID>_TERMINOLOGY_GLOSSARY_PROPOSAL.json
- <DOCUMENT_ID>_TERMINOLOGY_GLOSSARY_PROPOSAL.csv
- <DOCUMENT_ID>_TERMINOLOGY_GLOSSARY_PROPOSAL.md
- history/
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import html
import json
import re
import secrets
import socket
import threading
import shutil
import sys
import unicodedata
import urllib.parse
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


ENGINE_VERSION = "A23_TERMINOLOGY_CANDIDATE_REVIEW_V1_1_WEB"
CONTRACT_VERSION = "1.0"

CATEGORIES = (
    "EXISTING_TERM",
    "NEW_TERM_CANDIDATE",
    "ABBREVIATION",
    "PROPER_NAME",
    "TECHNICAL_IDENTIFIER",
    "FALSE_POSITIVE",
)

DECISIONS = (
    "REVIEW_REQUIRED",
    "ADD_TO_GLOSSARY",
    "KEEP_EXISTING",
    "KEEP_REFERENCE_ONLY",
    "MERGE_WITH_EXISTING",
    "REJECT_FALSE_POSITIVE",
)

AUTO_REPORT_DEFAULT = Path(
    "reports/documentation/standardization/canonical_candidates"
)
OUTPUT_DEFAULT = Path(
    "reports/documentation/standardization/terminology_reviews"
)

CHECKBOX_RE = re.compile(r"^\s*[-*+]?\s*\[[ xX]\]\s*")
HEADING_RE = re.compile(r"^\s*#{1,6}\s*")
ELLIPSIS_SECTION_RE = re.compile(
    r"^\s*(?:\.{2,}|…)\s*\d+(?:\.\d+)*[.)]?\s*"
)
NUMBERING_RE = re.compile(r"^\s*\d+(?:\.\d+)*[.)]\s*")
BULLET_RE = re.compile(r"^\s*[-*+]\s+")
MULTISPACE_RE = re.compile(r"\s+")
SENTENCE_END_RE = re.compile(r"[.!?]\s*$")
WORD_RE = re.compile(r"[A-Za-zÀ-ž0-9]+")
A_SCRIPT_RE = re.compile(r"^A\d{1,3}$", re.IGNORECASE)
MM_IDENTIFIER_RE = re.compile(
    r"^MM-[A-Z0-9]+(?:-[A-Z0-9]+)*$",
    re.IGNORECASE,
)

FALSE_PREFIXES = (
    "dnes jsme ",
    "proto jsme ",
    "poprvé ",
    "ráno",
    "večer",
    "máme ",
    "vytvořen ",
    "vytvořena ",
    "vytvořeno ",
    "vznikl ",
    "vznikla ",
    "vzniklo ",
    "začali jsme ",
    "byl spuštěn ",
    "byla doplněna ",
    "byla ověřena ",
    "audit a17 dosáhl ",
)

FALSE_EXACT = {
    "dashboard",
    "discovery",
    "governance",
    "governance vrstva",
    "source",
    "vrstva",
    "matchmatrix",
    "dokumentace matchmatrix",
    "dnes jsme zahájili audit",
    "poprvé máme systém který bude schopen",
    "máme základ celé source intelligence architektury",
    "soupisky trenéři lékaři fyzioterapeuti analytici management history layer",
    "fyzioterapeuti analytici management history layer",
    "meta tiktok people layer",
    "officials team layer",
    "player profiles coach profiles team",
    "player profiles coach profiles team officials team layer",
    "začali jsme budovat systém pro všechny sporty",
}

GENERIC_UPPERCASE_FALSE = {
    "DASHBOARD",
    "DISCOVERY",
    "GOVERNANCE",
    "SOURCE",
    "VRSTVA",
    "DOPLNIT",
    "MATCHMATRIX",
}

TECHNICAL_IDENTIFIERS = {
    "A17",
    "A19",
    "A20",
    "A21",
    "FB",
    "BK",
    "HB",
    "TN",
    "DL",
    "DOC",
    "REF",
}

PROPER_NAMES = {
    "EHF",
    "IHF",
    "ASOBAL",
    "LNH",
    "REMA",
}

ABBREVIATIONS = {
    "CMS",
    "ROI",
}

PROJECT_TERM_CANONICAL = {
    "source intelligence": "Source Intelligence",
    "source intelligence layer": "Source Intelligence Layer",
    "source discovery": "Source Discovery",
    "globální source discovery": "Source Discovery",
    "source discovery master": "Source Discovery Master",
    "source discovery queue": "Source Discovery Queue",
    "source discovery audit tracker": "Source Discovery Audit Tracker",
    "source discovery dashboard": "Source Discovery Dashboard",
    "national league discovery": "National League Discovery",
    "activation roadmap": "Activation Roadmap",
    "commercial model": "Commercial Model",
    "commercial use": "Commercial Use",
    "quality score": "Quality Score",
    "privacy policy": "Privacy Policy",
    "terms conditions": "Terms & Conditions",
    "media layer": "Media Layer",
    "people layer": "People Layer",
    "history layer": "History Layer",
    "team layer": "Team Layer",
    "ehf audit": "EHF Audit",
    "ihf audit": "IHF Audit",
}

VARIANT_MERGES = {
    "globální source discovery": "Source Discovery",
    "audit a17": "A17",
}

CATEGORY_DEFAULT_DECISION = {
    "EXISTING_TERM": "KEEP_EXISTING",
    "NEW_TERM_CANDIDATE": "REVIEW_REQUIRED",
    "ABBREVIATION": "REVIEW_REQUIRED",
    "PROPER_NAME": "KEEP_REFERENCE_ONLY",
    "TECHNICAL_IDENTIFIER": "KEEP_REFERENCE_ONLY",
    "FALSE_POSITIVE": "REJECT_FALSE_POSITIVE",
}


@dataclass
class CandidateItem:
    item_id: str
    canonical_term: str
    normalized_term: str
    original_terms: list[str]
    occurrences_reported: int
    occurrences_verified: int
    contexts: list[str]
    category: str
    suggested_decision: str
    decision: str
    confidence: str
    reason: str
    merge_target: str = ""
    confirmed: bool = False
    user_note: str = ""

    def validate(self) -> None:
        if self.category not in CATEGORIES:
            raise ValueError(f"Neplatná kategorie: {self.category}")
        if self.decision not in DECISIONS:
            raise ValueError(f"Neplatné rozhodnutí: {self.decision}")
        if self.suggested_decision not in DECISIONS:
            raise ValueError(
                f"Neplatné navržené rozhodnutí: "
                f"{self.suggested_decision}"
            )
        if not self.canonical_term.strip():
            raise ValueError("Kanonický termín je prázdný.")


@dataclass
class ReviewPackage:
    document_id: str
    source_report_path: str
    source_report_sha256: str
    document_path: str
    document_sha256: str
    glossary_path: str
    glossary_sha256: str
    generated_at: str
    engine_version: str
    items: list[CandidateItem] = field(default_factory=list)


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Předklasifikuje a umožní schválit terminologické "
            "kandidáty A22."
        )
    )
    parser.add_argument("--report")
    parser.add_argument("--output-dir")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Ověří vstupy a klasifikační kontrakt.",
    )
    parser.add_argument(
        "--auto-only",
        action="store_true",
        help="Vytvoří předklasifikaci bez otevření GUI.",
    )
    parser.add_argument(
        "--new-review",
        action="store_true",
        help="Ignoruje existující review state a začne znovu.",
    )
    parser.add_argument(
        "--web",
        action="store_true",
        help=(
            "Spustí webový editor na PC2, který lze otevřít "
            "z prohlížeče na PC1."
        ),
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help=(
            "Adresa webového serveru. Pro přístup z PC1 použij "
            "0.0.0.0. Výchozí 127.0.0.1."
        ),
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8765,
        help="Port webového editoru; výchozí 8765.",
    )
    parser.add_argument(
        "--web-token",
        help=(
            "Volitelný přístupový token. Pokud není zadán, "
            "vygeneruje se pro aktuální běh."
        ),
    )
    return parser.parse_args()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def normalize_term(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    without_marks = "".join(
        char for char in decomposed
        if not unicodedata.combining(char)
    )
    folded = without_marks.casefold()
    folded = folded.replace("&", " ")
    folded = re.sub(r"[`*_#>|:\[\]{}()]", " ", folded)
    folded = re.sub(r"[^a-z0-9]+", " ", folded)
    return MULTISPACE_RE.sub(" ", folded).strip()


def clean_term(value: str) -> str:
    result = value.strip()
    result = CHECKBOX_RE.sub("", result)
    result = HEADING_RE.sub("", result)
    result = ELLIPSIS_SECTION_RE.sub("", result)
    result = NUMBERING_RE.sub("", result)
    result = BULLET_RE.sub("", result)
    result = result.replace("**", "").replace("__", "")
    result = result.strip(" \t\r\n`*_#:;,.–—-…")
    result = MULTISPACE_RE.sub(" ", result).strip()
    return result


def read_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"JSON musí být objekt: {path}")
    return payload


def discover_report(root: Path, explicit: str | None) -> Path:
    if explicit:
        path = Path(explicit)
        if not path.is_absolute():
            path = root / path
        path = path.resolve()
        if not path.is_file():
            raise FileNotFoundError(
                f"Terminologický report nebyl nalezen: {path}"
            )
        return path

    folder = (root / AUTO_REPORT_DEFAULT).resolve()
    candidates = sorted(
        folder.glob("MM-DL-*_TERMINOLOGY_REPORT.json"),
        key=lambda path: path.stat().st_mtime,
        reverse=True,
    )
    if not candidates:
        raise FileNotFoundError(
            "Nebyl nalezen A22 terminologický report. "
            "Použij --report."
        )
    return candidates[0]


def resolve_output(root: Path, explicit: str | None) -> Path:
    path = Path(explicit) if explicit else OUTPUT_DEFAULT
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def resolve_payload_path(
    root: Path,
    value: str | None,
    label: str,
) -> Path:
    if not value:
        raise RuntimeError(f"A22 report neobsahuje {label}.")
    path = Path(value)
    if not path.is_absolute():
        path = root / path
    path = path.resolve()
    if not path.is_file():
        raise FileNotFoundError(f"{label} nebyl nalezen: {path}")
    return path


def glossary_terms(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8-sig")
    result: dict[str, str] = {}
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|") or stripped.startswith("|---"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if len(cells) < 2:
            continue
        term = clean_term(cells[0])
        if normalize_term(term) in {"pojem", "term"}:
            continue
        normalized = normalize_term(term)
        if normalized:
            result[normalized] = term
    if not result:
        raise RuntimeError(
            f"Ve slovníku nebyly nalezeny pojmy: {path}"
        )
    return result


def exact_occurrences(text: str, term: str) -> int:
    cleaned = term.strip()
    if not cleaned:
        return 0
    escaped = re.escape(cleaned)
    pattern = re.compile(
        rf"(?<![\w-]){escaped}(?![\w-])",
        re.IGNORECASE | re.UNICODE,
    )
    return len(pattern.findall(text))


def looks_like_sentence(term: str) -> bool:
    normalized = normalize_term(term)
    words = normalized.split()
    if not words:
        return True
    if normalized.startswith(FALSE_PREFIXES):
        return True
    if len(words) >= 7:
        return True
    if len(words) >= 4 and SENTENCE_END_RE.search(term):
        return True
    return False


def item_id(normalized: str) -> str:
    return hashlib.sha1(
        normalized.encode("utf-8")
    ).hexdigest()[:12].upper()


def canonicalize(cleaned: str) -> tuple[str, str]:
    normalized = normalize_term(cleaned)
    if normalized in PROJECT_TERM_CANONICAL:
        return PROJECT_TERM_CANONICAL[normalized], normalized

    if cleaned.isupper() and len(cleaned.split()) > 1:
        title = " ".join(
            word if word in PROPER_NAMES else word.title()
            for word in cleaned.split()
        )
        return title, normalize_term(title)

    return cleaned, normalized


def classify(
    *,
    canonical: str,
    normalized: str,
    original_terms: Sequence[str],
    verified_occurrences: int,
    glossary: Mapping[str, str],
) -> tuple[str, str, str, str, str]:
    originals_joined = " | ".join(original_terms)
    original_has_checkbox = any(
        CHECKBOX_RE.match(value.strip()) for value in original_terms
    )

    if normalized in glossary:
        return (
            "EXISTING_TERM",
            "KEEP_EXISTING",
            "HIGH",
            "Přesná normalizovaná shoda s MM-REF-001.",
            "",
        )

    if original_has_checkbox:
        return (
            "FALSE_POSITIVE",
            "REJECT_FALSE_POSITIVE",
            "HIGH",
            "Položka vznikla z Markdown checkboxu, nikoli z pojmu.",
            "",
        )

    if not canonical or not normalized:
        return (
            "FALSE_POSITIVE",
            "REJECT_FALSE_POSITIVE",
            "HIGH",
            "Po očištění nezůstal použitelný termín.",
            "",
        )

    if normalized in VARIANT_MERGES:
        target = VARIANT_MERGES[normalized]
        category = (
            "TECHNICAL_IDENTIFIER"
            if target in TECHNICAL_IDENTIFIERS
            else "NEW_TERM_CANDIDATE"
        )
        return (
            category,
            "MERGE_WITH_EXISTING",
            "HIGH",
            f"Jde o variantu nebo rozšíření termínu {target}.",
            target,
        )

    if canonical.upper() in TECHNICAL_IDENTIFIERS:
        return (
            "TECHNICAL_IDENTIFIER",
            "KEEP_REFERENCE_ONLY",
            "HIGH",
            "Interní identifikátor skriptu, dokumentu nebo sportu.",
            "",
        )

    if A_SCRIPT_RE.fullmatch(canonical) or MM_IDENTIFIER_RE.fullmatch(
        canonical
    ):
        return (
            "TECHNICAL_IDENTIFIER",
            "KEEP_REFERENCE_ONLY",
            "HIGH",
            "Technický identifikátor MatchMatrix.",
            "",
        )

    if canonical.upper() in PROPER_NAMES:
        return (
            "PROPER_NAME",
            "KEEP_REFERENCE_ONLY",
            "HIGH",
            "Název nebo zkratka konkrétní organizace či soutěže.",
            "",
        )

    if canonical.upper() in ABBREVIATIONS:
        return (
            "ABBREVIATION",
            "REVIEW_REQUIRED",
            "MEDIUM",
            "Samostatná odborná zkratka; je třeba rozhodnout, "
            "zda patří do slovníku.",
            "",
        )

    if canonical.upper() in GENERIC_UPPERCASE_FALSE:
        return (
            "FALSE_POSITIVE",
            "REJECT_FALSE_POSITIVE",
            "HIGH",
            "Obecné slovo zachycené pouze kvůli zápisu velkými písmeny.",
            "",
        )

    if normalized in FALSE_EXACT or looks_like_sentence(canonical):
        return (
            "FALSE_POSITIVE",
            "REJECT_FALSE_POSITIVE",
            "HIGH",
            "Celá věta, procesní sdělení nebo slepený seznam, "
            "nikoli samostatný odborný pojem.",
            "",
        )

    if verified_occurrences == 0:
        return (
            "FALSE_POSITIVE",
            "REJECT_FALSE_POSITIVE",
            "HIGH",
            "V kanonickém dokumentu nebyl nalezen samostatný "
            "výskyt; kandidát vznikl uvnitř jiného slova nebo cesty.",
            "",
        )

    if normalized in PROJECT_TERM_CANONICAL:
        return (
            "NEW_TERM_CANDIDATE",
            "REVIEW_REQUIRED",
            "HIGH",
            "Rozpoznaný projektový nebo architektonický termín.",
            "",
        )

    if normalized in {
        "privacy policy",
        "terms conditions",
        "commercial use",
    }:
        return (
            "NEW_TERM_CANDIDATE",
            "REVIEW_REQUIRED",
            "MEDIUM",
            "Právní nebo komerční termín relevantní pro "
            "Source Intelligence.",
            "",
        )

    words = normalized.split()
    if len(words) == 1 and canonical.isupper():
        return (
            "ABBREVIATION",
            "REVIEW_REQUIRED",
            "LOW",
            "Nerozpoznaná samostatná zkratka.",
            "",
        )

    if 2 <= len(words) <= 6:
        return (
            "NEW_TERM_CANDIDATE",
            "REVIEW_REQUIRED",
            "MEDIUM",
            "Krátké odborně působící spojení vyžadující "
            "uživatelské posouzení.",
            "",
        )

    return (
        "FALSE_POSITIVE",
        "REJECT_FALSE_POSITIVE",
        "MEDIUM",
        "Položka nesplňuje pravidla samostatného termínu.",
        "",
    )


def build_package(
    *,
    report_path: Path,
    root: Path,
) -> ReviewPackage:
    payload = read_json(report_path)
    document_id = str(payload.get("document_id") or "").strip()
    if not re.fullmatch(r"MM-DL-\d{8}", document_id):
        raise RuntimeError(
            f"Neplatné nebo chybějící DAILY_LOG ID: {document_id!r}"
        )

    document_path = resolve_payload_path(
        root,
        str(payload.get("document_path") or ""),
        "document_path",
    )
    glossary_path = resolve_payload_path(
        root,
        str(payload.get("glossary_path") or ""),
        "glossary_path",
    )
    document_text = document_path.read_text(encoding="utf-8-sig")
    glossary = glossary_terms(glossary_path)

    raw_candidates = payload.get("candidate_terms")
    if not isinstance(raw_candidates, list):
        raise RuntimeError(
            "A22 report neobsahuje pole candidate_terms."
        )

    grouped: dict[str, dict[str, Any]] = {}
    for raw in raw_candidates:
        if not isinstance(raw, dict):
            continue
        original = str(raw.get("term") or "").strip()
        cleaned = clean_term(original)
        canonical, normalized = canonicalize(cleaned)
        if not normalized:
            normalized = normalize_term(original)
        if not normalized:
            continue

        group = grouped.setdefault(
            normalized,
            {
                "canonical": canonical,
                "original_terms": [],
                "occurrences": 0,
                "contexts": [],
            },
        )
        if original and original not in group["original_terms"]:
            group["original_terms"].append(original)
        try:
            group["occurrences"] += int(
                raw.get("occurrences") or 0
            )
        except (TypeError, ValueError):
            pass
        contexts = raw.get("contexts")
        if isinstance(contexts, list):
            for context in contexts:
                value = str(context).strip()
                if value and value not in group["contexts"]:
                    group["contexts"].append(value)

    # Merge groups whose canonicalization points to the same target.
    merged: dict[str, dict[str, Any]] = {}
    for normalized, group in grouped.items():
        canonical = str(group["canonical"])
        canonical_normalized = normalize_term(canonical)
        key = canonical_normalized or normalized
        target = merged.setdefault(
            key,
            {
                "canonical": canonical,
                "original_terms": [],
                "occurrences": 0,
                "contexts": [],
            },
        )
        for value in group["original_terms"]:
            if value not in target["original_terms"]:
                target["original_terms"].append(value)
        target["occurrences"] += group["occurrences"]
        for value in group["contexts"]:
            if value not in target["contexts"]:
                target["contexts"].append(value)

    items: list[CandidateItem] = []
    for normalized, group in sorted(
        merged.items(),
        key=lambda pair: pair[1]["canonical"].casefold(),
    ):
        canonical = str(group["canonical"]).strip()
        verified = exact_occurrences(document_text, canonical)
        category, decision, confidence, reason, merge_target = (
            classify(
                canonical=canonical,
                normalized=normalized,
                original_terms=group["original_terms"],
                verified_occurrences=verified,
                glossary=glossary,
            )
        )
        item = CandidateItem(
            item_id=item_id(normalized),
            canonical_term=canonical,
            normalized_term=normalized,
            original_terms=list(group["original_terms"]),
            occurrences_reported=int(group["occurrences"]),
            occurrences_verified=verified,
            contexts=list(group["contexts"])[:10],
            category=category,
            suggested_decision=decision,
            decision=decision,
            confidence=confidence,
            reason=reason,
            merge_target=merge_target,
            confirmed=False,
            user_note="",
        )
        item.validate()
        items.append(item)

    return ReviewPackage(
        document_id=document_id,
        source_report_path=str(report_path),
        source_report_sha256=sha256_file(report_path),
        document_path=str(document_path),
        document_sha256=sha256_file(document_path),
        glossary_path=str(glossary_path),
        glossary_sha256=sha256_file(glossary_path),
        generated_at=utc_now(),
        engine_version=ENGINE_VERSION,
        items=items,
    )


def counts(items: Sequence[CandidateItem]) -> dict[str, Any]:
    category_counts = {
        category: sum(
            1 for item in items if item.category == category
        )
        for category in CATEGORIES
    }
    decision_counts = {
        decision: sum(
            1 for item in items if item.decision == decision
        )
        for decision in DECISIONS
    }
    return {
        "total": len(items),
        "confirmed": sum(1 for item in items if item.confirmed),
        "pending_confirmation": sum(
            1 for item in items if not item.confirmed
        ),
        "category_counts": category_counts,
        "decision_counts": decision_counts,
    }


def package_payload(
    package: ReviewPackage,
    final_status: str,
) -> dict[str, Any]:
    return {
        "contract_version": CONTRACT_VERSION,
        "generated_at": utc_now(),
        "engine_version": ENGINE_VERSION,
        "document_id": package.document_id,
        "source_report_path": package.source_report_path,
        "source_report_sha256": package.source_report_sha256,
        "document_path": package.document_path,
        "document_sha256": package.document_sha256,
        "glossary_path": package.glossary_path,
        "glossary_sha256": package.glossary_sha256,
        "statistics": counts(package.items),
        "items": [asdict(item) for item in package.items],
        "source_modified": False,
        "document_modified": False,
        "glossary_modified": False,
        "database_modified": False,
        "final_status": final_status,
    }


def write_csv(path: Path, items: Sequence[CandidateItem]) -> None:
    fields = [
        "item_id",
        "confirmed",
        "category",
        "decision",
        "canonical_term",
        "merge_target",
        "confidence",
        "occurrences_reported",
        "occurrences_verified",
        "original_terms",
        "reason",
        "user_note",
        "contexts",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for item in items:
            writer.writerow(
                {
                    "item_id": item.item_id,
                    "confirmed": item.confirmed,
                    "category": item.category,
                    "decision": item.decision,
                    "canonical_term": item.canonical_term,
                    "merge_target": item.merge_target,
                    "confidence": item.confidence,
                    "occurrences_reported": item.occurrences_reported,
                    "occurrences_verified": item.occurrences_verified,
                    "original_terms": " || ".join(item.original_terms),
                    "reason": item.reason,
                    "user_note": item.user_note,
                    "contexts": " || ".join(item.contexts),
                }
            )


def markdown_report(
    package: ReviewPackage,
    *,
    title: str,
    final_status: str,
) -> str:
    stats = counts(package.items)
    lines = [
        f"# {package.document_id} – {title}",
        "",
        f"- Zdrojový report: `{package.source_report_path}`",
        f"- Dokument: `{package.document_path}`",
        f"- Slovník: `{package.glossary_path}`",
        f"- Položek po očištění a sloučení: **{stats['total']}**",
        f"- Potvrzeno uživatelem: **{stats['confirmed']}**",
        f"- Čeká na potvrzení: "
        f"**{stats['pending_confirmation']}**",
        "",
        "## Souhrn kategorií",
        "",
        "| Kategorie | Počet |",
        "|---|---:|",
    ]
    for category in CATEGORIES:
        lines.append(
            f"| {category} | "
            f"{stats['category_counts'][category]} |"
        )

    lines.extend(
        [
            "",
            "## Kandidáti",
            "",
            "| OK | Kanonický termín | Kategorie | Rozhodnutí | "
            "Výskyty | Jistota |",
            "|---|---|---|---|---:|---|",
        ]
    )
    for item in package.items:
        mark = "ANO" if item.confirmed else "NE"
        lines.append(
            f"| {mark} | {item.canonical_term} | "
            f"{item.category} | {item.decision} | "
            f"{item.occurrences_verified} | {item.confidence} |"
        )

    lines.extend(
        [
            "",
            "> A23 nemění MM-REF-001. Výstup je pouze řízený "
            "schvalovací podklad.",
            "",
            f"**FINAL STATUS:** `{final_status}`",
            "",
        ]
    )
    return "\n".join(lines)


def proposal_payload(
    package: ReviewPackage,
) -> dict[str, Any]:
    additions = [
        item for item in package.items
        if item.confirmed
        and item.decision == "ADD_TO_GLOSSARY"
    ]
    merges = [
        item for item in package.items
        if item.confirmed
        and item.decision == "MERGE_WITH_EXISTING"
    ]
    return {
        "contract_version": CONTRACT_VERSION,
        "generated_at": utc_now(),
        "engine_version": ENGINE_VERSION,
        "document_id": package.document_id,
        "glossary_path": package.glossary_path,
        "approved_additions": [asdict(item) for item in additions],
        "approved_merges": [asdict(item) for item in merges],
        "approved_additions_count": len(additions),
        "approved_merges_count": len(merges),
        "glossary_modified": False,
        "requires_separate_glossary_update": bool(additions),
        "final_status": (
            "GLOSSARY_CHANGE_PROPOSAL_READY"
            if additions or merges
            else "NO_GLOSSARY_CHANGE_PROPOSED"
        ),
    }


def proposal_markdown(payload: Mapping[str, Any]) -> str:
    lines = [
        f"# {payload['document_id']} – NÁVRH ZMĚN MM-REF-001",
        "",
        f"- Slovník: `{payload['glossary_path']}`",
        f"- Schválené nové termíny: "
        f"**{payload['approved_additions_count']}**",
        f"- Schválená sloučení variant: "
        f"**{payload['approved_merges_count']}**",
        "",
        "## Nové termíny",
        "",
    ]
    additions = payload["approved_additions"]
    if additions:
        lines.extend(
            [
                "| Termín | Kategorie | Poznámka |",
                "|---|---|---|",
            ]
        )
        for item in additions:
            lines.append(
                f"| {item['canonical_term']} | "
                f"{item['category']} | "
                f"{item['user_note'] or item['reason']} |"
            )
    else:
        lines.append("Žádný nový termín nebyl schválen.")

    lines.extend(["", "## Sloučení variant", ""])
    merges = payload["approved_merges"]
    if merges:
        lines.extend(
            [
                "| Varianta | Cílový termín |",
                "|---|---|",
            ]
        )
        for item in merges:
            lines.append(
                f"| {item['canonical_term']} | "
                f"{item['merge_target']} |"
            )
    else:
        lines.append("Žádné sloučení variant nebylo schváleno.")

    lines.extend(
        [
            "",
            "> Tento dokument je pouze návrh. MM-REF-001 nebyl změněn.",
            "",
            f"**FINAL STATUS:** `{payload['final_status']}`",
            "",
        ]
    )
    return "\n".join(lines)


def write_proposal(
    output_dir: Path,
    package: ReviewPackage,
) -> None:
    payload = proposal_payload(package)
    prefix = package.document_id
    json_path = output_dir / (
        f"{prefix}_TERMINOLOGY_GLOSSARY_PROPOSAL.json"
    )
    csv_path = output_dir / (
        f"{prefix}_TERMINOLOGY_GLOSSARY_PROPOSAL.csv"
    )
    md_path = output_dir / (
        f"{prefix}_TERMINOLOGY_GLOSSARY_PROPOSAL.md"
    )
    json_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    rows = [
        *[
            {
                "proposal_type": "ADD_TO_GLOSSARY",
                "term": item["canonical_term"],
                "target": "",
                "category": item["category"],
                "note": item["user_note"] or item["reason"],
            }
            for item in payload["approved_additions"]
        ],
        *[
            {
                "proposal_type": "MERGE_WITH_EXISTING",
                "term": item["canonical_term"],
                "target": item["merge_target"],
                "category": item["category"],
                "note": item["user_note"] or item["reason"],
            }
            for item in payload["approved_merges"]
        ],
    ]
    with csv_path.open(
        "w", encoding="utf-8-sig", newline=""
    ) as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "proposal_type",
                "term",
                "target",
                "category",
                "note",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    md_path.write_text(
        proposal_markdown(payload),
        encoding="utf-8",
    )


def write_auto_outputs(
    output_dir: Path,
    package: ReviewPackage,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    prefix = package.document_id
    status = "TERMINOLOGY_AUTO_CLASSIFICATION_READY"
    payload = package_payload(package, status)
    (output_dir / f"{prefix}_TERMINOLOGY_AUTO_CLASSIFICATION.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_csv(
        output_dir
        / f"{prefix}_TERMINOLOGY_AUTO_CLASSIFICATION.csv",
        package.items,
    )
    (
        output_dir
        / f"{prefix}_TERMINOLOGY_AUTO_CLASSIFICATION.md"
    ).write_text(
        markdown_report(
            package,
            title="AUTOMATICKÁ PŘEDKLASIFIKACE",
            final_status=status,
        ),
        encoding="utf-8",
    )


def write_review_outputs(
    output_dir: Path,
    package: ReviewPackage,
    *,
    write_history: bool = True,
) -> str:
    output_dir.mkdir(parents=True, exist_ok=True)
    history = output_dir / "history"
    history.mkdir(parents=True, exist_ok=True)
    prefix = package.document_id
    stats = counts(package.items)
    status = (
        "TERMINOLOGY_CANDIDATE_REVIEW_CONFIRMED"
        if stats["pending_confirmation"] == 0
        else "TERMINOLOGY_CANDIDATE_REVIEW_PENDING"
    )
    payload = package_payload(package, status)

    json_path = (
        output_dir
        / f"{prefix}_TERMINOLOGY_REVIEW_STATE.json"
    )
    csv_path = (
        output_dir
        / f"{prefix}_TERMINOLOGY_REVIEW_STATE.csv"
    )
    md_path = (
        output_dir
        / f"{prefix}_TERMINOLOGY_REVIEW_STATE.md"
    )
    json_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    write_csv(csv_path, package.items)
    md_path.write_text(
        markdown_report(
            package,
            title="STAV TERMINOLOGICKÉ REVIZE",
            final_status=status,
        ),
        encoding="utf-8",
    )

    if write_history:
        stamp = datetime.now().astimezone().strftime(
            "%Y%m%d_%H%M%S"
        )
        shutil.copy2(
            json_path,
            history
            / f"{prefix}_TERMINOLOGY_REVIEW_STATE_{stamp}.json",
        )
    write_proposal(output_dir, package)
    return status


def load_review_state(
    path: Path,
    package: ReviewPackage,
) -> bool:
    if not path.is_file():
        return False
    payload = read_json(path)
    if (
        payload.get("source_report_sha256")
        != package.source_report_sha256
    ):
        return False
    by_id = {
        str(item.get("item_id")): item
        for item in payload.get("items", [])
        if isinstance(item, dict)
    }
    for item in package.items:
        saved = by_id.get(item.item_id)
        if not saved:
            continue
        item.canonical_term = str(
            saved.get("canonical_term")
            or item.canonical_term
        )
        category = str(saved.get("category") or item.category)
        decision = str(saved.get("decision") or item.decision)
        if category in CATEGORIES:
            item.category = category
        if decision in DECISIONS:
            item.decision = decision
        item.merge_target = str(
            saved.get("merge_target") or item.merge_target
        )
        item.confirmed = bool(saved.get("confirmed"))
        item.user_note = str(saved.get("user_note") or "")
    return True



def detect_lan_ip() -> str:
    """
    Vrátí pravděpodobnou LAN IPv4 adresu bez závislosti na internetu.
    Při neúspěchu vrátí hostname nebo 127.0.0.1.
    """
    try:
        hostname = socket.gethostname()
        addresses = socket.getaddrinfo(
            hostname,
            None,
            family=socket.AF_INET,
            type=socket.SOCK_STREAM,
        )
        candidates = []
        for entry in addresses:
            address = entry[4][0]
            if (
                address
                and not address.startswith("127.")
                and address not in candidates
            ):
                candidates.append(address)
        if candidates:
            return candidates[0]
    except OSError:
        pass

    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(("192.0.2.1", 9))
            address = sock.getsockname()[0]
            if address:
                return address
    except OSError:
        pass
    return "127.0.0.1"


WEB_HTML = r"""<!doctype html>
<html lang="cs">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>MatchMatrix A23 – Terminologická revize</title>
<style>
:root {
  --bg:#f6f5fa; --panel:#ffffff; --text:#211b2d; --muted:#6a6374;
  --accent:#6f42c1; --accent2:#56339a; --border:#ded9e8;
  --ok:#1f7a4d; --warn:#9b6500; --bad:#a52a2a; --shadow:0 8px 28px rgba(46,31,75,.10);
}
* { box-sizing:border-box; }
body { margin:0; font-family:Segoe UI,Arial,sans-serif; background:var(--bg); color:var(--text); }
header { position:sticky; top:0; z-index:10; background:#251a35; color:white; padding:14px 20px; box-shadow:var(--shadow); }
header h1 { margin:0 0 5px; font-size:20px; }
header .sub { color:#d9cfea; font-size:13px; }
main { padding:16px; max-width:1900px; margin:auto; }
.cards { display:grid; grid-template-columns:repeat(5,minmax(130px,1fr)); gap:10px; margin-bottom:12px; }
.card { background:var(--panel); border:1px solid var(--border); border-radius:10px; padding:10px 12px; box-shadow:var(--shadow); }
.card b { display:block; font-size:22px; color:var(--accent); }
.card span { color:var(--muted); font-size:12px; }
.toolbar { display:flex; flex-wrap:wrap; gap:8px; align-items:center; background:var(--panel); border:1px solid var(--border); border-radius:10px; padding:10px; margin-bottom:12px; }
select,input,textarea,button { font:inherit; }
select,input[type=text],textarea { border:1px solid var(--border); border-radius:7px; padding:7px 9px; background:white; }
button { border:0; border-radius:7px; padding:8px 12px; cursor:pointer; background:var(--accent); color:white; font-weight:600; }
button:hover { background:var(--accent2); }
button.secondary { background:#6c6674; }
button.danger { background:#9d2e3b; }
.layout { display:grid; grid-template-columns:minmax(680px,1.65fr) minmax(420px,1fr); gap:12px; min-height:650px; }
.panel { background:var(--panel); border:1px solid var(--border); border-radius:10px; box-shadow:var(--shadow); overflow:hidden; }
.table-wrap { overflow:auto; height:calc(100vh - 265px); min-height:560px; }
table { border-collapse:collapse; width:100%; font-size:13px; }
th { position:sticky; top:0; background:#eee9f7; z-index:2; text-align:left; padding:8px; border-bottom:1px solid var(--border); }
td { padding:7px 8px; border-bottom:1px solid #eeeaf2; vertical-align:top; }
tr:hover { background:#f8f4ff; }
tr.selected { background:#eee4ff; }
.badge { display:inline-block; border-radius:999px; padding:3px 7px; font-size:11px; font-weight:700; white-space:nowrap; }
.NEW_TERM_CANDIDATE { background:#e9defd; color:#4e278d; }
.ABBREVIATION { background:#fff0c8; color:#7c5500; }
.PROPER_NAME { background:#dceefc; color:#205a84; }
.TECHNICAL_IDENTIFIER { background:#e4e6ea; color:#3d4450; }
.FALSE_POSITIVE { background:#f9dddd; color:#8a2828; }
.EXISTING_TERM { background:#dcefe5; color:#246344; }
.detail { padding:14px; height:calc(100vh - 225px); min-height:600px; overflow:auto; }
.detail h2 { margin:0 0 12px; font-size:18px; }
.field { margin-bottom:10px; }
.field label { display:block; font-size:12px; font-weight:700; color:var(--muted); margin-bottom:4px; }
.field input[type=text], .field select, .field textarea { width:100%; }
.field textarea { min-height:78px; resize:vertical; }
.context { white-space:pre-wrap; background:#f7f5fa; border:1px solid var(--border); border-radius:7px; padding:9px; font-size:12px; max-height:260px; overflow:auto; }
.actions { display:flex; flex-wrap:wrap; gap:7px; margin-top:12px; }
.notice { padding:8px 10px; border-radius:7px; margin-bottom:10px; display:none; }
.notice.ok { display:block; background:#dcf2e6; color:#205c3d; }
.notice.err { display:block; background:#fae0e3; color:#8d2633; }
.small { color:var(--muted); font-size:12px; }
@media (max-width:1100px) {
  .layout { grid-template-columns:1fr; }
  .table-wrap,.detail { height:auto; min-height:480px; }
  .cards { grid-template-columns:repeat(2,1fr); }
}
</style>
</head>
<body>
<header>
  <h1>MatchMatrix A23 – Terminologická revize</h1>
  <div class="sub" id="headerSub">Načítám…</div>
</header>
<main>
  <div class="cards">
    <div class="card"><b id="total">0</b><span>Položek</span></div>
    <div class="card"><b id="confirmed">0</b><span>Potvrzeno</span></div>
    <div class="card"><b id="pending">0</b><span>Čeká</span></div>
    <div class="card"><b id="addCount">0</b><span>Přidat do slovníku</span></div>
    <div class="card"><b id="falseCount">0</b><span>False positive</span></div>
  </div>

  <div class="toolbar">
    <label>Kategorie:
      <select id="filterCategory"></select>
    </label>
    <label><input id="onlyPending" type="checkbox" checked> Jen nepotvrzené</label>
    <label>Hledat: <input id="search" type="text" placeholder="termín…"></label>
    <button id="confirmHigh">Potvrdit viditelné HIGH</button>
    <button id="saveReview" class="secondary">Uložit revizi</button>
    <button id="stopServer" class="danger">Uložit a ukončit server</button>
  </div>

  <div id="notice" class="notice"></div>

  <div class="layout">
    <section class="panel table-wrap">
      <table>
        <thead>
          <tr><th>OK</th><th>Termín</th><th>Kategorie</th><th>Rozhodnutí</th><th>Výskyty</th><th>Jistota</th></tr>
        </thead>
        <tbody id="rows"></tbody>
      </table>
    </section>

    <section class="panel detail">
      <h2 id="detailTitle">Vyber položku</h2>
      <div class="field"><label>Kanonický termín</label><input id="term" type="text"></div>
      <div class="field"><label>Kategorie</label><select id="category"></select></div>
      <div class="field"><label>Rozhodnutí</label><select id="decision"></select></div>
      <div class="field"><label>Cíl sloučení</label><input id="mergeTarget" type="text"></div>
      <div class="field"><label><input id="itemConfirmed" type="checkbox"> Položku jsem zkontroloval a potvrzuji</label></div>
      <div class="field"><label>Uživatelská poznámka</label><textarea id="note"></textarea></div>
      <div class="field"><label>Automatické zdůvodnění a kontext</label><div id="context" class="context"></div></div>
      <div class="actions">
        <button id="saveItem">Uložit položku</button>
        <button id="confirmNext" class="secondary">Uložit a další</button>
      </div>
      <p class="small">A23 nemění MM-REF-001 ani denní zápis. Ukládá pouze stav revize a návrh změn.</p>
    </section>
  </div>
</main>

<script>
const token = new URLSearchParams(location.search).get("token") || "";
let state = null;
let selectedId = null;

const $ = id => document.getElementById(id);
const api = path => `${path}?token=${encodeURIComponent(token)}`;

function notify(message, ok=true) {
  const el = $("notice");
  el.className = `notice ${ok ? "ok" : "err"}`;
  el.textContent = message;
  setTimeout(() => { el.className = "notice"; }, 3500);
}

async function request(path, options={}) {
  const response = await fetch(api(path), {
    headers: {"Content-Type":"application/json"},
    ...options
  });
  let payload = {};
  try { payload = await response.json(); } catch (_) {}
  if (!response.ok) throw new Error(payload.error || `HTTP ${response.status}`);
  return payload;
}

function fillSelect(el, values) {
  el.innerHTML = "";
  for (const value of values) {
    const opt = document.createElement("option");
    opt.value = value; opt.textContent = value;
    el.appendChild(opt);
  }
}

function filteredItems() {
  const category = $("filterCategory").value;
  const pending = $("onlyPending").checked;
  const search = $("search").value.trim().toLocaleLowerCase("cs");
  return state.items.filter(item => {
    if (category !== "ALL" && item.category !== category) return false;
    if (pending && item.confirmed) return false;
    if (search && !(
      item.canonical_term.toLocaleLowerCase("cs").includes(search) ||
      item.original_terms.join(" ").toLocaleLowerCase("cs").includes(search)
    )) return false;
    return true;
  });
}

function render() {
  const s = state.statistics;
  $("headerSub").textContent = `${state.document_id} | ${s.confirmed}/${s.total} potvrzeno`;
  $("total").textContent = s.total;
  $("confirmed").textContent = s.confirmed;
  $("pending").textContent = s.pending_confirmation;
  $("addCount").textContent = s.decision_counts.ADD_TO_GLOSSARY || 0;
  $("falseCount").textContent = s.decision_counts.REJECT_FALSE_POSITIVE || 0;

  const rows = $("rows");
  rows.innerHTML = "";
  for (const item of filteredItems()) {
    const tr = document.createElement("tr");
    if (item.item_id === selectedId) tr.classList.add("selected");
    tr.innerHTML = `
      <td>${item.confirmed ? "ANO" : "NE"}</td>
      <td>${escapeHtml(item.canonical_term)}</td>
      <td><span class="badge ${item.category}">${item.category}</span></td>
      <td>${item.decision}</td>
      <td>${item.occurrences_verified}</td>
      <td>${item.confidence}</td>`;
    tr.onclick = () => selectItem(item.item_id);
    rows.appendChild(tr);
  }
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, ch => ({
    "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"
  })[ch]);
}

function selectItem(id) {
  selectedId = id;
  const item = state.items.find(x => x.item_id === id);
  if (!item) return;
  $("detailTitle").textContent = item.canonical_term;
  $("term").value = item.canonical_term;
  $("category").value = item.category;
  $("decision").value = item.decision;
  $("mergeTarget").value = item.merge_target || "";
  $("itemConfirmed").checked = !!item.confirmed;
  $("note").value = item.user_note || "";
  $("context").textContent =
    `Jistota: ${item.confidence}\n` +
    `Navržené rozhodnutí: ${item.suggested_decision}\n` +
    `Důvod: ${item.reason}\n` +
    `Původní tvary: ${item.original_terms.join(" | ")}\n` +
    `Reportované výskyty: ${item.occurrences_reported}\n` +
    `Ověřené výskyty: ${item.occurrences_verified}\n\n` +
    `Kontexty:\n- ${item.contexts.join("\n- ")}`;
  render();
}

async function loadState() {
  state = await request("/api/state");
  fillSelect($("filterCategory"), ["ALL", ...state.categories]);
  fillSelect($("category"), state.categories);
  fillSelect($("decision"), state.decisions);
  render();
  const first = filteredItems()[0];
  if (first) selectItem(first.item_id);
}

async function saveSelected(goNext=false) {
  if (!selectedId) return notify("Nejprve vyber položku.", false);
  const payload = {
    item_id: selectedId,
    canonical_term: $("term").value.trim(),
    category: $("category").value,
    decision: $("decision").value,
    merge_target: $("mergeTarget").value.trim(),
    confirmed: $("itemConfirmed").checked,
    user_note: $("note").value.trim()
  };
  const oldList = filteredItems().map(x => x.item_id);
  const oldIndex = oldList.indexOf(selectedId);
  state = await request("/api/item", {
    method:"POST", body:JSON.stringify(payload)
  });
  notify("Položka byla uložena.");
  render();
  if (goNext) {
    const nextList = filteredItems();
    const next = nextList[Math.min(Math.max(oldIndex,0), nextList.length-1)];
    if (next) selectItem(next.item_id);
  } else {
    selectItem(selectedId);
  }
}

$("filterCategory").onchange = render;
$("onlyPending").onchange = render;
$("search").oninput = render;
$("saveItem").onclick = () => saveSelected(false);
$("confirmNext").onclick = () => saveSelected(true);

$("confirmHigh").onclick = async () => {
  const visibleIds = filteredItems()
    .filter(x => x.confidence === "HIGH")
    .map(x => x.item_id);
  if (!visibleIds.length) return notify("Žádné viditelné HIGH položky.");
  if (!confirm(`Potvrdit ${visibleIds.length} viditelných HIGH položek?`)) return;
  state = await request("/api/bulk-confirm", {
    method:"POST", body:JSON.stringify({item_ids:visibleIds})
  });
  notify("Viditelné HIGH položky byly potvrzeny.");
  render();
};

$("saveReview").onclick = async () => {
  const result = await request("/api/save", {method:"POST", body:"{}"});
  state = result.state;
  notify(`Revize uložena: ${result.status}`);
  render();
};

$("stopServer").onclick = async () => {
  if (!confirm("Uložit revizi a ukončit webový server A23?")) return;
  const result = await request("/api/shutdown", {method:"POST", body:"{}"});
  document.body.innerHTML = `<main><div class="panel" style="padding:30px;margin-top:50px">
    <h1>Revize byla uložena</h1><p>${escapeHtml(result.status)}</p>
    <p>Server A23 se ukončuje. Toto okno můžeš zavřít.</p></div></main>`;
};

loadState().catch(err => notify(err.message, false));
</script>
</body>
</html>
"""


class WebReviewState:
    def __init__(
        self,
        package: ReviewPackage,
        output_dir: Path,
        token: str,
    ) -> None:
        self.package = package
        self.output_dir = output_dir
        self.token = token
        self.lock = threading.RLock()

    def payload(self) -> dict[str, Any]:
        with self.lock:
            payload = package_payload(
                self.package,
                (
                    "TERMINOLOGY_CANDIDATE_REVIEW_CONFIRMED"
                    if counts(self.package.items)[
                        "pending_confirmation"
                    ] == 0
                    else "TERMINOLOGY_CANDIDATE_REVIEW_PENDING"
                ),
            )
            payload["categories"] = list(CATEGORIES)
            payload["decisions"] = list(DECISIONS)
            return payload

    def item_by_id(self, item_id_value: str) -> CandidateItem:
        for item in self.package.items:
            if item.item_id == item_id_value:
                return item
        raise KeyError(item_id_value)

    def update_item(self, data: Mapping[str, Any]) -> None:
        with self.lock:
            item = self.item_by_id(str(data.get("item_id") or ""))
            term = str(data.get("canonical_term") or "").strip()
            category = str(data.get("category") or "")
            decision = str(data.get("decision") or "")
            merge_target = str(data.get("merge_target") or "").strip()

            if not term:
                raise ValueError(
                    "Kanonický termín nesmí být prázdný."
                )
            if category not in CATEGORIES:
                raise ValueError("Neplatná kategorie.")
            if decision not in DECISIONS:
                raise ValueError("Neplatné rozhodnutí.")
            if (
                decision == "MERGE_WITH_EXISTING"
                and not merge_target
            ):
                raise ValueError(
                    "Pro MERGE_WITH_EXISTING je nutný cíl sloučení."
                )

            item.canonical_term = term
            item.normalized_term = normalize_term(term)
            item.category = category
            item.decision = decision
            item.merge_target = merge_target
            item.confirmed = bool(data.get("confirmed"))
            item.user_note = str(data.get("user_note") or "").strip()
            item.validate()
            write_review_outputs(
                self.output_dir,
                self.package,
                write_history=False,
            )

    def bulk_confirm(self, item_ids: Sequence[str]) -> None:
        allowed = set(item_ids)
        with self.lock:
            for item in self.package.items:
                if (
                    item.item_id in allowed
                    and item.confidence == "HIGH"
                ):
                    item.confirmed = True
            write_review_outputs(
                self.output_dir,
                self.package,
                write_history=False,
            )

    def save(self, *, history: bool) -> str:
        with self.lock:
            return write_review_outputs(
                self.output_dir,
                self.package,
                write_history=history,
            )


def create_web_server(
    package: ReviewPackage,
    output_dir: Path,
    *,
    host: str,
    port: int,
    token: str,
) -> tuple[ThreadingHTTPServer, WebReviewState]:
    state = WebReviewState(package, output_dir, token)

    class Handler(BaseHTTPRequestHandler):
        server_version = "MatchMatrixA23/1.1"

        def log_message(
            self,
            format_value: str,
            *args: object,
        ) -> None:
            print(
                "WEB "
                + self.address_string()
                + " "
                + (format_value % args),
                flush=True,
            )

        def token_ok(self) -> bool:
            query = urllib.parse.parse_qs(
                urllib.parse.urlsplit(self.path).query
            )
            return query.get("token", [""])[0] == state.token

        def send_json(
            self,
            payload: Mapping[str, Any],
            status: int = HTTPStatus.OK,
        ) -> None:
            body = json.dumps(
                payload,
                ensure_ascii=False,
            ).encode("utf-8")
            self.send_response(status)
            self.send_header(
                "Content-Type",
                "application/json; charset=utf-8",
            )
            self.send_header(
                "Cache-Control",
                "no-store",
            )
            self.send_header(
                "Content-Length",
                str(len(body)),
            )
            self.end_headers()
            self.wfile.write(body)

        def send_html(self, body_text: str) -> None:
            body = body_text.encode("utf-8")
            self.send_response(HTTPStatus.OK)
            self.send_header(
                "Content-Type",
                "text/html; charset=utf-8",
            )
            self.send_header(
                "Cache-Control",
                "no-store",
            )
            self.send_header(
                "Content-Length",
                str(len(body)),
            )
            self.end_headers()
            self.wfile.write(body)

        def read_json_body(self) -> dict[str, Any]:
            length = int(self.headers.get("Content-Length", "0"))
            if length > 2_000_000:
                raise ValueError("Požadavek je příliš velký.")
            raw = self.rfile.read(length)
            if not raw:
                return {}
            payload = json.loads(raw.decode("utf-8"))
            if not isinstance(payload, dict):
                raise ValueError("JSON body musí být objekt.")
            return payload

        def require_token(self) -> bool:
            if self.token_ok():
                return True
            self.send_json(
                {"error": "Neplatný nebo chybějící web token."},
                HTTPStatus.FORBIDDEN,
            )
            return False

        def do_GET(self) -> None:
            path = urllib.parse.urlsplit(self.path).path
            if not self.require_token():
                return
            if path == "/":
                self.send_html(WEB_HTML)
                return
            if path == "/api/state":
                self.send_json(state.payload())
                return
            if path == "/health":
                self.send_json(
                    {
                        "status": "READY",
                        "document_id": package.document_id,
                        "engine": ENGINE_VERSION,
                    }
                )
                return
            self.send_json(
                {"error": "Nenalezeno."},
                HTTPStatus.NOT_FOUND,
            )

        def do_POST(self) -> None:
            path = urllib.parse.urlsplit(self.path).path
            if not self.require_token():
                return
            try:
                data = self.read_json_body()
                if path == "/api/item":
                    state.update_item(data)
                    self.send_json(state.payload())
                    return
                if path == "/api/bulk-confirm":
                    values = data.get("item_ids")
                    if not isinstance(values, list):
                        raise ValueError(
                            "item_ids musí být seznam."
                        )
                    state.bulk_confirm(
                        [str(value) for value in values]
                    )
                    self.send_json(state.payload())
                    return
                if path == "/api/save":
                    status_value = state.save(history=True)
                    self.send_json(
                        {
                            "status": status_value,
                            "state": state.payload(),
                        }
                    )
                    return
                if path == "/api/shutdown":
                    status_value = state.save(history=True)
                    self.send_json(
                        {"status": status_value}
                    )
                    threading.Thread(
                        target=self.server.shutdown,
                        daemon=True,
                    ).start()
                    return
                self.send_json(
                    {"error": "Nenalezeno."},
                    HTTPStatus.NOT_FOUND,
                )
            except KeyError:
                self.send_json(
                    {"error": "Položka nebyla nalezena."},
                    HTTPStatus.NOT_FOUND,
                )
            except (ValueError, json.JSONDecodeError) as exc:
                self.send_json(
                    {"error": str(exc)},
                    HTTPStatus.BAD_REQUEST,
                )
            except Exception as exc:
                self.send_json(
                    {
                        "error": (
                            f"{type(exc).__name__}: {exc}"
                        )
                    },
                    HTTPStatus.INTERNAL_SERVER_ERROR,
                )

    server = ThreadingHTTPServer((host, port), Handler)
    server.daemon_threads = True
    return server, state


def run_web(
    package: ReviewPackage,
    output_dir: Path,
    *,
    host: str,
    port: int,
    token: str | None,
) -> str:
    if not (0 <= port <= 65535):
        raise ValueError("Port musí být v rozsahu 0 až 65535.")
    access_token = token or secrets.token_urlsafe(18)
    server, state = create_web_server(
        package,
        output_dir,
        host=host,
        port=port,
        token=access_token,
    )
    actual_port = int(server.server_address[1])
    lan_ip = detect_lan_ip()
    quoted = urllib.parse.quote(access_token, safe="")

    if host in {"0.0.0.0", "::"}:
        browser_host = lan_ip
    elif host in {"127.0.0.1", "localhost"}:
        browser_host = "127.0.0.1"
    else:
        browser_host = host

    url = (
        f"http://{browser_host}:{actual_port}/"
        f"?token={quoted}"
    )
    print()
    print("WEBOVÝ PANEL")
    print("-" * 79)
    print(f"LISTEN ADDRESS     : {host}:{actual_port}")
    print(f"OPEN ON PC1        : {url}")
    print("AUTOSAVE           : ENABLED")
    print("ACCESS TOKEN       : REQUIRED")
    print(
        "STOP               : tlačítko v panelu nebo Ctrl+C"
    )
    print(
        "FINAL STATUS       : "
        "TERMINOLOGY_WEB_REVIEW_RUNNING"
    )
    print(flush=True)

    try:
        server.serve_forever(poll_interval=0.25)
    except KeyboardInterrupt:
        print("\nWebový panel ukončen přes Ctrl+C.", flush=True)
    finally:
        server.server_close()

    return state.save(history=True)


def run_gui(
    package: ReviewPackage,
    output_dir: Path,
) -> str:
    import tkinter as tk
    from tkinter import messagebox, ttk

    class ReviewApp:
        def __init__(self, root: tk.Tk) -> None:
            self.root = root
            self.root.title(
                f"MatchMatrix A23 – {package.document_id}"
            )
            self.root.geometry("1500x880")
            self.filtered_ids: list[str] = []
            self.item_by_id = {
                item.item_id: item for item in package.items
            }

            top = ttk.Frame(root, padding=8)
            top.pack(fill="x")

            self.status_var = tk.StringVar()
            ttk.Label(
                top,
                textvariable=self.status_var,
                font=("Segoe UI", 11, "bold"),
            ).pack(side="left")

            ttk.Label(top, text="Kategorie:").pack(
                side="left", padx=(25, 4)
            )
            self.filter_category = tk.StringVar(value="ALL")
            category_box = ttk.Combobox(
                top,
                textvariable=self.filter_category,
                values=("ALL", *CATEGORIES),
                state="readonly",
                width=25,
            )
            category_box.pack(side="left")
            category_box.bind(
                "<<ComboboxSelected>>",
                lambda _event: self.refresh_tree(),
            )

            self.only_pending = tk.BooleanVar(value=True)
            ttk.Checkbutton(
                top,
                text="Jen nepotvrzené",
                variable=self.only_pending,
                command=self.refresh_tree,
            ).pack(side="left", padx=12)

            main = ttk.Panedwindow(root, orient="horizontal")
            main.pack(fill="both", expand=True, padx=8, pady=4)

            left = ttk.Frame(main)
            right = ttk.Frame(main, padding=(10, 0, 0, 0))
            main.add(left, weight=3)
            main.add(right, weight=2)

            columns = (
                "ok",
                "term",
                "category",
                "decision",
                "verified",
                "confidence",
            )
            self.tree = ttk.Treeview(
                left,
                columns=columns,
                show="headings",
                selectmode="browse",
            )
            headings = {
                "ok": "OK",
                "term": "Kanonický termín",
                "category": "Kategorie",
                "decision": "Rozhodnutí",
                "verified": "Výskyty",
                "confidence": "Jistota",
            }
            widths = {
                "ok": 45,
                "term": 290,
                "category": 190,
                "decision": 190,
                "verified": 70,
                "confidence": 75,
            }
            for key in columns:
                self.tree.heading(key, text=headings[key])
                self.tree.column(
                    key,
                    width=widths[key],
                    anchor="w" if key not in {"ok", "verified"} else "center",
                )
            scroll = ttk.Scrollbar(
                left,
                orient="vertical",
                command=self.tree.yview,
            )
            self.tree.configure(yscrollcommand=scroll.set)
            self.tree.pack(
                side="left", fill="both", expand=True
            )
            scroll.pack(side="right", fill="y")
            self.tree.bind(
                "<<TreeviewSelect>>",
                self.on_select,
            )

            form = ttk.Frame(right)
            form.pack(fill="x")

            ttk.Label(form, text="Kanonický termín").grid(
                row=0, column=0, sticky="w"
            )
            self.term_var = tk.StringVar()
            ttk.Entry(
                form,
                textvariable=self.term_var,
                width=55,
            ).grid(
                row=1,
                column=0,
                columnspan=2,
                sticky="ew",
                pady=(0, 8),
            )

            ttk.Label(form, text="Kategorie").grid(
                row=2, column=0, sticky="w"
            )
            ttk.Label(form, text="Rozhodnutí").grid(
                row=2, column=1, sticky="w"
            )
            self.category_var = tk.StringVar()
            self.decision_var = tk.StringVar()
            ttk.Combobox(
                form,
                textvariable=self.category_var,
                values=CATEGORIES,
                state="readonly",
                width=25,
            ).grid(row=3, column=0, sticky="ew", padx=(0, 5))
            ttk.Combobox(
                form,
                textvariable=self.decision_var,
                values=DECISIONS,
                state="readonly",
                width=28,
            ).grid(row=3, column=1, sticky="ew")

            ttk.Label(form, text="Cíl sloučení").grid(
                row=4, column=0, sticky="w", pady=(8, 0)
            )
            self.merge_var = tk.StringVar()
            ttk.Entry(
                form,
                textvariable=self.merge_var,
            ).grid(
                row=5,
                column=0,
                columnspan=2,
                sticky="ew",
            )

            self.confirmed_var = tk.BooleanVar()
            ttk.Checkbutton(
                form,
                text="Položku jsem zkontroloval a potvrzuji",
                variable=self.confirmed_var,
            ).grid(
                row=6,
                column=0,
                columnspan=2,
                sticky="w",
                pady=10,
            )

            ttk.Label(form, text="Uživatelská poznámka").grid(
                row=7, column=0, sticky="w"
            )
            self.note = tk.Text(
                form,
                height=4,
                wrap="word",
            )
            self.note.grid(
                row=8,
                column=0,
                columnspan=2,
                sticky="nsew",
            )

            ttk.Label(
                form,
                text="Automatické zdůvodnění a kontext",
            ).grid(
                row=9,
                column=0,
                sticky="w",
                pady=(10, 0),
            )
            self.context = tk.Text(
                form,
                height=18,
                wrap="word",
                state="disabled",
            )
            self.context.grid(
                row=10,
                column=0,
                columnspan=2,
                sticky="nsew",
            )
            form.columnconfigure(0, weight=1)
            form.columnconfigure(1, weight=1)
            form.rowconfigure(10, weight=1)

            buttons = ttk.Frame(right)
            buttons.pack(fill="x", pady=10)
            ttk.Button(
                buttons,
                text="Uložit položku",
                command=self.save_selected,
            ).pack(side="left")
            ttk.Button(
                buttons,
                text="Potvrdit viditelné HIGH",
                command=self.confirm_visible_high,
            ).pack(side="left", padx=6)
            ttk.Button(
                buttons,
                text="Uložit revizi",
                command=self.save_all,
            ).pack(side="left")
            ttk.Button(
                buttons,
                text="Uložit a zavřít",
                command=self.save_and_close,
            ).pack(side="right")

            self.current_id: str | None = None
            self.refresh_tree()
            self.update_status()
            self.root.protocol(
                "WM_DELETE_WINDOW",
                self.save_and_close,
            )

        def visible_items(self) -> list[CandidateItem]:
            category = self.filter_category.get()
            return [
                item
                for item in package.items
                if (
                    category == "ALL"
                    or item.category == category
                )
                and (
                    not self.only_pending.get()
                    or not item.confirmed
                )
            ]

        def refresh_tree(self) -> None:
            selected = self.current_id
            for iid in self.tree.get_children():
                self.tree.delete(iid)
            self.filtered_ids = []
            for item in self.visible_items():
                self.filtered_ids.append(item.item_id)
                self.tree.insert(
                    "",
                    "end",
                    iid=item.item_id,
                    values=(
                        "ANO" if item.confirmed else "NE",
                        item.canonical_term,
                        item.category,
                        item.decision,
                        item.occurrences_verified,
                        item.confidence,
                    ),
                )
            if selected and self.tree.exists(selected):
                self.tree.selection_set(selected)
                self.tree.focus(selected)

        def on_select(self, _event: object = None) -> None:
            selection = self.tree.selection()
            if not selection:
                return
            self.load_item(selection[0])

        def load_item(self, iid: str) -> None:
            item = self.item_by_id[iid]
            self.current_id = iid
            self.term_var.set(item.canonical_term)
            self.category_var.set(item.category)
            self.decision_var.set(item.decision)
            self.merge_var.set(item.merge_target)
            self.confirmed_var.set(item.confirmed)
            self.note.delete("1.0", "end")
            self.note.insert("1.0", item.user_note)
            details = [
                f"Jistota: {item.confidence}",
                f"Navržené rozhodnutí: "
                f"{item.suggested_decision}",
                f"Důvod: {item.reason}",
                f"Původní tvary: "
                f"{' | '.join(item.original_terms)}",
                f"Reportované výskyty: "
                f"{item.occurrences_reported}",
                f"Ověřené samostatné výskyty: "
                f"{item.occurrences_verified}",
                "",
                "Kontexty:",
                *[
                    f"- {context}"
                    for context in item.contexts
                ],
            ]
            self.context.configure(state="normal")
            self.context.delete("1.0", "end")
            self.context.insert("1.0", "\n".join(details))
            self.context.configure(state="disabled")

        def save_selected(self) -> bool:
            if not self.current_id:
                return True
            item = self.item_by_id[self.current_id]
            term = self.term_var.get().strip()
            category = self.category_var.get()
            decision = self.decision_var.get()
            merge_target = self.merge_var.get().strip()
            if not term:
                messagebox.showerror(
                    "A23",
                    "Kanonický termín nesmí být prázdný.",
                )
                return False
            if category not in CATEGORIES:
                messagebox.showerror(
                    "A23", "Vyber platnou kategorii."
                )
                return False
            if decision not in DECISIONS:
                messagebox.showerror(
                    "A23", "Vyber platné rozhodnutí."
                )
                return False
            if (
                decision == "MERGE_WITH_EXISTING"
                and not merge_target
            ):
                messagebox.showerror(
                    "A23",
                    "Pro sloučení je nutný cílový termín.",
                )
                return False
            item.canonical_term = term
            item.normalized_term = normalize_term(term)
            item.category = category
            item.decision = decision
            item.merge_target = merge_target
            item.confirmed = self.confirmed_var.get()
            item.user_note = self.note.get(
                "1.0", "end"
            ).strip()
            item.validate()
            self.refresh_tree()
            self.update_status()
            return True

        def confirm_visible_high(self) -> None:
            if not messagebox.askyesno(
                "A23",
                "Potvrdit všechny právě viditelné položky "
                "s jistotou HIGH podle automatického návrhu?",
            ):
                return
            for item in self.visible_items():
                if item.confidence == "HIGH":
                    item.confirmed = True
            self.refresh_tree()
            self.update_status()

        def save_all(self) -> None:
            if not self.save_selected():
                return
            status = write_review_outputs(
                output_dir,
                package,
            )
            self.update_status()
            messagebox.showinfo(
                "A23",
                f"Revize byla uložena.\n\n{status}",
            )

        def save_and_close(self) -> None:
            if not self.save_selected():
                return
            write_review_outputs(output_dir, package)
            self.root.destroy()

        def update_status(self) -> None:
            stats = counts(package.items)
            self.status_var.set(
                f"Položek: {stats['total']} | "
                f"Potvrzeno: {stats['confirmed']} | "
                f"Čeká: {stats['pending_confirmation']}"
            )

    root = tk.Tk()
    app = ReviewApp(root)
    root.mainloop()
    return write_review_outputs(output_dir, package)


def main() -> int:
    args = parse_args()
    root = project_root()
    report_path = discover_report(root, args.report)
    output_dir = resolve_output(root, args.output_dir)

    print("MATCHMATRIX TERMINOLOGY CANDIDATE REVIEW")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"A22 REPORT         : {report_path}")
    print(f"OUTPUT DIR         : {output_dir}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("GLOSSARY WRITES    : DISABLED")
    print("DOCUMENT WRITES    : DISABLED")
    print("DATABASE WRITES    : DISABLED")
    print()

    try:
        package = build_package(
            report_path=report_path,
            root=root,
        )
        stats = counts(package.items)
        raw_payload = read_json(report_path)
        raw_count = len(raw_payload.get("candidate_terms", []))

        print("VSTUP A PŘEDKLASIFIKACE")
        print("-" * 79)
        print(f"DOCUMENT ID        : {package.document_id}")
        print(f"RAW CANDIDATES     : {raw_count}")
        print(f"CLEANED ITEMS      : {stats['total']}")
        print(
            f"REMOVED/MERGED     : "
            f"{max(0, raw_count - stats['total'])}"
        )
        for category in CATEGORIES:
            print(
                f"{category:<20}: "
                f"{stats['category_counts'][category]}"
            )
        print("SOURCE VERIFIED    : True")
        print("GLOSSARY VERIFIED  : True")
        print("SOURCE MODIFIED    : False")
        print("GLOSSARY MODIFIED  : False")
        print("DATABASE MODIFIED  : False")
        print()

        if args.validate_only:
            print("VALIDACE")
            print("-" * 79)
            print("A22 CONTRACT       : VALID")
            print("DOCUMENT INPUT     : VALID")
            print("GLOSSARY INPUT     : VALID")
            print("CLASSIFIER         : READY")
            print("GUI REVIEW         : READY")
            print("WEB REVIEW         : READY")
            print(
                "FINAL STATUS       : "
                "TERMINOLOGY_CANDIDATE_REVIEW_VALIDATED"
            )
            return 0

        write_auto_outputs(output_dir, package)
        review_state = (
            output_dir
            / f"{package.document_id}_"
            "TERMINOLOGY_REVIEW_STATE.json"
        )
        resumed = False
        if not args.new_review:
            resumed = load_review_state(
                review_state,
                package,
            )

        print("VÝSTUP PŘEDKLASIFIKACE")
        print("-" * 79)
        print(
            f"AUTO JSON          : "
            f"{output_dir / (package.document_id + '_TERMINOLOGY_AUTO_CLASSIFICATION.json')}"
        )
        print(
            f"REVIEW RESUMED     : {resumed}"
        )

        if args.auto_only and args.web:
            raise RuntimeError(
                "--auto-only a --web nelze použít současně."
            )

        if args.auto_only:
            status = write_review_outputs(
                output_dir,
                package,
            )
        elif args.web:
            status = run_web(
                package,
                output_dir,
                host=args.host,
                port=args.port,
                token=args.web_token,
            )
        else:
            status = run_gui(package, output_dir)

        final_stats = counts(package.items)
        print()
        print("VÝSLEDEK REVIZE")
        print("-" * 79)
        print(
            f"CONFIRMED          : "
            f"{final_stats['confirmed']}"
        )
        print(
            f"PENDING            : "
            f"{final_stats['pending_confirmation']}"
        )
        print(
            f"ADD TO GLOSSARY    : "
            f"{final_stats['decision_counts']['ADD_TO_GLOSSARY']}"
        )
        print(
            f"MERGE              : "
            f"{final_stats['decision_counts']['MERGE_WITH_EXISTING']}"
        )
        print(
            f"FALSE POSITIVE     : "
            f"{final_stats['decision_counts']['REJECT_FALSE_POSITIVE']}"
        )
        print("GLOSSARY MODIFIED  : False")
        print("DOCUMENT MODIFIED  : False")
        print("DATABASE MODIFIED  : False")
        print(f"FINAL STATUS       : {status}")
        return 0

    except Exception as exc:
        print("TERMINOLOGY CANDIDATE REVIEW ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("GLOSSARY MODIFIED  : False")
        print("DOCUMENT MODIFIED  : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "TERMINOLOGY_CANDIDATE_REVIEW_BLOCKED"
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
