#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Provádí read-only audit existujícího Markdown dokumentu proti dokumentačním
standardům MatchMatrix a určuje, jaké náležitosti je potřeba doplnit nebo
restrukturalizovat.

K ČEMU:
- rozpozná typ dokumentu nebo přijme typ zadaný uživatelem,
- ověří obecná metadata, identitu, verzi, stav a název souboru,
- pro denní zápis ověří strukturu podle MM-DOC-900,
- pro navázání ověří strukturu podle MM-DOC-901 a MM-STD-009,
- pro hlavní dokument ověří strukturu podle MM-STD-001,
- upozorní na terminologické a ručně ověřitelné oblasti,
- vytvoří JSON a Markdown auditní report,
- původní dokument nijak nemění.

KDE:
tools/documentation/25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py

JAK:
Automatické rozpoznání typu:
    py -3.14 .\\tools\\documentation\\25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py --document "C:\\cesta\\dokument.md"

Vynucení typu:
    py -3.14 .\\tools\\documentation\\25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py --document "C:\\cesta\\dokument.md" --document-type DAILY_LOG

Podporované typy:
- AUTO
- DAILY_LOG
- CHAT_CONTINUATION
- MAIN_DOCUMENT
- GENERIC_DOCUMENT

VÝSTUP:
- reports/documentation/standardization/document_compliance_audit_YYYYMMDD_HHMMSS.json
- reports/documentation/standardization/document_compliance_audit_YYYYMMDD_HHMMSS.md
- reports/documentation/standardization/document_compliance_audit_latest.json
- reports/documentation/standardization/document_compliance_audit_latest.md
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


REPORT_PREFIX = "document_compliance_audit"
SUPPORTED_TYPES = {
    "AUTO",
    "DAILY_LOG",
    "CHAT_CONTINUATION",
    "MAIN_DOCUMENT",
    "GENERIC_DOCUMENT",
}

DOCUMENT_ID_RE = re.compile(
    r"\b(?:"
    r"MM-DL-\d{8}"
    r"|MM-NAV-\d{8}-\d{2}"
    r"|MM-[A-Z]{2,10}-\d{3,4}[A-Z]?"
    r")\b"
)
PLACEHOLDER_RE = re.compile(
    r"\[(?:DOPLNIT UŽIVATELEM|DOPLNIT UZIVATELEM)[^\]]*\]",
    re.IGNORECASE,
)
VERSION_RE = re.compile(r"\b\d+\.\d+\b")
STATUS_RE = re.compile(
    r"\b(DRAFT|IN_PROGRESS|REVIEW|APPROVED|ACTIVE|DEPRECATED|ARCHIVED|CANCELLED)\b",
    re.IGNORECASE,
)
DATE_RE = re.compile(
    r"\b(?:20\d{2}[-./]\d{1,2}[-./]\d{1,2}|\d{1,2}[.\-/]\d{1,2}[.\-/]20\d{2})\b"
)
GIT_COMMIT_RE = re.compile(r"\b[0-9a-fA-F]{7,64}\b")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$", re.MULTILINE)
TABLE_METADATA_KEY_RE = re.compile(
    r"\|\s*(Dokument|Označení|Document ID|Název|Název dokumentu|Verze|Stav|Edice|Datum|Autor|Autor projektu|Technická spolupráce|Primární formát|Umístění)\s*\|",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class Rule:
    rule_id: str
    title: str
    severity: str
    standard: str
    description: str
    aliases: tuple[str, ...] = ()
    category: str = "STRUCTURE"
    manual_review: bool = False


@dataclass
class Finding:
    rule_id: str
    title: str
    category: str
    severity: str
    standard: str
    result: str
    description: str
    evidence: list[str]
    recommendation: str
    score_weight: int
    passed_weight: int


COMMON_RULES: tuple[Rule, ...] = (
    Rule(
        "COMMON-DOC-ID",
        "Jednoznačný identifikátor dokumentu",
        "HIGH",
        "MM-STD-004 §4; MM-STD-007 §3",
        "Dokument má obsahovat jedinečný Document ID ve formátu MM-XXX-NNN.",
        category="METADATA",
    ),
    Rule(
        "COMMON-TITLE",
        "Jednoznačný název dokumentu",
        "HIGH",
        "MM-STD-004 §6",
        "Dokument musí obsahovat název odpovídající skutečnému obsahu.",
        category="METADATA",
    ),
    Rule(
        "COMMON-VERSION",
        "Číslo verze",
        "MEDIUM",
        "MM-STD-001 §8; MM-STD-003",
        "Oficiální dokument má uvádět číslo verze.",
        category="METADATA",
    ),
    Rule(
        "COMMON-STATUS",
        "Stav dokumentu",
        "MEDIUM",
        "MM-STD-004 §6; MM-STD-003",
        "Dokument má uvádět řízený stav, například DRAFT, REVIEW nebo ACTIVE.",
        category="METADATA",
    ),
    Rule(
        "COMMON-METADATA-SECTION",
        "Sekce Informace o dokumentu",
        "HIGH",
        "MM-STD-001 §4",
        "Dokument má mít přehlednou sekci s identifikačními údaji.",
        aliases=("informace o dokumentu", "identifikace dokumentu", "metadata dokumentu"),
        category="METADATA",
    ),
    Rule(
        "COMMON-FILENAME",
        "Standardizovaný název souboru",
        "MEDIUM",
        "MM-STD-004 §7; MM-STD-007 §5",
        "Název souboru má začínat Document ID a používat podtržítka bez mezer.",
        category="NAMING",
    ),
    Rule(
        "COMMON-TERMINOLOGY",
        "Jednotná terminologie",
        "MEDIUM",
        "MM-STD-006",
        "Terminologie má odpovídat MM-REF-001 a nové odborné pojmy mají být vysvětleny.",
        category="TERMINOLOGY",
        manual_review=True,
    ),
    Rule(
        "COMMON-PLACEHOLDERS",
        "Nevyplněné placeholdery",
        "MEDIUM",
        "MM-STD-001; MM-STD-004",
        "Kandidát připravený ke schválení nesmí obsahovat pole DOPLNIT UŽIVATELEM.",
        category="METADATA",
    ),
)


DAILY_RULES: tuple[Rule, ...] = (
    Rule(
        "DAILY-IDENTIFICATION",
        "Identifikace denního zápisu",
        "HIGH",
        "MM-DOC-900 §5.1",
        "Denní zápis má obsahovat datum, název nebo označení, autora a pracovní oblast.",
        aliases=("identifikace", "hlavička zápisu", "informace o zápisu", "základní údaje"),
        category="STRUCTURE",
    ),
    Rule(
        "DAILY-DATE",
        "Datum pracovního dne",
        "HIGH",
        "MM-DOC-900 §5.1",
        "Denní zápis musí být časově ukotven konkrétním datem.",
        category="METADATA",
    ),
    Rule(
        "DAILY-INITIAL-STATE",
        "Výchozí stav",
        "HIGH",
        "MM-DOC-900 §5.2",
        "Zápis má popsat stav projektu před zahájením práce.",
        aliases=("výchozí stav", "stav na začátku", "počáteční stav", "kontext dne"),
    ),
    Rule(
        "DAILY-WORK-DONE",
        "Provedené práce",
        "CRITICAL",
        "MM-DOC-900 §5.3",
        "Zápis musí zachytit významné provedené práce a jejich důvod.",
        aliases=("provedené práce", "co bylo provedeno", "průběh práce", "realizované práce", "dnešní práce"),
    ),
    Rule(
        "DAILY-DECISIONS",
        "Přijatá rozhodnutí",
        "MEDIUM",
        "MM-DOC-900 §5.4",
        "Významná rozhodnutí mají být zapsána samostatně, pokud vznikla.",
        aliases=("přijatá rozhodnutí", "rozhodnutí", "dohodnutá pravidla", "závěry a rozhodnutí"),
    ),
    Rule(
        "DAILY-PROBLEMS",
        "Problémy a jejich řešení",
        "MEDIUM",
        "MM-DOC-900 §5.5",
        "Chyby a problémy mají obsahovat příčinu, analýzu, řešení a výsledek.",
        aliases=("problémy", "chyby", "problémy a řešení", "zjištěné problémy", "blokátory"),
    ),
    Rule(
        "DAILY-RESULTS",
        "Výsledky dne",
        "HIGH",
        "MM-DOC-900 §5.6",
        "Zápis má shrnout dokončené, odložené a rozpracované oblasti.",
        aliases=("výsledky dne", "výsledek", "shrnutí dne", "stav na konci dne", "dosažené výsledky"),
    ),
    Rule(
        "DAILY-CONTINUATION",
        "Plán pokračování",
        "CRITICAL",
        "MM-DOC-900 §6",
        "Denní zápis musí obsahovat plán další práce a důležité návaznosti.",
        aliases=("plán pokračování", "další práce", "co dále", "pokračování", "plán na další den"),
    ),
    Rule(
        "DAILY-ONE-NEXT-STEP",
        "Jeden hlavní další krok",
        "CRITICAL",
        "MM-DOC-900 §6.1",
        "Na konci zápisu má být určen jeden hlavní konkrétní další krok.",
        aliases=("další krok", "první další krok", "hlavní další krok", "next step"),
    ),
    Rule(
        "DAILY-NAVAZANI-LINK",
        "Vazba na NAVÁZÁNÍ",
        "MEDIUM",
        "MM-DOC-900 §6.2",
        "Významnější denní zápis má uvést, zda je potřeba aktualizovat NAVÁZÁNÍ.",
        aliases=("navázání", "vazba na navázání", "navazující dokument"),
    ),
    Rule(
        "DAILY-VERIFIED-OUTPUTS",
        "Ověřené výsledky a technické zdroje",
        "MEDIUM",
        "MM-DOC-900 §5.3 a §5.5",
        "Zápis má uvádět relevantní soubory, skripty, databázové objekty nebo výsledky auditů.",
        aliases=("ověření", "výsledky a ověření", "použité skripty", "vytvořené soubory", "technické výstupy", "vazby"),
    ),
)


CONTINUATION_RULES: tuple[Rule, ...] = (
    Rule(
        "CONT-IDENTIFICATION",
        "Identifikace navázání",
        "CRITICAL",
        "MM-DOC-901 §5.1",
        "Navázání má obsahovat datum a čas, pracovní oblast, etapu, zdroj, vazbu a stav.",
        aliases=("identifikace", "informace o navázání", "základní údaje"),
    ),
    Rule(
        "CONT-CONTEXT",
        "Výchozí kontext",
        "HIGH",
        "MM-DOC-901 §5.2",
        "Navázání má stručně popsat cíl ukončené etapy a hlavní technický kontext.",
        aliases=("výchozí kontext", "kontext", "na co navazujeme", "výchozí stav"),
    ),
    Rule(
        "CONT-CURRENT-STATUS",
        "Aktuální stav",
        "CRITICAL",
        "MM-DOC-901 §5.3; MM-STD-009 §2",
        "Navázání musí vycházet z posledních ověřených informací o projektu.",
        aliases=("aktuální stav", "current status", "současný stav", "stav projektu"),
    ),
    Rule(
        "CONT-COMPLETED",
        "Co bylo dokončeno",
        "CRITICAL",
        "MM-DOC-901 §5.4",
        "Navázání musí shrnout významné výsledky poslední etapy.",
        aliases=("co bylo dokončeno", "dokončeno", "hotové práce", "výsledky etapy"),
    ),
    Rule(
        "CONT-IN-PROGRESS",
        "Co zůstává rozpracováno",
        "HIGH",
        "MM-DOC-901 §5.5",
        "Musí být zřejmé, kde byla práce přerušena a co ještě chybí.",
        aliases=("co zůstává rozpracováno", "rozpracováno", "nedokončené práce", "otevřená práce"),
    ),
    Rule(
        "CONT-OPEN-TASKS",
        "Otevřené úkoly",
        "HIGH",
        "MM-DOC-901 §5.6; MM-STD-009 §2",
        "Otevřené úkoly mají být uvedeny a podle potřeby prioritizovány.",
        aliases=("otevřené úkoly", "open questions", "otevřené otázky", "backlog", "úkoly"),
    ),
    Rule(
        "CONT-RISKS",
        "Rizika a upozornění",
        "HIGH",
        "MM-DOC-901 §5.7",
        "Navázání má zachytit známá omezení, rizika a neověřené předpoklady.",
        aliases=("rizika", "upozornění", "omezení", "blokátory", "známé problémy"),
    ),
    Rule(
        "CONT-DECISIONS",
        "Přijatá rozhodnutí",
        "MEDIUM",
        "MM-DOC-901 §5.8",
        "Významná rozhodnutí mají být oddělena od pracovního stavu.",
        aliases=("přijatá rozhodnutí", "rozhodnutí", "governance rozhodnutí", "architektonická rozhodnutí"),
    ),
    Rule(
        "CONT-SOURCES",
        "Ověřené zdroje a odkazy",
        "CRITICAL",
        "MM-DOC-901 §5.9",
        "Navázání má uvádět konkrétní soubory, skripty, objekty, audity a Git stav.",
        aliases=("ověřené zdroje", "zdroje a odkazy", "soubory a skripty", "technické zdroje", "vazby"),
    ),
    Rule(
        "CONT-AI-CONTEXT",
        "AI CONTEXT",
        "HIGH",
        "MM-STD-009 §2",
        "Navazovací dokument pro AI má obsahovat sekci AI CONTEXT.",
        aliases=("ai context",),
    ),
    Rule(
        "CONT-PROJECT-SNAPSHOT",
        "PROJECT SNAPSHOT",
        "HIGH",
        "MM-STD-009 §2",
        "Navazovací dokument pro AI má obsahovat sekci PROJECT SNAPSHOT.",
        aliases=("project snapshot",),
    ),
    Rule(
        "CONT-DATABASE-SNAPSHOT",
        "DATABASE SNAPSHOT",
        "HIGH",
        "MM-STD-009 §2",
        "Navazovací dokument pro AI má obsahovat sekci DATABASE SNAPSHOT.",
        aliases=("database snapshot",),
    ),
    Rule(
        "CONT-NEXT-STEP",
        "Jeden doporučený další krok",
        "CRITICAL",
        "MM-DOC-901 §5.10; MM-STD-009 §2",
        "Navázání musí určit první konkrétní a ověřitelný krok další etapy.",
        aliases=("doporučený další krok", "další krok", "next step", "první krok"),
    ),
)


MAIN_RULES: tuple[Rule, ...] = (
    Rule(
        "MAIN-INTRO",
        "Úvod",
        "CRITICAL",
        "MM-STD-001 §4",
        "Hlavní dokument musí obsahovat úvod.",
        aliases=("úvod",),
    ),
    Rule(
        "MAIN-BODY",
        "Hlavní kapitoly",
        "CRITICAL",
        "MM-STD-001 §4–5",
        "Dokument musí obsahovat odborné hlavní kapitoly.",
        category="CONTENT",
    ),
    Rule(
        "MAIN-CONCLUSION",
        "Závěr dokumentu",
        "CRITICAL",
        "MM-STD-001 §4",
        "Hlavní dokument musí obsahovat závěr.",
        aliases=("závěr", "závěr dokumentu", "závěr standardu"),
    ),
    Rule(
        "MAIN-VERSION-HISTORY",
        "Historie verzí",
        "HIGH",
        "MM-STD-001 §4 a §8; MM-STD-003",
        "Dokument musí obsahovat historii verzí.",
        aliases=("historie verzí", "version history"),
    ),
    Rule(
        "MAIN-CHAPTER-CONCLUSIONS",
        "Závěry hlavních kapitol",
        "HIGH",
        "MM-STD-001 §6",
        "Každá hlavní kapitola má mít shrnutí, přínos a návaznost.",
        category="STRUCTURE",
        manual_review=True,
    ),
    Rule(
        "MAIN-RELATIONS",
        "Vazby na ostatní dokumenty",
        "MEDIUM",
        "MM-STD-001 §3; MM-STD-004 §9",
        "Hlavní dokument má používat řízené odkazy přes Document ID.",
        category="RELATIONS",
    ),
)


SEVERITY_WEIGHT = {
    "CRITICAL": 12,
    "HIGH": 8,
    "MEDIUM": 4,
    "LOW": 2,
    "INFO": 0,
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit souladu Markdown dokumentu se standardy MatchMatrix."
    )
    parser.add_argument(
        "--document",
        required=True,
        help="Relativní nebo absolutní cesta k Markdown dokumentu.",
    )
    parser.add_argument(
        "--document-type",
        default="AUTO",
        choices=sorted(SUPPORTED_TYPES),
        help="Typ dokumentu; výchozí AUTO.",
    )
    parser.add_argument(
        "--output-dir",
        help="Volitelná výstupní složka. Výchozí reports/documentation/standardization.",
    )
    parser.add_argument(
        "--stdout-findings",
        type=int,
        default=30,
        help="Maximální počet zobrazených nevyhovujících pravidel.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    without_marks = "".join(ch for ch in decomposed if not unicodedata.combining(ch))
    lowered = without_marks.lower()
    lowered = re.sub(r"[`*_#>|]", " ", lowered)
    lowered = re.sub(r"[^a-z0-9]+", " ", lowered)
    return re.sub(r"\s+", " ", lowered).strip()


def resolve_document(root: Path, value: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def read_markdown(path: Path) -> tuple[str, bytes]:
    if not path.is_file():
        raise FileNotFoundError(f"Dokument nebyl nalezen: {path}")
    if path.suffix.lower() not in {".md", ".markdown", ".txt"}:
        raise RuntimeError("A17 podporuje Markdown nebo textové dokumenty.")
    raw = path.read_bytes()
    return raw.decode("utf-8-sig", errors="strict"), raw


def extract_headings(text: str) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for match in HEADING_RE.finditer(text):
        result.append(
            {
                "level": len(match.group(1)),
                "title": match.group(2).strip(),
                "normalized": normalize(match.group(2)),
                "line": text.count("\n", 0, match.start()) + 1,
            }
        )
    return result


def heading_matches(headings: Sequence[Mapping[str, Any]], aliases: Iterable[str]) -> list[str]:
    normalized_aliases = [normalize(alias) for alias in aliases if alias]
    matches: list[str] = []
    for heading in headings:
        value = str(heading["normalized"])
        for alias in normalized_aliases:
            if alias == value or alias in value or value in alias:
                matches.append(f"řádek {heading['line']}: {heading['title']}")
                break
    return matches


def text_contains_alias(text: str, aliases: Iterable[str]) -> list[str]:
    normalized_text = normalize(text)
    result: list[str] = []
    for alias in aliases:
        norm = normalize(alias)
        if norm and norm in normalized_text:
            result.append(alias)
    return result


def detect_type(path: Path, text: str, headings: Sequence[Mapping[str, Any]]) -> tuple[str, list[str]]:
    name = normalize(path.stem)
    normalized_text = normalize(text[:12000])
    heading_text = " ".join(str(item["normalized"]) for item in headings)
    evidence: list[str] = []

    daily_score = 0
    continuation_score = 0
    main_score = 0

    if any(token in name for token in ("denni zapis", "daily log", "zapis prace")):
        daily_score += 8
        evidence.append("Název souboru odpovídá dennímu zápisu.")
    if any(token in name for token in ("navazani", "navazujici", "new chat", "novy chat")):
        continuation_score += 8
        evidence.append("Název souboru odpovídá dokumentu NAVÁZÁNÍ.")

    for alias in ("vychozi stav", "provedene prace", "vysledky dne", "plan pokracovani"):
        if alias in heading_text:
            daily_score += 2
    for alias in ("ai context", "project snapshot", "database snapshot", "current status", "next step"):
        if alias in heading_text:
            continuation_score += 2
    for alias in ("informace o dokumentu", "historie verzi", "zaver dokumentu"):
        if alias in heading_text:
            main_score += 2

    if "kazdy pracovni den" in normalized_text or "denni zapis" in normalized_text:
        daily_score += 1
    if "novy chat" in normalized_text or "pracovni etapa" in normalized_text or "navazani" in normalized_text:
        continuation_score += 1
    if DOCUMENT_ID_RE.search(text) and len(headings) >= 5:
        main_score += 2

    scores = {
        "DAILY_LOG": daily_score,
        "CHAT_CONTINUATION": continuation_score,
        "MAIN_DOCUMENT": main_score,
    }
    detected = max(scores, key=scores.get)
    top = scores[detected]
    sorted_values = sorted(scores.values(), reverse=True)

    if top < 4 or (len(sorted_values) > 1 and sorted_values[0] == sorted_values[1]):
        return "GENERIC_DOCUMENT", evidence + [f"Detekční skóre: {scores}"]

    return detected, evidence + [f"Detekční skóre: {scores}"]


def make_finding(
    rule: Rule,
    result: str,
    evidence: list[str],
    recommendation: str,
    *,
    partial_fraction: float = 0.5,
) -> Finding:
    weight = SEVERITY_WEIGHT[rule.severity]
    if result == "PASS":
        passed = weight
    elif result == "PARTIAL":
        passed = round(weight * partial_fraction)
    else:
        passed = 0
    return Finding(
        rule_id=rule.rule_id,
        title=rule.title,
        category=rule.category,
        severity=rule.severity,
        standard=rule.standard,
        result=result,
        description=rule.description,
        evidence=evidence,
        recommendation=recommendation,
        score_weight=weight,
        passed_weight=passed,
    )



def valid_calendar_token(value: str) -> bool:
    try:
        datetime.strptime(value, "%Y%m%d")
        return True
    except ValueError:
        return False


def valid_document_filename(filename: str) -> bool:
    if " " in filename:
        return False

    path = Path(filename)
    if path.suffix.lower() not in {".md", ".markdown", ".txt"}:
        return False

    stem = path.stem
    if stem.upper() != stem:
        return False

    daily = re.fullmatch(
        r"MM-DL-(\d{8})_MATCHMATRIX_DENNI_ZAPIS",
        stem,
    )
    if daily:
        return valid_calendar_token(daily.group(1))

    continuation = re.fullmatch(
        r"MM-NAV-(\d{8})-(\d{2})_MATCHMATRIX_NAVAZANI_DO_CHATU",
        stem,
    )
    if continuation:
        return (
            valid_calendar_token(continuation.group(1))
            and int(continuation.group(2)) >= 1
        )

    return (
        re.fullmatch(
            r"MM-[A-Z]{2,10}-\d{3,4}[A-Z]?_[A-Z0-9_ÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ]+",
            stem,
        )
        is not None
    )


def evaluate_common(path: Path, text: str, headings: Sequence[Mapping[str, Any]]) -> list[Finding]:
    findings: list[Finding] = []
    ids = DOCUMENT_ID_RE.findall(text[:8000])
    if ids:
        findings.append(make_finding(COMMON_RULES[0], "PASS", sorted(set(ids)), "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[0], "FAIL", [], "Doplnit jednoznačný Document ID nebo označit dokument jako pracovní záznam mimo kanonický registr."))

    h1 = [h for h in headings if int(h["level"]) == 1]
    if h1:
        findings.append(make_finding(COMMON_RULES[1], "PASS", [f"řádek {h1[0]['line']}: {h1[0]['title']}"], "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[1], "FAIL", [], "Doplnit hlavní nadpis dokumentu."))

    versions = VERSION_RE.findall(text[:8000])
    if versions:
        findings.append(make_finding(COMMON_RULES[2], "PASS", sorted(set(versions))[:5], "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[2], "FAIL", [], "Doplnit číslo verze do metadat dokumentu."))

    statuses = STATUS_RE.findall(text[:8000])
    if statuses:
        findings.append(make_finding(COMMON_RULES[3], "PASS", sorted(set(x.upper() for x in statuses)), "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[3], "FAIL", [], "Doplnit řízený stav dokumentu."))

    evidence = heading_matches(headings, COMMON_RULES[4].aliases)
    if evidence or TABLE_METADATA_KEY_RE.search(text[:8000]):
        findings.append(make_finding(COMMON_RULES[4], "PASS", evidence or ["Nalezena tabulka identifikačních metadat."], "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[4], "FAIL", [], "Doplnit sekci Informace o dokumentu nebo odpovídající identifikační hlavičku."))

    filename = path.name
    filename_ok = valid_document_filename(filename)
    if filename_ok:
        findings.append(make_finding(COMMON_RULES[5], "PASS", [filename], "Bez akce."))
    else:
        findings.append(make_finding(COMMON_RULES[5], "FAIL", [filename], "Navrhnout standardizovaný název souboru začínající Document ID a používající podtržítka."))

    findings.append(make_finding(COMMON_RULES[6], "MANUAL_REVIEW", ["Automatický audit neumí spolehlivě posoudit význam všech odborných pojmů."], "Porovnat terminologii s MM-REF-001; později využít terminologický engine.", partial_fraction=0.5))

    placeholders = PLACEHOLDER_RE.findall(text)
    if placeholders:
        findings.append(
            make_finding(
                COMMON_RULES[7],
                "FAIL",
                sorted(set(placeholders))[:20],
                "Doplnit nebo schváleně odstranit všechny placeholdery před kanonickým schválením.",
            )
        )
    else:
        findings.append(
            make_finding(
                COMMON_RULES[7],
                "PASS",
                ["Nebyl nalezen žádný placeholder DOPLNIT UŽIVATELEM."],
                "Bez akce.",
            )
        )
    return findings


def evaluate_alias_rule(rule: Rule, text: str, headings: Sequence[Mapping[str, Any]]) -> Finding:
    evidence = heading_matches(headings, rule.aliases)
    if evidence:
        return make_finding(rule, "PASS", evidence, "Bez akce.")
    textual = text_contains_alias(text, rule.aliases)
    if textual:
        return make_finding(
            rule,
            "PARTIAL",
            [f"Pojem nalezen pouze v textu: {item}" for item in textual[:5]],
            "Doplnit nebo sjednotit samostatnou nadpisovou sekci podle standardu.",
        )
    return make_finding(rule, "FAIL", [], f"Doplnit samostatnou sekci: {rule.title}.")


def evaluate_daily(text: str, headings: Sequence[Mapping[str, Any]]) -> list[Finding]:
    findings: list[Finding] = []
    for rule in DAILY_RULES:
        if rule.rule_id == "DAILY-DATE":
            dates = DATE_RE.findall(text[:10000])
            if dates:
                findings.append(make_finding(rule, "PASS", sorted(set(dates))[:5], "Bez akce."))
            else:
                findings.append(make_finding(rule, "FAIL", [], "Doplnit konkrétní datum pracovního dne."))
        elif rule.rule_id == "DAILY-VERIFIED-OUTPUTS":
            technical = []
            for pattern, label in (
                (r"\b[\w.-]+\.py\b", "Python soubor"),
                (r"\b[\w.-]+\.sql\b", "SQL soubor"),
                (r"\b[\w.-]+\.md\b", "Markdown soubor"),
                (r"\b(?:documentation|ops|staging|public)\.[a-zA-Z_][\w]*\b", "databázový objekt"),
            ):
                matches = re.findall(pattern, text)
                if matches:
                    technical.extend(f"{label}: {item}" for item in matches[:5])
            if technical:
                findings.append(make_finding(rule, "PASS", technical[:10], "Bez akce."))
            else:
                findings.append(make_finding(rule, "FAIL", [], "Doplnit konkrétní soubory, skripty, SQL objekty nebo ověřené výsledky."))
        else:
            findings.append(evaluate_alias_rule(rule, text, headings))
    return findings


def evaluate_continuation(text: str, headings: Sequence[Mapping[str, Any]]) -> list[Finding]:
    findings = [evaluate_alias_rule(rule, text, headings) for rule in CONTINUATION_RULES]
    dates = DATE_RE.findall(text[:10000])
    if not dates:
        pseudo = Rule(
            "CONT-DATE",
            "Datum a čas uzavření",
            "HIGH",
            "MM-DOC-901 §5.1",
            "Navázání musí být časově ukotveno.",
            category="METADATA",
        )
        findings.append(make_finding(pseudo, "FAIL", [], "Doplnit datum a podle možností čas uzavření pracovní etapy."))
    else:
        pseudo = Rule(
            "CONT-DATE",
            "Datum a čas uzavření",
            "HIGH",
            "MM-DOC-901 §5.1",
            "Navázání musí být časově ukotveno.",
            category="METADATA",
        )
        findings.append(make_finding(pseudo, "PASS", sorted(set(dates))[:5], "Bez akce."))

    commits = GIT_COMMIT_RE.findall(text)
    paths = re.findall(r"(?:[A-Za-z]:\\[^\n`|]+|(?:docs|db|tools|workers|reports)/[^\s`|]+)", text)
    if commits or paths:
        pseudo = Rule(
            "CONT-TECHNICAL-TRACEABILITY",
            "Technická dohledatelnost",
            "HIGH",
            "MM-DOC-901 §5.9",
            "Navázání má obsahovat konkrétní Git commit, soubor nebo databázový zdroj.",
            category="RELATIONS",
        )
        findings.append(make_finding(pseudo, "PASS", ([f"Git: {x}" for x in commits[:3]] + [f"Cesta: {x}" for x in paths[:5]]), "Bez akce."))
    else:
        pseudo = Rule(
            "CONT-TECHNICAL-TRACEABILITY",
            "Technická dohledatelnost",
            "HIGH",
            "MM-DOC-901 §5.9",
            "Navázání má obsahovat konkrétní Git commit, soubor nebo databázový zdroj.",
            category="RELATIONS",
        )
        findings.append(make_finding(pseudo, "FAIL", [], "Doplnit konkrétní názvy souborů, skriptů, databázových objektů nebo Git commit."))
    return findings


def evaluate_main(text: str, headings: Sequence[Mapping[str, Any]]) -> list[Finding]:
    findings: list[Finding] = []
    for rule in MAIN_RULES:
        if rule.rule_id == "MAIN-BODY":
            main_chapters = [h for h in headings if int(h["level"]) == 1 and not any(alias in str(h["normalized"]) for alias in ("informace o dokumentu", "obsah", "zaver", "historie verzi"))]
            if len(main_chapters) >= 2:
                findings.append(make_finding(rule, "PASS", [f"Nalezeno hlavních kapitol: {len(main_chapters)}"], "Bez akce."))
            elif main_chapters:
                findings.append(make_finding(rule, "PARTIAL", [f"Nalezena pouze jedna hlavní kapitola: {main_chapters[0]['title']}"], "Prověřit, zda dokument obsahuje dostatečně rozvinuté hlavní kapitoly."))
            else:
                findings.append(make_finding(rule, "FAIL", [], "Doplnit odborné hlavní kapitoly."))
        elif rule.rule_id == "MAIN-CHAPTER-CONCLUSIONS":
            top = [h for h in headings if int(h["level"]) == 1]
            conclusions = [h for h in headings if "zaver" in str(h["normalized"]) or "shrnuti" in str(h["normalized"])]
            if len(top) <= 3:
                findings.append(make_finding(rule, "MANUAL_REVIEW", [f"Hlavních nadpisů: {len(top)}; závěrových/shrnujících nadpisů: {len(conclusions)}"], "Ručně ověřit, zda každá odborná hlavní kapitola končí shrnutím, přínosem a návazností."))
            elif len(conclusions) >= max(1, len(top) - 3):
                findings.append(make_finding(rule, "PASS", [f"Závěrových/shrnujících sekcí: {len(conclusions)}"], "Bez akce."))
            else:
                findings.append(make_finding(rule, "FAIL", [f"Hlavních nadpisů: {len(top)}; závěrových/shrnujících sekcí: {len(conclusions)}"], "Doplnit závěr ke každé hlavní kapitole nebo dokument předložit k ručnímu posouzení."))
        elif rule.rule_id == "MAIN-RELATIONS":
            ids = sorted(set(DOCUMENT_ID_RE.findall(text)))
            if len(ids) >= 2:
                findings.append(make_finding(rule, "PASS", ids[:15], "Bez akce."))
            elif len(ids) == 1:
                findings.append(make_finding(rule, "PARTIAL", ids, "Prověřit a doplnit související Document ID."))
            else:
                findings.append(make_finding(rule, "FAIL", [], "Doplnit řízené vazby na související dokumenty pomocí Document ID."))
        else:
            findings.append(evaluate_alias_rule(rule, text, headings))
    return findings


def overall_status(findings: Sequence[Finding]) -> tuple[str, str]:
    failed_critical = any(f.result == "FAIL" and f.severity == "CRITICAL" for f in findings)
    failed_high = sum(1 for f in findings if f.result == "FAIL" and f.severity == "HIGH")
    failed_total = sum(1 for f in findings if f.result == "FAIL")
    manual_total = sum(1 for f in findings if f.result == "MANUAL_REVIEW")
    partial_total = sum(1 for f in findings if f.result == "PARTIAL")

    if failed_critical or failed_high >= 3:
        return "RESTRUCTURE_REQUIRED", "Vytvořit standardizovaný návrh, zobrazit rozdíly a vyžádat schválení před uložením."
    if failed_high > 0:
        return "MISSING_REQUIRED_SECTIONS", "Doplnit povinné sekce a znovu spustit audit."
    if failed_total > 0:
        return "MINOR_FIX_REQUIRED", "Doplnit chybějící metadata nebo menší strukturální náležitosti."
    if manual_total > 0 or partial_total > 0:
        return "MANUAL_REVIEW_REQUIRED", "Provést ruční kontrolu označených pravidel; technická struktura je jinak přijatelná."
    return "COMPLIANT", "Dokument splňuje automaticky ověřitelná pravidla."


def score(findings: Sequence[Finding]) -> float:
    total = sum(f.score_weight for f in findings)
    passed = sum(f.passed_weight for f in findings)
    if total == 0:
        return 100.0
    return round(passed * 100.0 / total, 2)


def proposed_sections(document_type: str, findings: Sequence[Finding]) -> list[str]:
    missing = {f.rule_id for f in findings if f.result in {"FAIL", "PARTIAL"}}
    if document_type == "DAILY_LOG":
        ordered = [
            ("DAILY-IDENTIFICATION", "Identifikace zápisu"),
            ("DAILY-INITIAL-STATE", "Výchozí stav"),
            ("DAILY-WORK-DONE", "Provedené práce"),
            ("DAILY-DECISIONS", "Přijatá rozhodnutí"),
            ("DAILY-PROBLEMS", "Problémy a jejich řešení"),
            ("DAILY-RESULTS", "Výsledky dne / stav na konci dne"),
            ("DAILY-CONTINUATION", "Plán pokračování"),
            ("DAILY-ONE-NEXT-STEP", "Jeden hlavní další krok"),
            ("DAILY-NAVAZANI-LINK", "Vazba na NAVÁZÁNÍ"),
        ]
    elif document_type == "CHAT_CONTINUATION":
        ordered = [
            ("CONT-IDENTIFICATION", "Identifikace navázání"),
            ("CONT-CONTEXT", "Výchozí kontext"),
            ("CONT-CURRENT-STATUS", "CURRENT STATUS"),
            ("CONT-COMPLETED", "Co bylo dokončeno"),
            ("CONT-IN-PROGRESS", "Co zůstává rozpracováno"),
            ("CONT-OPEN-TASKS", "OPEN QUESTIONS / otevřené úkoly"),
            ("CONT-RISKS", "Rizika a upozornění"),
            ("CONT-DECISIONS", "Přijatá rozhodnutí"),
            ("CONT-SOURCES", "Ověřené zdroje a odkazy"),
            ("CONT-AI-CONTEXT", "AI CONTEXT"),
            ("CONT-PROJECT-SNAPSHOT", "PROJECT SNAPSHOT"),
            ("CONT-DATABASE-SNAPSHOT", "DATABASE SNAPSHOT"),
            ("CONT-NEXT-STEP", "NEXT STEP"),
        ]
    elif document_type == "MAIN_DOCUMENT":
        ordered = [
            ("COMMON-METADATA-SECTION", "Informace o dokumentu"),
            ("MAIN-INTRO", "Úvod"),
            ("MAIN-BODY", "Hlavní kapitoly"),
            ("MAIN-CONCLUSION", "Závěr dokumentu"),
            ("MAIN-VERSION-HISTORY", "Historie verzí"),
        ]
    else:
        ordered = [
            ("COMMON-METADATA-SECTION", "Informace o dokumentu"),
            ("COMMON-DOC-ID", "Document ID"),
            ("COMMON-VERSION", "Verze"),
            ("COMMON-STATUS", "Stav"),
        ]
    return [title for rule_id, title in ordered if rule_id in missing]


def markdown_report(payload: Mapping[str, Any]) -> str:
    lines = [
        "# MATCHMATRIX – AUDIT SOULADU DOKUMENTU SE STANDARDY",
        "",
        f"- Dokument: `{payload['document_path']}`",
        f"- SHA-256: `{payload['document_hash_sha256']}`",
        f"- Detekovaný typ: **{payload['document_type']}**",
        f"- Soulad: **{payload['compliance_score_percent']} %**",
        f"- Stav: **{payload['compliance_status']}**",
        f"- Doporučení: {payload['recommended_action']}",
        "",
        "## Souhrn",
        "",
        "| Výsledek | Počet |",
        "|---|---:|",
    ]
    for key, value in payload["result_counts"].items():
        lines.append(f"| {key} | {value} |")

    lines.extend([
        "",
        "## Zjištění",
        "",
        "| Pravidlo | Výsledek | Závažnost | Standard | Doporučení |",
        "|---|---|---|---|---|",
    ])
    for finding in payload["findings"]:
        recommendation = str(finding["recommendation"]).replace("|", "\\|")
        lines.append(
            f"| {finding['rule_id']} – {finding['title']} | {finding['result']} | "
            f"{finding['severity']} | {finding['standard']} | {recommendation} |"
        )

    missing = payload.get("proposed_missing_sections", [])
    if missing:
        lines.extend(["", "## Navržené chybějící sekce", ""])
        lines.extend(f"- {item}" for item in missing)

    lines.extend([
        "",
        "## Bezpečnostní závěr",
        "",
        "Tento audit původní dokument nezměnil. Případná standardizace musí vzniknout jako návrh s náhledem rozdílů a vyžaduje schválení uživatelem.",
        "",
    ])
    return "\n".join(lines)


def write_reports(root: Path, output_dir_arg: str | None, payload: dict[str, Any]) -> tuple[Path, Path, Path, Path]:
    if output_dir_arg:
        output_dir = Path(output_dir_arg)
        if not output_dir.is_absolute():
            output_dir = root / output_dir
    else:
        output_dir = root / "reports" / "documentation" / "standardization"
    output_dir.mkdir(parents=True, exist_ok=True)

    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")
    json_path = output_dir / f"{REPORT_PREFIX}_{stamp}.json"
    md_path = output_dir / f"{REPORT_PREFIX}_{stamp}.md"
    latest_json = output_dir / f"{REPORT_PREFIX}_latest.json"
    latest_md = output_dir / f"{REPORT_PREFIX}_latest.md"

    encoded = json.dumps(payload, ensure_ascii=False, indent=2)
    rendered = markdown_report(payload)
    for path in (json_path, latest_json):
        path.write_text(encoded, encoding="utf-8")
    for path in (md_path, latest_md):
        path.write_text(rendered, encoding="utf-8")
    return json_path, md_path, latest_json, latest_md


def main() -> int:
    args = parse_args()
    root = project_root()
    document_path = resolve_document(root, args.document)

    print("MATCHMATRIX DOCUMENT STANDARD COMPLIANCE AUDIT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"DOCUMENT           : {document_path}")
    print(f"REQUESTED TYPE     : {args.document_type}")
    print("DATABASE WRITES    : DISABLED")
    print("DOCUMENT WRITES    : DISABLED")
    print()

    try:
        text, raw = read_markdown(document_path)
        headings = extract_headings(text)
        detected, detection_evidence = detect_type(document_path, text, headings)
        document_type = detected if args.document_type == "AUTO" else args.document_type

        findings = evaluate_common(document_path, text, headings)
        if document_type == "DAILY_LOG":
            findings.extend(evaluate_daily(text, headings))
        elif document_type == "CHAT_CONTINUATION":
            findings.extend(evaluate_continuation(text, headings))
        elif document_type == "MAIN_DOCUMENT":
            findings.extend(evaluate_main(text, headings))

        compliance_status, recommended_action = overall_status(findings)
        compliance_score = score(findings)
        result_counts = {
            key: sum(1 for f in findings if f.result == key)
            for key in ("PASS", "PARTIAL", "FAIL", "MANUAL_REVIEW")
        }
        severity_counts = {
            key: sum(1 for f in findings if f.result != "PASS" and f.severity == key)
            for key in ("CRITICAL", "HIGH", "MEDIUM", "LOW")
        }

        payload: dict[str, Any] = {
            "generated_at": utc_now().isoformat(),
            "project_root": str(root),
            "document_path": str(document_path),
            "document_filename": document_path.name,
            "document_hash_sha256": hashlib.sha256(raw).hexdigest(),
            "document_size_bytes": len(raw),
            "heading_count": len(headings),
            "requested_document_type": args.document_type,
            "document_type": document_type,
            "type_detection_evidence": detection_evidence,
            "compliance_score_percent": compliance_score,
            "compliance_status": compliance_status,
            "recommended_action": recommended_action,
            "result_counts": result_counts,
            "severity_counts": severity_counts,
            "proposed_missing_sections": proposed_sections(document_type, findings),
            "findings": [asdict(f) for f in findings],
            "source_standards": sorted({f.standard for f in findings}),
            "document_modified": False,
            "final_status": "DOCUMENT_STANDARD_COMPLIANCE_AUDIT_READY",
        }

        json_path, md_path, latest_json, latest_md = write_reports(root, args.output_dir, payload)

        print("DETEKCE")
        print("-" * 79)
        print(f"DOCUMENT TYPE      : {document_type}")
        for item in detection_evidence:
            print(f"- {item}")
        print()

        print("SOUHRN")
        print("-" * 79)
        print(f"COMPLIANCE SCORE   : {compliance_score:.2f} %")
        print(f"COMPLIANCE STATUS  : {compliance_status}")
        print(f"PASS               : {result_counts['PASS']}")
        print(f"PARTIAL            : {result_counts['PARTIAL']}")
        print(f"FAIL               : {result_counts['FAIL']}")
        print(f"MANUAL REVIEW      : {result_counts['MANUAL_REVIEW']}")
        print(f"CRITICAL FINDINGS  : {severity_counts['CRITICAL']}")
        print(f"HIGH FINDINGS      : {severity_counts['HIGH']}")
        print(f"RECOMMENDED ACTION : {recommended_action}")

        problem_findings = [f for f in findings if f.result != "PASS"]
        if problem_findings:
            print()
            print("NEDOSTATKY")
            print("-" * 79)
            for finding in problem_findings[: max(args.stdout_findings, 0)]:
                print(
                    f"{finding.rule_id:<36} | {finding.result:<13} | "
                    f"{finding.severity:<8} | {finding.title}"
                )

        print()
        print(f"JSON REPORT        : {json_path}")
        print(f"MARKDOWN REPORT    : {md_path}")
        print(f"LATEST JSON        : {latest_json}")
        print(f"LATEST MARKDOWN    : {latest_md}")
        print("DOCUMENT MODIFIED  : False")
        print("FINAL STATUS       : DOCUMENT_STANDARD_COMPLIANCE_AUDIT_READY")
        return 0

    except Exception as exc:
        print("AUDIT ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("FINAL STATUS       : DOCUMENT_STANDARD_COMPLIANCE_AUDIT_BLOCKED")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
