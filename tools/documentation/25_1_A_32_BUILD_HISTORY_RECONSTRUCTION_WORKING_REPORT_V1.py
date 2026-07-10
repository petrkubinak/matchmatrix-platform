# -*- coding: utf-8 -*-
r"""
MATCHMATRIX – BUILD HISTORY RECONSTRUCTION WORKING REPORT V1

Document ID:
25_1_A_32_BUILD_HISTORY_RECONSTRUCTION_WORKING_REPORT_V1

CO:
- Načte jeden nebo více ověřených zdrojových bloků vytvořených skriptem A31.
- Sloučí jejich dokumenty bez duplicit a seřadí je chronologicky.
- Připraví pracovní rekonstrukční zprávu, důkazní matici a kontrolní JSON/CSV.
- Automaticky vytáhne kandidátní důkazní řádky, plány, opatrnostní tvrzení,
  technické objekty a chronologické či verzovací vazby.

K ČEMU:
- Vytvoří jednotný pracovní podklad pro ruční/AI rekonstrukci měsíční historie.
- Pomáhá oddělit doložené skutečnosti od plánů, širokých tvrzení a supersession.
- Nenahrazuje finální redakční posouzení ani schválený Project Snapshot.

KDE:
- tools/documentation/
  25_1_A_32_BUILD_HISTORY_RECONSTRUCTION_WORKING_REPORT_V1.py
- Výstupy:
  reports/documentation/history_review/

JAK:
- Čte pouze JSON výstupy A31 se stavem
  HISTORY_RECONSTRUCTION_SOURCE_BLOCK_READY.
- Vyžaduje, aby všechny bloky patřily do stejného měsíce.
- Odmítne duplicitní Document ID, prázdný obsah nebo neověřený zdroj.
- Vytvoří kanonický pracovní report:
  history_reconstruction_YYYYMMDD_YYYYMMDD_working_report_v1.md
- Vytvoří také JSON a CSV důkazní matici.
- Zdrojové bloky, historický archiv, manifest, klasifikaci ani databázi neupravuje.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from collections import Counter, defaultdict
from datetime import date, datetime
from pathlib import Path
from typing import Any, Iterable


SCRIPT_ID = "25_1_A_32_BUILD_HISTORY_RECONSTRUCTION_WORKING_REPORT_V1"
SCRIPT_VERSION = "1.0"

REMOTE_ROOT = Path(r"\\192.168.3.119\matchmatrix")
LOCAL_ROOT = Path(r"C:\MatchMatrix-Platform")

READY_SOURCE_STATUS = "HISTORY_RECONSTRUCTION_SOURCE_BLOCK_READY"

DOMAIN_RULES: dict[str, tuple[str, ...]] = {
    "CORE": (
        " core ", "fixture", "fixtures", "match", "matches", "league",
        "team", "teams", "stadium", "season", "canonical",
    ),
    "PEOPLE": (
        " people ", "player", "players", "coach", "coaches", "profile",
        "photo", "photos", "person",
    ),
    "MEDIA": (
        " media ", "article", "articles", "news", "trending", "decay",
        "discovery", "official site",
    ),
    "ODDS": (
        " odds ", "theodds", "bookmaker", "betting", "market",
    ),
    "TICKET ENGINE": (
        "ticket engine", "ticket", "tickets", "auto safe", "autosafe",
        "strategy", "stake",
    ),
    "HARVEST / ORCHESTRATION": (
        "harvest", "orchestration", "orchestrator", "planner", "worker",
        "ingest", "pipeline", "queue", "runtime routing",
    ),
    "GOVERNANCE": (
        "governance", "audit", "readiness", "registry", "mapping",
        "hold", "review", "source intelligence",
    ),
    "PANEL / UI": (
        "panel", "dashboard", "command center", "ui", "gui",
    ),
    "AI / ANALYTICS": (
        " ai ", "prediction", "rating", "analytics", "learning",
        "intelligence", "power",
    ),
    "INFRASTRUCTURE": (
        "pc1", "pc2", "server", "postgres", "database", "docker",
        "github", "network", "deployment", "migration",
    ),
}

CAUTION_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\b100\s*%",
        r"\bhotov[oaéý]?\b",
        r"\bkompletn[íěý]\b",
        r"\bproduction[- ]?ready\b",
        r"\bprodukčn[íě]\b",
        r"\bself[- ]?learning\b",
        r"\bplně funkčn[íě]\b",
        r"\bend[- ]to[- ]end\b",
        r"\bready\b",
        r"\bdokončen[oaéý]?\b",
    )
)

PLAN_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\bdalší krok\b",
        r"\bdalší den\b",
        r"\bzítra\b",
        r"\bplán\b",
        r"\bplánujeme\b",
        r"\bbude\b",
        r"\bbudeme\b",
        r"\bje třeba\b",
        r"\bje nutné\b",
        r"\bpřipravit\b",
        r"\bdoplnit\b",
        r"\bspustit\b",
        r"\bověřit\b",
        r"\btodo\b",
        r"\broadmap\b",
        r"\bcíl\b",
    )
)

RUNTIME_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\brun[_ -]?id\b",
        r"\bexit[_ -]?code\b",
        r"\breturn[_ -]?code\b",
        r"\brows?\b",
        r"\binserted\b",
        r"\bupdated\b",
        r"\bdeleted\b",
        r"\bparsed\b",
        r"\bfetched\b",
        r"\bprocessed\b",
        r"\bcount\b",
        r"\btotal\b",
        r"\bok\s*=",
        r"\berror\s*=",
        r"\bdone\b",
        r"\bsuccess\b",
        r"\bfailed\b",
        r"\bstatus\b",
        r"\bready\b",
        r"\bpartial\b",
        r"\bhold\b",
        r"\bwarning\b",
        r"\bcritical\b",
        r"\b\d{2,}\b",
    )
)

IMPLEMENTATION_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\.py\b",
        r"\.sql\b",
        r"\.ps1\b",
        r"\.vbs\b",
        r"\bcreate\s+(table|view|index)\b",
        r"\balter\s+table\b",
        r"\bpublic\.[a-z0-9_]+\b",
        r"\bstaging\.[a-z0-9_]+\b",
        r"\bops\.[a-z0-9_]+\b",
        r"\bv_[a-z0-9_]+\b",
        r"\bstg_[a-z0-9_]+\b",
        r"\brun_[a-z0-9_]+\b",
        r"\bpull_[a-z0-9_]+\b",
        r"\bparse_[a-z0-9_]+\b",
    )
)

DECISION_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(pattern, re.IGNORECASE)
    for pattern in (
        r"\brozhodnut",
        r"\barchitektur",
        r"\bpravidlo\b",
        r"\bstandard\b",
        r"\bnesmí\b",
        r"\bmusí\b",
        r"\bprefer",
        r"\bzdroj pravdy\b",
        r"\bsource of truth\b",
        r"\bgovernance stav\b",
    )
)


def project_root() -> Path:
    local_reports = LOCAL_ROOT / "reports" / "documentation"
    return LOCAL_ROOT if local_reports.is_dir() else REMOTE_ROOT


def build_parser() -> argparse.ArgumentParser:
    root = project_root()
    parser = argparse.ArgumentParser(
        description=(
            "Sestaví pracovní rekonstrukční report z ověřených bloků A31."
        )
    )
    parser.add_argument(
        "--source-block-json",
        action="append",
        required=True,
        help=(
            "JSON zdrojového bloku A31. Parametr lze zadat opakovaně."
        ),
    )
    parser.add_argument(
        "--expected-documents",
        type=int,
        default=0,
        help=(
            "Volitelný očekávaný počet unikátních dokumentů. "
            "Neshoda zastaví export."
        ),
    )
    parser.add_argument(
        "--output-dir",
        default=str(
            root / "reports" / "documentation" / "history_review"
        ),
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Povolí přepsání již existující kanonické pracovní zprávy.",
    )
    return parser


def load_json(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"Zdrojový blok nebyl nalezen: {path}")
    with path.open("r", encoding="utf-8-sig") as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise RuntimeError(f"Neplatná kořenová struktura JSON: {path}")
    return payload


def validate_iso_date(value: str, label: str) -> date:
    try:
        return datetime.strptime(value, "%Y-%m-%d").date()
    except ValueError as exc:
        raise RuntimeError(
            f"Neplatné {label} '{value}', očekáván formát YYYY-MM-DD."
        ) from exc


def normalize_text(value: Any) -> str:
    return (
        str(value or "")
        .replace("\r\n", "\n")
        .replace("\r", "\n")
        .strip()
    )


def compact_line(value: str, limit: int = 240) -> str:
    value = re.sub(r"\s+", " ", value).strip()
    if len(value) <= limit:
        return value
    return value[: limit - 1].rstrip() + "…"


def markdown_escape(value: Any) -> str:
    return compact_line(str(value or ""), 400).replace("|", r"\|")


def source_line_iter(content: str) -> Iterable[tuple[int, str]]:
    in_fence = False
    for line_no, raw in enumerate(content.splitlines(), 1):
        stripped = raw.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if not stripped:
            continue
        if stripped.startswith("<!--"):
            continue
        yield line_no, stripped


def is_heading_or_noise(line: str) -> bool:
    if line.startswith("#"):
        return True
    if re.fullmatch(r"[-=_*]{3,}", line):
        return True
    if line.startswith("|---"):
        return True
    return False


def unique_signals(
    content: str,
    patterns: tuple[re.Pattern[str], ...],
    limit: int,
    allow_headings: bool = False,
) -> list[dict[str, Any]]:
    found: list[dict[str, Any]] = []
    seen: set[str] = set()

    for line_no, line in source_line_iter(content):
        if not allow_headings and is_heading_or_noise(line):
            continue
        if len(line) < 4:
            continue
        if not any(pattern.search(line) for pattern in patterns):
            continue

        cleaned = compact_line(line)
        key = cleaned.casefold()
        if key in seen:
            continue
        seen.add(key)
        found.append({"line": line_no, "text": cleaned})
        if len(found) >= limit:
            break

    return found


def extract_headings(content: str, limit: int = 12) -> list[str]:
    headings: list[str] = []
    seen: set[str] = set()
    for _, line in source_line_iter(content):
        if not line.startswith("#"):
            continue
        cleaned = re.sub(r"^#+\s*", "", line).strip()
        if not cleaned:
            continue
        key = cleaned.casefold()
        if key in seen:
            continue
        seen.add(key)
        headings.append(compact_line(cleaned, 180))
        if len(headings) >= limit:
            break
    return headings


def infer_domains(title: str, content: str) -> list[str]:
    haystack = f" {title} {content[:20000]} ".casefold()
    domains: list[str] = []
    for domain, keywords in DOMAIN_RULES.items():
        if any(keyword.casefold() in haystack for keyword in keywords):
            domains.append(domain)
    return domains or ["NEZAŘAZENO"]


def classify_document(
    runtime: list[dict[str, Any]],
    implementation: list[dict[str, Any]],
    plans: list[dict[str, Any]],
) -> str:
    has_runtime = bool(runtime)
    has_impl = bool(implementation)
    has_plan = bool(plans)

    if has_runtime and has_impl and has_plan:
        return "MIXED: RUNTIME + IMPLEMENTATION + PLAN"
    if has_runtime and has_impl:
        return "RUNTIME TESTED / IMPLEMENTED"
    if has_runtime and has_plan:
        return "MIXED: RUNTIME + PLAN"
    if has_impl and has_plan:
        return "MIXED: IMPLEMENTATION + PLAN"
    if has_runtime:
        return "RUNTIME EVIDENCE CANDIDATE"
    if has_impl:
        return "IMPLEMENTATION EVIDENCE CANDIDATE"
    if has_plan:
        return "PLAN / ROADMAP CANDIDATE"
    return "MANUAL REVIEW REQUIRED"


def validate_and_merge(
    paths: list[Path],
) -> tuple[str, list[dict[str, Any]], list[dict[str, str]], list[dict[str, Any]]]:
    months: set[str] = set()
    documents: list[dict[str, Any]] = []
    relations: list[dict[str, str]] = []
    blocks: list[dict[str, Any]] = []
    seen_ids: dict[str, str] = {}

    for path in paths:
        payload = load_json(path)
        final_status = str(payload.get("final_status") or "").strip()
        if final_status != READY_SOURCE_STATUS:
            raise RuntimeError(
                f"{path}: neplatný stav zdrojového bloku "
                f"({final_status or 'NEURČENO'})."
            )

        month = str(payload.get("month") or "").strip()
        if not re.fullmatch(r"20\d{2}-(0[1-9]|1[0-2])", month):
            raise RuntimeError(f"{path}: neplatný nebo chybějící měsíc.")
        months.add(month)

        start_text = str(payload.get("start_date") or "").strip()
        end_text = str(payload.get("end_date") or "").strip()
        validate_iso_date(start_text, "počáteční datum bloku")
        validate_iso_date(end_text, "koncové datum bloku")

        raw_documents = payload.get("documents")
        if not isinstance(raw_documents, list) or not raw_documents:
            raise RuntimeError(f"{path}: blok neobsahuje dokumenty.")

        blocks.append(
            {
                "path": str(path),
                "month": month,
                "start_date": start_text,
                "end_date": end_text,
                "include_month_only": bool(
                    payload.get("include_month_only")
                ),
                "document_count": len(raw_documents),
                "relation_count": int(payload.get("relation_count") or 0),
            }
        )

        for item in raw_documents:
            if not isinstance(item, dict):
                raise RuntimeError(f"{path}: neplatný záznam dokumentu.")

            manifest = item.get("manifest")
            if not isinstance(manifest, dict):
                raise RuntimeError(f"{path}: dokument nemá manifest.")

            document_id = str(
                manifest.get("document_id") or ""
            ).strip()
            if not document_id:
                raise RuntimeError(f"{path}: dokument nemá Document ID.")
            if document_id in seen_ids:
                raise RuntimeError(
                    f"Duplicitní Document ID {document_id} v blocích "
                    f"{seen_ids[document_id]} a {path}."
                )

            if str(item.get("review_status") or "").strip() != "READY":
                raise RuntimeError(
                    f"{document_id}: review_status není READY."
                )
            if str(item.get("hash_status") or "").strip() != "MATCH":
                raise RuntimeError(
                    f"{document_id}: hash_status není MATCH."
                )
            if not bool(item.get("source_content_loaded")):
                raise RuntimeError(
                    f"{document_id}: obsah nebyl načten a ověřen A31."
                )

            content = normalize_text(item.get("content"))
            if not content:
                raise RuntimeError(f"{document_id}: obsah je prázdný.")

            current = dict(item)
            current["content"] = content
            current["_source_block"] = str(path)
            documents.append(current)
            seen_ids[document_id] = str(path)

        raw_relations = payload.get("relations") or []
        if not isinstance(raw_relations, list):
            raise RuntimeError(f"{path}: relations nemá seznamovou strukturu.")
        for relation in raw_relations:
            if isinstance(relation, dict):
                relations.append(
                    {
                        "document_id": str(
                            relation.get("document_id") or ""
                        ).strip(),
                        "chronology_role": str(
                            relation.get("chronology_role") or ""
                        ).strip(),
                        "related_document_id": str(
                            relation.get("related_document_id") or ""
                        ).strip(),
                        "related_scope": str(
                            relation.get("related_scope") or ""
                        ).strip(),
                        "review_note": str(
                            relation.get("review_note") or ""
                        ).strip(),
                    }
                )

    if len(months) != 1:
        raise RuntimeError(
            "Všechny zdrojové bloky musí patřit do stejného měsíce: "
            + ", ".join(sorted(months))
        )

    documents.sort(key=document_sort_key)
    relations = deduplicate_relations(relations)
    return next(iter(months)), documents, relations, blocks


def document_sort_key(item: dict[str, Any]) -> tuple[str, str]:
    manifest = item.get("manifest") or {}
    effective_date = str(
        item.get("effective_document_date") or ""
    ).strip()
    return (
        effective_date or "9999-99-99",
        str(manifest.get("document_id") or ""),
    )


def deduplicate_relations(
    relations: list[dict[str, str]],
) -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    seen: set[tuple[str, ...]] = set()
    for row in relations:
        key = (
            row["document_id"],
            row["chronology_role"],
            row["related_document_id"],
            row["review_note"],
        )
        if key in seen:
            continue
        seen.add(key)
        result.append(row)
    return result


def build_evidence_rows(
    documents: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []

    for order, item in enumerate(documents, 1):
        manifest = item.get("manifest") or {}
        document_id = str(manifest.get("document_id") or "").strip()
        title = str(manifest.get("title") or "").strip()
        content = normalize_text(item.get("content"))

        runtime = unique_signals(content, RUNTIME_PATTERNS, limit=18)
        implementation = unique_signals(
            content, IMPLEMENTATION_PATTERNS, limit=18
        )
        plans = unique_signals(content, PLAN_PATTERNS, limit=14)
        caution = unique_signals(content, CAUTION_PATTERNS, limit=14)
        decisions = unique_signals(content, DECISION_PATTERNS, limit=12)

        rows.append(
            {
                "order": order,
                "document_id": document_id,
                "title": title,
                "effective_document_date": str(
                    item.get("effective_document_date") or ""
                ).strip(),
                "effective_month": str(
                    item.get("effective_month") or ""
                ).strip(),
                "date_classification": str(
                    item.get("date_classification") or ""
                ).strip(),
                "date_confidence": str(
                    item.get("date_confidence") or ""
                ).strip(),
                "chronology_role": str(
                    item.get("chronology_role") or ""
                ).strip(),
                "related_document_id": str(
                    item.get("related_document_id") or ""
                ).strip(),
                "review_note": str(
                    item.get("review_note") or ""
                ).strip(),
                "domains": infer_domains(title, content),
                "headings": extract_headings(content),
                "runtime_signals": runtime,
                "implementation_signals": implementation,
                "plan_signals": plans,
                "caution_signals": caution,
                "decision_signals": decisions,
                "automatic_classification": classify_document(
                    runtime, implementation, plans
                ),
                "source_block": str(item.get("_source_block") or ""),
                "canonical_relative_path": str(
                    manifest.get("canonical_relative_path") or ""
                ),
            }
        )

    return rows


def aggregate_signal_count(
    rows: list[dict[str, Any]],
    key: str,
) -> int:
    return sum(len(row.get(key) or []) for row in rows)


def group_by_date(
    rows: list[dict[str, Any]],
) -> list[tuple[str, list[dict[str, Any]]]]:
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        date_key = row["effective_document_date"] or "MONTH_ONLY"
        grouped[date_key].append(row)

    exact_dates = sorted(key for key in grouped if key != "MONTH_ONLY")
    result = [(key, grouped[key]) for key in exact_dates]
    if "MONTH_ONLY" in grouped:
        result.append(("MONTH_ONLY", grouped["MONTH_ONLY"]))
    return result


def format_signal_list(
    document_id: str,
    signals: list[dict[str, Any]],
    empty_text: str,
) -> list[str]:
    if not signals:
        return [f"- {empty_text}"]
    return [
        f"- `{document_id}:L{signal['line']}` — {signal['text']}"
        for signal in signals
    ]


def build_markdown(
    month: str,
    start_date: str,
    end_date: str,
    documents: list[dict[str, Any]],
    relations: list[dict[str, str]],
    blocks: list[dict[str, Any]],
    evidence_rows: list[dict[str, Any]],
) -> str:
    domain_counts: Counter[str] = Counter()
    for row in evidence_rows:
        domain_counts.update(row["domains"])

    exact_count = sum(
        1 for row in evidence_rows if row["effective_document_date"]
    )
    month_only_count = len(evidence_rows) - exact_count

    lines: list[str] = [
        "# MATCHMATRIX – PRACOVNÍ REKONSTRUKCE HISTORIE",
        "",
        f"## Období {start_date} až {end_date}",
        "",
        "---",
        "",
        "## Informace o pracovním dokumentu",
        "",
        "| Položka | Hodnota |",
        "|---|---|",
        "| Typ výstupu | Pracovní rekonstrukční zpráva – automaticky připravený podklad |",
        f"| Období | {start_date} až {end_date} |",
        f"| Měsíc | {month} |",
        f"| Počet zdrojových bloků A31 | {len(blocks)} |",
        f"| Počet unikátních dokumentů | {len(documents)} |",
        f"| Přesně datované dokumenty | {exact_count} |",
        f"| Dokumenty pouze na úrovni měsíce | {month_only_count} |",
        "| Účel | Podklad pro ruční/AI rekonstrukci a následný Project Snapshot |",
        "| Stav | WORKING REVIEW – AUTO PREPARED |",
        "| Úprava historických zdrojů | NE |",
        "| Zdroj pravdy | Ověřené zdrojové bloky A31 a původní historický archiv |",
        "| Metoda | Chronologie, důkazní signály, plánové signály, opatrnostní tvrzení a supersession |",
        f"| Generátor | `{SCRIPT_ID}` v{SCRIPT_VERSION} |",
        "",
        "### Použité zdrojové bloky",
        "",
        "| Rozsah | Dokumenty | MONTH_ONLY | JSON |",
        "|---|---:|---|---|",
    ]

    for block in sorted(blocks, key=lambda item: item["start_date"]):
        lines.append(
            "| "
            f"{block['start_date']} až {block['end_date']} | "
            f"{block['document_count']} | "
            f"{'ANO' if block['include_month_only'] else 'NE'} | "
            f"`{block['path']}` |"
        )

    lines.extend(
        [
            "",
            "# 1. Účel rekonstrukce",
            "",
            "Tento dokument je pracovní podklad. Automatická část pouze shromažďuje a třídí důkazy; sama nepotvrzuje, že široké historické formulace byly pravdivé v celém rozsahu.",
            "",
            "Při redakčním dokončení je nutné:",
            "",
            "- určit skutečné technické milníky,",
            "- oddělit implementaci od plánu,",
            "- rozlišit lokální test od globální připravenosti,",
            "- sloučit opakované informace bez dvojího započítání,",
            "- zohlednit rozšířené, předchozí a superseded varianty,",
            "- každé důležité tvrzení svázat s konkrétním `MM-HIS-*` zdrojem.",
            "",
            "# 2. Klasifikace použitých důkazů",
            "",
            "| Klasifikace | Význam |",
            "|---|---|",
            "| RUNTIME TESTED | Zdroj uvádí konkrétní běh, výsledek, počet nebo návratový kód |",
            "| IMPLEMENTED | Je uveden konkrétní skript, view, tabulka nebo změna logiky |",
            "| TECH READY | Architektura nebo konfigurace existuje, ale není potvrzen plný ostrý běh |",
            "| PARTIAL | Funguje pouze část toku, omezený sport, provider, liga nebo entita |",
            "| PLANNED | Jde o plán, roadmapu nebo další krok |",
            "| CLAIM REQUIRING CAUTION | Tvrzení je širší než doložené důkazy |",
            "| SUPERSEDED / EXPANDED | Pozdější dokument závěr zpřesnil, rozšířil nebo nahradil |",
            "",
            "> Automatická klasifikace níže je pouze kandidátní. Finální důkazní stav musí být potvrzen redakčním review.",
            "",
            "# 3. Hlavní pracovní obraz období",
            "",
            f"Zdrojový soubor obsahuje **{len(documents)} unikátních dokumentů**. "
            f"Automatická extrakce nalezla **{aggregate_signal_count(evidence_rows, 'runtime_signals')} runtime/datových signálů**, "
            f"**{aggregate_signal_count(evidence_rows, 'implementation_signals')} implementačních signálů**, "
            f"**{aggregate_signal_count(evidence_rows, 'plan_signals')} plánových signálů** a "
            f"**{aggregate_signal_count(evidence_rows, 'caution_signals')} formulací vyžadujících opatrnou interpretaci**.",
            "",
            "### Doménové pokrytí zdrojů",
            "",
            "| Oblast | Počet dokumentů s výskytem |",
            "|---|---:|",
        ]
    )

    for domain, count in domain_counts.most_common():
        lines.append(f"| {domain} | {count} |")

    lines.extend(
        [
            "",
            "### Pracovní závěr k doplnění",
            "",
            "> **REDAKČNÍ ÚKOL:** Na základě chronologie v kapitole 4 formulovat 3–6 hlavních posunů období. Každý posun musí uvést zdrojové `MM-HIS-*` dokumenty a přesně vymezit rozsah platnosti.",
            "",
            "# 4. Chronologická rekonstrukce",
            "",
        ]
    )

    section_index = 1
    for date_key, date_rows in group_by_date(evidence_rows):
        display_date = (
            "Dokumenty zařazené pouze na úroveň měsíce"
            if date_key == "MONTH_ONLY"
            else date_key
        )
        lines.extend(
            [
                f"## 4.{section_index} {display_date}",
                "",
            ]
        )
        section_index += 1

        for row in date_rows:
            lines.extend(
                [
                    f"### {row['document_id']} – {row['title']}",
                    "",
                    "| Položka | Hodnota |",
                    "|---|---|",
                    f"| Automatická kandidátní klasifikace | {markdown_escape(row['automatic_classification'])} |",
                    f"| Domény | {markdown_escape(', '.join(row['domains']))} |",
                    f"| Klasifikace data | {markdown_escape(row['date_classification'])} |",
                    f"| Jistota data | {markdown_escape(row['date_confidence'])} |",
                    f"| Chronologická role | {markdown_escape(row['chronology_role'])} |",
                    f"| Související dokument | {markdown_escape(row['related_document_id'])} |",
                    f"| Zdrojová cesta | `{row['canonical_relative_path']}` |",
                    "",
                    "#### Struktura zdroje",
                    "",
                ]
            )

            if row["headings"]:
                lines.extend(f"- {heading}" for heading in row["headings"])
            else:
                lines.append("- Zdroj neobsahuje použitelné Markdown nadpisy.")

            lines.extend(
                [
                    "",
                    "#### Kandidátní runtime a datové důkazy",
                    "",
                    *format_signal_list(
                        row["document_id"],
                        row["runtime_signals"][:10],
                        "Automaticky nebyl nalezen jednoznačný runtime/datový řádek.",
                    ),
                    "",
                    "#### Kandidátní implementační důkazy",
                    "",
                    *format_signal_list(
                        row["document_id"],
                        row["implementation_signals"][:10],
                        "Automaticky nebyl nalezen jednoznačný implementační řádek.",
                    ),
                    "",
                    "#### Plány a otevřené kroky",
                    "",
                    *format_signal_list(
                        row["document_id"],
                        row["plan_signals"][:8],
                        "Automaticky nebyl nalezen jednoznačný plánový řádek.",
                    ),
                    "",
                    "#### Tvrzení vyžadující opatrnou interpretaci",
                    "",
                    *format_signal_list(
                        row["document_id"],
                        row["caution_signals"][:8],
                        "Automaticky nebyla nalezena typická nadsazená formulace.",
                    ),
                    "",
                    "#### Redakční rekonstrukční závěr",
                    "",
                    f"> **DOPLNIT:** Stručně vymezit, co dokument `{row['document_id']}` skutečně dokládá, co pouze plánuje a co nesmí být převzato doslova.",
                    "",
                ]
            )

    lines.extend(
        [
            "# 5. Návaznosti, překryvy a supersession dokumentů",
            "",
        ]
    )

    if relations:
        lines.extend(
            [
                "| Dokument | Role | Související dokument | Rozsah vazby | Review poznámka |",
                "|---|---|---|---|---|",
            ]
        )
        for relation in relations:
            lines.append(
                "| "
                f"{markdown_escape(relation['document_id'])} | "
                f"{markdown_escape(relation['chronology_role'])} | "
                f"{markdown_escape(relation['related_document_id'])} | "
                f"{markdown_escape(relation['related_scope'])} | "
                f"{markdown_escape(relation['review_note'])} |"
            )
    else:
        lines.append(
            "Ve zdrojových blocích nejsou evidovány zvláštní vazby."
        )

    lines.extend(
        [
            "",
            "### Povinná redakční kontrola",
            "",
            "- [ ] Rozšířená varianta nesmí vést k dvojímu započítání stejného výsledku.",
            "- [ ] Předchozí nebo kratší varianta má být použita pouze pro vývoj chronologie.",
            "- [ ] Checklist nesmí být vydáván za dokončenou implementaci.",
            "- [ ] Roadmapa nebo vize nesmí být vydávána za současný stav.",
            "",
            "# 6. Kandidátní milníky pro Project Snapshot",
            "",
            "> Následující tabulka není schváleným seznamem milníků. Dokumenty jsou seřazeny podle množství automaticky nalezených runtime a implementačních signálů.",
            "",
            "| Pořadí | Document ID | Datum | Domény | Runtime signály | Implementační signály | Kandidátní klasifikace |",
            "|---:|---|---|---|---:|---:|---|",
        ]
    )

    milestone_rows = sorted(
        evidence_rows,
        key=lambda row: (
            len(row["runtime_signals"]) + len(row["implementation_signals"]),
            len(row["runtime_signals"]),
        ),
        reverse=True,
    )
    for index, row in enumerate(milestone_rows, 1):
        lines.append(
            "| "
            f"{index} | {row['document_id']} | "
            f"{row['effective_document_date'] or 'MONTH_ONLY'} | "
            f"{markdown_escape(', '.join(row['domains']))} | "
            f"{len(row['runtime_signals'])} | "
            f"{len(row['implementation_signals'])} | "
            f"{markdown_escape(row['automatic_classification'])} |"
        )

    lines.extend(
        [
            "",
            "# 7. Tvrzení, která musí projít opatrnou interpretací",
            "",
        ]
    )

    caution_rows = [
        row for row in evidence_rows if row["caution_signals"]
    ]
    if caution_rows:
        for row in caution_rows:
            lines.append(
                f"## {row['document_id']} – {row['title']}"
            )
            lines.append("")
            lines.extend(
                format_signal_list(
                    row["document_id"],
                    row["caution_signals"],
                    "Bez nálezu.",
                )
            )
            lines.append("")
    else:
        lines.append(
            "Automatická kontrola nenašla typické opatrnostní formulace."
        )
        lines.append("")

    lines.extend(
        [
            "# 8. Kandidátní architektonická a governance rozhodnutí",
            "",
        ]
    )

    decision_rows = [
        row for row in evidence_rows if row["decision_signals"]
    ]
    if decision_rows:
        for row in decision_rows:
            lines.append(
                f"## {row['document_id']} – {row['title']}"
            )
            lines.append("")
            lines.extend(
                format_signal_list(
                    row["document_id"],
                    row["decision_signals"],
                    "Bez nálezu.",
                )
            )
            lines.append("")
    else:
        lines.append(
            "Automatická kontrola nenašla kandidátní rozhodovací řádky."
        )
        lines.append("")

    lines.extend(
        [
            "# 9. Stav hlavních oblastí na konci období",
            "",
            "| Oblast | Doložený stav | Omezení / otevřené body | Zdroje |",
            "|---|---|---|---|",
        ]
    )

    for domain, _ in domain_counts.most_common():
        source_ids = [
            row["document_id"]
            for row in evidence_rows
            if domain in row["domains"]
        ]
        lines.append(
            f"| {domain} | **DOPLNIT PO REVIEW** | "
            f"**DOPLNIT PO REVIEW** | "
            f"{', '.join(f'`{item}`' for item in source_ids)} |"
        )

    lines.extend(
        [
            "",
            "# 10. Otevřené otázky a práce přenášená dále",
            "",
        ]
    )

    plan_rows = [row for row in evidence_rows if row["plan_signals"]]
    if plan_rows:
        for row in plan_rows:
            lines.append(
                f"## {row['document_id']} – {row['title']}"
            )
            lines.append("")
            lines.extend(
                format_signal_list(
                    row["document_id"],
                    row["plan_signals"],
                    "Bez nálezu.",
                )
            )
            lines.append("")
    else:
        lines.append(
            "Automatická kontrola nenašla kandidátní plánové řádky."
        )
        lines.append("")

    lines.extend(
        [
            "# 11. Pracovní závěr",
            "",
            "> **REDAKČNÍ ÚKOL:** Po dokončení chronologického review shrnout skutečný přínos období, nejvýznamnější omezení a návaznost na další časový blok.",
            "",
            "Před převodem do Project Snapshot musí být splněno:",
            "",
            "- [ ] Každý milník má konkrétní zdroj.",
            "- [ ] Runtime výsledek není zobecněn mimo testovaný rozsah.",
            "- [ ] Plán není prezentován jako dokončená implementace.",
            "- [ ] Superseded a expanded dokumenty nejsou započítány duplicitně.",
            "- [ ] Dokumenty `MONTH_ONLY` nejsou přiřazeny ke konkrétnímu dni.",
            "- [ ] Stav každé hlavní oblasti je vyjádřen jako READY / PARTIAL / HOLD / DATA GAP / PLANNED podle důkazů.",
            "",
            "## Historie pracovní verze",
            "",
            "| Verze | Datum | Změna |",
            "|---|---|---|",
            f"| v1 | {datetime.now().date().isoformat()} | Automaticky připravený rekonstrukční podklad A32; čeká na redakční review |",
            "",
        ]
    )

    return "\n".join(lines).rstrip() + "\n"


def build_csv_rows(
    evidence_rows: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for row in evidence_rows:
        result.append(
            {
                "order": row["order"],
                "document_id": row["document_id"],
                "effective_document_date": row[
                    "effective_document_date"
                ],
                "effective_month": row["effective_month"],
                "title": row["title"],
                "domains": "; ".join(row["domains"]),
                "automatic_classification": row[
                    "automatic_classification"
                ],
                "runtime_signal_count": len(row["runtime_signals"]),
                "implementation_signal_count": len(
                    row["implementation_signals"]
                ),
                "plan_signal_count": len(row["plan_signals"]),
                "caution_signal_count": len(row["caution_signals"]),
                "decision_signal_count": len(row["decision_signals"]),
                "chronology_role": row["chronology_role"],
                "related_document_id": row["related_document_id"],
                "date_classification": row["date_classification"],
                "date_confidence": row["date_confidence"],
                "canonical_relative_path": row[
                    "canonical_relative_path"
                ],
                "source_block": row["source_block"],
            }
        )
    return result


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        raise RuntimeError("Nelze zapsat prázdnou důkazní matici.")
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=list(rows[0].keys()),
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    args = build_parser().parse_args()

    try:
        source_paths = [
            Path(value) for value in args.source_block_json
        ]
        month, documents, relations, blocks = validate_and_merge(
            source_paths
        )

        if (
            args.expected_documents > 0
            and len(documents) != args.expected_documents
        ):
            raise RuntimeError(
                f"Očekáváno {args.expected_documents} dokumentů, "
                f"nalezeno {len(documents)}."
            )

        exact_dates = [
            str(item.get("effective_document_date") or "").strip()
            for item in documents
            if str(item.get("effective_document_date") or "").strip()
        ]
        if not exact_dates:
            raise RuntimeError(
                "Nelze určit rozsah: žádný dokument nemá přesné datum."
            )

        start_date = min(exact_dates)
        end_date = max(exact_dates)
        validate_iso_date(start_date, "počáteční datum reportu")
        validate_iso_date(end_date, "koncové datum reportu")

        evidence_rows = build_evidence_rows(documents)

        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        start_token = start_date.replace("-", "")
        end_token = end_date.replace("-", "")
        base_name = (
            f"history_reconstruction_{start_token}_{end_token}"
            "_working_report_v1"
        )

        md_path = output_dir / f"{base_name}.md"
        json_path = output_dir / f"{base_name}.json"
        csv_path = output_dir / f"{base_name}.csv"

        existing = [
            path for path in (md_path, json_path, csv_path)
            if path.exists()
        ]
        if existing and not args.overwrite:
            raise FileExistsError(
                "Kanonický výstup již existuje. Pro řízené přepsání "
                "použijte --overwrite: "
                + ", ".join(str(path) for path in existing)
            )

        markdown_text = build_markdown(
            month=month,
            start_date=start_date,
            end_date=end_date,
            documents=documents,
            relations=relations,
            blocks=blocks,
            evidence_rows=evidence_rows,
        )

        json_payload = {
            "generated_at": datetime.now().astimezone().isoformat(),
            "engine": SCRIPT_ID,
            "engine_version": SCRIPT_VERSION,
            "month": month,
            "start_date": start_date,
            "end_date": end_date,
            "source_blocks": blocks,
            "source_block_count": len(blocks),
            "document_count": len(documents),
            "exact_date_count": sum(
                1 for row in evidence_rows
                if row["effective_document_date"]
            ),
            "month_only_count": sum(
                1 for row in evidence_rows
                if not row["effective_document_date"]
            ),
            "relation_count": len(relations),
            "runtime_signal_count": aggregate_signal_count(
                evidence_rows, "runtime_signals"
            ),
            "implementation_signal_count": aggregate_signal_count(
                evidence_rows, "implementation_signals"
            ),
            "plan_signal_count": aggregate_signal_count(
                evidence_rows, "plan_signals"
            ),
            "caution_signal_count": aggregate_signal_count(
                evidence_rows, "caution_signals"
            ),
            "decision_signal_count": aggregate_signal_count(
                evidence_rows, "decision_signals"
            ),
            "evidence_rows": evidence_rows,
            "relations": relations,
            "source_blocks_modified": False,
            "archive_modified": False,
            "manifest_modified": False,
            "classification_modified": False,
            "database_modified": False,
            "final_status": (
                "HISTORY_RECONSTRUCTION_WORKING_REPORT_AUTO_PREPARED"
            ),
        }

        csv_rows = build_csv_rows(evidence_rows)

        md_path.write_text(markdown_text, encoding="utf-8")
        json_path.write_text(
            json.dumps(
                json_payload,
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
        write_csv(csv_path, csv_rows)

        print("MATCHMATRIX HISTORY RECONSTRUCTION WORKING REPORT")
        print("=" * 76)
        print(f"MONTH                  : {month}")
        print(f"START DATE             : {start_date}")
        print(f"END DATE               : {end_date}")
        print(f"SOURCE BLOCKS          : {len(blocks)}")
        print(f"DOCUMENTS              : {len(documents)}")
        print(
            "EXACT DATE             : "
            + str(sum(
                1 for row in evidence_rows
                if row["effective_document_date"]
            ))
        )
        print(
            "MONTH ONLY             : "
            + str(sum(
                1 for row in evidence_rows
                if not row["effective_document_date"]
            ))
        )
        print(f"RELATIONS              : {len(relations)}")
        print(
            "RUNTIME SIGNALS        : "
            + str(aggregate_signal_count(
                evidence_rows, "runtime_signals"
            ))
        )
        print(
            "IMPLEMENTATION SIGNALS : "
            + str(aggregate_signal_count(
                evidence_rows, "implementation_signals"
            ))
        )
        print(
            "PLAN SIGNALS           : "
            + str(aggregate_signal_count(
                evidence_rows, "plan_signals"
            ))
        )
        print(
            "CAUTION SIGNALS        : "
            + str(aggregate_signal_count(
                evidence_rows, "caution_signals"
            ))
        )
        print(
            "DECISION SIGNALS       : "
            + str(aggregate_signal_count(
                evidence_rows, "decision_signals"
            ))
        )
        print("-" * 76)

        for row in evidence_rows:
            print(
                f"{row['document_id']} | "
                f"{row['effective_document_date'] or month + '-MONTH_ONLY'} | "
                f"{row['automatic_classification']} | "
                f"{','.join(row['domains'])}"
            )

        print("-" * 76)
        print(f"MARKDOWN               : {md_path}")
        print(f"JSON                   : {json_path}")
        print(f"CSV                    : {csv_path}")
        print("SOURCE BLOCKS MODIFIED : False")
        print("ARCHIVE MODIFIED       : False")
        print("MANIFEST MODIFIED      : False")
        print("CLASSIFICATION MODIFIED: False")
        print("DATABASE MODIFIED      : False")
        print(
            "FINAL STATUS           : "
            "HISTORY_RECONSTRUCTION_WORKING_REPORT_AUTO_PREPARED"
        )
        return 0

    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
