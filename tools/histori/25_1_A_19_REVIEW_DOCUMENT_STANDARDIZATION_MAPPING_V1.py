#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Poskytuje bezpečný panelový editor mapování standardizačního návrhu vytvořeného
skriptem A18.

K ČEMU:
- načte panelový kontrakt A18,
- ověří kontrakt, zdrojový dokument a jeho SHA-256,
- zobrazí bloky dokumentu v přehledné mapovací frontě,
- umožní potvrdit navrženou kapitolu,
- umožní přesunout blok do jiné kapitoly,
- umožní bezpečně rozdělit blok bez ztráty textu,
- umožní označit skutečný šum k vyloučení,
- umožní vrátit blok k ručnímu posouzení,
- podporuje hromadné potvrzení a přesun vybraných bloků,
- průběžně ukládá rozpracovanou revizi,
- povolí uzavření mapování až po rozhodnutí o všech povinných blocích,
- připravuje stabilní výstupní kontrakt pro následné sestavení dokumentu,
- původní dokument ani databázi nemění.

KDE:
tools/documentation/25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py

JAK:
Běžné GUI:
    py -3.14 .\\tools\\documentation\\25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py

Explicitní vstup:
    py -3.14 .\\tools\\documentation\\25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py ^
      --mapping reports\\documentation\\standardization\\proposals\\document_standardization_panel_mapping_latest.json

Pouze validace bez GUI:
    py -3.14 .\\tools\\documentation\\25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py ^
      --validate-only

BEZPEČNOST:
- zdrojový dokument je pouze pro čtení,
- před načtením i uložením se ověřuje jeho SHA-256,
- databáze se nemění,
- původní kontrakt A18 se nepřepisuje,
- rozdělení bloku je dovoleno pouze tehdy, když po odstranění značek SPLIT
  vznikne přesně původní text,
- mapování nelze uzavřít, dokud všechny povinné bloky nemají potvrzené
  rozhodnutí.

VÝSTUP:
reports/documentation/standardization/reviews/
- document_standardization_panel_review_YYYYMMDD_HHMMSS.json
- document_standardization_panel_review_YYYYMMDD_HHMMSS.csv
- document_standardization_panel_review_YYYYMMDD_HHMMSS.md
- document_standardization_panel_review_latest.json
- document_standardization_panel_review_latest.csv
- document_standardization_panel_review_latest.md
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
import sys
from copy import deepcopy
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

try:
    import tkinter as tk
    from tkinter import filedialog, messagebox, simpledialog, ttk
except ImportError as exc:  # pragma: no cover - depends on local Python build
    raise SystemExit(
        "Tkinter není dostupný v této instalaci Pythonu. "
        "Nainstaluj Python s podporou Tcl/Tk."
    ) from exc


MAPPING_DEFAULT = Path(
    "reports/documentation/standardization/proposals/"
    "document_standardization_panel_mapping_latest.json"
)
OUTPUT_DEFAULT = Path(
    "reports/documentation/standardization/reviews"
)
LATEST_REVIEW_NAME = "document_standardization_panel_review_latest.json"

SUPPORTED_CONTRACT_VERSIONS = {"1.0"}
EXPECTED_INPUT_STATUS = "DOCUMENT_STANDARDIZATION_PANEL_MAPPING_READY"
ENGINE_VERSION = "A19_PANEL_MAPPING_REVIEW_V1"
OUTPUT_CONTRACT_VERSION = "1.0"

ACTION_CONFIRM = "CONFIRM"
ACTION_MOVE = "MOVE"
ACTION_SPLIT = "SPLIT"
ACTION_EXCLUDE = "EXCLUDE_AS_NOISE"
ACTION_MANUAL = "RETURN_TO_MANUAL_REVIEW"

ALLOWED_ACTIONS = {
    ACTION_CONFIRM,
    ACTION_MOVE,
    ACTION_SPLIT,
    ACTION_EXCLUDE,
    ACTION_MANUAL,
}
COMPLETED_STATUSES = {"CONFIRMED", "EXCLUDED", "SPLIT_CONFIRMED"}
PENDING_STATUSES = {"PENDING", "RETURNED_TO_MANUAL_REVIEW"}

SPLIT_MARKER = "<<<SPLIT>>>"


@dataclass(frozen=True)
class Category:
    code: str
    order: int
    label_cs: str


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Panelový editor ručního mapování standardizačního návrhu A18."
        )
    )
    parser.add_argument(
        "--mapping",
        help="Cesta k panelovému JSON kontraktu A18.",
    )
    parser.add_argument(
        "--output-dir",
        help="Výstupní složka revizních kontraktů.",
    )
    parser.add_argument(
        "--reviewer",
        help="Výchozí jméno schvalujícího uživatele.",
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Pouze ověří vstup a vypíše souhrn bez otevření GUI.",
    )
    parser.add_argument(
        "--no-resume",
        action="store_true",
        help="Nenačítat poslední rozpracovanou revizi.",
    )
    return parser.parse_args()


def resolve_path(root: Path, value: str | None, default: Path) -> Path:
    path = Path(value) if value else default
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def read_json(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, dict):
        raise RuntimeError(f"JSON musí být objekt: {path}")
    return payload


def validate_mapping_payload(
    payload: Mapping[str, Any],
    mapping_path: Path,
) -> tuple[Path, list[Category]]:
    contract_version = str(payload.get("contract_version") or "")
    if contract_version not in SUPPORTED_CONTRACT_VERSIONS:
        raise RuntimeError(
            f"Nepodporovaná verze kontraktu {contract_version!r}. "
            f"Podporováno: {sorted(SUPPORTED_CONTRACT_VERSIONS)}."
        )

    if payload.get("final_status") != EXPECTED_INPUT_STATUS:
        raise RuntimeError(
            f"Vstup nemá final_status {EXPECTED_INPUT_STATUS}."
        )

    source_value = str(payload.get("source_document_path") or "").strip()
    expected_hash = str(payload.get("source_hash_sha256") or "").strip()
    if not source_value:
        raise RuntimeError("Kontrakt neobsahuje source_document_path.")
    if len(expected_hash) != 64:
        raise RuntimeError("Kontrakt neobsahuje platný source_hash_sha256.")

    source_path = Path(source_value)
    if not source_path.is_file():
        raise FileNotFoundError(
            f"Zdrojový dokument nebyl nalezen: {source_path}"
        )

    current_hash = sha256_file(source_path)
    if current_hash != expected_hash:
        raise RuntimeError(
            "Zdrojový dokument se od vytvoření A18 změnil. "
            "Spusť znovu A17 a A18."
        )

    blocks = payload.get("blocks")
    if not isinstance(blocks, list) or not blocks:
        raise RuntimeError("Kontrakt neobsahuje žádné bloky.")

    seen_ids: set[str] = set()
    for item in blocks:
        if not isinstance(item, dict):
            raise RuntimeError("Každý blok musí být JSON objekt.")
        block_id = str(item.get("block_id") or "")
        if not block_id:
            raise RuntimeError("Blok bez block_id.")
        if block_id in seen_ids:
            raise RuntimeError(f"Duplicitní block_id: {block_id}")
        seen_ids.add(block_id)

        source = item.get("source")
        proposal = item.get("proposal")
        review = item.get("review")
        decision = item.get("user_decision")
        if not all(
            isinstance(value, dict)
            for value in (source, proposal, review, decision)
        ):
            raise RuntimeError(
                f"Blok {block_id} nemá úplnou strukturu "
                "source/proposal/review/user_decision."
            )

        text = source.get("text")
        if not isinstance(text, str) or not text.strip():
            raise RuntimeError(f"Blok {block_id} nemá text.")

        category = str(proposal.get("category") or "")
        allowed_categories = review.get("allowed_categories")
        if not category:
            raise RuntimeError(f"Blok {block_id} nemá navrženou kategorii.")
        if not isinstance(allowed_categories, list) or not allowed_categories:
            raise RuntimeError(
                f"Blok {block_id} nemá allowed_categories."
            )

    catalog_raw = payload.get("category_catalog")
    if not isinstance(catalog_raw, list) or not catalog_raw:
        raise RuntimeError("Kontrakt neobsahuje category_catalog.")

    categories: list[Category] = []
    seen_categories: set[str] = set()
    for raw in catalog_raw:
        if not isinstance(raw, dict):
            raise RuntimeError("Neplatná položka category_catalog.")
        code = str(raw.get("code") or "")
        label = str(raw.get("label_cs") or code)
        order = int(raw.get("order") or 999)
        if not code or code in seen_categories:
            raise RuntimeError(
                f"Neplatná nebo duplicitní kategorie: {code!r}"
            )
        seen_categories.add(code)
        categories.append(Category(code=code, order=order, label_cs=label))

    categories.sort(key=lambda item: (item.order, item.code))
    return source_path, categories


def decision_status(item: Mapping[str, Any]) -> str:
    decision = item.get("user_decision") or {}
    return str(decision.get("status") or "PENDING")


def effective_category(item: Mapping[str, Any]) -> str:
    decision = item.get("user_decision") or {}
    selected = str(decision.get("selected_category") or "").strip()
    if selected:
        return selected
    proposal = item.get("proposal") or {}
    return str(proposal.get("category") or "")


def review_required(item: Mapping[str, Any]) -> bool:
    review = item.get("review") or {}
    return bool(review.get("required"))


def verify_split_parts(original_text: str, parts: Sequence[Mapping[str, Any]]) -> None:
    if len(parts) < 2:
        raise RuntimeError("Rozdělení musí obsahovat alespoň dvě části.")
    reconstructed = "".join(str(part.get("text") or "") for part in parts)
    if reconstructed != original_text:
        raise RuntimeError(
            "Rozdělené části po spojení neodpovídají přesně původnímu textu."
        )
    for index, part in enumerate(parts, start=1):
        if not str(part.get("text") or ""):
            raise RuntimeError(f"Rozdělená část {index} je prázdná.")
        if not str(part.get("selected_category") or ""):
            raise RuntimeError(
                f"Rozdělená část {index} nemá vybranou kategorii."
            )


def validate_decisions(
    payload: Mapping[str, Any],
    *,
    require_complete: bool,
) -> dict[str, int | bool]:
    blocks = payload["blocks"]
    required_total = 0
    required_completed = 0
    pending = 0
    confirmed = 0
    moved = 0
    excluded = 0
    split = 0
    returned = 0

    category_codes = {
        str(item.get("code") or "")
        for item in payload.get("category_catalog", [])
    }

    for item in blocks:
        block_id = str(item["block_id"])
        decision = item["user_decision"]
        status = str(decision.get("status") or "PENDING")
        action = decision.get("action")
        selected = str(decision.get("selected_category") or "").strip()

        if review_required(item):
            required_total += 1

        if action is not None and action not in ALLOWED_ACTIONS:
            raise RuntimeError(
                f"Blok {block_id} má nepovolenou akci {action!r}."
            )

        if status in COMPLETED_STATUSES:
            if review_required(item):
                required_completed += 1

            if status == "CONFIRMED":
                confirmed += 1
                if not selected or selected not in category_codes:
                    raise RuntimeError(
                        f"Potvrzený blok {block_id} nemá platnou kategorii."
                    )
                if action == ACTION_MOVE:
                    moved += 1

            elif status == "EXCLUDED":
                excluded += 1
                if action != ACTION_EXCLUDE:
                    raise RuntimeError(
                        f"Vyloučený blok {block_id} nemá akci "
                        f"{ACTION_EXCLUDE}."
                    )

            elif status == "SPLIT_CONFIRMED":
                split += 1
                if action != ACTION_SPLIT:
                    raise RuntimeError(
                        f"Rozdělený blok {block_id} nemá akci {ACTION_SPLIT}."
                    )
                parts = decision.get("split_parts")
                if not isinstance(parts, list):
                    raise RuntimeError(
                        f"Rozdělený blok {block_id} nemá split_parts."
                    )
                verify_split_parts(
                    str(item["source"]["text"]),
                    parts,
                )

        elif status in PENDING_STATUSES:
            pending += 1
            if status == "RETURNED_TO_MANUAL_REVIEW":
                returned += 1
        elif status == "NOT_REQUIRED":
            pass
        else:
            raise RuntimeError(
                f"Blok {block_id} má neznámý decision status {status!r}."
            )

    complete = (
        required_total == required_completed
        and pending == 0
    )

    if require_complete and not complete:
        raise RuntimeError(
            "Mapování nelze uzavřít: "
            f"potvrzeno {required_completed}/{required_total}, "
            f"čeká {pending} bloků."
        )

    return {
        "total_blocks": len(blocks),
        "required_blocks": required_total,
        "required_completed": required_completed,
        "pending_blocks": pending,
        "confirmed_blocks": confirmed,
        "moved_blocks": moved,
        "excluded_blocks": excluded,
        "split_blocks": split,
        "returned_blocks": returned,
        "mapping_approval_allowed": complete,
    }


def merge_resume_decisions(
    current: dict[str, Any],
    review_payload: Mapping[str, Any],
) -> int:
    if (
        review_payload.get("source_hash_sha256")
        != current.get("source_hash_sha256")
    ):
        return 0
    if (
        review_payload.get("source_mapping_path")
        and Path(str(review_payload["source_mapping_path"])).name
        != Path(str(current.get("_mapping_path") or "")).name
    ):
        return 0

    previous_blocks = {
        str(item.get("block_id")): item
        for item in review_payload.get("blocks", [])
        if isinstance(item, dict)
    }
    merged = 0

    for item in current["blocks"]:
        previous = previous_blocks.get(str(item["block_id"]))
        if not previous:
            continue
        previous_decision = previous.get("user_decision")
        if not isinstance(previous_decision, dict):
            continue
        item["user_decision"] = deepcopy(previous_decision)
        merged += 1

    return merged


def review_payload(
    mapping_payload: Mapping[str, Any],
    mapping_path: Path,
    reviewer: str,
    *,
    finalizing: bool,
) -> dict[str, Any]:
    payload = deepcopy(dict(mapping_payload))
    summary = validate_decisions(
        payload,
        require_complete=finalizing,
    )

    review_status = (
        "MAPPING_CONFIRMED"
        if summary["mapping_approval_allowed"]
        else "IN_PROGRESS"
    )
    final_status = (
        "DOCUMENT_STANDARDIZATION_PANEL_REVIEW_CONFIRMED"
        if review_status == "MAPPING_CONFIRMED"
        else "DOCUMENT_STANDARDIZATION_PANEL_REVIEW_SAVED"
    )

    return {
        "contract_version": OUTPUT_CONTRACT_VERSION,
        "generated_at": utc_now().isoformat(),
        "review_engine_version": ENGINE_VERSION,
        "source_mapping_path": str(mapping_path),
        "source_document_path": payload["source_document_path"],
        "source_hash_sha256": payload["source_hash_sha256"],
        "document_type": payload["document_type"],
        "reviewer": reviewer,
        "read_only_source": True,
        "source_modified": False,
        "database_modified": False,
        "category_catalog": payload["category_catalog"],
        "summary": {
            **summary,
            "placeholder_count": int(
                payload.get("summary", {}).get("placeholder_count") or 0
            ),
            "document_approval_allowed": bool(
                summary["mapping_approval_allowed"]
                and int(
                    payload.get("summary", {}).get("placeholder_count") or 0
                ) == 0
            ),
        },
        "blocks": payload["blocks"],
        "review_status": review_status,
        "final_status": final_status,
    }


def write_review_csv(
    path: Path,
    payload: Mapping[str, Any],
) -> None:
    fields = [
        "block_id",
        "start_line",
        "end_line",
        "heading",
        "text_preview",
        "proposed_category",
        "effective_category",
        "confidence",
        "confidence_score",
        "review_required",
        "decision_status",
        "decision_action",
        "decision_note",
        "approved_by",
        "approved_at",
        "split_parts_count",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for item in payload["blocks"]:
            source = item["source"]
            proposal = item["proposal"]
            review = item["review"]
            decision = item["user_decision"]
            text_preview = str(source["text"]).replace("\n", " ")[:500]
            split_parts = decision.get("split_parts")
            writer.writerow(
                {
                    "block_id": item["block_id"],
                    "start_line": source.get("start_line"),
                    "end_line": source.get("end_line"),
                    "heading": source.get("heading") or "",
                    "text_preview": text_preview,
                    "proposed_category": proposal.get("category"),
                    "effective_category": effective_category(item),
                    "confidence": proposal.get("confidence"),
                    "confidence_score": proposal.get("confidence_score"),
                    "review_required": review.get("required"),
                    "decision_status": decision.get("status"),
                    "decision_action": decision.get("action") or "",
                    "decision_note": decision.get("note") or "",
                    "approved_by": decision.get("approved_by") or "",
                    "approved_at": decision.get("approved_at") or "",
                    "split_parts_count": (
                        len(split_parts)
                        if isinstance(split_parts, list)
                        else 0
                    ),
                }
            )


def write_review_markdown(
    path: Path,
    payload: Mapping[str, Any],
) -> None:
    summary = payload["summary"]
    lines = [
        "# MATCHMATRIX – REVIZE PANELOVÉHO MAPOVÁNÍ",
        "",
        f"- Stav revize: **{payload['review_status']}**",
        f"- Dokument: `{payload['source_document_path']}`",
        f"- Typ dokumentu: **{payload['document_type']}**",
        f"- Schvalující: **{payload.get('reviewer') or 'NEUVEDEN'}**",
        f"- Celkem bloků: **{summary['total_blocks']}**",
        f"- Povinných bloků: **{summary['required_blocks']}**",
        f"- Potvrzeno: **{summary['required_completed']}**",
        f"- Čeká: **{summary['pending_blocks']}**",
        f"- Přesunuto: **{summary['moved_blocks']}**",
        f"- Rozděleno: **{summary['split_blocks']}**",
        f"- Vyloučeno jako šum: **{summary['excluded_blocks']}**",
        f"- Mapování lze schválit: **{summary['mapping_approval_allowed']}**",
        f"- Dokument lze schválit: **{summary['document_approval_allowed']}**",
        "",
        "## Rozhodnutí",
        "",
        "| Blok | Stav | Akce | Kategorie | Původní návrh | Jistota | Poznámka |",
        "|---|---|---|---|---|---|---|",
    ]

    for item in payload["blocks"]:
        decision = item["user_decision"]
        proposal = item["proposal"]
        note = str(decision.get("note") or "").replace("|", r"\|")
        lines.append(
            f"| {item['block_id']} "
            f"| {decision.get('status')} "
            f"| {decision.get('action') or ''} "
            f"| {effective_category(item)} "
            f"| {proposal.get('category')} "
            f"| {proposal.get('confidence')} / "
            f"{proposal.get('confidence_score')} "
            f"| {note} |"
        )

    lines.extend(
        [
            "",
            "## Bezpečnost",
            "",
            "- Zdrojový dokument nebyl změněn.",
            "- Databáze nebyla změněna.",
            "- Tento výstup obsahuje pouze rozhodnutí o mapování.",
            "",
            f"**FINAL STATUS:** `{payload['final_status']}`",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def save_review_files(
    output_dir: Path,
    payload: Mapping[str, Any],
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().astimezone().strftime("%Y%m%d_%H%M%S")

    paths = {
        "json": output_dir
        / f"document_standardization_panel_review_{stamp}.json",
        "csv": output_dir
        / f"document_standardization_panel_review_{stamp}.csv",
        "markdown": output_dir
        / f"document_standardization_panel_review_{stamp}.md",
    }

    write_json(paths["json"], payload)
    write_review_csv(paths["csv"], payload)
    write_review_markdown(paths["markdown"], payload)

    latest = {
        "json": output_dir / LATEST_REVIEW_NAME,
        "csv": output_dir
        / "document_standardization_panel_review_latest.csv",
        "markdown": output_dir
        / "document_standardization_panel_review_latest.md",
    }
    for key in paths:
        shutil.copyfile(paths[key], latest[key])

    return paths


class SplitDialog(tk.Toplevel):
    def __init__(
        self,
        parent: tk.Misc,
        block_id: str,
        original_text: str,
        categories: Sequence[Category],
        default_category: str,
    ) -> None:
        super().__init__(parent)
        self.title(f"Rozdělit blok {block_id}")
        self.geometry("900x650")
        self.minsize(700, 500)
        self.transient(parent)
        self.grab_set()

        self.original_text = original_text
        self.categories = list(categories)
        self.result: list[dict[str, Any]] | None = None

        ttk.Label(
            self,
            text=(
                f"Vlož značku {SPLIT_MARKER} přesně do míst rozdělení. "
                "Ostatní text se nesmí změnit."
            ),
            wraplength=840,
        ).pack(fill="x", padx=12, pady=(12, 6))

        self.editor = tk.Text(self, wrap="word", undo=True)
        self.editor.pack(
            fill="both",
            expand=True,
            padx=12,
            pady=6,
        )
        self.editor.insert("1.0", original_text)

        category_frame = ttk.Frame(self)
        category_frame.pack(fill="x", padx=12, pady=6)
        ttk.Label(
            category_frame,
            text="Výchozí kategorie částí:",
        ).pack(side="left")

        self.category_var = tk.StringVar(value=default_category)
        values = [
            f"{category.code} — {category.label_cs}"
            for category in self.categories
        ]
        self.category_combo = ttk.Combobox(
            category_frame,
            textvariable=self.category_var,
            values=values,
            state="readonly",
            width=55,
        )
        self.category_combo.pack(side="left", padx=8)

        matching = next(
            (
                index
                for index, category in enumerate(self.categories)
                if category.code == default_category
            ),
            0,
        )
        if values:
            self.category_combo.current(matching)

        buttons = ttk.Frame(self)
        buttons.pack(fill="x", padx=12, pady=(6, 12))
        ttk.Button(
            buttons,
            text="Zrušit",
            command=self.destroy,
        ).pack(side="right")
        ttk.Button(
            buttons,
            text="Potvrdit rozdělení",
            command=self._accept,
        ).pack(side="right", padx=8)

    def _selected_category(self) -> str:
        value = self.category_var.get()
        return value.split(" — ", 1)[0].strip()

    def _accept(self) -> None:
        edited = self.editor.get("1.0", "end-1c")
        if edited.replace(SPLIT_MARKER, "") != self.original_text:
            messagebox.showerror(
                "Neplatné rozdělení",
                "Text byl změněn. Je dovoleno pouze vložit značky "
                f"{SPLIT_MARKER}.",
                parent=self,
            )
            return

        raw_parts = edited.split(SPLIT_MARKER)
        if len(raw_parts) < 2 or any(part == "" for part in raw_parts):
            messagebox.showerror(
                "Neplatné rozdělení",
                "Vlož alespoň jednu značku mezi neprázdné části.",
                parent=self,
            )
            return

        category = self._selected_category()
        self.result = [
            {
                "part_id": f"PART-{index:02d}",
                "text": part,
                "selected_category": category,
                "status": "CONFIRMED",
            }
            for index, part in enumerate(raw_parts, start=1)
        ]
        verify_split_parts(self.original_text, self.result)
        self.destroy()


class MappingReviewApp(ttk.Frame):
    def __init__(
        self,
        master: tk.Tk,
        *,
        mapping_path: Path,
        output_dir: Path,
        payload: dict[str, Any],
        source_path: Path,
        categories: Sequence[Category],
        reviewer: str,
    ) -> None:
        super().__init__(master)
        self.master = master
        self.mapping_path = mapping_path
        self.output_dir = output_dir
        self.payload = payload
        self.source_path = source_path
        self.categories = list(categories)
        self.category_by_code = {
            category.code: category
            for category in self.categories
        }
        self.reviewer_var = tk.StringVar(value=reviewer)
        self.selected_category_var = tk.StringVar()
        self.note_var = tk.StringVar()
        self.filter_search_var = tk.StringVar()
        self.filter_status_var = tk.StringVar(value="PENDING")
        self.filter_confidence_var = tk.StringVar(value="ALL")
        self.filter_category_var = tk.StringVar(value="ALL")
        self.status_var = tk.StringVar()

        self.master.title(
            "MatchMatrix – Revize mapování dokumentu A19"
        )
        self.master.geometry("1500x900")
        self.master.minsize(1150, 700)

        self._configure_style()
        self._build_ui()
        self._refresh_all()

    def _configure_style(self) -> None:
        style = ttk.Style(self.master)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass
        style.configure(
            "Title.TLabel",
            font=("Segoe UI", 16, "bold"),
        )
        style.configure(
            "Kpi.TLabel",
            font=("Segoe UI", 11, "bold"),
        )
        style.configure(
            "Primary.TButton",
            font=("Segoe UI", 10, "bold"),
        )

    def _build_ui(self) -> None:
        self.pack(fill="both", expand=True)

        header = ttk.Frame(self)
        header.pack(fill="x", padx=12, pady=(10, 6))
        ttk.Label(
            header,
            text="Dokumentace – ruční mapování bloků",
            style="Title.TLabel",
        ).pack(side="left")

        ttk.Label(header, text="Schvalující:").pack(
            side="right",
            padx=(12, 4),
        )
        ttk.Entry(
            header,
            textvariable=self.reviewer_var,
            width=28,
        ).pack(side="right")

        source_frame = ttk.LabelFrame(
            self,
            text="Zdroj",
        )
        source_frame.pack(fill="x", padx=12, pady=6)
        ttk.Label(
            source_frame,
            text=str(self.source_path),
            wraplength=1400,
        ).pack(anchor="w", padx=8, pady=4)
        ttk.Label(
            source_frame,
            text=(
                f"Typ: {self.payload.get('document_type')} | "
                f"SHA-256 ověřeno | "
                f"Kontrakt: {self.payload.get('contract_version')}"
            ),
        ).pack(anchor="w", padx=8, pady=(0, 4))

        self.kpi_frame = ttk.Frame(self)
        self.kpi_frame.pack(fill="x", padx=12, pady=6)
        self.kpi_labels: dict[str, ttk.Label] = {}
        for key, title in (
            ("total", "Bloky"),
            ("required", "Povinné"),
            ("completed", "Potvrzené"),
            ("pending", "Čeká"),
            ("moved", "Přesunuto"),
            ("split", "Rozděleno"),
            ("excluded", "Vyloučeno"),
        ):
            frame = ttk.LabelFrame(self.kpi_frame, text=title)
            frame.pack(side="left", padx=(0, 8))
            label = ttk.Label(
                frame,
                text="0",
                style="Kpi.TLabel",
                width=10,
                anchor="center",
            )
            label.pack(padx=8, pady=5)
            self.kpi_labels[key] = label

        filters = ttk.LabelFrame(self, text="Filtry")
        filters.pack(fill="x", padx=12, pady=6)

        ttk.Label(filters, text="Stav:").grid(
            row=0, column=0, padx=4, pady=5, sticky="w"
        )
        ttk.Combobox(
            filters,
            textvariable=self.filter_status_var,
            values=(
                "ALL",
                "PENDING",
                "CONFIRMED",
                "NOT_REQUIRED",
                "EXCLUDED",
                "SPLIT_CONFIRMED",
                "RETURNED_TO_MANUAL_REVIEW",
            ),
            state="readonly",
            width=28,
        ).grid(row=0, column=1, padx=4, pady=5)

        ttk.Label(filters, text="Jistota:").grid(
            row=0, column=2, padx=4, pady=5, sticky="w"
        )
        ttk.Combobox(
            filters,
            textvariable=self.filter_confidence_var,
            values=("ALL", "HIGH", "MEDIUM", "LOW"),
            state="readonly",
            width=12,
        ).grid(row=0, column=3, padx=4, pady=5)

        ttk.Label(filters, text="Kategorie:").grid(
            row=0, column=4, padx=4, pady=5, sticky="w"
        )
        category_values = ["ALL"] + [
            f"{category.code} — {category.label_cs}"
            for category in self.categories
        ]
        ttk.Combobox(
            filters,
            textvariable=self.filter_category_var,
            values=category_values,
            state="readonly",
            width=38,
        ).grid(row=0, column=5, padx=4, pady=5)

        ttk.Label(filters, text="Hledat:").grid(
            row=0, column=6, padx=4, pady=5, sticky="w"
        )
        search_entry = ttk.Entry(
            filters,
            textvariable=self.filter_search_var,
            width=32,
        )
        search_entry.grid(row=0, column=7, padx=4, pady=5)

        ttk.Button(
            filters,
            text="Použít filtry",
            command=self._refresh_tree,
        ).grid(row=0, column=8, padx=5, pady=5)
        ttk.Button(
            filters,
            text="Vyčistit",
            command=self._clear_filters,
        ).grid(row=0, column=9, padx=5, pady=5)

        filters.columnconfigure(7, weight=1)
        search_entry.bind("<Return>", lambda _event: self._refresh_tree())

        paned = ttk.Panedwindow(
            self,
            orient="horizontal",
        )
        paned.pack(fill="both", expand=True, padx=12, pady=6)

        left = ttk.Frame(paned)
        right = ttk.Frame(paned)
        paned.add(left, weight=3)
        paned.add(right, weight=2)

        columns = (
            "block_id",
            "lines",
            "confidence",
            "score",
            "proposed",
            "effective",
            "decision",
            "preview",
        )
        self.tree = ttk.Treeview(
            left,
            columns=columns,
            show="headings",
            selectmode="extended",
        )
        headings = {
            "block_id": "Blok",
            "lines": "Řádky",
            "confidence": "Jistota",
            "score": "Skóre",
            "proposed": "Návrh",
            "effective": "Výsledná kapitola",
            "decision": "Rozhodnutí",
            "preview": "Text",
        }
        widths = {
            "block_id": 85,
            "lines": 70,
            "confidence": 80,
            "score": 65,
            "proposed": 150,
            "effective": 170,
            "decision": 150,
            "preview": 520,
        }
        for column in columns:
            self.tree.heading(column, text=headings[column])
            self.tree.column(
                column,
                width=widths[column],
                stretch=(column == "preview"),
            )

        y_scroll = ttk.Scrollbar(
            left,
            orient="vertical",
            command=self.tree.yview,
        )
        x_scroll = ttk.Scrollbar(
            left,
            orient="horizontal",
            command=self.tree.xview,
        )
        self.tree.configure(
            yscrollcommand=y_scroll.set,
            xscrollcommand=x_scroll.set,
        )
        self.tree.grid(row=0, column=0, sticky="nsew")
        y_scroll.grid(row=0, column=1, sticky="ns")
        x_scroll.grid(row=1, column=0, sticky="ew")
        left.rowconfigure(0, weight=1)
        left.columnconfigure(0, weight=1)

        self.tree.bind(
            "<<TreeviewSelect>>",
            self._on_tree_select,
        )

        details = ttk.LabelFrame(
            right,
            text="Detail vybraného bloku",
        )
        details.pack(fill="both", expand=True)

        self.detail_text = tk.Text(
            details,
            wrap="word",
            height=20,
            state="disabled",
        )
        detail_scroll = ttk.Scrollbar(
            details,
            orient="vertical",
            command=self.detail_text.yview,
        )
        self.detail_text.configure(
            yscrollcommand=detail_scroll.set,
        )
        self.detail_text.grid(
            row=0,
            column=0,
            columnspan=2,
            sticky="nsew",
            padx=(6, 0),
            pady=6,
        )
        detail_scroll.grid(
            row=0,
            column=2,
            sticky="ns",
            pady=6,
        )

        ttk.Label(
            details,
            text="Výsledná kapitola:",
        ).grid(row=1, column=0, sticky="w", padx=6, pady=4)

        category_values = [
            f"{category.code} — {category.label_cs}"
            for category in self.categories
        ]
        self.category_combo = ttk.Combobox(
            details,
            textvariable=self.selected_category_var,
            values=category_values,
            state="readonly",
        )
        self.category_combo.grid(
            row=1,
            column=1,
            sticky="ew",
            padx=6,
            pady=4,
        )

        ttk.Label(
            details,
            text="Poznámka:",
        ).grid(row=2, column=0, sticky="w", padx=6, pady=4)
        ttk.Entry(
            details,
            textvariable=self.note_var,
        ).grid(
            row=2,
            column=1,
            sticky="ew",
            padx=6,
            pady=4,
        )

        single_actions = ttk.Frame(details)
        single_actions.grid(
            row=3,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=6,
            pady=6,
        )
        ttk.Button(
            single_actions,
            text="Potvrdit",
            command=self._confirm_selected_single,
            style="Primary.TButton",
        ).pack(side="left", padx=(0, 5))
        ttk.Button(
            single_actions,
            text="Přesunout",
            command=self._move_selected_single,
        ).pack(side="left", padx=5)
        ttk.Button(
            single_actions,
            text="Rozdělit",
            command=self._split_selected_single,
        ).pack(side="left", padx=5)
        ttk.Button(
            single_actions,
            text="Vyloučit jako šum",
            command=self._exclude_selected_single,
        ).pack(side="left", padx=5)
        ttk.Button(
            single_actions,
            text="Vrátit k posouzení",
            command=self._return_selected_single,
        ).pack(side="left", padx=5)

        details.rowconfigure(0, weight=1)
        details.columnconfigure(1, weight=1)

        bulk = ttk.LabelFrame(
            self,
            text="Hromadné akce nad označenými bloky",
        )
        bulk.pack(fill="x", padx=12, pady=6)

        ttk.Button(
            bulk,
            text="Potvrdit vybrané",
            command=self._bulk_confirm,
        ).pack(side="left", padx=5, pady=5)
        ttk.Button(
            bulk,
            text="Přesunout vybrané do zvolené kapitoly",
            command=self._bulk_move,
        ).pack(side="left", padx=5, pady=5)
        ttk.Button(
            bulk,
            text="Vyloučit vybrané jako šum",
            command=self._bulk_exclude,
        ).pack(side="left", padx=5, pady=5)
        ttk.Button(
            bulk,
            text="Vrátit vybrané k posouzení",
            command=self._bulk_return,
        ).pack(side="left", padx=5, pady=5)

        footer = ttk.Frame(self)
        footer.pack(fill="x", padx=12, pady=(4, 12))
        ttk.Label(
            footer,
            textvariable=self.status_var,
        ).pack(side="left")

        ttk.Button(
            footer,
            text="Uložit průběžně",
            command=self._save_progress,
        ).pack(side="right", padx=5)
        ttk.Button(
            footer,
            text="Uzavřít mapování",
            command=self._finalize_mapping,
            style="Primary.TButton",
        ).pack(side="right", padx=5)

    def _block_by_id(self, block_id: str) -> dict[str, Any]:
        for item in self.payload["blocks"]:
            if item["block_id"] == block_id:
                return item
        raise KeyError(block_id)

    def _category_display(self, code: str) -> str:
        category = self.category_by_code.get(code)
        if category:
            return f"{category.code} — {category.label_cs}"
        return code

    def _selected_category_code(self) -> str:
        value = self.selected_category_var.get()
        return value.split(" — ", 1)[0].strip()

    def _selected_ids(self) -> list[str]:
        return [str(item) for item in self.tree.selection()]

    def _clear_filters(self) -> None:
        self.filter_status_var.set("ALL")
        self.filter_confidence_var.set("ALL")
        self.filter_category_var.set("ALL")
        self.filter_search_var.set("")
        self._refresh_tree()

    def _matches_filters(self, item: Mapping[str, Any]) -> bool:
        status_filter = self.filter_status_var.get()
        confidence_filter = self.filter_confidence_var.get()
        category_filter = self.filter_category_var.get()
        search = self.filter_search_var.get().strip().lower()

        if (
            status_filter != "ALL"
            and decision_status(item) != status_filter
        ):
            return False

        confidence = str(item["proposal"].get("confidence") or "")
        if (
            confidence_filter != "ALL"
            and confidence != confidence_filter
        ):
            return False

        if category_filter != "ALL":
            category_code = category_filter.split(" — ", 1)[0]
            if effective_category(item) != category_code:
                return False

        if search:
            haystack = " ".join(
                [
                    str(item.get("block_id") or ""),
                    str(item["source"].get("heading") or ""),
                    str(item["source"].get("text") or ""),
                    str(item["proposal"].get("category") or ""),
                    str(item["proposal"].get("category_label_cs") or ""),
                    str(item["user_decision"].get("note") or ""),
                ]
            ).lower()
            if search not in haystack:
                return False

        return True

    def _refresh_tree(self) -> None:
        selected_before = set(self._selected_ids())
        self.tree.delete(*self.tree.get_children())

        for item in self.payload["blocks"]:
            if not self._matches_filters(item):
                continue
            source = item["source"]
            proposal = item["proposal"]
            preview = str(source["text"]).replace("\n", " ")[:260]
            values = (
                item["block_id"],
                f"{source.get('start_line')}–{source.get('end_line')}",
                proposal.get("confidence"),
                proposal.get("confidence_score"),
                proposal.get("category_label_cs")
                or proposal.get("category"),
                self._category_display(effective_category(item)),
                decision_status(item),
                preview,
            )
            self.tree.insert(
                "",
                "end",
                iid=item["block_id"],
                values=values,
            )

        for block_id in selected_before:
            if self.tree.exists(block_id):
                self.tree.selection_add(block_id)

    def _refresh_kpis(self) -> None:
        summary = validate_decisions(
            self.payload,
            require_complete=False,
        )
        values = {
            "total": summary["total_blocks"],
            "required": summary["required_blocks"],
            "completed": summary["required_completed"],
            "pending": summary["pending_blocks"],
            "moved": summary["moved_blocks"],
            "split": summary["split_blocks"],
            "excluded": summary["excluded_blocks"],
        }
        for key, value in values.items():
            self.kpi_labels[key].configure(text=str(value))

        self.status_var.set(
            f"Potvrzeno {summary['required_completed']}/"
            f"{summary['required_blocks']} | "
            f"čeká {summary['pending_blocks']} | "
            f"mapování lze uzavřít: "
            f"{summary['mapping_approval_allowed']}"
        )

    def _refresh_all(self) -> None:
        self._refresh_tree()
        self._refresh_kpis()

    def _on_tree_select(self, _event: object | None = None) -> None:
        selected = self._selected_ids()
        if not selected:
            return
        item = self._block_by_id(selected[0])
        source = item["source"]
        proposal = item["proposal"]
        review = item["review"]
        decision = item["user_decision"]

        alternatives = proposal.get("alternatives") or []
        reasons = proposal.get("reasons") or []

        text = [
            f"Blok: {item['block_id']}",
            f"Řádky: {source.get('start_line')}–{source.get('end_line')}",
            f"Původní nadpis: {source.get('heading') or '—'}",
            "",
            "PŮVODNÍ TEXT",
            "-" * 72,
            str(source.get("text") or ""),
            "",
            "NÁVRH A18",
            "-" * 72,
            f"Kategorie: {proposal.get('category')} — "
            f"{proposal.get('category_label_cs')}",
            f"Jistota: {proposal.get('confidence')} / "
            f"{proposal.get('confidence_score')} %",
            f"Rozdíl skóre: {proposal.get('score_margin')}",
            f"Metoda: {proposal.get('method')}",
            "",
            "Důvody:",
            *[f"- {reason}" for reason in reasons],
            "",
            "Alternativy:",
            *[
                f"- {alt.get('category')} — "
                f"{alt.get('category_label_cs')} | "
                f"{alt.get('score')} %"
                for alt in alternatives
            ],
            "",
            "REVIZE",
            "-" * 72,
            f"Povinná: {review.get('required')}",
            f"Priorita: {review.get('priority')}",
            f"Doporučená akce: {review.get('recommended_action')}",
            f"Stav: {decision.get('status')}",
            f"Akce: {decision.get('action')}",
            f"Schválil: {decision.get('approved_by')}",
            f"Čas: {decision.get('approved_at')}",
        ]

        self.detail_text.configure(state="normal")
        self.detail_text.delete("1.0", "end")
        self.detail_text.insert("1.0", "\n".join(text))
        self.detail_text.configure(state="disabled")

        category_code = effective_category(item)
        self.selected_category_var.set(
            self._category_display(category_code)
        )
        self.note_var.set(str(decision.get("note") or ""))

    def _reviewer(self) -> str:
        reviewer = self.reviewer_var.get().strip()
        return reviewer or "LOCAL_OPERATOR"

    def _stamp_decision(
        self,
        item: dict[str, Any],
        *,
        status: str,
        action: str,
        category: str | None,
        note: str | None,
        split_parts: list[dict[str, Any]] | None = None,
    ) -> None:
        decision = item["user_decision"]
        decision.update(
            {
                "status": status,
                "action": action,
                "selected_category": category,
                "note": note or None,
                "approved_by": self._reviewer(),
                "approved_at": utc_now().isoformat(),
            }
        )
        if split_parts is None:
            decision.pop("split_parts", None)
        else:
            decision["split_parts"] = split_parts

    def _confirm_items(
        self,
        block_ids: Iterable[str],
        *,
        category: str | None = None,
        move: bool = False,
    ) -> None:
        for block_id in block_ids:
            item = self._block_by_id(block_id)
            selected = category or effective_category(item)
            if selected not in self.category_by_code:
                raise RuntimeError(
                    f"Neplatná kategorie pro {block_id}: {selected}"
                )
            proposed = str(item["proposal"].get("category") or "")
            action = (
                ACTION_MOVE
                if move or selected != proposed
                else ACTION_CONFIRM
            )
            self._stamp_decision(
                item,
                status="CONFIRMED",
                action=action,
                category=selected,
                note=self.note_var.get().strip(),
            )

    def _confirm_selected_single(self) -> None:
        selected = self._selected_ids()
        if len(selected) != 1:
            messagebox.showwarning(
                "Výběr",
                "Vyber právě jeden blok.",
            )
            return
        try:
            category = self._selected_category_code()
            self._confirm_items(selected, category=category)
            self._refresh_all()
            self._on_tree_select()
        except Exception as exc:
            messagebox.showerror("Chyba", str(exc))

    def _move_selected_single(self) -> None:
        selected = self._selected_ids()
        if len(selected) != 1:
            messagebox.showwarning(
                "Výběr",
                "Vyber právě jeden blok.",
            )
            return
        try:
            category = self._selected_category_code()
            self._confirm_items(
                selected,
                category=category,
                move=True,
            )
            self._refresh_all()
            self._on_tree_select()
        except Exception as exc:
            messagebox.showerror("Chyba", str(exc))

    def _split_selected_single(self) -> None:
        selected = self._selected_ids()
        if len(selected) != 1:
            messagebox.showwarning(
                "Výběr",
                "Vyber právě jeden blok.",
            )
            return
        item = self._block_by_id(selected[0])
        dialog = SplitDialog(
            self.master,
            item["block_id"],
            str(item["source"]["text"]),
            self.categories,
            effective_category(item),
        )
        self.master.wait_window(dialog)
        if dialog.result is None:
            return

        self._stamp_decision(
            item,
            status="SPLIT_CONFIRMED",
            action=ACTION_SPLIT,
            category=None,
            note=self.note_var.get().strip(),
            split_parts=dialog.result,
        )
        self._refresh_all()
        self._on_tree_select()

    def _exclude_items(self, block_ids: Iterable[str]) -> None:
        for block_id in block_ids:
            item = self._block_by_id(block_id)
            self._stamp_decision(
                item,
                status="EXCLUDED",
                action=ACTION_EXCLUDE,
                category=None,
                note=self.note_var.get().strip()
                or "Označeno uživatelem jako skutečný šum.",
            )

    def _exclude_selected_single(self) -> None:
        selected = self._selected_ids()
        if len(selected) != 1:
            messagebox.showwarning(
                "Výběr",
                "Vyber právě jeden blok.",
            )
            return
        if not messagebox.askyesno(
            "Vyloučit blok",
            "Opravdu je tento blok skutečný šum, který nemá být "
            "součástí standardizovaného dokumentu?",
        ):
            return
        self._exclude_items(selected)
        self._refresh_all()
        self._on_tree_select()

    def _return_items(self, block_ids: Iterable[str]) -> None:
        for block_id in block_ids:
            item = self._block_by_id(block_id)
            self._stamp_decision(
                item,
                status="RETURNED_TO_MANUAL_REVIEW",
                action=ACTION_MANUAL,
                category=None,
                note=self.note_var.get().strip()
                or "Vráceno k dalšímu ručnímu posouzení.",
            )

    def _return_selected_single(self) -> None:
        selected = self._selected_ids()
        if len(selected) != 1:
            messagebox.showwarning(
                "Výběr",
                "Vyber právě jeden blok.",
            )
            return
        self._return_items(selected)
        self._refresh_all()
        self._on_tree_select()

    def _bulk_confirm(self) -> None:
        selected = self._selected_ids()
        if not selected:
            messagebox.showwarning(
                "Výběr",
                "Označ alespoň jeden blok.",
            )
            return
        if not messagebox.askyesno(
            "Hromadné potvrzení",
            f"Potvrdit {len(selected)} vybraných bloků "
            "v jejich aktuálních kategoriích?",
        ):
            return
        try:
            self._confirm_items(selected)
            self._refresh_all()
        except Exception as exc:
            messagebox.showerror("Chyba", str(exc))

    def _bulk_move(self) -> None:
        selected = self._selected_ids()
        if not selected:
            messagebox.showwarning(
                "Výběr",
                "Označ alespoň jeden blok.",
            )
            return
        category = self._selected_category_code()
        if category not in self.category_by_code:
            messagebox.showwarning(
                "Kategorie",
                "Vyber cílovou kapitolu v detailu vpravo.",
            )
            return
        if not messagebox.askyesno(
            "Hromadný přesun",
            f"Přesunout {len(selected)} bloků do kapitoly "
            f"{self._category_display(category)}?",
        ):
            return
        try:
            self._confirm_items(
                selected,
                category=category,
                move=True,
            )
            self._refresh_all()
        except Exception as exc:
            messagebox.showerror("Chyba", str(exc))

    def _bulk_exclude(self) -> None:
        selected = self._selected_ids()
        if not selected:
            messagebox.showwarning(
                "Výběr",
                "Označ alespoň jeden blok.",
            )
            return
        if not messagebox.askyesno(
            "Hromadné vyloučení",
            f"Opravdu vyloučit {len(selected)} bloků jako skutečný šum?",
        ):
            return
        self._exclude_items(selected)
        self._refresh_all()

    def _bulk_return(self) -> None:
        selected = self._selected_ids()
        if not selected:
            messagebox.showwarning(
                "Výběr",
                "Označ alespoň jeden blok.",
            )
            return
        self._return_items(selected)
        self._refresh_all()

    def _verify_source(self) -> None:
        current_hash = sha256_file(self.source_path)
        expected = str(self.payload["source_hash_sha256"])
        if current_hash != expected:
            raise RuntimeError(
                "Zdrojový dokument se během revize změnil. "
                "Uložení bylo zablokováno."
            )

    def _save(self, *, finalizing: bool) -> dict[str, Path]:
        self._verify_source()
        reviewer = self._reviewer()
        payload = review_payload(
            self.payload,
            self.mapping_path,
            reviewer,
            finalizing=finalizing,
        )
        paths = save_review_files(
            self.output_dir,
            payload,
        )
        return paths

    def _save_progress(self) -> None:
        try:
            paths = self._save(finalizing=False)
            messagebox.showinfo(
                "Revize uložena",
                "Rozpracované mapování bylo bezpečně uloženo.\n\n"
                f"JSON: {paths['json']}",
            )
        except Exception as exc:
            messagebox.showerror(
                "Uložení zablokováno",
                str(exc),
            )

    def _finalize_mapping(self) -> None:
        try:
            summary = validate_decisions(
                self.payload,
                require_complete=False,
            )
        except Exception as exc:
            messagebox.showerror(
                "Mapování je neplatné",
                str(exc),
            )
            return

        if not summary["mapping_approval_allowed"]:
            messagebox.showwarning(
                "Mapování není dokončené",
                "Nejprve rozhodni o všech povinných blocích.\n\n"
                f"Potvrzeno: {summary['required_completed']}/"
                f"{summary['required_blocks']}\n"
                f"Čeká: {summary['pending_blocks']}",
            )
            return

        if not messagebox.askyesno(
            "Uzavřít mapování",
            "Všechna povinná rozhodnutí jsou uzavřena. "
            "Chceš vytvořit potvrzený mapovací kontrakt?",
        ):
            return

        try:
            paths = self._save(finalizing=True)
            messagebox.showinfo(
                "Mapování potvrzeno",
                "Mapování bylo uzavřeno.\n\n"
                f"JSON: {paths['json']}",
            )
            self._refresh_all()
        except Exception as exc:
            messagebox.showerror(
                "Uzavření zablokováno",
                str(exc),
            )


def main() -> int:
    args = parse_args()
    root = project_root()
    mapping_path = resolve_path(
        root,
        args.mapping,
        MAPPING_DEFAULT,
    )
    output_dir = resolve_path(
        root,
        args.output_dir,
        OUTPUT_DEFAULT,
    )

    print("MATCHMATRIX DOCUMENT STANDARDIZATION MAPPING REVIEW")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"MAPPING CONTRACT   : {mapping_path}")
    print(f"ENGINE             : {ENGINE_VERSION}")
    print("DATABASE WRITES    : DISABLED")
    print("SOURCE WRITES      : DISABLED")
    print()

    try:
        if not mapping_path.is_file():
            raise FileNotFoundError(
                f"Panelový kontrakt A18 nebyl nalezen: {mapping_path}"
            )

        payload = read_json(mapping_path)
        payload["_mapping_path"] = str(mapping_path)
        source_path, categories = validate_mapping_payload(
            payload,
            mapping_path,
        )

        resumed = 0
        latest_review = output_dir / LATEST_REVIEW_NAME
        if not args.no_resume and latest_review.is_file():
            previous = read_json(latest_review)
            resumed = merge_resume_decisions(payload, previous)

        summary = validate_decisions(
            payload,
            require_complete=False,
        )

        print("VSTUP")
        print("-" * 79)
        print(f"DOCUMENT           : {source_path}")
        print(f"DOCUMENT TYPE      : {payload.get('document_type')}")
        print("SHA-256 VERIFIED  : True")
        print(f"BLOCKS             : {summary['total_blocks']}")
        print(f"REQUIRED REVIEW    : {summary['required_blocks']}")
        print(f"RESUMED DECISIONS  : {resumed}")
        print(f"PENDING            : {summary['pending_blocks']}")
        print()

        if args.validate_only:
            print("VALIDACE")
            print("-" * 79)
            print(f"CATEGORIES         : {len(categories)}")
            print("SOURCE MODIFIED    : False")
            print("DATABASE MODIFIED  : False")
            print(
                "MAPPING APPROVAL   : "
                f"{summary['mapping_approval_allowed']}"
            )
            print(
                "FINAL STATUS       : "
                "DOCUMENT_STANDARDIZATION_MAPPING_REVIEW_VALIDATED"
            )
            return 0

        reviewer = args.reviewer or "LOCAL_OPERATOR"
        window = tk.Tk()
        MappingReviewApp(
            window,
            mapping_path=mapping_path,
            output_dir=output_dir,
            payload=payload,
            source_path=source_path,
            categories=categories,
            reviewer=reviewer,
        )
        window.mainloop()

        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "DOCUMENT_STANDARDIZATION_MAPPING_REVIEW_CLOSED"
        )
        return 0

    except Exception as exc:
        print("MAPPING REVIEW ERROR")
        print("-" * 79)
        print(f"{type(exc).__name__}: {exc}")
        print("SOURCE MODIFIED    : False")
        print("DATABASE MODIFIED  : False")
        print(
            "FINAL STATUS       : "
            "DOCUMENT_STANDARDIZATION_MAPPING_REVIEW_BLOCKED"
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
