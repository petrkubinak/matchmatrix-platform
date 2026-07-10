#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Vytváří bezpečný standardizační návrh existujícího denního zápisu nebo
navazovacího dokumentu a připravuje přesný mapovací kontrakt pro ruční
kontrolu v MatchMatrix Control Panelu.

K ČEMU:
- načte audit A17 a původní dokument,
- ověří SHA-256 původního dokumentu,
- rozdělí dokument na dohledatelné zdrojové bloky,
- upřednostňuje jednoznačné nadpisy a celé kapitoly před technickými signály uvnitř textu,
- slučuje odstavce a kódové bloky stejné kapitoly do jednoho mapovacího celku,
- u každého bloku vypočítá kandidátní kapitoly, skóre, jistotu a důvody,
- vytvoří standardizovaný návrh bez přepsání původního souboru,
- vytvoří unified diff,
- vytvoří mapovací report,
- vytvoří panelový JSON/CSV kontrakt pro potvrzení nebo přesun bloků,
- bezpečně oddělí připravenost mapování od finálního schválení dokumentu.

KDE:
tools/documentation/25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py

JAK:
Výchozí audit A17:
    py -3.14 .\\tools\\documentation\\25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py

Explicitní audit:
    py -3.14 .\\tools\\documentation\\25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py `
      --audit reports\\documentation\\standardization\\document_compliance_audit_latest.json

Volitelná metadata:
    --document-id "MM-HIS-123"
    --title "MATCHMATRIX – DENNÍ ZÁPIS – 2026-06-30"
    --version "1.0"
    --date "2026-06-30"
    --author "Jméno"
    --working-area "Dokumentace"

Volitelné prahy:
    --minimum-mapping-coverage 70
    --automatic-accept-score 78
    --high-confidence-score 82
    --medium-confidence-score 58

BEZPEČNOST:
- původní dokument se nikdy nepřepisuje,
- databáze se nemění,
- při změně SHA-256 od auditu A17 se běh zablokuje,
- slabé nebo nejednoznačné mapování se zařadí do ruční fronty,
- neověřená fakta se nevymýšlejí,
- finální schválení je zakázáno, dokud existují ruční bloky nebo placeholdery.

PODPOROVANÉ TYPY:
- DAILY_LOG
- CHAT_CONTINUATION

VÝSTUP:
reports/documentation/standardization/proposals/
- document_standardization_proposal_YYYYMMDD_HHMMSS.md
- document_standardization_diff_YYYYMMDD_HHMMSS.diff
- document_standardization_mapping_YYYYMMDD_HHMMSS.json
- document_standardization_mapping_YYYYMMDD_HHMMSS.md
- document_standardization_panel_mapping_YYYYMMDD_HHMMSS.json
- document_standardization_panel_mapping_YYYYMMDD_HHMMSS.csv
- document_standardization_panel_mapping_YYYYMMDD_HHMMSS.md
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
import unicodedata
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


AUDIT_DEFAULT = Path(
    "reports/documentation/standardization/document_compliance_audit_latest.json"
)
OUTPUT_DEFAULT = Path("reports/documentation/standardization/proposals")
SUPPORTED_TYPES = {"DAILY_LOG", "CHAT_CONTINUATION"}
ENGINE_VERSION = "A18_CONTEXTUAL_MAPPING_V3_SECTION_FIRST"
PANEL_CONTRACT_VERSION = "1.0"

DOCUMENT_ID_RE = re.compile(
    r"\bMM-[A-Z]{2,10}-(?:20\d{6}(?:-\d{1,3})?|\d{3,4}[A-Z]?)\b"
)
VERSION_RE = re.compile(r"\b(?:v|verze\s*)?(\d+\.\d+)\b", re.IGNORECASE)
DATE_RE = re.compile(
    r"\b("
    r"20\d{2}[-./]\d{1,2}[-./]\d{1,2}"
    r"|"
    r"\d{1,2}[.\-/]\d{1,2}[.\-/]20\d{2}"
    r")\b"
)
HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$")
MARKDOWN_HEADING_WITH_LEVEL_RE = re.compile(
    r"^\s{0,3}(#{1,6})\s+(.+?)\s*$"
)
HEADING_PREFIX_RE = re.compile(
    r"^\s*(?:"
    r"\d{1,3}(?:\.\d{1,3})*[.)-]?|"
    r"[A-ZÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ][.)-]|"
    r"[IVXLCDM]{1,8}[.)-]"
    r")\s+",
    re.IGNORECASE,
)
NUMBERED_HEADING_RE = re.compile(
    r"^\s*(?:"
    r"\d{1,3}(?:\.\d{1,3})*[.)-]?|"
    r"[A-ZÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ][.)-]|"
    r"[IVXLCDM]{1,8}[.)-]"
    r")\s+(.+?)\s*$",
    re.IGNORECASE,
)
LABEL_ONLY_RE = re.compile(r"^\s*([^:]{2,120}):\s*$")
SEPARATOR_RE = re.compile(r"^\s*[-=_–—*]{3,}\s*$")
BULLET_RE = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+")
PATH_RE = re.compile(
    r"(?:[A-Za-z]:\\[^\n`|]+|\\\\[^\n`|]+|"
    r"(?:docs|db|tools|workers|reports)/[^\s`|]+)",
    re.IGNORECASE,
)
COMMAND_RE = re.compile(
    r"\b(?:py(?:thon)?|git|psql|powershell|select|insert|update|delete|"
    r"create|alter|drop|commit|rollback)\b",
    re.IGNORECASE,
)
STATUS_TOKEN_RE = re.compile(
    r"\b(?:READY|DONE|ERROR|BLOCKED|WARNING|IN_SYNC|PARTIAL|CRITICAL|"
    r"DOCUMENT_[A-Z0-9_]+|MATCHMATRIX_[A-Z0-9_]+)\b"
)
CODE_FENCE_RE = re.compile(r"^\s*```")


CATEGORY_CATALOG: dict[str, list[dict[str, Any]]] = {
    "DAILY_LOG": [
        {
            "code": "identification",
            "order": 1,
            "label_cs": "Identifikace denního zápisu",
            "heading_aliases": (
                "matchmatrix denni zapis",
                "informace o dokumentu",
                "identifikace",
                "identifikace zapisu",
                "identifikace denniho zapisu",
                "datum a identifikace",
            ),
            "keywords": (
                "datum", "cas", "autor", "projekt", "matchmatrix",
                "pracovni oblast", "pracovni vetev", "document id", "verze",
            ),
        },
        {
            "code": "initial_state",
            "order": 2,
            "label_cs": "Výchozí stav",
            "heading_aliases": (
                "vychozi stav", "stav na zacatku", "pocatecni stav",
                "kontext dne", "predchozi stav",
            ),
            "keywords": (
                "vychozi stav", "stav na zacatku", "pocatecni stav",
                "navazali jsme", "pred zahajenim", "kontext dne",
                "na zacatku", "pred praci", "predchozi stav",
            ),
        },
        {
            "code": "goal",
            "order": 3,
            "label_cs": "Cíl pracovního dne",
            "heading_aliases": (
                "cil", "cil dne", "cil prace", "cil pracovniho dne",
                "priorita dne", "plan dne",
            ),
            "keywords": (
                "cil dne", "cil prace", "dnesni cil", "zamer dne",
                "co chceme", "ukolem bylo", "cilem bylo", "priorita dne",
            ),
        },
        {
            "code": "work_done",
            "order": 4,
            "label_cs": "Provedené práce",
            "heading_aliases": (
                "provedene prace", "co jsme udelali", "co bylo provedeno",
                "prubeh prace", "realizovane kroky",
            ),
            "keywords": (
                "udelali", "vytvorili", "opravili", "doplnili", "nastavili",
                "implementovali", "spustili", "overili", "pripravili",
                "zmenili", "nasadili", "vyresili", "pridali", "odstranili",
                "upravili", "zavedli", "otestovali", "analyzovali",
                "provedli", "zpracovali", "nahrali", "importovali",
                "vygenerovali", "propojili", "aktualizovali",
            ),
        },
        {
            "code": "decisions",
            "order": 5,
            "label_cs": "Přijatá rozhodnutí",
            "heading_aliases": (
                "rozhodnuti", "prijata rozhodnuti", "dohodnuta pravidla",
            ),
            "keywords": (
                "rozhodli", "dohodli", "schvalili", "zvolili",
                "plati pravidlo", "stanovili", "potvrdili",
                "budeme pouzivat", "nebude se", "od ted",
            ),
        },
        {
            "code": "problems",
            "order": 6,
            "label_cs": "Problémy a jejich řešení",
            "heading_aliases": (
                "problemy", "problemy a jejich reseni", "chyby a reseni",
                "komplikace", "blokatory",
            ),
            "keywords": (
                "problem", "chyba", "nefung", "selhal", "blokator", "error",
                "warning", "404", "timeout", "kritick", "nedostatek",
                "riziko", "komplikace", "nepovedlo", "chybi", "nesedi",
                "konflikt", "opraveno tak", "reseni bylo",
            ),
        },
        {
            "code": "verified_outputs",
            "order": 7,
            "label_cs": "Ověřené výsledky a technické výstupy",
            "heading_aliases": (
                "overene vysledky", "technicke vystupy", "vysledky a overeni",
                "soubory a skripty", "kontrolni vystupy",
            ),
            "keywords": (
                "vysledek", "overeno", "ready", "done", "pocet", "radku",
                "vystup", "final status", "commit", "script", "skript", "sql",
                "report", "tabulka", "view", "soubor", "cesta", "hash",
                "sha-256", "return code", "status", "kpi", "db", "databaze",
            ),
        },
        {
            "code": "results",
            "order": 8,
            "label_cs": "Výsledky dne a stav na konci dne",
            "heading_aliases": (
                "vysledky dne", "stav na konci dne", "souhrn", "souhrn dne",
                "finalni stav",
            ),
            "keywords": (
                "vysledky dne", "stav na konci", "dokonceno", "hotovo",
                "rozpracovano", "odlozeno", "souhrn dne", "finalni stav",
                "na konci dne", "dnesni vysledek", "celkovy stav",
            ),
        },
        {
            "code": "continuation",
            "order": 9,
            "label_cs": "Plán pokračování",
            "heading_aliases": (
                "plan pokracovani", "co dale", "dalsi prace", "pokracovani",
            ),
            "keywords": (
                "budeme pokracovat", "zitra", "co dale", "dalsi prace",
                "navazeme", "pokracovani", "nasledne", "priste",
                "dale budeme", "v dalsim kroku", "dalsi etapa",
            ),
        },
        {
            "code": "next_step",
            "order": 10,
            "label_cs": "Jeden hlavní další krok",
            "heading_aliases": (
                "dalsi krok", "hlavni dalsi krok", "prvni dalsi krok",
                "next step",
            ),
            "keywords": (
                "hlavni dalsi krok", "prvni dalsi krok", "dalsi krok",
                "next step", "zacit tim", "navazat tim", "bezprostredni krok",
            ),
        },
        {
            "code": "links",
            "order": 11,
            "label_cs": "Vazby a NAVÁZÁNÍ",
            "heading_aliases": (
                "navazani", "vazby", "odkazy a vazby", "souvisejici dokumenty",
            ),
            "keywords": (
                "navazani", "navazujici dokument", "predchozi zapis",
                "git commit", "pouzite skripty", "vazby", "odkaz",
                "souvisi s", "predchozi dokument",
            ),
        },
    ],
    "CHAT_CONTINUATION": [
        {
            "code": "identification",
            "order": 1,
            "label_cs": "Identifikace navázání",
            "heading_aliases": (
                "matchmatrix navazani", "informace o dokumentu", "identifikace",
                "identifikace navazani",
            ),
            "keywords": (
                "identifikace", "datum", "projekt", "pracovni vetev",
                "navazani", "document id", "verze", "autor", "pracovni oblast",
            ),
        },
        {
            "code": "context",
            "order": 2,
            "label_cs": "Výchozí kontext",
            "heading_aliases": (
                "vychozi kontext", "kontext", "predchozi chat",
            ),
            "keywords": (
                "vychozi kontext", "kontext", "proc dokument vznikl",
                "predchozi chat", "na co navazuje", "predchozi prace",
                "vychozi situace",
            ),
        },
        {
            "code": "current_status",
            "order": 3,
            "label_cs": "CURRENT STATUS",
            "heading_aliases": (
                "current status", "aktualni stav", "soucasny stav",
                "stav projektu", "kde jsme",
            ),
            "keywords": (
                "current status", "aktualni stav", "soucasny stav",
                "stav projektu", "finalni stav", "stav nyni", "kde jsme",
            ),
        },
        {
            "code": "completed",
            "order": 4,
            "label_cs": "Co bylo dokončeno",
            "heading_aliases": (
                "co bylo dokonceno", "dokonceno", "hotove oblasti",
            ),
            "keywords": (
                "dokonceno", "co bylo dokonceno", "hotovo", "provedeno",
                "ready", "vytvoreno", "opraveno", "implementovano", "overeno",
            ),
        },
        {
            "code": "in_progress",
            "order": 5,
            "label_cs": "Co zůstává rozpracováno",
            "heading_aliases": (
                "co zustava rozpracovano", "rozpracovano", "nedokonceno",
            ),
            "keywords": (
                "rozpracovano", "co zustava", "in progress", "nedokonceno",
                "ceka na", "zbyva", "pokracuje", "neni hotovo",
            ),
        },
        {
            "code": "open_tasks",
            "order": 6,
            "label_cs": "OPEN QUESTIONS / otevřené úkoly",
            "heading_aliases": (
                "open questions", "otevrene ukoly", "otevrene otazky", "todo",
            ),
            "keywords": (
                "open questions", "otevrene ukoly", "otevrene otazky", "todo",
                "k vyreseni", "nezodpovezeno", "cekajici ukoly",
            ),
        },
        {
            "code": "risks",
            "order": 7,
            "label_cs": "Rizika a upozornění",
            "heading_aliases": (
                "rizika", "rizika a upozorneni", "blokatory", "upozorneni",
            ),
            "keywords": (
                "rizika", "upozorneni", "problem", "blokator", "pozor",
                "kriticke", "omezeni", "nebezpeci", "nesmi se",
            ),
        },
        {
            "code": "decisions",
            "order": 8,
            "label_cs": "Přijatá rozhodnutí a platná pravidla",
            "heading_aliases": (
                "rozhodnuti", "prijata rozhodnuti", "platna pravidla",
            ),
            "keywords": (
                "rozhodnuti", "prijata rozhodnuti", "dohodnuto", "plati",
                "schvaleno", "budeme pouzivat", "pravidlo", "od ted",
            ),
        },
        {
            "code": "sources",
            "order": 9,
            "label_cs": "Ověřené zdroje, soubory a příkazy",
            "heading_aliases": (
                "overene zdroje", "soubory a prikazy",
                "soubory skripty a prikazy", "technicke zdroje",
            ),
            "keywords": (
                "overene zdroje", "odkazy", "soubor", "skript", "sql",
                "report", "cesta", "prikaz", "git commit", "tabulka", "view",
                "vystup",
            ),
        },
        {
            "code": "ai_context",
            "order": 10,
            "label_cs": "AI CONTEXT",
            "heading_aliases": (
                "ai context", "pravidla pro ai", "kontext pro ai",
            ),
            "keywords": (
                "ai context", "pravidla pro ai", "kontext pro ai", "assistant",
                "chatgpt", "novy chat musi", "dodrzovat",
            ),
        },
        {
            "code": "project_snapshot",
            "order": 11,
            "label_cs": "PROJECT SNAPSHOT",
            "heading_aliases": (
                "project snapshot", "snapshot projektu", "projektovy snapshot",
            ),
            "keywords": (
                "project snapshot", "snapshot projektu", "projektovy snapshot",
                "stav vrstev", "stav projektu", "architektura",
            ),
        },
        {
            "code": "database_snapshot",
            "order": 12,
            "label_cs": "DATABASE SNAPSHOT",
            "heading_aliases": (
                "database snapshot", "databazovy snapshot", "stav databaze",
            ),
            "keywords": (
                "database snapshot", "databazovy snapshot", "stav databaze",
                "pocty", "tabulky", "radku", "importy",
            ),
        },
        {
            "code": "next_step",
            "order": 13,
            "label_cs": "NEXT STEP",
            "heading_aliases": (
                "next step", "dalsi krok", "prvni dalsi krok",
                "hlavni dalsi krok",
            ),
            "keywords": (
                "next step", "prvni dalsi krok", "hlavni dalsi krok",
                "navazat", "pokracovat", "zacit", "bezprostredni krok",
            ),
        },
    ],
}


HEADING_SEMANTIC_RULES: dict[str, tuple[tuple[str, tuple[str, ...]], ...]] = {
    "DAILY_LOG": (
        ("identification", (
            "informace o dokumentu", "identifikace", "historie verzi",
        )),
        ("initial_state", (
            "vychozi stav", "stav na zacatku", "pocatecni stav",
            "predchozi stav", "kontext dne",
        )),
        ("goal", (
            "cil pracovniho dne", "cil dne", "cil prace", "priorita dne",
        )),
        ("work_done", (
            "provedene prace", "co jsme udelali", "co bylo provedeno",
            "realizovane kroky", "prubeh prace", "dokoncene prace",
        )),
        ("decisions", (
            "prijata rozhodnuti", "rozhodnuti", "dohodnuta pravidla",
        )),
        ("problems", (
            "problemy a jejich reseni", "problemy", "chyby a reseni",
            "komplikace", "blokatory",
        )),
        ("verified_outputs", (
            "overene vysledky", "technicke vystupy", "kontrolni vystupy",
            "soubory a skripty", "overene soubory", "aktivni skripty",
        )),
        ("results", (
            "vysledky dne", "stav na konci dne", "souhrn dne",
            "finalni stav", "celkovy stav",
        )),
        ("continuation", (
            "plan pokracovani", "dalsi prace", "co dale", "pokracovani",
            "otevrene ukoly",
        )),
        ("next_step", (
            "jeden hlavni dalsi krok", "hlavni dalsi krok",
            "prvni dalsi krok", "next step", "presny dalsi krok",
        )),
        ("links", (
            "vazby a navazani", "souvisejici dokumenty", "odkazy a vazby",
        )),
    ),
    "CHAT_CONTINUATION": (
        ("identification", (
            "informace o dokumentu", "identifikace navazani", "identifikace",
            "historie verzi",
        )),
        ("context", (
            "ucel navazani", "nejdulezitejsi skutecnost", "vychozi kontext",
            "predchozi chat", "na co navazuje", "kontext",
        )),
        ("current_status", (
            "current status", "aktualni stav", "soucasny stav",
            "overeny soucasny stav", "stav projektu", "kde jsme",
            "overeny dokument", "git",
        )),
        ("completed", (
            "co bylo dokonceno", "dokonceno", "hotove oblasti",
            "provedene opravy", "dokoncene opravy", "opravy a overeni",
            "prirustkove vazby", "prirustkove overeni",
            "explicitni incremental rezim", "odstraneny syntaxwarning",
            "novy stav po selhani overeni", "historie skriptu",
        )),
        ("in_progress", (
            "co zustava rozpracovano", "rozpracovano", "nedokonceno",
            "dalsi technicky krok", "nasledujici hlavni etapa",
            "dalsi etapa", "plan pokracovani",
        )),
        ("open_tasks", (
            "open questions", "otevrene ukoly", "otevrene otazky", "todo",
        )),
        ("risks", (
            "rizika a upozorneni", "rizika", "upozorneni", "blokatory",
            "co se nesmi udelat", "co se nema znovu delat",
        )),
        ("decisions", (
            "prijata rozhodnuti a platna pravidla", "prijata rozhodnuti",
            "platna pravidla", "rozhodnuti",
        )),
        ("sources", (
            "overene zdroje soubory a prikazy", "overene zdroje",
            "soubory skripty a prikazy", "technicke zdroje",
            "aktivni skripty", "historicke verze", "dokumenty historie",
        )),
        ("ai_context", (
            "ai context", "pravidla pro ai", "kontext pro ai",
        )),
        ("project_snapshot", (
            "project snapshot", "snapshot projektu", "projektovy snapshot",
        )),
        ("database_snapshot", (
            "database snapshot", "databazovy snapshot", "stav databaze",
            "databaze",
        )),
        ("next_step", (
            "next step", "prvni krok noveho chatu", "prvni dalsi krok",
            "hlavni dalsi krok", "jeden hlavni dalsi krok",
        )),
    ),
}


ACTION_VERBS = (
    "udelali", "vytvorili", "opravili", "doplnili", "nastavili",
    "implementovali", "spustili", "overili", "pripravili", "zmenili",
    "nasadili", "vyresili", "pridali", "odstranili", "upravili",
    "zavedli", "otestovali", "analyzovali", "provedli", "zpracovali",
    "nahrali", "importovali", "vygenerovali", "propojili", "aktualizovali",
)
DECISION_VERBS = (
    "rozhodli", "dohodli", "schvalili", "zvolili", "stanovili",
    "potvrdili", "budeme pouzivat", "nebude se", "od ted",
)
PROBLEM_TOKENS = (
    "problem", "chyba", "nefung", "selhal", "blokator", "error",
    "warning", "404", "timeout", "kritick", "konflikt", "nesedi",
)
FUTURE_TOKENS = (
    "zitra", "priste", "budeme pokracovat", "dale budeme", "nasledne",
    "v dalsim kroku", "navazeme",
)
NEXT_STEP_TOKENS = (
    "dalsi krok", "prvni krok", "prvni dalsi krok", "hlavni dalsi krok",
    "next step", "zacit tim", "navazat tim",
)


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Vytvoří kontextový standardizační návrh a panelovou mapovací frontu."
        )
    )
    parser.add_argument(
        "--audit",
        help="Cesta k JSON auditu A17. Výchozí je latest report.",
    )
    parser.add_argument(
        "--output-dir",
        help="Volitelná výstupní složka návrhů.",
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
        "--minimum-mapping-coverage",
        type=float,
        default=70.0,
        help="Minimální procento zachyceného obsahu. Výchozí 70.",
    )
    parser.add_argument(
        "--automatic-accept-score",
        type=float,
        default=78.0,
        help="Minimální skóre pro automaticky přijatelné mapování. Výchozí 78.",
    )
    parser.add_argument(
        "--high-confidence-score",
        type=float,
        default=82.0,
        help="Spodní hranice HIGH. Výchozí 82.",
    )
    parser.add_argument(
        "--medium-confidence-score",
        type=float,
        default=55.0,
        help="Spodní hranice MEDIUM. Výchozí 55.",
    )
    return parser.parse_args()


def resolve_path(root: Path, value: str | None, default: Path) -> Path:
    path = Path(value) if value else default
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def read_text(path: Path) -> tuple[str, bytes]:
    raw = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-8", "cp1250", "latin-1"):
        try:
            return raw.decode(encoding), raw
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace"), raw


def sha256_bytes(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    no_marks = "".join(
        character
        for character in decomposed
        if not unicodedata.combining(character)
    )
    return re.sub(r"\s+", " ", no_marks.lower()).strip()


def clean_line(line: str) -> str:
    return line.strip().strip("\ufeff")


def category_items(document_type: str) -> list[dict[str, Any]]:
    return CATEGORY_CATALOG[document_type]


def category_by_code(document_type: str) -> dict[str, dict[str, Any]]:
    return {
        str(item["code"]): item
        for item in category_items(document_type)
    }


def category_order(document_type: str) -> dict[str, int]:
    return {
        str(item["code"]): int(item["order"])
        for item in category_items(document_type)
    }


def heading_alias_map(document_type: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for item in category_items(document_type):
        code = str(item["code"])
        for alias in item["heading_aliases"]:
            result[normalize(str(alias))] = code
    return result


def load_audit(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"Audit A17 nebyl nalezen: {path}")

    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError("Audit A17 musí být JSON objekt.")

    expected_status = "DOCUMENT_STANDARD_COMPLIANCE_AUDIT_READY"
    if payload.get("final_status") != expected_status:
        raise RuntimeError(
            "Audit A17 nemá očekávaný final_status "
            f"{expected_status}."
        )

    document_type = str(payload.get("document_type") or "")
    if document_type not in SUPPORTED_TYPES:
        raise RuntimeError(
            f"A18 podporuje pouze {sorted(SUPPORTED_TYPES)}; "
            f"audit obsahuje {document_type!r}."
        )

    document_path = str(payload.get("document_path") or "").strip()
    if not document_path:
        raise RuntimeError("Audit A17 neobsahuje document_path.")

    expected_hash = str(payload.get("document_hash_sha256") or "").strip()
    if not re.fullmatch(r"[0-9a-f]{64}", expected_hash):
        raise RuntimeError(
            "Audit A17 neobsahuje platný SHA-256 zdrojového dokumentu."
        )

    return payload


def clean_metadata_cell(value: str) -> str:
    cleaned = value.strip().strip("`").strip()
    cleaned = re.sub(r"^\*{1,2}|\*{1,2}$", "", cleaned).strip()
    return cleaned


def extract_metadata_table(text: str) -> dict[str, str]:
    metadata: dict[str, str] = {}
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not (line.startswith("|") and line.endswith("|")):
            continue
        cells = [clean_metadata_cell(cell) for cell in line.strip("|").split("|")]
        if len(cells) < 2:
            continue
        key, value = cells[0], cells[1]
        normalized_key = normalize_heading(key)
        if not normalized_key or normalized_key in {"polozka", "field"}:
            continue
        if re.fullmatch(r"[-: ]+", key) or re.fullmatch(r"[-: ]+", value):
            continue
        if value:
            metadata.setdefault(normalized_key, value)
    return metadata


def metadata_value(metadata: Mapping[str, str], *aliases: str) -> str | None:
    for alias in aliases:
        value = metadata.get(normalize_heading(alias))
        if value:
            return value
    return None


def count_placeholders(proposal: str) -> int:
    patterns = (
        r"\[DOPLNIT UŽIVATELEM[^\]]*\]",
        r">\s*\*\*DOPLNIT UŽIVATELEM:\*\*",
    )
    return sum(len(re.findall(pattern, proposal)) for pattern in patterns)


def first_title(text: str) -> str | None:
    for raw in text.splitlines():
        line = clean_line(raw)
        if not line:
            continue
        markdown = HEADING_RE.match(line)
        candidate = markdown.group(1).strip() if markdown else line.strip("=-–— ")
        if 3 <= len(candidate) <= 180:
            return candidate
    return None


def extract_first(regex: re.Pattern[str], text: str) -> str | None:
    match = regex.search(text)
    if not match:
        return None
    return match.group(1) if match.lastindex else match.group(0)


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
            continue
    return raw


def normalize_heading(value: str) -> str:
    normalized_value = normalize(value)
    return re.sub(r"[^a-z0-9]+", " ", normalized_value).strip()


def strip_heading_numbering(value: str) -> str:
    candidate = value.strip().strip("# ")
    return HEADING_PREFIX_RE.sub("", candidate, count=1).strip(" :-–—")


def exact_heading_category(
    candidate: str,
    document_type: str,
) -> str | None:
    cleaned_candidate = strip_heading_numbering(candidate)
    normalized_candidate = normalize_heading(cleaned_candidate)
    aliases = {
        normalize_heading(alias): code
        for alias, code in heading_alias_map(document_type).items()
    }
    exact = aliases.get(normalized_candidate)
    if exact:
        return exact

    for category, phrases in HEADING_SEMANTIC_RULES[document_type]:
        for phrase in phrases:
            normalized_phrase = normalize_heading(phrase)
            phrase_words = normalized_phrase.split()
            contained_phrase = (
                len(phrase_words) >= 2
                and len(normalized_candidate.split()) <= 14
                and normalized_phrase in normalized_candidate
            )
            if (
                normalized_candidate == normalized_phrase
                or normalized_candidate.startswith(normalized_phrase + " ")
                or contained_phrase
            ):
                return category

    if document_type == "CHAT_CONTINUATION":
        if (
            re.match(r"^(?:a6|a7|a24)\b", normalized_candidate)
            and len(normalized_candidate.split()) <= 12
            and not candidate.strip().endswith((".", "!", "?", ";"))
        ):
            return "completed"
        if normalized_candidate.startswith("prvni krok"):
            return "next_step"
        if normalized_candidate.startswith("dalsi technicky krok"):
            return "in_progress"
        if normalized_candidate.startswith("nasledujici hlavni etapa"):
            return "in_progress"

    return None


def detect_heading(
    line: str,
    document_type: str,
) -> tuple[bool, str | None, str | None, str | None]:
    stripped = clean_line(line)
    if not stripped or SEPARATOR_RE.match(stripped):
        return False, None, None, None

    # Markdown tables, table rows and list items must never be treated as headings.
    if stripped.startswith("|") and stripped.endswith("|"):
        return False, None, None, None
    if BULLET_RE.match(stripped):
        return False, None, None, None

    normalized_heading_text = normalize_heading(stripped)
    document_title_prefix = (
        "matchmatrix denni zapis"
        if document_type == "DAILY_LOG"
        else "matchmatrix navazani"
    )
    if normalized_heading_text.startswith(document_title_prefix):
        return True, stripped.strip(" :-–—"), "identification", "document_title"

    markdown = MARKDOWN_HEADING_WITH_LEVEL_RE.match(stripped)
    if markdown:
        heading = markdown.group(2).strip()
        return (
            True,
            heading,
            exact_heading_category(heading, document_type),
            "markdown_heading",
        )

    label_only = LABEL_ONLY_RE.match(stripped)
    if label_only:
        heading = label_only.group(1).strip()
        category = exact_heading_category(heading, document_type)
        if category:
            return True, heading, category, "label_heading"

    numbered = NUMBERED_HEADING_RE.match(stripped)
    if numbered:
        heading = numbered.group(1).strip(" :-–—")
        normalized_heading = normalize(heading)
        category = exact_heading_category(heading, document_type)
        action_like = any(
            normalized_heading.startswith(token)
            for token in ACTION_VERBS + DECISION_VERBS + PROBLEM_TOKENS
        )
        sentence_like = heading.endswith((".", "!", "?", ";"))
        if category and not action_like and not sentence_like:
            return True, heading, category, "numbered_known_heading"

    category = exact_heading_category(stripped, document_type)
    plain_sentence_like = stripped.endswith((".", ",", ";", "?", "!"))
    if (
        category
        and len(stripped) <= 180
        and len(stripped.split()) <= 14
        and not plain_sentence_like
        and not stripped.startswith("**")
    ):
        return True, stripped.strip(" :-–—"), category, "known_plain_heading"

    letters = [character for character in stripped if character.isalpha()]
    uppercase = [character for character in letters if character.isupper()]
    uppercase_ratio = len(uppercase) / len(letters) if letters else 0.0

    if (
        3 <= len(stripped) <= 100
        and len(stripped.split()) <= 12
        and uppercase_ratio >= 0.75
        and not stripped.endswith((".", ",", ";", "?", "!"))
        and not BULLET_RE.match(stripped)
        and not PATH_RE.search(stripped)
        and "|" not in stripped
    ):
        return True, stripped.strip(" :-–—"), None, "visual_plain_heading"

    return False, None, None, None


def split_chunks(text: str, document_type: str) -> list[dict[str, Any]]:
    chunks: list[dict[str, Any]] = []
    active_heading: str | None = None
    active_category: str | None = None
    active_heading_method: str | None = None
    active_heading_line: int | None = None
    active_heading_level: int | None = None
    heading_stack: dict[int, tuple[str, str | None]] = {}
    current_lines: list[str] = []
    start_line = 1
    inside_code_fence = False

    def nearest_parent_category(level: int | None = None) -> str | None:
        candidate_levels = sorted(heading_stack, reverse=True)
        for stack_level in candidate_levels:
            if level is not None and stack_level >= level:
                continue
            category = heading_stack[stack_level][1]
            if category:
                return category
        return None

    def flush(end_line: int) -> None:
        nonlocal current_lines, start_line
        nonlocal active_heading, active_category
        nonlocal active_heading_method, active_heading_line, active_heading_level
        body = "\n".join(current_lines).strip()
        if body:
            chunks.append(
                {
                    "block_id": f"BLK-{len(chunks) + 1:04d}",
                    "index": len(chunks) + 1,
                    "heading": active_heading,
                    "section_category_hint": active_category,
                    "heading_detection_method": active_heading_method,
                    "heading_line": active_heading_line,
                    "heading_level": active_heading_level,
                    "text": body,
                    "start_line": start_line,
                    "end_line": end_line,
                    "source_character_count": len(body),
                    "is_list_item": bool(BULLET_RE.match(body.splitlines()[0])),
                    "contains_code_fence": "```" in body,
                }
            )
            if active_heading_method == "document_title":
                active_heading = None
                active_category = None
                active_heading_method = None
                active_heading_line = None
                active_heading_level = None
        current_lines = []

    lines = text.splitlines()
    for line_number, raw in enumerate(lines, start=1):
        line = raw.rstrip()

        if CODE_FENCE_RE.match(line):
            if inside_code_fence:
                current_lines.append(line)
                inside_code_fence = False
                flush(line_number)
            else:
                flush(line_number - 1)
                inside_code_fence = True
                current_lines = [line]
                start_line = line_number
            continue

        if inside_code_fence:
            current_lines.append(line)
            continue

        if SEPARATOR_RE.match(line):
            flush(line_number - 1)
            continue

        markdown = MARKDOWN_HEADING_WITH_LEVEL_RE.match(clean_line(line))
        if markdown:
            flush(line_number - 1)
            level = len(markdown.group(1))
            heading = markdown.group(2).strip()
            direct_category = exact_heading_category(heading, document_type)
            inherited_category = nearest_parent_category(level)
            active_heading = heading
            active_category = direct_category or inherited_category
            active_heading_method = (
                "markdown_heading"
                if direct_category
                else "markdown_heading_inherited"
                if inherited_category
                else "markdown_heading"
            )
            active_heading_line = line_number
            active_heading_level = level
            for stack_level in [value for value in heading_stack if value >= level]:
                heading_stack.pop(stack_level, None)
            heading_stack[level] = (heading, active_category)
            start_line = line_number + 1
            continue

        is_heading, heading, category, method = detect_heading(
            line,
            document_type,
        )
        if is_heading:
            flush(line_number - 1)
            inherited_category = nearest_parent_category()
            active_heading = heading
            active_category = category or inherited_category
            active_heading_method = (
                method
                if category or not inherited_category
                else f"{method}_inherited"
            )
            active_heading_line = line_number
            active_heading_level = None
            start_line = line_number + 1
            continue

        if not line.strip():
            flush(line_number - 1)
            start_line = line_number + 1
            continue

        if not current_lines:
            start_line = line_number
        current_lines.append(line)

    flush(len(lines))
    return chunks


def coalesce_section_chunks(chunks: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    """Sloučí sousední fragmenty patřící pod stejný zdrojový nadpis.

    A18 má mapovat logické kapitoly, ne nutit uživatele potvrzovat každý
    odstavec, kódový blok nebo řádek tabulky samostatně.
    """
    merged: list[dict[str, Any]] = []
    for raw_chunk in chunks:
        chunk = dict(raw_chunk)
        same_section = bool(
            merged
            and chunk.get("heading_line") is not None
            and chunk.get("heading_line") == merged[-1].get("heading_line")
            and chunk.get("heading") == merged[-1].get("heading")
            and chunk.get("section_category_hint")
            == merged[-1].get("section_category_hint")
        )
        if same_section:
            previous = merged[-1]
            previous["text"] = (
                f"{str(previous['text']).rstrip()}\n\n{str(chunk['text']).lstrip()}"
            )
            previous["end_line"] = chunk["end_line"]
            previous["source_character_count"] = len(str(previous["text"]))
            previous["contains_code_fence"] = bool(
                previous.get("contains_code_fence")
                or chunk.get("contains_code_fence")
            )
            continue
        merged.append(chunk)

    for index, chunk in enumerate(merged, start=1):
        chunk["block_id"] = f"BLK-{index:04d}"
        chunk["index"] = index
    return merged


def add_score(
    scores: dict[str, float],
    reasons: dict[str, list[str]],
    category: str,
    amount: float,
    reason: str,
) -> None:
    scores[category] = scores.get(category, 0.0) + amount
    reasons.setdefault(category, []).append(reason)


def keyword_occurrences(text: str, keyword: str) -> int:
    normalized_text = normalize(text)
    normalized_keyword = normalize(keyword)
    if not normalized_keyword:
        return 0
    return normalized_text.count(normalized_keyword)


def score_chunk(
    chunk: Mapping[str, Any],
    document_type: str,
    position_ratio: float,
) -> dict[str, Any]:
    categories = category_items(document_type)
    scores = {str(item["code"]): 0.0 for item in categories}
    reasons: dict[str, list[str]] = defaultdict(list)

    heading_hint = chunk.get("section_category_hint")
    if heading_hint:
        add_score(
            scores,
            reasons,
            str(heading_hint),
            120.0,
            "Obsah se nachází pod jednoznačně rozpoznaným nadpisem; nadpis má přednost před technickými signály uvnitř kapitoly.",
        )

    heading = str(chunk.get("heading") or "")
    text = str(chunk.get("text") or "")
    combined = f"{heading}\n{text}" if heading else text
    normalized_text = normalize(text)

    for item in categories:
        code = str(item["code"])
        for keyword in item["keywords"]:
            count = keyword_occurrences(combined, str(keyword))
            if count <= 0:
                continue
            amount = min(16.0, count * (6.0 if " " in str(keyword) else 3.0))
            add_score(
                scores,
                reasons,
                code,
                amount,
                f"Nalezen výraz „{keyword}“ ({count}×).",
            )

    technical_category = (
        "verified_outputs" if document_type == "DAILY_LOG" else "sources"
    )
    if PATH_RE.search(text):
        add_score(
            scores,
            reasons,
            technical_category,
            10.0,
            "Blok obsahuje cestu k souboru nebo projektovému artefaktu.",
        )
    if COMMAND_RE.search(text):
        add_score(
            scores,
            reasons,
            technical_category,
            9.0,
            "Blok obsahuje příkaz, SQL nebo Git operaci.",
        )
    if STATUS_TOKEN_RE.search(text):
        add_score(
            scores,
            reasons,
            technical_category,
            8.0,
            "Blok obsahuje ověřitelný technický stav.",
        )
    if chunk.get("contains_code_fence"):
        add_score(
            scores,
            reasons,
            technical_category,
            10.0,
            "Blok obsahuje samostatný kódový blok.",
        )

    if document_type == "DAILY_LOG":
        if any(token in normalized_text for token in DECISION_VERBS):
            add_score(
                scores,
                reasons,
                "decisions",
                34.0,
                "Blok obsahuje explicitní rozhodnutí nebo pravidlo.",
            )
        if any(token in normalized_text for token in PROBLEM_TOKENS):
            add_score(
                scores,
                reasons,
                "problems",
                34.0,
                "Blok popisuje problém, chybu nebo blokátor.",
            )
        if any(token in normalized_text for token in NEXT_STEP_TOKENS):
            add_score(
                scores,
                reasons,
                "next_step",
                42.0,
                "Blok výslovně určuje další krok.",
            )
        elif any(token in normalized_text for token in FUTURE_TOKENS):
            add_score(
                scores,
                reasons,
                "continuation",
                34.0,
                "Blok popisuje budoucí pokračování.",
            )
        if any(token in normalized_text for token in ACTION_VERBS):
            add_score(
                scores,
                reasons,
                "work_done",
                32.0,
                "Blok obsahuje sloveso provedené práce.",
            )
        if DATE_RE.search(text) and position_ratio <= 0.18:
            add_score(
                scores,
                reasons,
                "identification",
                20.0,
                "Datum se nachází v úvodní části dokumentu.",
            )
        if position_ratio <= 0.12:
            add_score(
                scores,
                reasons,
                "initial_state",
                5.0,
                "Blok je v úvodní části denního zápisu.",
            )
        elif 0.12 < position_ratio < 0.70:
            add_score(
                scores,
                reasons,
                "work_done",
                6.0,
                "Blok je v hlavní pracovní části denního zápisu.",
            )
        elif position_ratio >= 0.86:
            add_score(
                scores,
                reasons,
                "continuation",
                5.0,
                "Blok se nachází v závěrečné části dokumentu.",
            )
    else:
        if any(token in normalized_text for token in DECISION_VERBS):
            add_score(
                scores,
                reasons,
                "decisions",
                34.0,
                "Blok obsahuje platné rozhodnutí nebo pravidlo.",
            )
        if any(token in normalized_text for token in PROBLEM_TOKENS):
            add_score(
                scores,
                reasons,
                "risks",
                34.0,
                "Blok obsahuje problém, riziko nebo blokátor.",
            )
        if any(token in normalized_text for token in NEXT_STEP_TOKENS):
            add_score(
                scores,
                reasons,
                "next_step",
                42.0,
                "Blok výslovně určuje první další krok.",
            )
        if position_ratio <= 0.12:
            add_score(
                scores,
                reasons,
                "context",
                6.0,
                "Blok je v úvodní části navazovacího dokumentu.",
            )
        elif position_ratio >= 0.88:
            add_score(
                scores,
                reasons,
                "next_step",
                5.0,
                "Blok je v závěrečné části navazovacího dokumentu.",
            )

    ranked = sorted(scores.items(), key=lambda item: item[1], reverse=True)
    return {
        **dict(chunk),
        "category_scores_raw": scores,
        "category_reasons_raw": dict(reasons),
        "initial_category": ranked[0][0],
        "initial_score_raw": ranked[0][1],
        "initial_margin_raw": ranked[0][1] - ranked[1][1] if len(ranked) > 1 else ranked[0][1],
    }


def apply_section_group_context(
    scored_chunks: list[dict[str, Any]],
) -> None:
    grouped: dict[tuple[str | None, int | None], list[dict[str, Any]]] = defaultdict(list)
    for chunk in scored_chunks:
        key = (
            str(chunk.get("heading")) if chunk.get("heading") else None,
            int(chunk["heading_line"]) if chunk.get("heading_line") else None,
        )
        grouped[key].append(chunk)

    for group_key, group in grouped.items():
        if not group:
            continue
        if group_key == (None, None):
            continue

        explicit_hint = group[0].get("section_category_hint")
        if explicit_hint:
            for chunk in group:
                scores = chunk["category_scores_raw"]
                reasons = chunk["category_reasons_raw"]
                add_score(
                    scores,
                    reasons,
                    str(explicit_hint),
                    35.0,
                    "Kategorie byla potvrzena kontextem stejné nadpisové sekce.",
                )
            continue

        votes = Counter(
            str(chunk["initial_category"])
            for chunk in group
            if float(chunk["initial_score_raw"]) >= 18.0
            and float(chunk["initial_margin_raw"]) >= 5.0
        )
        if not votes:
            continue

        winner, vote_count = votes.most_common(1)[0]
        if vote_count < 2 and len(group) > 2:
            continue

        for chunk in group:
            scores = chunk["category_scores_raw"]
            reasons = chunk["category_reasons_raw"]
            add_score(
                scores,
                reasons,
                winner,
                14.0,
                "Kategorie byla posílena většinovým tématem stejné sekce.",
            )


def apply_neighbor_context(
    scored_chunks: list[dict[str, Any]],
    document_type: str,
) -> None:
    orders = category_order(document_type)

    def current_winner(chunk: Mapping[str, Any]) -> tuple[str, float, float]:
        ranked = sorted(
            chunk["category_scores_raw"].items(),
            key=lambda item: item[1],
            reverse=True,
        )
        margin = ranked[0][1] - ranked[1][1] if len(ranked) > 1 else ranked[0][1]
        return ranked[0][0], ranked[0][1], margin

    snapshots = [current_winner(chunk) for chunk in scored_chunks]

    for index, chunk in enumerate(scored_chunks):
        category, score, margin = snapshots[index]
        if score >= 48.0 and margin >= 12.0:
            continue

        previous = snapshots[index - 1] if index > 0 else None
        following = snapshots[index + 1] if index + 1 < len(snapshots) else None
        scores = chunk["category_scores_raw"]
        reasons = chunk["category_reasons_raw"]

        if previous and following and previous[0] == following[0]:
            add_score(
                scores,
                reasons,
                previous[0],
                22.0,
                "Předchozí i následující blok patří do stejné kategorie.",
            )
            continue

        if previous and previous[1] >= 30.0 and previous[2] >= 7.0:
            previous_category = previous[0]
            current_order = orders.get(category, 999)
            previous_order = orders.get(previous_category, 999)
            same_heading = (
                chunk.get("heading")
                and chunk.get("heading") == scored_chunks[index - 1].get("heading")
            )
            if same_heading or abs(current_order - previous_order) <= 1:
                add_score(
                    scores,
                    reasons,
                    previous_category,
                    11.0,
                    "Kategorie byla posílena návazností na předchozí jistý blok.",
                )

        if following and following[1] >= 30.0 and following[2] >= 7.0:
            following_category = following[0]
            current_order = orders.get(category, 999)
            following_order = orders.get(following_category, 999)
            same_heading = (
                chunk.get("heading")
                and chunk.get("heading") == scored_chunks[index + 1].get("heading")
            )
            if same_heading or abs(current_order - following_order) <= 1:
                add_score(
                    scores,
                    reasons,
                    following_category,
                    8.0,
                    "Kategorie byla posílena návazností na následující jistý blok.",
                )


def score_to_confidence(
    score: float,
    margin: float,
    high_threshold: float,
    medium_threshold: float,
) -> tuple[str, float]:
    normalized_score = min(100.0, max(0.0, score))

    if normalized_score >= high_threshold and margin >= 14.0:
        return "HIGH", normalized_score
    if normalized_score >= medium_threshold and margin >= 7.0:
        return "MEDIUM", normalized_score
    return "LOW", normalized_score


def finalize_classification(
    scored_chunks: list[dict[str, Any]],
    document_type: str,
    high_threshold: float,
    medium_threshold: float,
    automatic_accept_score: float,
) -> tuple[dict[str, list[dict[str, Any]]], list[dict[str, Any]]]:
    catalog = category_by_code(document_type)
    mapped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    manual_queue: list[dict[str, Any]] = []

    for chunk in scored_chunks:
        ranked = sorted(
            chunk["category_scores_raw"].items(),
            key=lambda item: item[1],
            reverse=True,
        )
        best_category, best_raw_score = ranked[0]
        second_score = ranked[1][1] if len(ranked) > 1 else 0.0
        margin = best_raw_score - second_score
        confidence, confidence_score = score_to_confidence(
            best_raw_score,
            margin,
            high_threshold,
            medium_threshold,
        )

        alternatives = []
        for category, score in ranked[:4]:
            alternatives.append(
                {
                    "category": category,
                    "label_cs": str(catalog[category]["label_cs"]),
                    "score": round(min(100.0, max(0.0, score)), 2),
                    "reasons": chunk["category_reasons_raw"].get(category, [])[:8],
                }
            )

        needs_review = not (
            confidence == "HIGH"
            and confidence_score >= automatic_accept_score
            and margin >= 14.0
        )
        review_priority = (
            "CRITICAL"
            if confidence_score < 35.0
            else "HIGH"
            if confidence == "LOW"
            else "MEDIUM"
            if needs_review
            else "LOW"
        )
        action = (
            "MOVE_OR_CONFIRM"
            if confidence == "LOW"
            else "CONFIRM_OR_MOVE"
            if needs_review
            else "AUTO_ACCEPTABLE"
        )

        method_parts: list[str] = []
        if chunk.get("section_category_hint"):
            method_parts.append("explicit_section")
        if any(
            "soused" in reason.lower() or "návaz" in reason.lower()
            for reasons in chunk["category_reasons_raw"].values()
            for reason in reasons
        ):
            method_parts.append("neighbor_context")
        if any(
            "většinovým tématem" in reason.lower()
            or "stejné nadpisové sekce" in reason.lower()
            for reasons in chunk["category_reasons_raw"].values()
            for reason in reasons
        ):
            method_parts.append("section_context")
        if PATH_RE.search(str(chunk["text"])) or COMMAND_RE.search(str(chunk["text"])):
            method_parts.append("technical_signal")
        method_parts.append("weighted_rules")

        finalized = {
            key: value
            for key, value in chunk.items()
            if key not in {"category_scores_raw", "category_reasons_raw"}
        }
        finalized.update(
            {
                "proposed_category": best_category,
                "proposed_category_label_cs": str(catalog[best_category]["label_cs"]),
                "classification_score": round(confidence_score, 2),
                "classification_margin": round(margin, 2),
                "classification_confidence": confidence,
                "classification_method": "+".join(dict.fromkeys(method_parts)),
                "classification_reasons": chunk["category_reasons_raw"].get(
                    best_category,
                    [],
                )[:12],
                "category_alternatives": alternatives,
                "needs_manual_review": needs_review,
                "review_priority": review_priority,
                "recommended_panel_action": action,
            }
        )

        mapped[best_category].append(finalized)
        if needs_review:
            manual_queue.append(finalized)

    return dict(mapped), manual_queue


def mapping_metrics(
    source_chunks: Sequence[Mapping[str, Any]],
    mapped_chunks: Sequence[Mapping[str, Any]],
    manual_queue: Sequence[Mapping[str, Any]],
    minimum_coverage: float,
) -> dict[str, Any]:
    total_characters = sum(
        int(chunk.get("source_character_count") or len(str(chunk.get("text") or "")))
        for chunk in source_chunks
    )
    mapped_characters = sum(
        int(chunk.get("source_character_count") or len(str(chunk.get("text") or "")))
        for chunk in mapped_chunks
    )

    coverage = (
        round(mapped_characters * 100.0 / total_characters, 2)
        if total_characters
        else 100.0
    )
    confidence_counts = Counter(
        str(chunk["classification_confidence"])
        for chunk in mapped_chunks
    )
    manual_percent = (
        round(len(manual_queue) * 100.0 / len(mapped_chunks), 2)
        if mapped_chunks
        else 0.0
    )

    if coverage < 40.0:
        quality = "MAPPING_INSUFFICIENT"
    elif coverage < minimum_coverage:
        quality = "MANUAL_MAPPING_REQUIRED"
    elif manual_queue:
        quality = "READY_FOR_PANEL_MAPPING"
    else:
        quality = "READY_FOR_DOCUMENT_COMPLETION"

    return {
        "source_chunks_count": len(source_chunks),
        "mapped_chunks_count": len(mapped_chunks),
        "unmapped_chunks_count": max(0, len(source_chunks) - len(mapped_chunks)),
        "source_characters": total_characters,
        "mapped_characters": mapped_characters,
        "character_mapping_coverage_percent": coverage,
        "minimum_mapping_coverage_percent": minimum_coverage,
        "high_confidence_chunks_count": confidence_counts.get("HIGH", 0),
        "medium_confidence_chunks_count": confidence_counts.get("MEDIUM", 0),
        "low_confidence_chunks_count": confidence_counts.get("LOW", 0),
        "manual_review_chunks_count": len(manual_queue),
        "manual_review_chunks_percent": manual_percent,
        "proposal_quality_status": quality,
    }


def hidden_block_marker(chunk: Mapping[str, Any]) -> str:
    return (
        "<!-- "
        f"MM-BLOCK-ID={chunk['block_id']}; "
        f"CATEGORY={chunk['proposed_category']}; "
        f"CONFIDENCE={chunk['classification_confidence']}; "
        f"SCORE={chunk['classification_score']}"
        " -->"
    )


def render_chunks(
    chunks: Sequence[Mapping[str, Any]] | None,
    placeholder: str,
) -> str:
    if not chunks:
        return f"> **DOPLNIT UŽIVATELEM:** {placeholder}"

    blocks: list[str] = []
    for chunk in chunks:
        block_parts = [hidden_block_marker(chunk)]
        if chunk["needs_manual_review"]:
            block_parts.append(
                "> **MAPOVÁNÍ K POTVRZENÍ – "
                f"{chunk['block_id']} | "
                f"{chunk['classification_confidence']} | "
                f"{chunk['classification_score']} %**"
            )
        if chunk.get("heading"):
            block_parts.append(f"**Původní část: {chunk['heading']}**")
        block_parts.append(str(chunk["text"]).strip())
        blocks.append("\n\n".join(block_parts))
    return "\n\n".join(blocks)


def metadata_table(
    *,
    document_id: str,
    title: str,
    version: str,
    date_value: str,
    author: str,
    working_area: str,
    source_path: Path,
    source_hash: str,
    audit_path: Path,
    document_type: str,
) -> str:
    return "\n".join(
        [
            "| Položka | Hodnota |",
            "|---|---|",
            f"| Document ID | {document_id} |",
            f"| Název dokumentu | {title} |",
            f"| Typ dokumentu | {document_type} |",
            f"| Verze návrhu | {version} |",
            "| Stav | DRAFT – NEEDS_USER_APPROVAL |",
            f"| Datum | {date_value} |",
            f"| Autor | {author} |",
            f"| Pracovní oblast | {working_area} |",
            f"| Původní soubor | `{source_path}` |",
            f"| SHA-256 původního souboru | `{source_hash}` |",
            f"| Zdrojový audit A17 | `{audit_path}` |",
            f"| Klasifikační engine | {ENGINE_VERSION} |",
            "| Způsob vzniku | Kontextový standardizační návrh A18 |",
        ]
    )


def build_daily(
    *,
    metadata: str,
    title: str,
    mapped: Mapping[str, Sequence[Mapping[str, Any]]],
) -> str:
    return f"""# {title}

## Informace o dokumentu

{metadata}

> **Bezpečnostní stav:** Toto je pouze návrh. Původní dokument nebyl změněn.
> Bloky označené `MAPOVÁNÍ K POTVRZENÍ` čekají na rozhodnutí v panelu.
> Obsah `DOPLNIT UŽIVATELEM` nebylo možné bezpečně odvodit.

## 1. Identifikace denního zápisu

{render_chunks(mapped.get('identification'), 'Doplnit datum, autora, projekt a pracovní oblast.')}

## 2. Výchozí stav

{render_chunks(mapped.get('initial_state'), 'Popsat stav projektu před zahájením práce.')}

## 3. Cíl pracovního dne

{render_chunks(mapped.get('goal'), 'Jednou až několika větami určit cíl pracovního dne.')}

## 4. Provedené práce

{render_chunks(mapped.get('work_done'), 'Popsat významné provedené práce, jejich důvod a pořadí.')}

## 5. Přijatá rozhodnutí

{render_chunks(mapped.get('decisions'), 'Uvést přijatá rozhodnutí, nebo potvrdit, že žádné nové rozhodnutí nevzniklo.')}

## 6. Problémy a jejich řešení

{render_chunks(mapped.get('problems'), 'Uvést problémy, příčiny, řešení a výsledek; pokud nebyly, výslovně to potvrdit.')}

## 7. Ověřené výsledky a technické výstupy

{render_chunks(mapped.get('verified_outputs'), 'Doplnit ověřené počty, stavy, soubory, skripty, příkazy, reporty a Git commity.')}

## 8. Výsledky dne a stav na konci dne

{render_chunks(mapped.get('results'), 'Shrnout dokončené, rozpracované a odložené oblasti.')}

## 9. Plán pokračování

{render_chunks(mapped.get('continuation'), 'Popsat plán další práce a návaznosti.')}

## 10. Jeden hlavní další krok

{render_chunks(mapped.get('next_step'), 'Určit jeden konkrétní první krok pro další pracovní blok.')}

## 11. Vazby a NAVÁZÁNÍ

{render_chunks(mapped.get('links'), 'Doplnit předchozí zápis, navazující dokument, NAVÁZÁNÍ a Git commit.')}

## 12. Schválení návrhu

- [ ] Všechny bloky v panelové mapovací frontě byly potvrzeny nebo přesunuty.
- [ ] Uživatel doplnil všechna pole `DOPLNIT UŽIVATELEM`.
- [ ] Uživatel schválil Document ID, název, verzi a cílové umístění.
- [ ] Byla zkontrolována terminologie podle MM-REF-001.
- [ ] Byl zkontrolován finální diff.
- [ ] Bylo rozhodnuto o vytvoření nové kanonické verze.
"""


def build_continuation(
    *,
    metadata: str,
    title: str,
    mapped: Mapping[str, Sequence[Mapping[str, Any]]],
) -> str:
    return f"""# {title}

## Informace o dokumentu

{metadata}

> **Bezpečnostní stav:** Toto je pouze návrh. Původní dokument nebyl změněn.
> Bloky označené `MAPOVÁNÍ K POTVRZENÍ` čekají na rozhodnutí v panelu.
> Obsah `DOPLNIT UŽIVATELEM` nebylo možné bezpečně odvodit.

## 1. Identifikace navázání

{render_chunks(mapped.get('identification'), 'Doplnit datum, pracovní etapu, autora a oblast projektu.')}

## 2. Výchozí kontext

{render_chunks(mapped.get('context'), 'Popsat, proč dokument vznikl a na jakou práci nebo chat navazuje.')}

## 3. CURRENT STATUS

{render_chunks(mapped.get('current_status'), 'Stručně popsat současný ověřený stav projektu.')}

## 4. Co bylo dokončeno

{render_chunks(mapped.get('completed'), 'Uvést dokončené a ověřené oblasti.')}

## 5. Co zůstává rozpracováno

{render_chunks(mapped.get('in_progress'), 'Uvést rozpracované oblasti a jejich stav.')}

## 6. OPEN QUESTIONS / otevřené úkoly

{render_chunks(mapped.get('open_tasks'), 'Vypsat otevřené otázky, úkoly a rozhodnutí čekající na vyřešení.')}

## 7. Rizika a upozornění

{render_chunks(mapped.get('risks'), 'Uvést známá rizika, blokátory a důležitá upozornění.')}

## 8. Přijatá rozhodnutí a platná pravidla

{render_chunks(mapped.get('decisions'), 'Uvést rozhodnutí a pravidla, která musí nový chat respektovat.')}

## 9. Ověřené zdroje, soubory a příkazy

{render_chunks(mapped.get('sources'), 'Doplnit ověřené soubory, skripty, SQL, reporty, cesty a příkazy.')}

## 10. AI CONTEXT

{render_chunks(mapped.get('ai_context'), 'Doplnit kontext a pravidla nezbytná pro pokračování AI asistenta.')}

## 11. PROJECT SNAPSHOT

{render_chunks(mapped.get('project_snapshot'), 'Doplnit projektový snapshot a stav hlavních vrstev.')}

## 12. DATABASE SNAPSHOT

{render_chunks(mapped.get('database_snapshot'), 'Doplnit ověřené databázové počty, stavy a poslední importy.')}

## 13. NEXT STEP

{render_chunks(mapped.get('next_step'), 'Určit jeden přesný první krok pro nový chat.')}

## 14. Schválení návrhu

- [ ] Všechny bloky v panelové mapovací frontě byly potvrzeny nebo přesunuty.
- [ ] Uživatel doplnil všechna pole `DOPLNIT UŽIVATELEM`.
- [ ] Uživatel ověřil aktuálnost PROJECT SNAPSHOT a DATABASE SNAPSHOT.
- [ ] Uživatel schválil NEXT STEP.
- [ ] Byl zkontrolován finální diff.
- [ ] Bylo rozhodnuto o vytvoření nové kanonické verze.
"""


def category_catalog_payload(document_type: str) -> list[dict[str, Any]]:
    return [
        {
            "code": str(item["code"]),
            "order": int(item["order"]),
            "label_cs": str(item["label_cs"]),
        }
        for item in category_items(document_type)
    ]


def panel_queue_item(
    chunk: Mapping[str, Any],
    document_type: str,
) -> dict[str, Any]:
    allowed_categories = [
        str(item["code"])
        for item in category_items(document_type)
    ]
    return {
        "block_id": chunk["block_id"],
        "source": {
            "start_line": chunk["start_line"],
            "end_line": chunk["end_line"],
            "heading": chunk.get("heading"),
            "text": chunk["text"],
            "character_count": chunk["source_character_count"],
        },
        "proposal": {
            "category": chunk["proposed_category"],
            "category_label_cs": chunk["proposed_category_label_cs"],
            "confidence": chunk["classification_confidence"],
            "confidence_score": chunk["classification_score"],
            "score_margin": chunk["classification_margin"],
            "method": chunk["classification_method"],
            "reasons": chunk["classification_reasons"],
            "alternatives": chunk["category_alternatives"],
        },
        "review": {
            "required": chunk["needs_manual_review"],
            "priority": chunk["review_priority"],
            "recommended_action": chunk["recommended_panel_action"],
            "allowed_actions": [
                "CONFIRM",
                "MOVE",
                "SPLIT",
                "EXCLUDE_AS_NOISE",
                "RETURN_TO_MANUAL_REVIEW",
            ],
            "allowed_categories": allowed_categories,
        },
        "user_decision": {
            "status": "PENDING" if chunk["needs_manual_review"] else "NOT_REQUIRED",
            "action": None,
            "selected_category": None,
            "note": None,
            "approved_by": None,
            "approved_at": None,
        },
    }


def markdown_mapping_report(payload: Mapping[str, Any]) -> str:
    lines = [
        "# MATCHMATRIX – MAPOVÁNÍ STANDARDIZAČNÍHO NÁVRHU",
        "",
        f"- Původní dokument: `{payload['source_document_path']}`",
        f"- Audit A17: `{payload['audit_path']}`",
        f"- Typ: **{payload['document_type']}**",
        f"- Engine: **{payload['classification_engine_version']}**",
        f"- Původní SHA-256: `{payload['source_hash_sha256']}`",
        f"- Návrh: `{payload['proposal_path']}`",
        f"- Diff: `{payload['diff_path']}`",
        f"- Zdrojových bloků: **{payload['source_chunks_count']}**",
        f"- Mapovaných bloků: **{payload['mapped_chunks_count']}**",
        f"- Pokrytí obsahu: **{payload['character_mapping_coverage_percent']} %**",
        f"- HIGH: **{payload['high_confidence_chunks_count']}**",
        f"- MEDIUM: **{payload['medium_confidence_chunks_count']}**",
        f"- LOW: **{payload['low_confidence_chunks_count']}**",
        f"- Ruční fronta: **{payload['manual_review_chunks_count']}**",
        f"- Kvalita návrhu: **{payload['proposal_quality_status']}**",
        f"- Placeholdery: **{payload['placeholder_count']}**",
        "",
        "## Mapované bloky",
        "",
        "| Blok | Řádky | Kategorie | Skóre | Jistota | Ruční kontrola | Metoda | Původní nadpis |",
        "|---|---:|---|---:|---|---|---|---|",
    ]

    for item in payload["mapped_chunks"]:
        lines.append(
            f"| {item['block_id']} | {item['start_line']}–{item['end_line']} | "
            f"{item['proposed_category']} | {item['classification_score']} | "
            f"{item['classification_confidence']} | "
            f"{'ANO' if item['needs_manual_review'] else 'NE'} | "
            f"{item['classification_method']} | {item.get('heading') or ''} |"
        )

    lines.extend(
        [
            "",
            "## Ruční mapovací fronta",
            "",
        ]
    )
    if payload["manual_review_chunks"]:
        for item in payload["manual_review_chunks"]:
            preview = str(item["text"]).replace("\n", " ")[:240]
            alternatives = ", ".join(
                f"{alternative['category']}={alternative['score']}"
                for alternative in item["category_alternatives"][:3]
            )
            lines.append(
                f"- **{item['block_id']}** | {item['review_priority']} | "
                f"návrh `{item['proposed_category']}` | "
                f"alternativy: {alternatives} | {preview}"
            )
    else:
        lines.append("- Žádné bloky nevyžadují ruční mapování.")

    lines.extend(
        [
            "",
            "## Bezpečnostní závěr",
            "",
            "- Původní dokument nebyl změněn.",
            "- Databáze nebyla změněna.",
            "- Návrh nebyl schválen ani importován.",
            "- Panel smí schválení povolit až po uzavření ruční fronty a doplnění placeholderů.",
            "",
        ]
    )
    return "\n".join(lines)


def panel_markdown_report(panel_payload: Mapping[str, Any]) -> str:
    lines = [
        "# MATCHMATRIX – PANELOVÁ MAPOVACÍ FRONTA",
        "",
        f"- Kontrakt: **{panel_payload['contract_version']}**",
        f"- Dokument: `{panel_payload['source_document_path']}`",
        f"- Typ: **{panel_payload['document_type']}**",
        f"- Celkem bloků: **{panel_payload['summary']['total_blocks']}**",
        f"- K ručnímu rozhodnutí: **{panel_payload['summary']['pending_review_blocks']}**",
        f"- Automaticky přijatelné: **{panel_payload['summary']['automatic_blocks']}**",
        "",
        "## Bloky k rozhodnutí",
        "",
    ]

    pending = [
        item
        for item in panel_payload["blocks"]
        if item["review"]["required"]
    ]
    if not pending:
        lines.append("- Žádné.")
    else:
        for item in pending:
            proposal = item["proposal"]
            source = item["source"]
            preview = str(source["text"]).replace("\n", " ")[:300]
            lines.extend(
                [
                    f"### {item['block_id']} – {proposal['category_label_cs']}",
                    "",
                    f"- Řádky: {source['start_line']}–{source['end_line']}",
                    f"- Jistota: **{proposal['confidence']} / {proposal['confidence_score']} %**",
                    f"- Priorita: **{item['review']['priority']}**",
                    f"- Doporučená akce: `{item['review']['recommended_action']}`",
                    f"- Text: {preview}",
                    "",
                ]
            )
    return "\n".join(lines).rstrip() + "\n"


def write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def write_panel_csv(
    path: Path,
    panel_payload: Mapping[str, Any],
) -> None:
    fields = [
        "block_id",
        "start_line",
        "end_line",
        "heading",
        "text_preview",
        "proposed_category",
        "proposed_category_label_cs",
        "confidence",
        "confidence_score",
        "score_margin",
        "review_required",
        "review_priority",
        "recommended_action",
        "alternative_1",
        "alternative_2",
        "alternative_3",
        "user_status",
        "user_action",
        "user_selected_category",
        "user_note",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for item in panel_payload["blocks"]:
            source = item["source"]
            proposal = item["proposal"]
            review = item["review"]
            decision = item["user_decision"]
            alternatives = proposal["alternatives"]
            row = {
                "block_id": item["block_id"],
                "start_line": source["start_line"],
                "end_line": source["end_line"],
                "heading": source.get("heading") or "",
                "text_preview": str(source["text"]).replace("\n", " ")[:500],
                "proposed_category": proposal["category"],
                "proposed_category_label_cs": proposal["category_label_cs"],
                "confidence": proposal["confidence"],
                "confidence_score": proposal["confidence_score"],
                "score_margin": proposal["score_margin"],
                "review_required": review["required"],
                "review_priority": review["priority"],
                "recommended_action": review["recommended_action"],
                "alternative_1": alternatives[0]["category"] if len(alternatives) > 0 else "",
                "alternative_2": alternatives[1]["category"] if len(alternatives) > 1 else "",
                "alternative_3": alternatives[2]["category"] if len(alternatives) > 2 else "",
                "user_status": decision["status"],
                "user_action": decision["action"] or "",
                "user_selected_category": decision["selected_category"] or "",
                "user_note": decision["note"] or "",
            }
            writer.writerow(row)


def write_outputs(
    *,
    root: Path,
    output_dir_arg: str | None,
    proposal: str,
    original: str,
    mapping: dict[str, Any],
    panel_payload: dict[str, Any],
) -> dict[str, Path]:
    output_dir = resolve_path(root, output_dir_arg, OUTPUT_DEFAULT)
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths = {
        "proposal": output_dir / f"document_standardization_proposal_{stamp}.md",
        "diff": output_dir / f"document_standardization_diff_{stamp}.diff",
        "mapping_json": output_dir / f"document_standardization_mapping_{stamp}.json",
        "mapping_markdown": output_dir / f"document_standardization_mapping_{stamp}.md",
        "panel_json": output_dir / f"document_standardization_panel_mapping_{stamp}.json",
        "panel_csv": output_dir / f"document_standardization_panel_mapping_{stamp}.csv",
        "panel_markdown": output_dir / f"document_standardization_panel_mapping_{stamp}.md",
    }

    diff = "\n".join(
        difflib.unified_diff(
            original.splitlines(),
            proposal.splitlines(),
            fromfile=str(mapping["source_document_path"]),
            tofile=str(paths["proposal"]),
            lineterm="",
        )
    )
    if diff:
        diff += "\n"

    paths["proposal"].write_text(proposal, encoding="utf-8")
    paths["diff"].write_text(diff, encoding="utf-8")

    mapping.update(
        {
            "proposal_path": str(paths["proposal"]),
            "diff_path": str(paths["diff"]),
            "mapping_json_path": str(paths["mapping_json"]),
            "mapping_markdown_path": str(paths["mapping_markdown"]),
            "panel_mapping_json_path": str(paths["panel_json"]),
            "panel_mapping_csv_path": str(paths["panel_csv"]),
            "panel_mapping_markdown_path": str(paths["panel_markdown"]),
        }
    )
    panel_payload.update(
        {
            "proposal_path": str(paths["proposal"]),
            "diff_path": str(paths["diff"]),
            "mapping_path": str(paths["mapping_json"]),
        }
    )

    write_json(paths["mapping_json"], mapping)
    paths["mapping_markdown"].write_text(
        markdown_mapping_report(mapping),
        encoding="utf-8",
    )
    write_json(paths["panel_json"], panel_payload)
    write_panel_csv(paths["panel_csv"], panel_payload)
    paths["panel_markdown"].write_text(
        panel_markdown_report(panel_payload),
        encoding="utf-8",
    )

    latest_names = {
        "proposal": "document_standardization_proposal_latest.md",
        "diff": "document_standardization_diff_latest.diff",
        "mapping_json": "document_standardization_mapping_latest.json",
        "mapping_markdown": "document_standardization_mapping_latest.md",
        "panel_json": "document_standardization_panel_mapping_latest.json",
        "panel_csv": "document_standardization_panel_mapping_latest.csv",
        "panel_markdown": "document_standardization_panel_mapping_latest.md",
    }
    for key, latest_name in latest_names.items():
        shutil.copyfile(paths[key], output_dir / latest_name)

    return paths


def main() -> int:
    args = parse_args()
    root = project_root()
    audit_path = resolve_path(root, args.audit, AUDIT_DEFAULT)

    print("MATCHMATRIX DOCUMENT STANDARDIZATION PROPOSAL")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"AUDIT              : {audit_path}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("DATABASE WRITES    : DISABLED")
    print("SOURCE WRITES      : DISABLED")
    print()

    try:
        if not 0.0 <= args.minimum_mapping_coverage <= 100.0:
            raise ValueError("--minimum-mapping-coverage musí být 0 až 100.")
        if not 0.0 <= args.automatic_accept_score <= 100.0:
            raise ValueError("--automatic-accept-score musí být 0 až 100.")
        if not 0.0 <= args.medium_confidence_score <= args.high_confidence_score <= 100.0:
            raise ValueError(
                "Musí platit 0 <= medium-confidence-score <= "
                "high-confidence-score <= 100."
            )

        audit = load_audit(audit_path)
        document_type = str(audit["document_type"])
        source_path = Path(str(audit["document_path"]))

        if not source_path.is_file():
            raise FileNotFoundError(
                f"Původní dokument z auditu nebyl nalezen: {source_path}"
            )

        original_text, raw = read_text(source_path)
        current_hash = sha256_bytes(raw)
        expected_hash = str(audit["document_hash_sha256"])
        if current_hash != expected_hash:
            raise RuntimeError(
                "Původní dokument se od auditu A17 změnil. "
                "Spusť znovu A17 a teprve potom A18."
            )

        chunks = coalesce_section_chunks(
            split_chunks(original_text, document_type)
        )
        if not chunks:
            raise RuntimeError("Zdrojový dokument neobsahuje žádný mapovatelný blok.")

        scored_chunks = [
            score_chunk(
                chunk,
                document_type,
                index / max(1, len(chunks) - 1),
            )
            for index, chunk in enumerate(chunks)
        ]
        apply_section_group_context(scored_chunks)
        apply_neighbor_context(scored_chunks, document_type)
        mapped, manual_queue = finalize_classification(
            scored_chunks,
            document_type,
            args.high_confidence_score,
            args.medium_confidence_score,
            args.automatic_accept_score,
        )
        mapped_chunks = sorted(
            (
                chunk
                for category_chunks in mapped.values()
                for chunk in category_chunks
            ),
            key=lambda chunk: int(chunk["index"]),
        )

        source_metadata = extract_metadata_table(original_text)
        source_document_id = (
            metadata_value(source_metadata, "Document ID", "ID dokumentu")
            or extract_first(DOCUMENT_ID_RE, original_text)
        )
        source_version = (
            metadata_value(source_metadata, "Verze", "Version")
            or extract_first(VERSION_RE, original_text)
        )
        source_date = normalize_date(
            metadata_value(source_metadata, "Datum", "Date")
            or extract_first(DATE_RE, original_text)
        )
        source_title = (
            metadata_value(source_metadata, "Název dokumentu", "Název", "Title")
            or first_title(original_text)
        )
        source_author = metadata_value(
            source_metadata,
            "Autor",
            "Autor projektu",
            "Zpracoval",
        )
        source_working_area = metadata_value(
            source_metadata,
            "Pracovní oblast",
            "Pracovní větev",
            "Oblast projektu",
        )

        document_id = (
            args.document_id
            or source_document_id
            or "[DOPLNIT UŽIVATELEM – DOCUMENT ID]"
        )
        version = (
            args.version
            or source_version
            or "[DOPLNIT UŽIVATELEM – VERZE]"
        )
        date_value = (
            normalize_date(args.date)
            or source_date
            or "[DOPLNIT UŽIVATELEM – DATUM]"
        )
        author = (
            args.author
            or source_author
            or "[DOPLNIT UŽIVATELEM – AUTOR]"
        )
        working_area = (
            args.working_area
            or source_working_area
            or "[DOPLNIT UŽIVATELEM – PRACOVNÍ OBLAST]"
        )

        if args.title:
            title = args.title
        elif source_title and len(source_title) <= 180:
            title = source_title
        elif document_type == "DAILY_LOG":
            title = f"MATCHMATRIX – DENNÍ ZÁPIS – {date_value}"
        else:
            title = f"MATCHMATRIX – NAVÁZÁNÍ – {date_value}"

        metadata = metadata_table(
            document_id=document_id,
            title=title,
            version=version,
            date_value=date_value,
            author=author,
            working_area=working_area,
            source_path=source_path,
            source_hash=current_hash,
            audit_path=audit_path,
            document_type=document_type,
        )

        proposal = (
            build_daily(metadata=metadata, title=title, mapped=mapped)
            if document_type == "DAILY_LOG"
            else build_continuation(metadata=metadata, title=title, mapped=mapped)
        ).rstrip() + "\n"

        placeholder_count = count_placeholders(proposal)
        metrics = mapping_metrics(
            chunks,
            mapped_chunks,
            manual_queue,
            args.minimum_mapping_coverage,
        )
        mapping_approval_allowed = (
            metrics["character_mapping_coverage_percent"]
            >= args.minimum_mapping_coverage
            and metrics["manual_review_chunks_count"] == 0
            and metrics["unmapped_chunks_count"] == 0
        )
        document_approval_allowed = (
            mapping_approval_allowed and placeholder_count == 0
        )

        mapping: dict[str, Any] = {
            "generated_at": utc_now().isoformat(),
            "project_root": str(root),
            "classification_engine_version": ENGINE_VERSION,
            "audit_path": str(audit_path),
            "source_document_path": str(source_path),
            "source_hash_sha256": current_hash,
            "source_size_bytes": len(raw),
            "document_type": document_type,
            "audit_compliance_score_percent": audit.get("compliance_score_percent"),
            "audit_compliance_status": audit.get("compliance_status"),
            "category_catalog": category_catalog_payload(document_type),
            **metrics,
            "placeholder_count": placeholder_count,
            "mapped_chunks": mapped_chunks,
            "manual_review_chunks": manual_queue,
            "document_modified": False,
            "database_modified": False,
            "requires_user_approval": True,
            "proposal_status": "DRAFT_NEEDS_USER_APPROVAL",
            "mapping_approval_allowed": mapping_approval_allowed,
            "document_approval_allowed": document_approval_allowed,
            "final_status": "DOCUMENT_STANDARDIZATION_PROPOSAL_READY",
        }

        panel_blocks = [
            panel_queue_item(chunk, document_type)
            for chunk in mapped_chunks
        ]
        panel_payload: dict[str, Any] = {
            "contract_version": PANEL_CONTRACT_VERSION,
            "generated_at": utc_now().isoformat(),
            "classification_engine_version": ENGINE_VERSION,
            "source_document_path": str(source_path),
            "source_hash_sha256": current_hash,
            "document_type": document_type,
            "read_only_source": True,
            "category_catalog": category_catalog_payload(document_type),
            "summary": {
                "total_blocks": len(panel_blocks),
                "automatic_blocks": sum(
                    1
                    for item in panel_blocks
                    if not item["review"]["required"]
                ),
                "pending_review_blocks": sum(
                    1
                    for item in panel_blocks
                    if item["review"]["required"]
                ),
                "high_confidence_blocks": metrics["high_confidence_chunks_count"],
                "medium_confidence_blocks": metrics["medium_confidence_chunks_count"],
                "low_confidence_blocks": metrics["low_confidence_chunks_count"],
                "content_coverage_percent": metrics[
                    "character_mapping_coverage_percent"
                ],
                "proposal_quality_status": metrics["proposal_quality_status"],
                "mapping_approval_allowed": mapping_approval_allowed,
                "document_approval_allowed": document_approval_allowed,
                "placeholder_count": placeholder_count,
            },
            "panel_workflow": {
                "pending_status": "PENDING",
                "completed_status": "CONFIRMED",
                "required_before_mapping_approval": (
                    "Všechny bloky review.required=true musí mít "
                    "user_decision.status=CONFIRMED."
                ),
                "required_before_document_approval": (
                    "Mapování musí být schválené a placeholder_count musí být 0."
                ),
            },
            "blocks": panel_blocks,
            "final_status": "DOCUMENT_STANDARDIZATION_PANEL_MAPPING_READY",
        }

        paths = write_outputs(
            root=root,
            output_dir_arg=args.output_dir,
            proposal=proposal,
            original=original_text,
            mapping=mapping,
            panel_payload=panel_payload,
        )

        print("ZDROJ")
        print("-" * 79)
        print(f"DOCUMENT           : {source_path}")
        print(f"DOCUMENT TYPE      : {document_type}")
        print("SHA-256 VERIFIED  : True")
        print(f"A17 SCORE          : {audit.get('compliance_score_percent')} %")
        print(f"A17 STATUS         : {audit.get('compliance_status')}")
        print()

        print("MAPOVÁNÍ")
        print("-" * 79)
        print(f"SOURCE CHUNKS      : {metrics['source_chunks_count']}")
        print(f"MAPPED CHUNKS      : {metrics['mapped_chunks_count']}")
        print(f"UNMAPPED CHUNKS    : {metrics['unmapped_chunks_count']}")
        print(
            "CONTENT COVERAGE   : "
            f"{metrics['character_mapping_coverage_percent']} %"
        )
        print(f"HIGH CONFIDENCE    : {metrics['high_confidence_chunks_count']}")
        print(f"MEDIUM CONFIDENCE  : {metrics['medium_confidence_chunks_count']}")
        print(f"LOW CONFIDENCE     : {metrics['low_confidence_chunks_count']}")
        print(f"MANUAL REVIEW      : {metrics['manual_review_chunks_count']}")
        print(f"PROPOSAL QUALITY   : {metrics['proposal_quality_status']}")
        print(f"MAPPING APPROVAL   : {mapping_approval_allowed}")
        print(f"DOCUMENT APPROVAL  : {document_approval_allowed}")
        print(f"PLACEHOLDERS       : {placeholder_count}")
        print()

        print("VÝSTUP")
        print("-" * 79)
        print(f"PROPOSAL           : {paths['proposal']}")
        print(f"DIFF               : {paths['diff']}")
        print(f"MAPPING JSON       : {paths['mapping_json']}")
        print(f"MAPPING MARKDOWN   : {paths['mapping_markdown']}")
        print(f"PANEL JSON         : {paths['panel_json']}")
        print(f"PANEL CSV          : {paths['panel_csv']}")
        print(f"PANEL MARKDOWN     : {paths['panel_markdown']}")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print("USER APPROVAL      : REQUIRED")
        print("FINAL STATUS       : DOCUMENT_STANDARDIZATION_PROPOSAL_READY")
        return 0

    except Exception as exc:
        print("STANDARDIZATION ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print("FINAL STATUS       : DOCUMENT_STANDARDIZATION_PROPOSAL_BLOCKED")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
