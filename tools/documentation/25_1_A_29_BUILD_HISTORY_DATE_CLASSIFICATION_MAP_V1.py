# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – BUILD HISTORY DATE CLASSIFICATION MAP V1

Document ID skriptu:
25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1

CO:
- Vytvoří řízenou klasifikační mapu 35 historických dokumentů,
  které mají v manifestu prázdné document_date.
- Zapíše schválenou klasifikaci, doporučené datum nebo měsíc,
  jistotu, důvod, chronologickou roli a vazbu na související dokument.

K ČEMU:
- Slouží jako bezpečný podklad pro doplněný květnový a červnový export.
- Odděluje explicitní datum, odvozené datum, odvozený měsíc,
  jiné období, nadčasový referenční dokument a nevyřešené datum.
- Zabraňuje tomu, aby plánovaný milestone, datum zápasu nebo datum narození
  bylo omylem použito jako datum dokumentu.

KDE:
- Aktivní skript:
  tools/documentation/
  25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1.py
- Výstupy:
  reports/documentation/history_review/
  history_date_classification_map_v1.csv
  history_date_classification_map_v1.json
  history_date_classification_map_v1.md
  history_date_classification_map_latest.csv
  history_date_classification_map_latest.json
  history_date_classification_map_latest.md

JAK:
- Načte aktuální historický manifest pouze pro kontrolu existence dokumentů.
- Manifest, historický archiv ani databázi neupravuje.
- Klasifikační rozhodnutí jsou explicitně zapsána v tomto skriptu.
- Při chybějícím nebo duplicitním Document ID skončí chybou.
- Výstup je auditovatelný a připravený pro navazující exportér.

PŘÍKLAD:
py.exe -3.14 ^
  tools\documentation\25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1.py ^
  --manifest reports\documentation\history_corpus_manifest_latest.csv ^
  --output-dir reports\documentation\history_review
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Any


SCRIPT_ID = "25_1_A_29_BUILD_HISTORY_DATE_CLASSIFICATION_MAP_V1"
SCRIPT_VERSION = "1.0"

DEFAULT_REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
DEFAULT_LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")

OUTPUT_FIELDS = [
    "document_id",
    "manifest_document_date",
    "title",
    "canonical_relative_path",
    "classification",
    "recommended_document_date",
    "recommended_month",
    "date_confidence",
    "date_basis",
    "chronology_role",
    "related_document_id",
    "review_note",
    "apply_to_manifest",
]

ALLOWED_CLASSIFICATIONS = {
    "EXPLICIT_DATE",
    "INFERRED_DATE",
    "INFERRED_MONTH",
    "OTHER_PERIOD",
    "TIMELESS_REFERENCE",
    "DATE_UNRESOLVED",
}

CLASSIFICATION_ROWS: list[dict[str, str]] = [
    {
        "document_id": "MM-HIS-0001",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Technický artefakt bez datumové stopy.",
        "chronology_role": "TECHNICAL_ARTIFACT",
        "related_document_id": "",
        "review_note": "Docker Compose; nezařazovat automaticky do měsíční chronologie.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0002",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Technický artefakt bez datumové stopy.",
        "chronology_role": "TECHNICAL_ARTIFACT",
        "related_document_id": "",
        "review_note": "DB seed; nezařazovat automaticky do měsíční chronologie.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0017",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-24",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V obsahu je uvedeno Datum 24.06.2026.",
        "chronology_role": "PRIMARY_DAILY_RECORD",
        "related_document_id": "MM-HIS-0277",
        "review_note": "Založení Source Intelligence Layer a HB proof of concept.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0018",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Obecný Git workflow bez data.",
        "chronology_role": "PROCESS_REFERENCE",
        "related_document_id": "",
        "review_note": "Referenční návod, nikoli denní milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0019",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Obecný Git recovery workflow bez data.",
        "chronology_role": "PROCESS_REFERENCE",
        "related_document_id": "",
        "review_note": "Referenční návod, nikoli denní milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0020",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Obsahově předchází Release Readiness auditu z 2026-06-03 a používá stejné governance počty.",
        "chronology_role": "SUPPORTING_PREDECESSOR",
        "related_document_id": "MM-HIS-0027",
        "review_note": "Bez dalšího důkazu neurčovat přesný den.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0021",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Plán druhého PC před červencovým harvestem; datum 2026-06-15 je plánovaný milestone, ne jisté datum autorství.",
        "chronology_role": "STRATEGIC_PLAN",
        "related_document_id": "MM-HIS-0270",
        "review_note": "Zařadit do června pouze na úrovni měsíce.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0022",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-06",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 06.06.2026.",
        "chronology_role": "MASTER_ARCHITECTURE_SNAPSHOT",
        "related_document_id": "",
        "review_note": "Architektonická mapa projektu.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0023",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "MEDIUM",
        "date_basis": "Strategický dokument bez bezpečně určitelného data.",
        "chronology_role": "STRATEGIC_REFERENCE",
        "related_document_id": "",
        "review_note": "Může podporovat červnovou vizi, ale nemá vytvářet falešný denní milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0024",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-05",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V obsahu je uvedeno Datum: 05.06.2026.",
        "chronology_role": "MASTER_PROJECT_SNAPSHOT",
        "related_document_id": "MM-HIS-0028",
        "review_note": "Stav projektu, infrastruktura a dlouhodobá vize.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0025",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Audit migrace V11 na V17 a návrh V18 tematicky předchází V18 Command Center reportu z 2026-06-03.",
        "chronology_role": "PLAN_PREDECESSOR",
        "related_document_id": "MM-HIS-0029",
        "review_note": "Bez dalšího důkazu neurčovat přesný den.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0026",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-01",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 2026-06-01.",
        "chronology_role": "IMPLEMENTATION_SUCCESSOR",
        "related_document_id": "MM-HIS-0031",
        "review_note": "FB People přechází z PARTIAL na READY.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0027",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-03",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 2026-06-03.",
        "chronology_role": "AUDIT_SNAPSHOT",
        "related_document_id": "MM-HIS-0020",
        "review_note": "Release Readiness audit; procenta chápat jako dobový odhad.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0028",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-05",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V záhlaví je uvedeno Datum: 05.06.2026.",
        "chronology_role": "CHAT_HANDOFF",
        "related_document_id": "MM-HIS-0024",
        "review_note": "Navazovací souhrn pro další chat.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0029",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-03",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Dokument uvádí Stav projektu k 2026-06-03.",
        "chronology_role": "PANEL_PLAN",
        "related_document_id": "MM-HIS-0025",
        "review_note": "V18 Harvest Command Center plán.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0030",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Návrh 17_9 Team Duplicate Prevention přímo předchází dokončení popsanému dne 2026-06-07.",
        "chronology_role": "PLAN_PREDECESSOR",
        "related_document_id": "MM-HIS-0274",
        "review_note": "Pravděpodobně 6.–7. června; přesný den neurčovat.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0031",
        "classification": "DATE_UNRESOLVED",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "LOW",
        "date_basis": "Dokument předchází FB People dokončení z 2026-06-01, ale mohl vzniknout 2026-05-31 nebo 2026-06-01.",
        "chronology_role": "TRANSITIONAL_PREDECESSOR",
        "related_document_id": "MM-HIS-0026",
        "review_note": "Používat jako přechodový podpůrný zdroj; neřadit k přesnému dni.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0225",
        "classification": "OTHER_PERIOD",
        "recommended_document_date": "",
        "recommended_month": "2026-03",
        "date_confidence": "HIGH",
        "date_basis": "Relativní cesta obsahuje komunikace s chatGPT/03_2026.",
        "chronology_role": "PROCESS_REFERENCE",
        "related_document_id": "",
        "review_note": "Březen 2026; metodický kontext spolupráce s AI.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0258",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-24",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum založení: 2026-06-24.",
        "chronology_role": "EXPANDED_VARIANT",
        "related_document_id": "MM-HIS-0290",
        "review_note": "Širší governance dokument včetně rozšíření sekce 24.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0261",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "MEDIUM",
        "date_basis": "Strategický souhrn bez bezpečně určitelného data.",
        "chronology_role": "STRATEGIC_REFERENCE",
        "related_document_id": "",
        "review_note": "Součást korpusu, nikoli samostatný denní milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0266",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-10",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Obsah uvádí Datum: 10.06.2026; ostatní data jsou data zápasů. Název souboru 09062026 je v rozporu.",
        "chronology_role": "PARTIAL_PREDECESSOR",
        "related_document_id": "MM-HIS-0267",
        "review_note": "Filename mismatch; MM-HIS-0267 je širší pokračování.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0267",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-10",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Obsah opakovaně uvádí datum 10.06.2026.",
        "chronology_role": "EXPANDED_SUCCESSOR",
        "related_document_id": "MM-HIS-0266",
        "review_note": "Obsahuje Context Engine i Match/League Governance.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0268",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-07",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V záhlaví je uvedeno Datum: 2026-06-07; 2002-01-28 je datum narození hráče.",
        "chronology_role": "PRIMARY_DAILY_RECORD",
        "related_document_id": "MM-HIS-0274",
        "review_note": "Team a Player Governance + OPS Panel V18.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0270",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-22",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V záhlaví je uvedeno Datum: 22.06.2026.",
        "chronology_role": "CHAT_HANDOFF",
        "related_document_id": "MM-HIS-0021",
        "review_note": "Dokončená serverová infrastruktura a návrat k datům.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0272",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-14",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V záhlaví je uvedeno Datum: 14.06.2026.",
        "chronology_role": "CHAT_HANDOFF",
        "related_document_id": "",
        "review_note": "Runtime audit People pipeline a zpřísnění významu DONE.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0273",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-05",
        "date_confidence": "MEDIUM",
        "date_basis": "People Layer checklist tematicky přímo doprovází Reality/Priority dokumenty z 2026-05-20.",
        "chronology_role": "SUPPORTING_CHECKLIST",
        "related_document_id": "MM-HIS-0283;MM-HIS-0284",
        "review_note": "Používat v květnovém korpusu bez tvrzení o přesném dni.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0274",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-07",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 2026-06-07.",
        "chronology_role": "IMPLEMENTATION_SUCCESSOR",
        "related_document_id": "MM-HIS-0030",
        "review_note": "Team Dedup 17_8 a Team Duplicate Prevention 17_9.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0275",
        "classification": "INFERRED_DATE",
        "recommended_document_date": "2026-05-25",
        "recommended_month": "2026-05",
        "date_confidence": "MEDIUM",
        "date_basis": "Zápis 107_A–107_S odpovídá datovanému V17 Orchestration milestone z 2026-05-25.",
        "chronology_role": "ORCHESTRATION_MILESTONE",
        "related_document_id": "MM-HIS-0014",
        "review_note": "Datum je rekonstruováno tematickou návazností, nikoli explicitním záhlavím.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0277",
        "classification": "INFERRED_MONTH",
        "recommended_document_date": "",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "Navázání Autonomous Harvest na Source Discovery přímo předchází Source Intelligence Layer z 2026-06-24.",
        "chronology_role": "TRANSITIONAL_PREDECESSOR",
        "related_document_id": "MM-HIS-0017",
        "review_note": "Pravděpodobně 23.–24. června; přesný den neurčovat.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0283",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-05-20",
        "recommended_month": "2026-05",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 2026-05-20.",
        "chronology_role": "PRIMARY_REFERENCE",
        "related_document_id": "MM-HIS-0284",
        "review_note": "People Provider Priority V1.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0284",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-05-20",
        "recommended_month": "2026-05",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum: 2026-05-20.",
        "chronology_role": "COMPOSITE_EXPANDED_VARIANT",
        "related_document_id": "MM-HIS-0283",
        "review_note": "Reality Matrix a opakovaný obsah Priority V1; zabránit dvojímu započítání.",
        "apply_to_manifest": "YES",
    },
    {
        "document_id": "MM-HIS-0287",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Pomocný příkaz bez data.",
        "chronology_role": "TECHNICAL_REFERENCE",
        "related_document_id": "",
        "review_note": "Nevytvářet z něj historický milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0288",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "MEDIUM",
        "date_basis": "Dokumentační README bez bezpečně určitelného data.",
        "chronology_role": "DOCUMENTATION_REFERENCE",
        "related_document_id": "",
        "review_note": "Referenční popis struktury dokumentace.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0289",
        "classification": "TIMELESS_REFERENCE",
        "recommended_document_date": "",
        "recommended_month": "",
        "date_confidence": "HIGH",
        "date_basis": "Pracovní šablona bez data.",
        "chronology_role": "TEMPLATE_REFERENCE",
        "related_document_id": "",
        "review_note": "Nevytvářet z ní historický milestone.",
        "apply_to_manifest": "NO",
    },
    {
        "document_id": "MM-HIS-0290",
        "classification": "EXPLICIT_DATE",
        "recommended_document_date": "2026-06-24",
        "recommended_month": "2026-06",
        "date_confidence": "HIGH",
        "date_basis": "V dokumentu je uvedeno Datum založení: 2026-06-24.",
        "chronology_role": "SHORTER_VARIANT",
        "related_document_id": "MM-HIS-0258",
        "review_note": "Kratší varianta governance dokumentu; nepočítat jako nezávislý milestone.",
        "apply_to_manifest": "YES",
    },
]


def resolve_project_root() -> Path:
    local_manifest = (
        DEFAULT_LOCAL_ROOT
        / "reports"
        / "documentation"
        / "history_corpus_manifest_latest.csv"
    )
    return DEFAULT_LOCAL_ROOT if local_manifest.is_file() else DEFAULT_REMOTE_ROOT


def build_parser() -> argparse.ArgumentParser:
    root = resolve_project_root()

    parser = argparse.ArgumentParser(
        description="Vytvoří řízenou klasifikační mapu nedatovaných historických dokumentů."
    )
    parser.add_argument(
        "--manifest",
        default=str(
            root
            / "reports"
            / "documentation"
            / "history_corpus_manifest_latest.csv"
        ),
        help="Aktuální CSV manifest historického korpusu.",
    )
    parser.add_argument(
        "--output-dir",
        default=str(
            root
            / "reports"
            / "documentation"
            / "history_review"
        ),
        help="Výstupní složka.",
    )
    return parser


def read_manifest(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(f"Manifest nebyl nalezen: {path}")

    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))

    if not rows:
        raise RuntimeError("Manifest je prázdný.")

    required = {
        "document_id",
        "document_date",
        "title",
        "canonical_relative_path",
        "extraction_status",
    }
    missing = sorted(required - set(rows[0].keys()))
    if missing:
        raise RuntimeError(
            "Manifest neobsahuje povinné sloupce: " + ", ".join(missing)
        )

    return rows


def validate_classification_rows() -> None:
    ids = [row["document_id"] for row in CLASSIFICATION_ROWS]
    duplicates = sorted(
        document_id
        for document_id, count in Counter(ids).items()
        if count > 1
    )
    if duplicates:
        raise RuntimeError(
            "Duplicitní Document ID v klasifikační mapě: "
            + ", ".join(duplicates)
        )

    if len(CLASSIFICATION_ROWS) != 35:
        raise RuntimeError(
            f"Očekáváno 35 klasifikačních řádků, nalezeno {len(CLASSIFICATION_ROWS)}."
        )

    for row in CLASSIFICATION_ROWS:
        classification = row["classification"]
        if classification not in ALLOWED_CLASSIFICATIONS:
            raise RuntimeError(
                f"{row['document_id']}: nepovolená klasifikace {classification}"
            )

        recommended_date = row["recommended_document_date"]
        recommended_month = row["recommended_month"]

        if recommended_date:
            datetime.strptime(recommended_date, "%Y-%m-%d")
            if recommended_month and not recommended_date.startswith(recommended_month):
                raise RuntimeError(
                    f"{row['document_id']}: datum a měsíc si neodpovídají."
                )

        if recommended_month:
            datetime.strptime(recommended_month, "%Y-%m")

        if row["apply_to_manifest"] not in {"YES", "NO"}:
            raise RuntimeError(
                f"{row['document_id']}: apply_to_manifest musí být YES nebo NO."
            )


def enrich_rows(
    manifest_rows: list[dict[str, str]],
) -> list[dict[str, str]]:
    manifest_by_id: dict[str, dict[str, str]] = {}

    for row in manifest_rows:
        document_id = str(row.get("document_id") or "").strip()
        if document_id in manifest_by_id:
            raise RuntimeError(
                f"Manifest obsahuje duplicitní Document ID: {document_id}"
            )
        manifest_by_id[document_id] = row

    enriched: list[dict[str, str]] = []

    for decision in CLASSIFICATION_ROWS:
        document_id = decision["document_id"]
        source = manifest_by_id.get(document_id)

        if source is None:
            raise RuntimeError(
                f"Document ID nebyl nalezen v manifestu: {document_id}"
            )

        manifest_document_date = str(
            source.get("document_date") or ""
        ).strip()

        if manifest_document_date:
            raise RuntimeError(
                f"{document_id}: document_date již není prázdné "
                f"({manifest_document_date})."
            )

        extraction_status = str(
            source.get("extraction_status") or ""
        ).strip().upper()

        if extraction_status != "READY":
            raise RuntimeError(
                f"{document_id}: extraction_status není READY "
                f"({extraction_status})."
            )

        row = {
            "document_id": document_id,
            "manifest_document_date": manifest_document_date,
            "title": str(source.get("title") or "").strip(),
            "canonical_relative_path": str(
                source.get("canonical_relative_path") or ""
            ).strip(),
            **decision,
        }

        enriched.append(row)

    return enriched


def write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=OUTPUT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def write_json(
    path: Path,
    rows: list[dict[str, str]],
    manifest_path: Path,
) -> None:
    counts = Counter(row["classification"] for row in rows)
    month_counts = Counter(
        row["recommended_month"]
        for row in rows
        if row["recommended_month"]
    )

    payload: dict[str, Any] = {
        "generated_at": datetime.now().astimezone().isoformat(),
        "engine": SCRIPT_ID,
        "engine_version": SCRIPT_VERSION,
        "manifest": str(manifest_path),
        "document_count": len(rows),
        "classification_counts": dict(sorted(counts.items())),
        "recommended_month_counts": dict(sorted(month_counts.items())),
        "manifest_modified": False,
        "archive_modified": False,
        "database_modified": False,
        "documents": rows,
        "final_status": "HISTORY_DATE_CLASSIFICATION_MAP_READY",
    }

    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def escape_md(value: str) -> str:
    return str(value or "").replace("|", r"\|").replace("\n", " ")


def write_markdown(
    path: Path,
    rows: list[dict[str, str]],
    manifest_path: Path,
) -> None:
    counts = Counter(row["classification"] for row in rows)
    month_counts = Counter(
        row["recommended_month"]
        for row in rows
        if row["recommended_month"]
    )

    lines = [
        "# MATCHMATRIX – HISTORY DATE CLASSIFICATION MAP V1",
        "",
        "## Informace",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Vytvořeno | {datetime.now().astimezone().isoformat()} |",
        f"| Skript | `{SCRIPT_ID}` |",
        f"| Verze | {SCRIPT_VERSION} |",
        f"| Manifest | `{manifest_path}` |",
        f"| Dokumentů | {len(rows)} |",
        "| Manifest upraven | NE |",
        "| Archiv upraven | NE |",
        "| Databáze upravena | NE |",
        "",
        "## Souhrn klasifikací",
        "",
        "| Klasifikace | Počet |",
        "|---|---:|",
    ]

    for key, value in sorted(counts.items()):
        lines.append(f"| {key} | {value} |")

    lines.extend(
        [
            "",
            "## Souhrn doporučených měsíců",
            "",
            "| Měsíc | Počet |",
            "|---|---:|",
        ]
    )

    for key, value in sorted(month_counts.items()):
        lines.append(f"| {key} | {value} |")

    lines.extend(
        [
            "",
            "## Klasifikační mapa",
            "",
            "| Document ID | Název | Klasifikace | Doporučené datum | Doporučený měsíc | Jistota | Chronologická role | Vazba | Apply |",
            "|---|---|---|---|---|---|---|---|---|",
        ]
    )

    for row in rows:
        lines.append(
            "| "
            f"{escape_md(row['document_id'])} | "
            f"{escape_md(row['title'])} | "
            f"{escape_md(row['classification'])} | "
            f"{escape_md(row['recommended_document_date'])} | "
            f"{escape_md(row['recommended_month'])} | "
            f"{escape_md(row['date_confidence'])} | "
            f"{escape_md(row['chronology_role'])} | "
            f"{escape_md(row['related_document_id'])} | "
            f"{escape_md(row['apply_to_manifest'])} |"
        )

    lines.extend(
        [
            "",
            "## Detail rozhodnutí",
            "",
        ]
    )

    for row in rows:
        lines.extend(
            [
                f"### {row['document_id']} – {row['title']}",
                "",
                f"- **Klasifikace:** `{row['classification']}`",
                f"- **Doporučené datum:** `{row['recommended_document_date'] or 'NEVYPLNĚNO'}`",
                f"- **Doporučený měsíc:** `{row['recommended_month'] or 'NEVYPLNĚNO'}`",
                f"- **Jistota:** `{row['date_confidence']}`",
                f"- **Základ rozhodnutí:** {row['date_basis']}",
                f"- **Chronologická role:** `{row['chronology_role']}`",
                f"- **Související dokument:** `{row['related_document_id'] or 'NEVYPLNĚNO'}`",
                f"- **Poznámka:** {row['review_note']}",
                f"- **Přímá aplikace do manifestu:** `{row['apply_to_manifest']}`",
                "",
            ]
        )

    path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def main() -> int:
    args = build_parser().parse_args()

    try:
        manifest_path = Path(args.manifest)
        output_dir = Path(args.output_dir)

        validate_classification_rows()
        manifest_rows = read_manifest(manifest_path)
        rows = enrich_rows(manifest_rows)

        output_dir.mkdir(parents=True, exist_ok=True)

        base_name = "history_date_classification_map_v1"
        latest_name = "history_date_classification_map_latest"

        csv_path = output_dir / f"{base_name}.csv"
        json_path = output_dir / f"{base_name}.json"
        md_path = output_dir / f"{base_name}.md"

        latest_csv_path = output_dir / f"{latest_name}.csv"
        latest_json_path = output_dir / f"{latest_name}.json"
        latest_md_path = output_dir / f"{latest_name}.md"

        for path in (csv_path, latest_csv_path):
            write_csv(path, rows)

        for path in (json_path, latest_json_path):
            write_json(path, rows, manifest_path)

        for path in (md_path, latest_md_path):
            write_markdown(path, rows, manifest_path)

        counts = Counter(row["classification"] for row in rows)
        month_counts = Counter(
            row["recommended_month"]
            for row in rows
            if row["recommended_month"]
        )

        print("MATCHMATRIX HISTORY DATE CLASSIFICATION MAP")
        print("=" * 72)
        print(f"DOCUMENTS          : {len(rows)}")

        for key, value in sorted(counts.items()):
            print(f"{key:<18} : {value}")

        print("-" * 72)

        for key, value in sorted(month_counts.items()):
            print(f"MONTH {key:<11} : {value}")

        print("-" * 72)
        print(f"CSV                : {csv_path}")
        print(f"JSON               : {json_path}")
        print(f"MARKDOWN           : {md_path}")
        print(f"LATEST CSV         : {latest_csv_path}")
        print(f"LATEST JSON        : {latest_json_path}")
        print(f"LATEST MARKDOWN    : {latest_md_path}")
        print("MANIFEST MODIFIED  : False")
        print("ARCHIVE MODIFIED   : False")
        print("DATABASE MODIFIED  : False")
        print("FINAL STATUS       : HISTORY_DATE_CLASSIFICATION_MAP_READY")

        return 0

    except Exception as exc:
        print(f"FATAL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
