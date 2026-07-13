# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – EXPORT HISTORY RECONSTRUCTION SOURCE BLOCK V1

Document ID:
25_1_A_31_EXPORT_HISTORY_RECONSTRUCTION_SOURCE_BLOCK_V1

CO:
- Načte úplný měsíční historický korpus vytvořený skriptem A30.
- Vybere přesně určený chronologický blok dokumentů.
- Volitelně připojí dokumenty zařazené pouze na úroveň měsíce.
- Zachová metadata, chronologické vazby a celý normalizovaný obsah.

K ČEMU:
- Připraví menší a obsahově úplný zdrojový balíček pro řízenou
  rekonstrukční pracovní zprávu.
- Zabrání tomu, aby se při ruční rekonstrukci přehlédl dokument,
  časová klasifikace nebo vztah mezi verzemi.

KDE:
- tools/documentation/
  25_1_A_31_EXPORT_HISTORY_RECONSTRUCTION_SOURCE_BLOCK_V1.py
- Výstupy:
  reports/documentation/history_review/

JAK:
- Čte pouze JSON korpus vytvořený skriptem A30.
- Kontroluje měsíc, stav korpusu, počet varování a připravenost dokumentů.
- Přesně datované dokumenty vybírá včetně obou krajních dat.
- Dokumenty MONTH_ONLY přidá jen při použití --include-month-only.
- Vytváří Markdown, JSON a CSV včetně aliasů latest.
- Zdrojový korpus, archiv, manifest, klasifikaci ani databázi neupravuje.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from datetime import date, datetime
from pathlib import Path
from typing import Any


SCRIPT_ID = "25_1_A_31_EXPORT_HISTORY_RECONSTRUCTION_SOURCE_BLOCK_V1"
SCRIPT_VERSION = "1.1"

REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")

READY_CORPUS_STATUSES = {
    "COMPLETE_HISTORY_MONTH_CORPUS_READY",
}


def project_root() -> Path:
    local_reports = LOCAL_ROOT / "reports" / "documentation"
    return LOCAL_ROOT if local_reports.is_dir() else REMOTE_ROOT


def parser() -> argparse.ArgumentParser:
    root = project_root()
    result = argparse.ArgumentParser(
        description=(
            "Export zdrojového bloku pro řízenou rekonstrukci historie."
        )
    )
    result.add_argument(
        "--month",
        required=True,
        help="Měsíc ve formátu YYYY-MM.",
    )
    result.add_argument(
        "--start-date",
        required=True,
        help="První datum bloku ve formátu YYYY-MM-DD.",
    )
    result.add_argument(
        "--end-date",
        required=True,
        help="Poslední datum bloku ve formátu YYYY-MM-DD.",
    )
    result.add_argument(
        "--include-month-only",
        action="store_true",
        help=(
            "Připojí také dokumenty klasifikované pouze na úroveň měsíce."
        ),
    )
    result.add_argument(
        "--corpus-json",
        default="",
        help=(
            "Cesta k JSON korpusu A30. Bez zadání se použije "
            "history_complete_month_corpus_YYYY_MM_latest.json."
        ),
    )
    result.add_argument(
        "--output-dir",
        default=str(
            root / "reports" / "documentation" / "history_review"
        ),
    )
    return result


def validate_month(value: str) -> str:
    value = value.strip()
    if not re.fullmatch(r"20\d{2}-(0[1-9]|1[0-2])", value):
        raise ValueError(
            f"Neplatný měsíc '{value}'. Očekáván formát YYYY-MM."
        )
    datetime.strptime(value, "%Y-%m")
    return value


def validate_date(value: str, label: str) -> date:
    value = value.strip()
    try:
        return datetime.strptime(value, "%Y-%m-%d").date()
    except ValueError as exc:
        raise ValueError(
            f"Neplatné {label} '{value}'. Očekáván formát YYYY-MM-DD."
        ) from exc


def read_json(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"JSON korpus nebyl nalezen: {path}")
    with path.open("r", encoding="utf-8-sig") as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise RuntimeError("JSON korpus nemá objektovou kořenovou strukturu.")
    return payload


def require_corpus_ready(
    payload: dict[str, Any],
    month: str,
) -> list[dict[str, Any]]:
    corpus_month = str(payload.get("month") or "").strip()
    if corpus_month != month:
        raise RuntimeError(
            f"JSON korpus patří měsíci {corpus_month or 'NEURČENO'}, "
            f"nikoli {month}."
        )

    final_status = str(payload.get("final_status") or "").strip()
    if final_status not in READY_CORPUS_STATUSES:
        raise RuntimeError(
            "Korpus není ve stavu bez varování: "
            f"{final_status or 'NEURČENO'}."
        )

    warning_count = int(payload.get("warning_count") or 0)
    if warning_count != 0:
        raise RuntimeError(
            f"Korpus obsahuje {warning_count} varování; rekonstrukční "
            "blok se nevytvoří."
        )

    documents = payload.get("documents")
    if not isinstance(documents, list) or not documents:
        raise RuntimeError("Korpus neobsahuje žádné dokumenty.")

    normalized: list[dict[str, Any]] = []
    seen_ids: set[str] = set()

    for raw in documents:
        if not isinstance(raw, dict):
            raise RuntimeError("Korpus obsahuje neplatný záznam dokumentu.")

        manifest = raw.get("manifest")
        if not isinstance(manifest, dict):
            raise RuntimeError(
                "Dokument v korpusu neobsahuje objekt manifest."
            )

        document_id = str(manifest.get("document_id") or "").strip()
        if not document_id:
            raise RuntimeError("Dokument v korpusu nemá document_id.")
        if document_id in seen_ids:
            raise RuntimeError(
                f"Korpus obsahuje duplicitní document_id: {document_id}."
            )
        seen_ids.add(document_id)

        review_status = str(raw.get("review_status") or "").strip()
        hash_status = str(raw.get("hash_status") or "").strip()
        resolved_path = str(raw.get("resolved_path") or "").strip()

        if review_status != "READY":
            raise RuntimeError(
                f"{document_id}: review_status není READY "
                f"({review_status or 'NEURČENO'})."
            )
        if hash_status != "MATCH":
            raise RuntimeError(
                f"{document_id}: hash_status není MATCH "
                f"({hash_status or 'NEURČENO'})."
            )
        if not resolved_path:
            raise RuntimeError(
                f"{document_id}: chybí resolved_path ke zdrojovému souboru."
            )

        normalized.append(raw)

    return normalized



def normalize_manifest_text(text: str) -> str:
    """
    Stejná normalizace jako A25/A30:
    CRLF/CR -> LF, trim okrajů a přesně jeden koncový LF.
    """
    return (
        text.replace("\r\n", "\n")
        .replace("\r", "\n")
        .strip()
        + "\n"
    )


def decode_source(raw: bytes) -> tuple[str, str]:
    encodings = [
        ("utf-8-sig", "UTF-8 BOM"),
        ("utf-8", "UTF-8"),
        ("cp1250", "Windows-1250"),
        ("cp1252", "Windows-1252"),
        ("latin-1", "Latin-1"),
    ]
    for encoding, label in encodings:
        try:
            return raw.decode(encoding, errors="strict"), label
        except UnicodeDecodeError:
            continue

    return (
        raw.decode("utf-8", errors="replace"),
        "UTF-8 s náhradou chybných znaků",
    )


def hydrate_selected_documents(
    selected: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """
    A30 JSON je záměrně metadatový. Obsah se proto znovu načte
    z resolved_path a ověří proti hashům uloženým A30.
    """
    import hashlib

    hydrated: list[dict[str, Any]] = []

    for item in selected:
        manifest = item.get("manifest") or {}
        document_id = str(manifest.get("document_id") or "").strip()
        source_path = Path(str(item.get("resolved_path") or "").strip())

        if not source_path.is_file():
            raise RuntimeError(
                f"{document_id}: zdrojový soubor nebyl nalezen: {source_path}"
            )

        raw = source_path.read_bytes()
        decoded_text, encoding = decode_source(raw)
        normalized_text = normalize_manifest_text(decoded_text)

        raw_hash = hashlib.sha256(raw).hexdigest()
        text_hash = hashlib.sha256(
            normalized_text.encode("utf-8")
        ).hexdigest()

        expected_raw_hash = str(
            item.get("raw_file_sha256") or ""
        ).strip().lower()
        expected_text_hash = str(
            item.get("export_text_sha256")
            or manifest.get("content_sha256")
            or ""
        ).strip().lower()

        if expected_raw_hash and raw_hash.lower() != expected_raw_hash:
            raise RuntimeError(
                f"{document_id}: SHA-256 původních bajtů se změnil "
                "od vytvoření korpusu A30."
            )

        if expected_text_hash and text_hash.lower() != expected_text_hash:
            raise RuntimeError(
                f"{document_id}: normalizovaný textový SHA-256 se změnil "
                "od vytvoření korpusu A30."
            )

        current = dict(item)
        current.update(
            {
                "content": normalized_text,
                "source_encoding_verified": encoding,
                "source_raw_sha256_verified": raw_hash,
                "source_text_sha256_verified": text_hash,
                "source_content_loaded": True,
            }
        )
        hydrated.append(current)

    return hydrated

def select_block(
    documents: list[dict[str, Any]],
    month: str,
    start_date: date,
    end_date: date,
    include_month_only: bool,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    selected: list[dict[str, Any]] = []
    month_only: list[dict[str, Any]] = []

    for item in documents:
        effective_month = str(item.get("effective_month") or "").strip()
        if effective_month != month:
            continue

        effective_date = str(
            item.get("effective_document_date") or ""
        ).strip()

        if not effective_date:
            month_only.append(item)
            if include_month_only:
                selected.append(item)
            continue

        current = validate_date(
            effective_date,
            "efektivní datum dokumentu",
        )
        if start_date <= current <= end_date:
            selected.append(item)

    selected.sort(key=document_sort_key)
    month_only.sort(key=document_sort_key)
    return selected, month_only


def document_sort_key(item: dict[str, Any]) -> tuple[str, str, str]:
    manifest = item.get("manifest") or {}
    return (
        str(item.get("effective_document_date") or "9999-99-99"),
        str(manifest.get("canonical_relative_path") or "").casefold(),
        str(manifest.get("document_id") or ""),
    )


def relation_rows(
    selected: list[dict[str, Any]],
    all_documents: list[dict[str, Any]],
) -> list[dict[str, str]]:
    all_ids = {
        str((item.get("manifest") or {}).get("document_id") or "").strip()
        for item in all_documents
    }
    selected_ids = {
        str((item.get("manifest") or {}).get("document_id") or "").strip()
        for item in selected
    }

    rows: list[dict[str, str]] = []
    for item in selected:
        manifest = item.get("manifest") or {}
        document_id = str(manifest.get("document_id") or "").strip()
        role = str(item.get("chronology_role") or "").strip()
        related = str(item.get("related_document_id") or "").strip()
        review_note = str(item.get("review_note") or "").strip()

        if not role and not related and not review_note:
            continue

        if not related:
            related_scope = ""
        elif related in selected_ids:
            related_scope = "IN_BLOCK"
        elif related in all_ids:
            related_scope = "IN_MONTH_OUTSIDE_BLOCK"
        else:
            related_scope = "NOT_FOUND_IN_MONTH_CORPUS"

        rows.append(
            {
                "document_id": document_id,
                "chronology_role": role,
                "related_document_id": related,
                "related_scope": related_scope,
                "review_note": review_note,
            }
        )

    return rows


def esc(value: Any) -> str:
    return str(value or "").replace("|", r"\|").replace("\n", " ")


def build_markdown(
    month: str,
    start_text: str,
    end_text: str,
    include_month_only: bool,
    corpus_path: Path,
    selected: list[dict[str, Any]],
    month_only: list[dict[str, Any]],
    relations: list[dict[str, str]],
) -> str:
    exact_count = sum(
        1 for item in selected
        if str(item.get("effective_document_date") or "").strip()
    )
    included_month_only = len(selected) - exact_count

    lines = [
        "# MATCHMATRIX – HISTORY RECONSTRUCTION SOURCE BLOCK",
        "",
        "## Informace o exportu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        f"| Měsíc | `{month}` |",
        f"| Rozsah | `{start_text}` až `{end_text}` |",
        f"| Dokumenty MONTH_ONLY připojeny | {'ANO' if include_month_only else 'NE'} |",
        f"| Vytvořeno | {datetime.now().astimezone().isoformat()} |",
        f"| Skript | `{SCRIPT_ID}` |",
        f"| Verze skriptu | `{SCRIPT_VERSION}` |",
        f"| Zdrojový JSON korpus | `{corpus_path}` |",
        f"| Vybraných dokumentů | {len(selected)} |",
        f"| Přesně datovaných ve výběru | {exact_count} |",
        f"| MONTH_ONLY ve výběru | {included_month_only} |",
        f"| MONTH_ONLY dostupných v měsíci | {len(month_only)} |",
        "| Zdrojový korpus upraven | NE |",
        "| Historický archiv upraven | NE |",
        "| Manifest upraven | NE |",
        "| Klasifikační mapa upravena | NE |",
        "| Databáze upravena | NE |",
        "",
        "## Pravidla interpretace",
        "",
        "- Tento soubor je zdrojový balíček, nikoli hotová rekonstrukční zpráva.",
        "- Doložený fakt musí být odvozen z konkrétního zdrojového dokumentu.",
        "- Návrh, plán a budoucí záměr nesmí být prezentován jako dokončený stav.",
        "- Dokument MONTH_ONLY nesmí být přiřazen ke konkrétnímu dni.",
        "- Rozšířená nebo následná varianta nesmí vést k dvojímu započítání stejného milníku.",
        "",
        "## Přehled vybraných dokumentů",
        "",
        (
            "| # | Document ID | Efektivní datum | Klasifikace | "
            "Jistota | Role | Související dokument | Název |"
        ),
        "|---:|---|---|---|---|---|---|---|",
    ]

    for index, item in enumerate(selected, 1):
        manifest = item.get("manifest") or {}
        lines.append(
            "| "
            f"{index} | {esc(manifest.get('document_id'))} | "
            f"{esc(item.get('effective_document_date') or 'MONTH_ONLY')} | "
            f"{esc(item.get('date_classification'))} | "
            f"{esc(item.get('date_confidence'))} | "
            f"{esc(item.get('chronology_role'))} | "
            f"{esc(item.get('related_document_id'))} | "
            f"{esc(manifest.get('title'))} |"
        )

    lines.extend(
        [
            "",
            "## Chronologické a verzovací vazby",
            "",
        ]
    )

    if relations:
        lines.extend(
            [
                (
                    "| Document ID | Role | Související dokument | "
                    "Umístění souvisejícího dokumentu | Review poznámka |"
                ),
                "|---|---|---|---|---|",
            ]
        )
        for row in relations:
            lines.append(
                "| "
                f"{esc(row['document_id'])} | "
                f"{esc(row['chronology_role'])} | "
                f"{esc(row['related_document_id'])} | "
                f"{esc(row['related_scope'])} | "
                f"{esc(row['review_note'])} |"
            )
    else:
        lines.append(
            "V tomto bloku nejsou evidovány zvláštní chronologické "
            "nebo verzovací vazby."
        )

    lines.extend(
        [
            "",
            "## Kontrolní seznam pro rekonstrukční zprávu",
            "",
            "- [ ] Oddělit dokončené výsledky od návrhů a plánů.",
            "- [ ] U každého významného závěru uvést zdrojový Document ID.",
            "- [ ] Sloučit opakované informace bez ztráty důkazní vazby.",
            "- [ ] Zabránit dvojímu započítání rozšířených variant.",
            "- [ ] Vymezit otevřené problémy a nedokončené oblasti.",
            "- [ ] Připravit doložené milníky pro měsíční Project Snapshot.",
            "",
            "## Zdrojové dokumenty",
            "",
        ]
    )

    for index, item in enumerate(selected, 1):
        manifest = item.get("manifest") or {}
        document_id = str(manifest.get("document_id") or "")
        title = str(manifest.get("title") or "")
        content = str(item.get("content") or "").rstrip()

        lines.extend(
            [
                "---",
                "",
                f"# {index}. {document_id} – {title}",
                "",
                "## Metadata",
                "",
                "| Položka | Hodnota |",
                "|---|---|",
                f"| Document ID | {esc(document_id)} |",
                (
                    "| Efektivní datum | "
                    f"{esc(item.get('effective_document_date') or 'POUZE MĚSÍC')} |"
                ),
                f"| Efektivní měsíc | {esc(item.get('effective_month'))} |",
                f"| Klasifikace | {esc(item.get('date_classification'))} |",
                f"| Jistota | {esc(item.get('date_confidence'))} |",
                f"| Zdroj výběru | {esc(item.get('selection_source'))} |",
                f"| Chronologická role | {esc(item.get('chronology_role'))} |",
                f"| Související dokument | {esc(item.get('related_document_id'))} |",
                f"| Základ rozhodnutí | {esc(item.get('date_basis'))} |",
                f"| Review poznámka | {esc(item.get('review_note'))} |",
                (
                    "| Relativní cesta | "
                    f"`{manifest.get('canonical_relative_path', '')}` |"
                ),
                f"| Stav načtení | {esc(item.get('review_status'))} |",
                f"| Hash status | {esc(item.get('hash_status'))} |",
                "",
                "## Původní obsah",
                "",
                f"<!-- BEGIN ORIGINAL CONTENT {document_id} -->",
                "",
                content,
                "",
                f"<!-- END ORIGINAL CONTENT {document_id} -->",
                "",
            ]
        )

    return "\n".join(lines).rstrip() + "\n"


def csv_rows(selected: list[dict[str, Any]]) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for item in selected:
        manifest = item.get("manifest") or {}
        rows.append(
            {
                "document_id": str(manifest.get("document_id") or ""),
                "title": str(manifest.get("title") or ""),
                "effective_document_date": str(
                    item.get("effective_document_date") or ""
                ),
                "effective_month": str(item.get("effective_month") or ""),
                "date_classification": str(
                    item.get("date_classification") or ""
                ),
                "date_confidence": str(
                    item.get("date_confidence") or ""
                ),
                "selection_source": str(
                    item.get("selection_source") or ""
                ),
                "chronology_role": str(
                    item.get("chronology_role") or ""
                ),
                "related_document_id": str(
                    item.get("related_document_id") or ""
                ),
                "review_note": str(item.get("review_note") or ""),
                "canonical_relative_path": str(
                    manifest.get("canonical_relative_path") or ""
                ),
                "review_status": str(item.get("review_status") or ""),
                "hash_status": str(item.get("hash_status") or ""),
            }
        )
    return rows


def write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    if not rows:
        raise RuntimeError("Nelze zapsat prázdný CSV výstup.")
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=list(rows[0].keys()),
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    args = parser().parse_args()

    try:
        month = validate_month(args.month)
        start_date = validate_date(args.start_date, "počáteční datum")
        end_date = validate_date(args.end_date, "koncové datum")

        if start_date > end_date:
            raise ValueError(
                "Počáteční datum nesmí být pozdější než koncové datum."
            )
        if start_date.strftime("%Y-%m") != month:
            raise ValueError(
                "Počáteční datum nepatří do zadaného měsíce."
            )
        if end_date.strftime("%Y-%m") != month:
            raise ValueError(
                "Koncové datum nepatří do zadaného měsíce."
            )

        output_dir = Path(args.output_dir)
        token = month.replace("-", "_")

        if args.corpus_json:
            corpus_path = Path(args.corpus_json)
        else:
            corpus_path = (
                output_dir
                / f"history_complete_month_corpus_{token}_latest.json"
            )

        payload = read_json(corpus_path)
        documents = require_corpus_ready(payload, month)

        selected, month_only = select_block(
            documents=documents,
            month=month,
            start_date=start_date,
            end_date=end_date,
            include_month_only=bool(args.include_month_only),
        )

        if not selected:
            print(
                "ERROR: Pro zadaný rozsah nebyl vybrán žádný dokument."
            )
            return 2

        selected = hydrate_selected_documents(selected)
        relations = relation_rows(selected, documents)

        output_dir.mkdir(parents=True, exist_ok=True)

        start_token = start_date.strftime("%Y%m%d")
        end_token = end_date.strftime("%Y%m%d")
        suffix = "_WITH_MONTH_ONLY" if args.include_month_only else ""
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        base = (
            f"history_reconstruction_source_block_"
            f"{start_token}_{end_token}{suffix}_{stamp}"
        )
        latest = (
            f"history_reconstruction_source_block_"
            f"{start_token}_{end_token}{suffix}_latest"
        )

        md_path = output_dir / f"{base}.md"
        json_path = output_dir / f"{base}.json"
        csv_path = output_dir / f"{base}.csv"
        latest_md = output_dir / f"{latest}.md"
        latest_json = output_dir / f"{latest}.json"
        latest_csv = output_dir / f"{latest}.csv"

        md_text = build_markdown(
            month=month,
            start_text=start_date.isoformat(),
            end_text=end_date.isoformat(),
            include_month_only=bool(args.include_month_only),
            corpus_path=corpus_path,
            selected=selected,
            month_only=month_only,
            relations=relations,
        )

        json_payload = {
            "generated_at": datetime.now().astimezone().isoformat(),
            "engine": SCRIPT_ID,
            "engine_version": SCRIPT_VERSION,
            "month": month,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "include_month_only": bool(args.include_month_only),
            "source_corpus_json": str(corpus_path),
            "selected_document_count": len(selected),
            "exact_date_count": sum(
                1 for item in selected
                if str(item.get("effective_document_date") or "").strip()
            ),
            "included_month_only_count": sum(
                1 for item in selected
                if not str(item.get("effective_document_date") or "").strip()
            ),
            "available_month_only_count": len(month_only),
            "relation_count": len(relations),
            "source_modified": False,
            "archive_modified": False,
            "manifest_modified": False,
            "classification_modified": False,
            "database_modified": False,
            "documents": selected,
            "relations": relations,
            "final_status": "HISTORY_RECONSTRUCTION_SOURCE_BLOCK_READY",
        }
        json_text = json.dumps(
            json_payload,
            ensure_ascii=False,
            indent=2,
        )
        rows = csv_rows(selected)

        for path in (md_path, latest_md):
            path.write_text(md_text, encoding="utf-8")
        for path in (json_path, latest_json):
            path.write_text(json_text, encoding="utf-8")
        for path in (csv_path, latest_csv):
            write_csv(path, rows)

        print("MATCHMATRIX HISTORY RECONSTRUCTION SOURCE BLOCK")
        print("=" * 76)
        print(f"MONTH                  : {month}")
        print(f"START DATE             : {start_date.isoformat()}")
        print(f"END DATE               : {end_date.isoformat()}")
        print(
            "INCLUDE MONTH ONLY     : "
            + ("YES" if args.include_month_only else "NO")
        )
        print(f"DOCUMENTS              : {len(selected)}")
        print(
            "EXACT DATE             : "
            + str(sum(
                1 for item in selected
                if str(item.get("effective_document_date") or "").strip()
            ))
        )
        print(
            "MONTH ONLY INCLUDED    : "
            + str(sum(
                1 for item in selected
                if not str(item.get("effective_document_date") or "").strip()
            ))
        )
        print(f"MONTH ONLY AVAILABLE   : {len(month_only)}")
        print(f"RELATIONS              : {len(relations)}")
        print("-" * 76)

        for item in selected:
            manifest = item.get("manifest") or {}
            display_date = (
                str(item.get("effective_document_date") or "").strip()
                or f"{month}-MONTH_ONLY"
            )
            print(
                f"{manifest.get('document_id')} | "
                f"{display_date} | "
                f"{item.get('date_classification')} | "
                f"{item.get('chronology_role')} | "
                f"{manifest.get('title')}"
            )

        print("-" * 76)
        print(f"MARKDOWN               : {md_path}")
        print(f"JSON                   : {json_path}")
        print(f"CSV                    : {csv_path}")
        print(f"LATEST MARKDOWN        : {latest_md}")
        print(f"LATEST JSON            : {latest_json}")
        print(f"LATEST CSV             : {latest_csv}")
        print("SOURCE CORPUS MODIFIED : False")
        print("ARCHIVE MODIFIED       : False")
        print("MANIFEST MODIFIED      : False")
        print("CLASSIFICATION MODIFIED: False")
        print("DATABASE MODIFIED      : False")
        print(
            "FINAL STATUS           : "
            "HISTORY_RECONSTRUCTION_SOURCE_BLOCK_READY"
        )
        return 0

    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
