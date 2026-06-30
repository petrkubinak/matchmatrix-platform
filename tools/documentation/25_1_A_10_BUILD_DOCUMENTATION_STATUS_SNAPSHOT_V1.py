#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Sestaví jednotný stavový snapshot dokumentační vrstvy MatchMatrix z posledních
reportů A5, A7, A8 a A9.

K ČEMU:
- sjednotí stav manifestu, integrity, synchronizace a kontrolního cyklu,
- vytvoří KPI pro budoucí OPS panel,
- určí celkový stav READY / WARNING / BLOCKED,
- odhalí chybějící nebo neplatné latest reporty,
- vytvoří JSON, CSV a Markdown snapshot,
- databázi ani zdrojové dokumenty nemění.

KDE:
tools/documentation/25_1_A_10_BUILD_DOCUMENTATION_STATUS_SNAPSHOT_V1.py

JAK:
    py -3.14 .\\tools\\documentation\\25_1_A_10_BUILD_DOCUMENTATION_STATUS_SNAPSHOT_V1.py

Výstupy:
- reports/documentation/documentation_status_snapshot_YYYYMMDD_HHMMSS.json
- reports/documentation/documentation_status_snapshot_YYYYMMDD_HHMMSS.csv
- reports/documentation/documentation_status_snapshot_YYYYMMDD_HHMMSS.md
- reports/documentation/documentation_status_snapshot_latest.json
- reports/documentation/documentation_status_snapshot_latest.csv
- reports/documentation/documentation_status_snapshot_latest.md
"""

from __future__ import annotations

import argparse
import csv
import json
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Mapping


REPORTS = {
    "manifest": Path(
        "reports/documentation/document_import_manifest_latest.json"
    ),
    "verification": Path(
        "reports/documentation/document_import_verification_latest.json"
    ),
    "sync_plan": Path(
        "reports/documentation/document_sync_plan_latest.json"
    ),
    "control_cycle": Path(
        "reports/documentation/document_control_cycle_latest.json"
    ),
}

EXPECTED_STATUSES = {
    "manifest": "DOCUMENT_IMPORT_MANIFEST_READY",
    "verification": "DOCUMENTATION_IMPORT_VERIFIED",
    "sync_plan": "DOCUMENT_SYNC_PLAN_IN_SYNC",
    "control_cycle": "DOCUMENTATION_CONTROL_CYCLE_READY",
}

FINAL_READY = "DOCUMENTATION_STATUS_READY"
FINAL_WARNING = "DOCUMENTATION_STATUS_WARNING"
FINAL_BLOCKED = "DOCUMENTATION_STATUS_BLOCKED"
REPORT_PREFIX = "documentation_status_snapshot"


@dataclass
class ReportState:
    key: str
    path: Path
    exists: bool
    readable: bool
    final_status: str | None
    expected_status: str
    status_ok: bool
    modified_at: str | None
    payload: dict[str, Any] | None
    error: str | None

    def as_dict(self) -> dict[str, Any]:
        return {
            "key": self.key,
            "path": str(self.path),
            "exists": self.exists,
            "readable": self.readable,
            "final_status": self.final_status,
            "expected_status": self.expected_status,
            "status_ok": self.status_ok,
            "modified_at": self.modified_at,
            "error": self.error,
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Sestaví jednotný status snapshot dokumentace MatchMatrix."
        )
    )
    parser.add_argument(
        "--allow-dirty",
        action="store_true",
        help=(
            "Povolí READY i při nečistém Git stromu. "
            "Standardně dirty Git vede ke stavu WARNING."
        ),
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def git_info(root: Path) -> dict[str, Any]:
    def run(*args: str) -> str:
        result = subprocess.run(
            ["git", *args],
            cwd=root,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
        return result.stdout.strip()

    commit = run("rev-parse", "HEAD")
    status = run("status", "--porcelain")
    branch = run("branch", "--show-current")

    return {
        "commit": commit or None,
        "branch": branch or None,
        "dirty": bool(status),
        "status_lines": status.splitlines() if status else [],
    }


def load_report(
    root: Path,
    key: str,
    relative_path: Path,
) -> ReportState:
    path = root / relative_path
    expected = EXPECTED_STATUSES[key]

    if not path.is_file():
        return ReportState(
            key=key,
            path=path,
            exists=False,
            readable=False,
            final_status=None,
            expected_status=expected,
            status_ok=False,
            modified_at=None,
            payload=None,
            error=f"Report nebyl nalezen: {path}",
        )

    modified_at = datetime.fromtimestamp(
        path.stat().st_mtime,
        tz=timezone.utc,
    ).isoformat()

    try:
        payload = json.loads(
            path.read_text(encoding="utf-8-sig")
        )
    except Exception as exc:
        return ReportState(
            key=key,
            path=path,
            exists=True,
            readable=False,
            final_status=None,
            expected_status=expected,
            status_ok=False,
            modified_at=modified_at,
            payload=None,
            error=f"{type(exc).__name__}: {exc}",
        )

    final_status = payload.get("final_status")
    return ReportState(
        key=key,
        path=path,
        exists=True,
        readable=True,
        final_status=final_status,
        expected_status=expected,
        status_ok=final_status == expected,
        modified_at=modified_at,
        payload=payload,
        error=None,
    )


def nested(
    payload: Mapping[str, Any] | None,
    *keys: str,
    default: Any = None,
) -> Any:
    current: Any = payload
    for key in keys:
        if not isinstance(current, Mapping):
            return default
        current = current.get(key)
    return default if current is None else current


def first_int(*values: Any, default: int = 0) -> int:
    for value in values:
        if value is None:
            continue
        try:
            return int(value)
        except (TypeError, ValueError):
            continue
    return default


def build_kpis(states: Mapping[str, ReportState]) -> dict[str, Any]:
    manifest = states["manifest"].payload
    verification = states["verification"].payload
    sync_plan = states["sync_plan"].payload
    control_cycle = states["control_cycle"].payload

    manifest_summary = nested(manifest, "summary", default={})
    verification_counts = nested(
        verification,
        "counts",
        default={},
    )
    verification_findings = nested(
        verification,
        "findings",
        default={},
    )
    sync_summary = nested(sync_plan, "summary", default={})

    status_counts = nested(
        sync_plan,
        "summary",
        "status_counts",
        default={},
    )
    if not isinstance(status_counts, Mapping):
        status_counts = {}

    documents = first_int(
        verification_counts.get("documents")
        if isinstance(verification_counts, Mapping)
        else None,
        sync_summary.get("database_documents")
        if isinstance(sync_summary, Mapping)
        else None,
        nested(manifest, "summary", "eligible_candidates"),
        nested(manifest, "summary", "ready_candidates"),
    )

    return {
        "documents": documents,
        "current_versions": first_int(
            verification_counts.get("current_versions")
            if isinstance(verification_counts, Mapping)
            else None
        ),
        "sections": first_int(
            verification_counts.get("document_sections")
            if isinstance(verification_counts, Mapping)
            else None
        ),
        "relations": first_int(
            verification_counts.get("document_relations")
            if isinstance(verification_counts, Mapping)
            else None
        ),
        "status_history": first_int(
            verification_counts.get("document_status_history")
            if isinstance(verification_counts, Mapping)
            else None
        ),
        "import_runs": first_int(
            verification_counts.get("import_runs")
            if isinstance(verification_counts, Mapping)
            else None
        ),
        "checks_total": first_int(
            verification_findings.get("checks_total")
            if isinstance(verification_findings, Mapping)
            else None
        ),
        "checks_passed": first_int(
            verification_findings.get("checks_passed")
            if isinstance(verification_findings, Mapping)
            else None
        ),
        "verification_warnings": len(
            verification_findings.get("warnings", [])
            if isinstance(verification_findings, Mapping)
            else []
        ),
        "verification_blockers": len(
            verification_findings.get("blockers", [])
            if isinstance(verification_findings, Mapping)
            else []
        ),
        "in_sync": first_int(status_counts.get("IN_SYNC")),
        "sync_actions": first_int(
            sync_summary.get("actions")
            if isinstance(sync_summary, Mapping)
            else None
        ),
        "sync_blockers": first_int(
            sync_summary.get("blockers")
            if isinstance(sync_summary, Mapping)
            else None
        ),
        "unregistered_sources": first_int(
            sync_summary.get("unregistered_sources")
            if isinstance(sync_summary, Mapping)
            else None
        ),
        "database_only_documents": first_int(
            sync_summary.get("database_only_documents")
            if isinstance(sync_summary, Mapping)
            else None
        ),
        "manifest_candidates": first_int(
            manifest_summary.get("configured_candidates")
            if isinstance(manifest_summary, Mapping)
            else None,
            manifest_summary.get("candidate_count")
            if isinstance(manifest_summary, Mapping)
            else None,
            nested(manifest, "document_count"),
            len(manifest.get("documents", []))
            if isinstance(manifest, Mapping)
            else None,
        ),
        "manifest_ready": first_int(
            manifest_summary.get("eligible_candidates")
            if isinstance(manifest_summary, Mapping)
            else None,
            manifest_summary.get("ready_candidates")
            if isinstance(manifest_summary, Mapping)
            else None,
            len(manifest.get("documents", []))
            if isinstance(manifest, Mapping)
            else None,
        ),
        "manifest_blockers": first_int(
            manifest_summary.get("candidate_blockers")
            if isinstance(manifest_summary, Mapping)
            else None,
            manifest_summary.get("blockers")
            if isinstance(manifest_summary, Mapping)
            else None,
        ),
        "manifest_warnings": first_int(
            manifest_summary.get("warnings")
            if isinstance(manifest_summary, Mapping)
            else None,
        ),
        "control_stages": first_int(
            control_cycle.get("stage_count")
            if isinstance(control_cycle, Mapping)
            else None
        ),
        "control_stages_successful": first_int(
            control_cycle.get("successful_stage_count")
            if isinstance(control_cycle, Mapping)
            else None
        ),
    }


def derive_health(
    states: Mapping[str, ReportState],
    kpis: Mapping[str, Any],
    git: Mapping[str, Any],
    allow_dirty: bool,
) -> tuple[str, str, list[str], list[str]]:
    blockers: list[str] = []
    warnings: list[str] = []

    for key, state in states.items():
        if not state.exists:
            blockers.append(f"{key}: latest report chybí")
        elif not state.readable:
            blockers.append(f"{key}: latest report nelze načíst")
        elif not state.status_ok:
            blockers.append(
                f"{key}: {state.final_status} "
                f"(očekáváno {state.expected_status})"
            )

    if int(kpis.get("verification_blockers", 0)) > 0:
        blockers.append("Integritní audit obsahuje blokátory.")

    if int(kpis.get("sync_blockers", 0)) > 0:
        blockers.append("Synchronizační plán obsahuje blokátory.")

    if int(kpis.get("manifest_blockers", 0)) > 0:
        blockers.append("Manifest obsahuje blokátory.")

    if int(kpis.get("verification_warnings", 0)) > 0:
        warnings.append("Integritní audit obsahuje varování.")

    if int(kpis.get("sync_actions", 0)) > 0:
        warnings.append("Synchronizační plán vyžaduje akci.")

    if int(kpis.get("manifest_warnings", 0)) > 0:
        warnings.append("Manifest obsahuje varování.")

    if git.get("dirty") and not allow_dirty:
        warnings.append(
            "Git pracovní strom není čistý; snapshot je provozně správný, "
            "ale změny ještě nejsou plně uzavřené."
        )

    if blockers:
        return (
            "BLOCKED",
            FINAL_BLOCKED,
            blockers,
            warnings,
        )

    if warnings:
        return (
            "WARNING",
            FINAL_WARNING,
            blockers,
            warnings,
        )

    return (
        "READY",
        FINAL_READY,
        blockers,
        warnings,
    )


def markdown_report(
    *,
    generated_at: str,
    health: str,
    final_status: str,
    git: Mapping[str, Any],
    kpis: Mapping[str, Any],
    states: Mapping[str, ReportState],
    blockers: list[str],
    warnings: list[str],
) -> str:
    lines = [
        "# MATCHMATRIX DOCUMENTATION STATUS SNAPSHOT",
        "",
        f"- Generated at: `{generated_at}`",
        f"- Health: **{health}**",
        f"- Final status: `{final_status}`",
        f"- Git commit: `{git.get('commit')}`",
        f"- Git branch: `{git.get('branch')}`",
        f"- Git dirty: `{git.get('dirty')}`",
        "",
        "## KPI",
        "",
        "| KPI | Hodnota |",
        "|---|---:|",
    ]

    labels = {
        "documents": "Dokumenty",
        "current_versions": "Aktuální verze",
        "sections": "Sekce",
        "relations": "Vazby",
        "status_history": "Historie stavů",
        "import_runs": "Importní běhy",
        "checks_total": "Kontroly celkem",
        "checks_passed": "Kontroly úspěšné",
        "in_sync": "Dokumenty IN_SYNC",
        "sync_actions": "Synchronizační akce",
        "sync_blockers": "Synchronizační blokátory",
        "unregistered_sources": "Nezařazené zdroje",
        "database_only_documents": "Pouze v databázi",
        "manifest_candidates": "Kandidáti manifestu",
        "manifest_ready": "Připravení kandidáti",
        "control_stages": "Kroky kontrolního cyklu",
        "control_stages_successful": "Úspěšné kroky cyklu",
    }

    for key, label in labels.items():
        lines.append(f"| {label} | {kpis.get(key, 0)} |")

    lines.extend(
        [
            "",
            "## Stav zdrojových reportů",
            "",
            "| Report | Stav | Očekáváno | Výsledek |",
            "|---|---|---|---|",
        ]
    )

    for key in ("manifest", "verification", "sync_plan", "control_cycle"):
        state = states[key]
        lines.append(
            f"| {key} | {state.final_status or 'MISSING'} | "
            f"{state.expected_status} | "
            f"{'OK' if state.status_ok else 'BLOCKED'} |"
        )

    if blockers:
        lines.extend(["", "## Blokátory", ""])
        lines.extend(f"- {item}" for item in blockers)

    if warnings:
        lines.extend(["", "## Varování", ""])
        lines.extend(f"- {item}" for item in warnings)

    lines.extend(
        [
            "",
            "## Doporučený další krok",
            "",
        ]
    )

    if blockers:
        lines.append(
            "Opravit blokující report nebo nekonzistenci a znovu spustit A9."
        )
    elif warnings:
        lines.append(
            "Uzavřít Git změny nebo vyřešit uvedené akce a snapshot obnovit."
        )
    else:
        lines.append(
            "Dokumentační vrstva je připravena pro napojení do OPS panelu."
        )

    lines.append("")
    return "\n".join(lines)


def write_outputs(
    root: Path,
    payload: Mapping[str, Any],
    markdown: str,
) -> tuple[Path, Path, Path]:
    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)

    timestamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")

    json_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.json"
    csv_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.csv"
    md_path = reports_dir / f"{REPORT_PREFIX}_{timestamp}.md"

    latest_json = reports_dir / f"{REPORT_PREFIX}_latest.json"
    latest_csv = reports_dir / f"{REPORT_PREFIX}_latest.csv"
    latest_md = reports_dir / f"{REPORT_PREFIX}_latest.md"

    encoded = json.dumps(
        payload,
        ensure_ascii=False,
        indent=2,
    )

    for path in (json_path, latest_json):
        path.write_text(encoded, encoding="utf-8")

    kpis = payload.get("kpis", {})
    csv_row = {
        "generated_at": payload.get("generated_at"),
        "health": payload.get("health"),
        "final_status": payload.get("final_status"),
        "git_commit": nested(payload, "git", "commit"),
        "git_dirty": nested(payload, "git", "dirty"),
        **kpis,
    }
    fieldnames = list(csv_row.keys())

    for path in (csv_path, latest_csv):
        with path.open(
            "w",
            encoding="utf-8-sig",
            newline="",
        ) as handle:
            writer = csv.DictWriter(
                handle,
                fieldnames=fieldnames,
            )
            writer.writeheader()
            writer.writerow(csv_row)

    for path in (md_path, latest_md):
        path.write_text(markdown, encoding="utf-8")

    return json_path, csv_path, md_path


def main() -> int:
    args = parse_args()
    root = project_root()
    generated_at = utc_now().isoformat()
    git = git_info(root)

    print("MATCHMATRIX DOCUMENTATION STATUS SNAPSHOT")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"GIT COMMIT         : {git.get('commit')}")
    print(f"GIT BRANCH         : {git.get('branch')}")
    print(f"GIT DIRTY          : {git.get('dirty')}")
    print()

    states = {
        key: load_report(root, key, path)
        for key, path in REPORTS.items()
    }

    print("ZDROJOVÉ REPORTY")
    print("-" * 79)
    for key in ("manifest", "verification", "sync_plan", "control_cycle"):
        state = states[key]
        print(
            f"{key:<16} | "
            f"{str(state.final_status or 'MISSING'):<42} | "
            f"{'OK' if state.status_ok else 'BLOCKED'}"
        )

    kpis = build_kpis(states)
    health, final_status, blockers, warnings = derive_health(
        states,
        kpis,
        git,
        args.allow_dirty,
    )

    payload = {
        "generated_at": generated_at,
        "project_root": str(root),
        "git": git,
        "health": health,
        "kpis": kpis,
        "reports": {
            key: state.as_dict()
            for key, state in states.items()
        },
        "blockers": blockers,
        "warnings": warnings,
        "final_status": final_status,
    }

    md_content = markdown_report(
        generated_at=generated_at,
        health=health,
        final_status=final_status,
        git=git,
        kpis=kpis,
        states=states,
        blockers=blockers,
        warnings=warnings,
    )

    json_path, csv_path, md_path = write_outputs(
        root,
        payload,
        md_content,
    )

    print()
    print("KPI")
    print("-" * 79)
    print(f"documents                    : {kpis['documents']}")
    print(f"current_versions             : {kpis['current_versions']}")
    print(f"sections                     : {kpis['sections']}")
    print(f"relations                    : {kpis['relations']}")
    print(f"checks_passed                : {kpis['checks_passed']}")
    print(f"checks_total                 : {kpis['checks_total']}")
    print(f"in_sync                      : {kpis['in_sync']}")
    print(f"sync_actions                 : {kpis['sync_actions']}")
    print(f"sync_blockers                : {kpis['sync_blockers']}")

    if blockers:
        print()
        print("BLOKÁTORY")
        print("-" * 79)
        for item in blockers:
            print(f"- {item}")

    if warnings:
        print()
        print("VAROVÁNÍ")
        print("-" * 79)
        for item in warnings:
            print(f"- {item}")

    print()
    print("SOUHRN")
    print("-" * 79)
    print(f"HEALTH                        : {health}")
    print(f"JSON REPORT                   : {json_path}")
    print(f"CSV REPORT                    : {csv_path}")
    print(f"MARKDOWN REPORT               : {md_path}")
    print(f"FINAL STATUS                  : {final_status}")

    return 1 if final_status == FINAL_BLOCKED else 0


if __name__ == "__main__":
    raise SystemExit(main())
