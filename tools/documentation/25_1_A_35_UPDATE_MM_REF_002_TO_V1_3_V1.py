#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
===============================================================================
MatchMatrix
25_1_A_35_UPDATE_MM_REF_002_TO_V1_3_V1.py
===============================================================================

CO:
    Aktualizuje MM-REF-002 z verze 1.2 na verzi 1.3.

K ČEMU:
    Zachová všech 222 existujících výkladů, doplní 41 chybějících pojmů
    z MM-REF-001 v1.7, znovu sestaví klikací rejstřík a číslované výklady
    a ověří úplnou synchronizaci 263 / 263.

KDE:
    Aktivní nástroj:
    tools/documentation/25_1_A_35_UPDATE_MM_REF_002_TO_V1_3_V1.py

    Vstupy:
    docs/10_REFERENCE/MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md
    docs/10_REFERENCE/MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md

    Archiv:
    docs/99_ARCHIVE/10_REFERENCE/20260728_REFERENCE_UPDATE/

JAK:
    PROJECT_ROOT se odvodí z umístění skriptu.
    Skript funguje přímo na PC2 i v terminálu VS Code připojeném přes SSH.
    Před zápisem provede přísné kontroly vstupů a po zápisu úplnou validaci.
    Git commit ani databázový import neprovádí.
===============================================================================
"""

from __future__ import annotations

import hashlib
import re
import shutil
import subprocess
import sys
import unicodedata
from dataclasses import dataclass
from pathlib import Path


SCRIPT_VERSION = "1.0"
ENGINE = "A35_UPDATE_MM_REF_002_TO_V1_3_V1_0"
EXPECTED_OLD_COUNT = 222
EXPECTED_NEW_COUNT = 263
EXPECTED_MISSING_COUNT = 41


@dataclass(frozen=True)
class TermEntry:
    translation: str
    explanation: str
    source: str
    target_section: str


NEW_ENTRIES: dict[str, TermEntry] = {
    "Absolute Path": TermEntry(
        "Absolutní cesta",
        "Úplná cesta k souboru nebo složce začínající kořenem disku nebo síťového umístění. Nezávisí na aktuální pracovní složce.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Active Document": TermEntry(
        "Aktivní dokument",
        "Řízený dokument, který je v daném okamžiku oficiálně používán jako platný zdroj informací a pravidel.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Active File": TermEntry(
        "Aktivní soubor",
        "Jediný soubor uložený ve standardní aktivní cestě, který představuje aktuálně používanou podobu konkrétního dokumentu.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Active Version": TermEntry(
        "Aktivní verze",
        "Aktuálně platná a používaná verze dokumentu. Její číslo je uvedeno uvnitř dokumentu, nikoli v názvu aktivního souboru.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Archive Copy": TermEntry(
        "Archivní kopie",
        "Neměnná kopie dřívější významné verze nebo nahrazeného souboru uložená v řízeném archivu.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Canonical Source File": TermEntry(
        "Kanonický zdrojový soubor",
        "Jediný řízený zdrojový soubor považovaný za referenční podklad pro další zpracování, sestavení nebo publikaci dokumentu.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Canonicalization": TermEntry(
        "Kanonikalizace / sjednocení do referenční podoby",
        "Řízený proces sjednocení více zdrojových identit nebo záznamů do jedné referenční entity při zachování dohledatelnosti původních providerových identit.",
        "MM-DOC-300",
        "Architektura a datový tok",
    ),
    "Clean Git Tree": TermEntry(
        "Čistý pracovní strom Git",
        "Stav repozitáře, ve kterém nejsou žádné nezapsané změny, nové nesledované soubory ani neprovedené přesuny určené k zahrnutí do dalšího commitu.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Controlled Archive": TermEntry(
        "Řízený archiv",
        "Vyhrazená část projektu pro historické a nahrazené verze, v níž jsou zachovány identita, původ, důvod archivace a dohledatelnost souboru.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Controlled Document": TermEntry(
        "Řízený dokument",
        "Dokument spravovaný podle závazných pravidel identifikace, struktury, stavů, verzování, schvalování, archivace a publikace.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "Data type": TermEntry(
        "Datový typ",
        "Definice druhu hodnot, které může databázový sloupec nebo objekt obsahovat, včetně způsobu jejich ukládání a zpracování.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Database Audit": TermEntry(
        "Databázový audit",
        "Strukturovaná kontrola databázových schémat, objektů, vazeb, omezení, velikostí a rizik prováděná s dohledatelným výsledkem.",
        "MM-DOC-200",
        "Governance a audit",
    ),
    "Default value": TermEntry(
        "Výchozí hodnota",
        "Hodnota automaticky použitá databází, pokud při vložení záznamu není pro daný sloupec zadána vlastní hodnota.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Dirty Git Tree": TermEntry(
        "Pracovní strom Git s neuloženými změnami",
        "Stav repozitáře obsahující upravené, odstraněné nebo nové nesledované soubory, které dosud nejsou zahrnuty do commitu.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Document Type": TermEntry(
        "Typ dokumentu",
        "Klasifikace určující účel a roli dokumentu, například standard, referenční dokument, denní zápis, navázání nebo export.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "Downstream Layer": TermEntry(
        "Navazující datová vrstva",
        "Vrstva, tabulka nebo proces využívající výstupy předchozí části datového toku a závislý na jejich správnosti a úplnosti.",
        "MM-DOC-300",
        "Architektura a datový tok",
    ),
    "Evidence Source": TermEntry(
        "Důkazní zdroj",
        "Zdroj poskytující ověřitelný podklad pro závěr, rozhodnutí, mapování nebo změnu stavu. Musí být dohledatelný a přiměřeně důvěryhodný.",
        "MM-DOC-200",
        "Governance a audit",
    ),
    "Historical Alias": TermEntry(
        "Historický alias",
        "Dříve používaný identifikátor nebo název zachovaný pouze kvůli zpětné dohledatelnosti. Nesmí nahrazovat aktuální stabilní identitu.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "Host Computer": TermEntry(
        "Hostitelský počítač",
        "Počítač, ze kterého je nástroj nebo panel právě spuštěn. Nemusí být totožný s počítačem, na němž jsou data nebo databáze.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Host-independent": TermEntry(
        "Nezávislý na hostitelském počítači",
        "Vlastnost nástroje, který odvozuje projektové cesty a cílové prostředí z konfigurace nebo vlastního umístění a není pevně svázán s jedním PC.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Nullable": TermEntry(
        "Povolující hodnotu NULL",
        "Vlastnost databázového sloupce určující, že může obsahovat hodnotu NULL, tedy neznámou nebo nezadanou hodnotu.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Ordinal position": TermEntry(
        "Pořadí sloupce",
        "Číselné pořadí sloupce v definici databázové tabulky nebo pohledu.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Post-commit Audit": TermEntry(
        "Audit po trvalém potvrzení změny",
        "Kontrola provedená po databázovém COMMITu nebo jiném trvalém zápisu, která ověřuje skutečný výsledný stav a ne pouze plánovanou změnu.",
        "MM-DOC-200",
        "Governance a audit",
    ),
    "Precision": TermEntry(
        "Přesnost",
        "Celkový maximální počet číslic, které může obsahovat číselný databázový typ s pevnou přesností.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Project Root": TermEntry(
        "Kořenová složka projektu",
        "Nejvyšší řízená složka repozitáře, od níž se odvozují relativní cesty k dokumentům, nástrojům, databázovým skriptům a výstupům.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Provider Identity": TermEntry(
        "Identita entity u poskytovatele dat",
        "Jedinečná kombinace poskytovatele, typu entity a jeho zdrojového identifikátoru používaná pro vazbu na kanonickou entitu MatchMatrix.",
        "MM-DOC-300",
        "Architektura a datový tok",
    ),
    "Read Only": TermEntry(
        "Pouze pro čtení",
        "Režim, ve kterém nástroj nebo databázová transakce smí data pouze číst a nesmí provést trvalou změnu.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Reference Document": TermEntry(
        "Referenční dokument",
        "Autoritativní řízený dokument určený jako společný zdroj konkrétních informací, definic, seznamů nebo pravidel pro ostatní části projektu.",
        "MM-STD-008",
        "Správa terminologie a referenčního slovníku",
    ),
    "Relative Path": TermEntry(
        "Relativní cesta",
        "Cesta vyjádřená vzhledem ke kořenové nebo aktuální pracovní složce bez pevného uvedení disku či síťového serveru.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Review Version": TermEntry(
        "Verze určená ke kontrole",
        "Pracovní řízená verze připravená k věcné, technické nebo uživatelské kontrole před schválením a aktivací.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Scale": TermEntry(
        "Desetinný rozsah",
        "Počet číslic povolených za desetinnou čárkou u číselného databázového typu s pevnou přesností.",
        "MM-DB-003",
        "Terminologičtí kandidáti",
    ),
    "Single Active File": TermEntry(
        "Jediný aktivní soubor",
        "Pravidlo, podle kterého smí pro jeden Document ID a jednu aktivní edici existovat v aktivních složkách právě jeden zdrojový soubor.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Single Active Truth": TermEntry(
        "Jediná aktivní referenční pravda",
        "Princip, že aktuální stav určitého řízeného dokumentu nebo informace má právě jedno oficiální aktivní místo a ostatní kopie jsou pouze historické nebo pracovní.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
    "Stable Document ID": TermEntry(
        "Stabilní identifikátor dokumentu",
        "Neměnný identifikátor přidělený dokumentu po celou dobu jeho životního cyklu bez ohledu na změny verze, stavu, edice nebo umístění.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "Stable Filename": TermEntry(
        "Stabilní název souboru",
        "Aktivní název souboru odvozený od Document ID a popisného názvu, který se při běžném verzování nemění a neobsahuje číslo verze ani dlouhodobý příznak REVIEW.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Target Computer": TermEntry(
        "Cílový počítač",
        "Počítač, na kterém má být příkaz, databázový krok nebo souborová operace skutečně provedena, i když je řízena z jiného hostitelského PC.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Time-based ID": TermEntry(
        "Identifikátor založený na datu",
        "Identifikátor, jehož významnou část tvoří datum a případně pořadové číslo, například u denních zápisů, navázání nebo exportů.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "UNC Path": TermEntry(
        "Síťová cesta UNC",
        "Síťová cesta ve tvaru dvě zpětná lomítka, server a sdílená složka, používaná pro přístup k souborům na jiném počítači.",
        "MM-STD-004",
        "Názvosloví a struktura dokumentace",
    ),
    "Validate Only": TermEntry(
        "Pouze ověřit bez trvalého zápisu",
        "Bezpečný režim, který provede všechny dostupné kontroly a sestaví výsledek, ale změny na konci vrátí zpět nebo je vůbec nezapíše.",
        "MM-DOC-800",
        "Vývojové a provozní postupy",
    ),
    "Verification Hierarchy": TermEntry(
        "Hierarchie ověřování",
        "Stanovené pořadí důvěryhodnosti důkazů a kontrol, podle něhož mají přímá databázová měření, aktivní soubory a ověřené výstupy přednost před staršími souhrny nebo odhady.",
        "MM-STD-007",
        "Identifikace dokumentů",
    ),
    "Working Copy": TermEntry(
        "Pracovní kopie",
        "Dočasná upravovaná kopie dokumentu nebo souboru, která ještě není aktivní schválenou verzí a nesmí být zaměněna za referenční zdroj.",
        "MM-STD-003",
        "Životní cyklus a stavy",
    ),
}


def fail(message: str) -> "NoReturn":
    raise RuntimeError(message)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def slugify(term: str) -> str:
    normalized = unicodedata.normalize("NFKD", term)
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", ascii_text.lower()).strip("-")
    if not slug:
        fail(f"Nelze vytvořit kotvu pro pojem: {term!r}")
    return f"term-{slug}"


def extract_between(text: str, start_pattern: str, end_pattern: str, label: str) -> str:
    match = re.search(
        rf"(?ms){start_pattern}\s*\r?\n(?P<body>.*?)(?={end_pattern})",
        text,
    )
    if not match:
        fail(f"Nebyla nalezena sekce: {label}")
    return match.group("body")


def parse_ref001_terms(text: str) -> dict[str, str]:
    body = extract_between(
        text,
        r"^#\s+3\.\s+Překladový slovník\s*$",
        r"^#\s+4\.\s+Souhrn verze",
        "MM-REF-001 / 3. Překladový slovník",
    )

    result: dict[str, str] = {}
    row_pattern = re.compile(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$")

    for line in body.splitlines():
        match = row_pattern.match(line)
        if not match:
            continue
        term = match.group(1).strip()
        translation = match.group(2).strip()
        if term in {"Cizí výraz", "---"}:
            continue
        if term in result:
            fail(f"Duplicitní pojem v MM-REF-001: {term}")
        result[term] = translation

    return result


def parse_index(text: str) -> dict[str, tuple[str, str, str, str]]:
    body = extract_between(
        text,
        r"^#\s+2\.\s+Klikací rejstřík\s*$",
        r"^#\s+3\.\s+Výklady pojmů\s*$",
        "MM-REF-002 / 2. Klikací rejstřík",
    )

    result: dict[str, tuple[str, str, str, str]] = {}
    row_pattern = re.compile(
        r"^\|\s*([^|]+?)\s*"
        r"\|\s*([^|]+?)\s*"
        r"\|\s*\[Otevřít výklad\]\(#([^)]+)\)\s*"
        r"\|\s*([^|]+?)\s*"
        r"\|\s*([^|]+?)\s*\|$"
    )

    for line in body.splitlines():
        match = row_pattern.match(line)
        if not match:
            continue
        term = match.group(1).strip()
        translation = match.group(2).strip()
        anchor = match.group(3).strip()
        source = match.group(4).strip()
        target = match.group(5).strip()
        if term in result:
            fail(f"Duplicitní pojem v klikacím rejstříku MM-REF-002: {term}")
        result[term] = (translation, anchor, source, target)

    return result


def parse_detail_blocks(text: str) -> dict[str, str]:
    details_body = extract_between(
        text,
        r"^#\s+3\.\s+Výklady pojmů\s*$",
        r"^#\s+4\.\s+Pravidla napojení panelu\s*$",
        "MM-REF-002 / 3. Výklady pojmů",
    )

    pattern = re.compile(
        r'(?ms)'
        r'(?P<block>'
        r'<a id="(?P<anchor>term-[^"]+)"></a>\s*\r?\n+'
        r'##\s+3\.\d+\s+(?P<term>[^\r\n]+)\s*\r?\n'
        r'.*?'
        r'\[Zpět na rejstřík\]\(#2-klikaci-rejstrik\)'
        r')'
    )

    result: dict[str, str] = {}
    for match in pattern.finditer(details_body):
        term = match.group("term").strip()
        block = match.group("block").strip()
        if term in result:
            fail(f"Duplicitní výkladová sekce v MM-REF-002: {term}")
        result[term] = block

    return result


def build_new_block(number: int, term: str, entry: TermEntry) -> str:
    anchor = slugify(term)
    return f"""<a id="{anchor}"></a>
## 3.{number} {term}

**Český překlad:** {entry.translation}

**Vysvětlení:** {entry.explanation}

**Zdrojový dokument:** `{entry.source}`

**Cílová kapitola nebo sekce:** {entry.target_section}

**Funkce v panelu:**

- zobrazit tento výklad,
- otevřít odpovídající kapitolu,
- otevřít celý zdrojový dokument.

[Zpět na rejstřík](#2-klikaci-rejstrik)"""


def renumber_existing_block(block: str, number: int, term: str) -> str:
    updated, count = re.subn(
        r"(?m)^##\s+3\.\d+\s+[^\r\n]+$",
        f"## 3.{number} {term}",
        block,
        count=1,
    )
    if count != 1:
        fail(f"Nepodařilo se přečíslovat výklad: {term}")
    return updated.strip()


def replace_required(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        fail(f"Nepodařilo se aktualizovat: {label}")
    return updated


def validate_final(text: str, ref001_terms: dict[str, str]) -> None:
    index = parse_index(text)
    blocks = parse_detail_blocks(text)

    if len(index) != EXPECTED_NEW_COUNT:
        fail(f"Finální klikací rejstřík nemá {EXPECTED_NEW_COUNT} položek: {len(index)}")
    if len(blocks) != EXPECTED_NEW_COUNT:
        fail(f"Finální výkladová sekce nemá {EXPECTED_NEW_COUNT} položek: {len(blocks)}")
    if set(index) != set(ref001_terms):
        missing = sorted(set(ref001_terms) - set(index), key=str.casefold)
        extra = sorted(set(index) - set(ref001_terms), key=str.casefold)
        fail(f"Finální rejstřík není synchronní. Chybí={missing}; navíc={extra}")
    if set(blocks) != set(ref001_terms):
        missing = sorted(set(ref001_terms) - set(blocks), key=str.casefold)
        extra = sorted(set(blocks) - set(ref001_terms), key=str.casefold)
        fail(f"Finální výklady nejsou synchronní. Chybí={missing}; navíc={extra}")

    for term, translation in ref001_terms.items():
        index_translation = index[term][0]
        if index_translation != translation:
            fail(
                f"Neshodný překlad u pojmu {term!r}: "
                f"MM-REF-001={translation!r}, MM-REF-002={index_translation!r}"
            )

    if "| Verze | 1.3 |" not in text:
        fail("Finální dokument neobsahuje verzi 1.3.")
    if "| Stav | REVIEW |" not in text:
        fail("Finální dokument neobsahuje stav REVIEW.")
    if "| Celkový počet výkladů | 263 |" not in text:
        fail("Finální dokument neobsahuje souhrnný počet 263 výkladů.")


def main() -> int:
    script_path = Path(__file__).resolve()
    project_root = script_path.parents[2]

    ref001_path = (
        project_root
        / "docs"
        / "10_REFERENCE"
        / "MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md"
    )
    ref002_path = (
        project_root
        / "docs"
        / "10_REFERENCE"
        / "MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md"
    )
    archive_path = (
        project_root
        / "docs"
        / "99_ARCHIVE"
        / "10_REFERENCE"
        / "20260728_REFERENCE_UPDATE"
        / "MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX_PREVIOUS_APPROVED_V1_2.md"
    )

    print()
    print("MATCHMATRIX – AKTUALIZACE MM-REF-002 NA VERZI 1.3")
    print("=" * 79)
    print(f"ENGINE        : {ENGINE}")
    print(f"SCRIPT VERSION: {SCRIPT_VERSION}")
    print(f"PROJECT_ROOT  : {project_root}")
    print(f"MM-REF-001    : {ref001_path}")
    print(f"MM-REF-002    : {ref002_path}")
    print(f"ARCHIV        : {archive_path}")
    print()

    if not ref001_path.is_file():
        fail(f"Chybí MM-REF-001: {ref001_path}")
    if not ref002_path.is_file():
        fail(f"Chybí MM-REF-002: {ref002_path}")

    ref001_text = ref001_path.read_text(encoding="utf-8-sig")
    old_bytes = ref002_path.read_bytes()
    old_text = old_bytes.decode("utf-8-sig")

    ref001_terms = parse_ref001_terms(ref001_text)
    old_index = parse_index(old_text)
    old_blocks = parse_detail_blocks(old_text)

    print("VSTUPNÍ KONTROLA")
    print("-" * 79)
    print(f"MM-REF-001 pojmů       : {len(ref001_terms)}")
    print(f"MM-REF-002 rejstřík    : {len(old_index)}")
    print(f"MM-REF-002 výklady     : {len(old_blocks)}")

    if len(ref001_terms) != EXPECTED_NEW_COUNT:
        fail(
            f"MM-REF-001 musí obsahovat {EXPECTED_NEW_COUNT} pojmů, "
            f"nalezeno {len(ref001_terms)}."
        )

    if len(old_index) == EXPECTED_NEW_COUNT and len(old_blocks) == EXPECTED_NEW_COUNT:
        validate_final(old_text, ref001_terms)
        print()
        print("Dokument již odpovídá verzi 1.3 a je synchronní 263 / 263.")
        print("Nebyla provedena žádná změna.")
        return 0

    if len(old_index) != EXPECTED_OLD_COUNT:
        fail(
            f"Výchozí klikací rejstřík musí obsahovat {EXPECTED_OLD_COUNT} položek, "
            f"nalezeno {len(old_index)}."
        )
    if len(old_blocks) != EXPECTED_OLD_COUNT:
        fail(
            f"Výchozí výkladová sekce musí obsahovat {EXPECTED_OLD_COUNT} položek, "
            f"nalezeno {len(old_blocks)}."
        )
    if set(old_index) != set(old_blocks):
        fail("Původní klikací rejstřík a výkladové sekce nemají shodnou množinu pojmů.")

    missing = sorted(set(ref001_terms) - set(old_index), key=str.casefold)
    extra = sorted(set(old_index) - set(ref001_terms), key=str.casefold)

    print(f"Chybí v MM-REF-002     : {len(missing)}")
    print(f"Navíc v MM-REF-002     : {len(extra)}")

    if extra:
        fail(f"MM-REF-002 obsahuje pojmy navíc: {extra}")
    if len(missing) != EXPECTED_MISSING_COUNT:
        fail(
            f"Očekáváno {EXPECTED_MISSING_COUNT} chybějících pojmů, "
            f"nalezeno {len(missing)}: {missing}"
        )
    if set(missing) != set(NEW_ENTRIES):
        not_defined = sorted(set(missing) - set(NEW_ENTRIES), key=str.casefold)
        not_missing = sorted(set(NEW_ENTRIES) - set(missing), key=str.casefold)
        fail(
            "Neshoda mezi auditovanými a připravenými pojmy. "
            f"Bez definice={not_defined}; neočekávané definice={not_missing}"
        )

    for term, entry in NEW_ENTRIES.items():
        glossary_translation = ref001_terms[term]
        if glossary_translation != entry.translation:
            fail(
                f"Překlad u {term!r} neodpovídá MM-REF-001: "
                f"{entry.translation!r} != {glossary_translation!r}"
            )

    all_terms = sorted(ref001_terms, key=str.casefold)

    combined_index: dict[str, tuple[str, str, str, str]] = dict(old_index)
    for term, entry in NEW_ENTRIES.items():
        combined_index[term] = (
            entry.translation,
            slugify(term),
            entry.source,
            entry.target_section,
        )

    index_lines = [
        "# 2. Klikací rejstřík",
        "",
        "| Cizí výraz | Český překlad | Výklad | Zdrojový dokument | Cílová kapitola |",
        "|---|---|---|---|---|",
    ]
    for term in all_terms:
        translation, anchor, source, target = combined_index[term]
        index_lines.append(
            f"| {term} | {translation} | "
            f"[Otevřít výklad](#{anchor}) | {source} | {target} |"
        )
    index_section = "\n".join(index_lines) + "\n\n---\n\n"

    detail_blocks: list[str] = []
    for number, term in enumerate(all_terms, start=1):
        if term in old_blocks:
            block = renumber_existing_block(old_blocks[term], number, term)
        else:
            block = build_new_block(number, term, NEW_ENTRIES[term])
        detail_blocks.append(block)

    details_section = (
        "# 3. Výklady pojmů\n\n"
        + "\n\n---\n\n".join(detail_blocks)
        + "\n\n---\n\n"
    )

    new_text = old_text

    new_text = replace_required(
        new_text,
        r"^\| Verze \| 1\.2 \|$",
        "| Verze | 1.3 |",
        "metadata / Verze",
    )
    new_text = replace_required(
        new_text,
        r"^\| Stav \| APPROVED \|$",
        "| Stav | REVIEW |",
        "metadata / Stav",
    )
    new_text = replace_required(
        new_text,
        r"^\| Původní stav zdrojového dokumentu \| [^|]+ \|$",
        "| Původní stav zdrojového dokumentu | APPROVED |",
        "metadata / Původní stav",
    )
    new_text = replace_required(
        new_text,
        r"^\| Nahrazuje \| MM-REF-002 v1\.1 po schválení \|$",
        "| Nahrazuje | MM-REF-002 v1.2 po schválení |",
        "metadata / Nahrazuje",
    )
    new_text = replace_required(
        new_text,
        r"^\| Referenční standardy \| [^|]+ \|$",
        "| Referenční standardy | MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008, MM-STD-009 |",
        "metadata / Referenční standardy",
    )

    purpose_pattern = (
        r"(?m)^Verze 1\.2 doplňuje 9 výkladových položek ze zdroje "
        r"`MM-DB-003`\. Nové pojmy jsou zařazeny do hlavního klikacího "
        r"rejstříku i do hlavní číslované sekce výkladů\.$"
    )
    purpose_replacement = (
        "Verze 1.3 zachovává všech 222 výkladů verze 1.2 a doplňuje "
        "41 chybějících položek z MM-REF-001 v1.7. Klikací rejstřík "
        "i číslované výklady jsou nově úplně synchronní v rozsahu 263 / 263."
    )
    new_text, purpose_count = re.subn(
        purpose_pattern,
        purpose_replacement,
        new_text,
        count=1,
    )
    if purpose_count != 1:
        fail("Nepodařilo se aktualizovat účel verze 1.2 na 1.3.")

    new_text, index_count = re.subn(
        r"(?ms)^#\s+2\.\s+Klikací rejstřík\s*$.*?(?=^#\s+3\.\s+Výklady pojmů\s*$)",
        index_section,
        new_text,
        count=1,
    )
    if index_count != 1:
        fail("Nepodařilo se nahradit klikací rejstřík.")

    new_text, details_count = re.subn(
        r"(?ms)^#\s+3\.\s+Výklady pojmů\s*$.*?(?=^#\s+4\.\s+Pravidla napojení panelu\s*$)",
        details_section,
        new_text,
        count=1,
    )
    if details_count != 1:
        fail("Nepodařilo se nahradit výkladovou sekci.")

    summary_section = """# 6. Souhrn verze 1.3

| Položka | Hodnota |
|---|---:|
| Výklady převzaté z verze 1.2 | 222 |
| Nové výklady doplněné ve verzi 1.3 | 41 |
| Celkový počet výkladů | 263 |
| Synchronizace s MM-REF-001 v1.7 | 263 / 263 |
| Pojmy navíc v MM-REF-002 | 0 |
| Zdrojové snapshoty | MM-PS-20260331, MM-PS-20260430, MM-PS-20260531 |
| Další zdroje | MM-DB-003, MM-STD-003, MM-STD-004, MM-STD-007, MM-STD-008, MM-DOC-200, MM-DOC-300, MM-DOC-800 |

"""
    new_text, summary_count = re.subn(
        r"(?ms)^#\s+6\.\s+Souhrn verze 1\.2\s*$.*?(?=^#\s+7\.\s+Historie verzí\s*$)",
        summary_section,
        new_text,
        count=1,
    )
    if summary_count != 1:
        fail("Nepodařilo se aktualizovat souhrn verze.")

    history_row = (
        "| 1.3 | 2026-07-28 | Zachováno 222 výkladů verze 1.2, "
        "doplněno 41 chybějících pojmů a dosažena úplná synchronizace "
        "263 / 263 s MM-REF-001 v1.7. |"
    )
    if history_row not in new_text:
        new_text, history_count = re.subn(
            r"(?m)^(\| 1\.2 \| 2026-07-17 \|[^\r\n]+\|)$",
            rf"\1\n{history_row}",
            new_text,
            count=1,
        )
        if history_count != 1:
            fail("Nepodařilo se doplnit historii verze 1.3.")

    new_text = new_text.replace(
        "MM-REF-002 v1.2 poskytuje panelu MatchMatrix úplný výkladový protějšek k překladovému slovníku MM-REF-001.",
        "MM-REF-002 v1.3 poskytuje panelu MatchMatrix úplný výkladový protějšek k MM-REF-001 v1.7. Oba referenční dokumenty jsou synchronní v rozsahu 263 pojmů.",
        1,
    )

    validate_final(new_text, ref001_terms)

    archive_path.parent.mkdir(parents=True, exist_ok=True)
    if archive_path.exists():
        archived_bytes = archive_path.read_bytes()
        if sha256_bytes(archived_bytes) != sha256_bytes(old_bytes):
            fail(
                "Cílový archivní soubor již existuje s jiným obsahem: "
                f"{archive_path}"
            )
        print()
        print("Archivní kopie v1.2 již existuje a obsahově odpovídá vstupu.")
    else:
        shutil.copy2(ref002_path, archive_path)
        print()
        print("ARCHIVOVÁNO")
        print(f"  {archive_path}")

    temporary_path = ref002_path.with_suffix(ref002_path.suffix + ".new")
    temporary_path.write_text(new_text, encoding="utf-8", newline="\n")

    written_text = temporary_path.read_text(encoding="utf-8")
    validate_final(written_text, ref001_terms)

    temporary_path.replace(ref002_path)

    final_text = ref002_path.read_text(encoding="utf-8")
    validate_final(final_text, ref001_terms)

    print()
    print("AKTUALIZACE DOKONČENA")
    print("-" * 79)
    print(f"AKTIVNÍ SOUBOR       : {ref002_path}")
    print("VERZE                 : 1.3")
    print("STAV                  : REVIEW")
    print(f"KLIKACÍ REJSTŘÍK     : {len(parse_index(final_text))}")
    print(f"VÝKLADOVÉ SEKCE      : {len(parse_detail_blocks(final_text))}")
    print("SYNCHRONIZACE REF-001 : 263 / 263")
    print("POJMY NAVÍC           : 0")
    print("GIT COMMIT            : NEPROVEDEN")
    print("A24                    : NEPROVEDENO")

    try:
        relative_active = ref002_path.relative_to(project_root)
        relative_archive = archive_path.relative_to(project_root)
        result = subprocess.run(
            [
                "git",
                "-C",
                str(project_root),
                "status",
                "--short",
                "--",
                str(relative_active),
                str(relative_archive),
            ],
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        print()
        print("GIT STATUS – DOTČENÉ SOUBORY")
        print("-" * 79)
        print(result.stdout.rstrip() or "Bez změn.")
    except Exception as exc:  # noqa: BLE001
        print()
        print(f"VAROVÁNÍ: Git status se nepodařilo zobrazit: {exc}")

    print()
    print("=" * 79)
    print("A35 UPDATE OK")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # noqa: BLE001
        print()
        print("=" * 79)
        print("A35 UPDATE FAILED")
        print(str(exc))
        raise SystemExit(1)
