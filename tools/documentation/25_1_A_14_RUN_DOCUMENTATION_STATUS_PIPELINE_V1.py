#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Spouští kompletní provozní pipeline dokumentačního statusu MatchMatrix.

K ČEMU:
- spustí A9: kompletní kontrolní cyklus dokumentace,
- spustí A10: sestavení stavového snapshotu,
- spustí A13: dry run nebo skutečný import snapshotu do databáze,
- zastaví se při prvním neúspěšném kroku,
- ověří finální stav každého kroku,
- vytvoří společný JSON report celé status pipeline,
- sjednotí provozní spuštění do jednoho příkazu.

KDE:
tools/documentation/25_1_A_14_RUN_DOCUMENTATION_STATUS_PIPELINE_V1.py

JAK:
Bez zápisu do databáze:
    py -3.14 .\\tools\\documentation\\25_1_A_14_RUN_DOCUMENTATION_STATUS_PIPELINE_V1.py

Se zápisem snapshotu:
    py -3.14 .\\tools\\documentation\\25_1_A_14_RUN_DOCUMENTATION_STATUS_PIPELINE_V1.py --apply

Povolení nečistého Git stromu:
    --allow-dirty

Volitelné PostgreSQL DSN:
    --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Volitelné přeskočení obnovy manifestu v A9:
    --skip-manifest-refresh

VÝSTUP:
- reports/documentation/documentation_status_pipeline_YYYYMMDD_HHMMSS.json
- reports/documentation/documentation_status_pipeline_latest.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


SCRIPT_A9 = "25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py"
SCRIPT_A10 = "25_1_A_10_BUILD_DOCUMENTATION_STATUS_SNAPSHOT_V1.py"
SCRIPT_A13 = "25_1_A_13_IMPORT_DOCUMENTATION_STATUS_SNAPSHOT_V1.py"

A9_REPORT = Path(
    "reports/documentation/document_control_cycle_latest.json"
)
A10_REPORT = Path(
    "reports/documentation/documentation_status_snapshot_latest.json"
)

A9_EXPECTED = {
    "DOCUMENTATION_CONTROL_CYCLE_READY",
}
A10_EXPECTED = {
    "DOCUMENTATION_STATUS_READY",
}
A13_EXPECTED_DRY_RUN = {
    "DOCUMENTATION_STATUS_SNAPSHOT_DRY_RUN_READY",
}
A13_EXPECTED_APPLY = {
    "DOCUMENTATION_STATUS_SNAPSHOT_IMPORTED",
    "DOCUMENTATION_STATUS_SNAPSHOT_UNCHANGED",
}

FINAL_READY = "DOCUMENTATION_STATUS_PIPELINE_READY"
FINAL_BLOCKED = "DOCUMENTATION_STATUS_PIPELINE_BLOCKED"
REPORT_PREFIX = "documentation_status_pipeline"
FINAL_STATUS_PATTERN = re.compile(
    r"FINAL STATUS\s*:\s*([A-Z0-9_]+)"
)


@dataclass
class StageResult:
    key: str
    title: str
    command: list[str]
    started_at: str
    finished_at: str
    return_code: int
    expected_statuses: list[str]
    actual_status: str | None
    successful: bool
    output_tail: list[str]
    error: str | None

    def as_dict(self) -> dict[str, Any]:
        return {
            "key": self.key,
            "title": self.title,
            "command": self.command,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
            "return_code": self.return_code,
            "expected_statuses": self.expected_statuses,
            "actual_status": self.actual_status,
            "successful": self.successful,
            "output_tail": self.output_tail,
            "error": self.error,
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Spustí kompletní dokumentační status pipeline MatchMatrix."
        )
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Povolí A13 skutečně uložit snapshot do databáze.",
    )
    parser.add_argument(
        "--allow-dirty",
        action="store_true",
        help="Povolí A10 stav READY i při nečistém Git stromu.",
    )
    parser.add_argument(
        "--skip-manifest-refresh",
        action="store_true",
        help="Předá A9 volbu --skip-manifest-refresh.",
    )
    parser.add_argument(
        "--dsn",
        help="Volitelné PostgreSQL DSN předané A9 a A13.",
    )
    parser.add_argument(
        "--stdout-tail-lines",
        type=int,
        default=50,
        help="Počet posledních řádků každého kroku uložených do reportu.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def safe_command(command: Iterable[str]) -> list[str]:
    result: list[str] = []
    redact_next = False

    for item in command:
        if redact_next:
            result.append("<REDACTED_DSN>")
            redact_next = False
            continue

        result.append(item)
        if item == "--dsn":
            redact_next = True

    return result


def stream_process(
    command: list[str],
    cwd: Path,
) -> tuple[int, list[str]]:
    child_env = os.environ.copy()
    child_env["PYTHONUTF8"] = "1"
    child_env["PYTHONIOENCODING"] = "utf-8"

    process = subprocess.Popen(
        command,
        cwd=cwd,
        env=child_env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="strict",
        bufsize=1,
    )

    output: list[str] = []
    assert process.stdout is not None

    for line in process.stdout:
        print(line, end="")
        output.append(line.rstrip("\r\n"))

    return process.wait(), output


def extract_final_status(lines: list[str]) -> str | None:
    for line in reversed(lines):
        match = FINAL_STATUS_PATTERN.search(line)
        if match:
            return match.group(1)
    return None


def load_final_status(path: Path) -> str | None:
    if not path.is_file():
        return None

    payload = json.loads(
        path.read_text(encoding="utf-8-sig")
    )
    status = payload.get("final_status")
    return str(status) if status else None


def run_stage(
    *,
    root: Path,
    key: str,
    title: str,
    script_name: str,
    arguments: list[str],
    expected_statuses: set[str],
    report_path: Path | None,
    tail_lines: int,
) -> StageResult:
    script_path = (
        root
        / "tools"
        / "documentation"
        / script_name
    )
    started = utc_now()

    print()
    print("=" * 79)
    print(f"KROK {key}: {title}")
    print("=" * 79)

    if not script_path.is_file():
        finished = utc_now()
        return StageResult(
            key=key,
            title=title,
            command=[],
            started_at=started.isoformat(),
            finished_at=finished.isoformat(),
            return_code=2,
            expected_statuses=sorted(expected_statuses),
            actual_status=None,
            successful=False,
            output_tail=[],
            error=f"Skript nebyl nalezen: {script_path}",
        )

    command = [
        sys.executable,
        str(script_path),
        *arguments,
    ]

    try:
        return_code, output = stream_process(
            command,
            root,
        )
        error = None
    except Exception as exc:
        finished = utc_now()
        return StageResult(
            key=key,
            title=title,
            command=safe_command(command),
            started_at=started.isoformat(),
            finished_at=finished.isoformat(),
            return_code=2,
            expected_statuses=sorted(expected_statuses),
            actual_status=None,
            successful=False,
            output_tail=[],
            error=f"{type(exc).__name__}: {exc}",
        )

    finished = utc_now()

    actual_status: str | None = None
    if report_path is not None:
        try:
            actual_status = load_final_status(
                root / report_path
            )
        except Exception as exc:
            error = (
                f"Nelze načíst report {root / report_path}: "
                f"{type(exc).__name__}: {exc}"
            )
    else:
        actual_status = extract_final_status(output)

    successful = (
        return_code == 0
        and actual_status in expected_statuses
        and error is None
    )

    return StageResult(
        key=key,
        title=title,
        command=safe_command(command),
        started_at=started.isoformat(),
        finished_at=finished.isoformat(),
        return_code=return_code,
        expected_statuses=sorted(expected_statuses),
        actual_status=actual_status,
        successful=successful,
        output_tail=output[-max(tail_lines, 0):],
        error=error,
    )


def write_report(
    root: Path,
    payload: dict[str, Any],
) -> tuple[Path, Path]:
    reports_dir = (
        root
        / "reports"
        / "documentation"
    )
    reports_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    timestamp = utc_now().astimezone().strftime(
        "%Y%m%d_%H%M%S"
    )
    timestamped = (
        reports_dir
        / f"{REPORT_PREFIX}_{timestamp}.json"
    )
    latest = (
        reports_dir
        / f"{REPORT_PREFIX}_latest.json"
    )

    encoded = json.dumps(
        payload,
        ensure_ascii=False,
        indent=2,
    )

    timestamped.write_text(
        encoded,
        encoding="utf-8",
    )
    latest.write_text(
        encoded,
        encoding="utf-8",
    )

    return timestamped, latest


def main() -> int:
    args = parse_args()
    root = project_root()
    started_at = utc_now().isoformat()

    print("MATCHMATRIX DOCUMENTATION STATUS PIPELINE")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"PYTHON             : {sys.executable}")
    print(f"MODE               : {'APPLY' if args.apply else 'DRY_RUN'}")
    print(f"ALLOW DIRTY        : {args.allow_dirty}")
    print(
        "MANIFEST REFRESH   : "
        f"{'SKIPPED' if args.skip_manifest_refresh else 'ENABLED'}"
    )

    results: list[StageResult] = []
    unhandled_error: str | None = None

    try:
        a9_args: list[str] = []
        if args.skip_manifest_refresh:
            a9_args.append(
                "--skip-manifest-refresh"
            )
        if args.dsn:
            a9_args.extend(
                ["--dsn", args.dsn]
            )

        result = run_stage(
            root=root,
            key="A9",
            title="Kompletní kontrolní cyklus",
            script_name=SCRIPT_A9,
            arguments=a9_args,
            expected_statuses=A9_EXPECTED,
            report_path=A9_REPORT,
            tail_lines=args.stdout_tail_lines,
        )
        results.append(result)

        if result.successful:
            a10_args: list[str] = []
            if args.allow_dirty:
                a10_args.append("--allow-dirty")

            result = run_stage(
                root=root,
                key="A10",
                title="Sestavení status snapshotu",
                script_name=SCRIPT_A10,
                arguments=a10_args,
                expected_statuses=A10_EXPECTED,
                report_path=A10_REPORT,
                tail_lines=args.stdout_tail_lines,
            )
            results.append(result)

        if results[-1].successful:
            a13_args: list[str] = []
            if args.apply:
                a13_args.append("--apply")
            if args.dsn:
                a13_args.extend(
                    ["--dsn", args.dsn]
                )

            expected = (
                A13_EXPECTED_APPLY
                if args.apply
                else A13_EXPECTED_DRY_RUN
            )

            result = run_stage(
                root=root,
                key="A13",
                title=(
                    "Import status snapshotu"
                    if args.apply
                    else "Dry run importu status snapshotu"
                ),
                script_name=SCRIPT_A13,
                arguments=a13_args,
                expected_statuses=expected,
                report_path=None,
                tail_lines=args.stdout_tail_lines,
            )
            results.append(result)

    except Exception as exc:
        unhandled_error = (
            f"{type(exc).__name__}: {exc}"
        )
        print()
        print("PIPELINE ERROR")
        print("-" * 79)
        print(unhandled_error)
        print(traceback.format_exc())

    all_successful = (
        len(results) == 3
        and all(
            result.successful
            for result in results
        )
        and unhandled_error is None
    )

    final_status = (
        FINAL_READY
        if all_successful
        else FINAL_BLOCKED
    )

    payload = {
        "started_at": started_at,
        "finished_at": utc_now().isoformat(),
        "project_root": str(root),
        "mode": (
            "APPLY"
            if args.apply
            else "DRY_RUN"
        ),
        "allow_dirty": args.allow_dirty,
        "manifest_refresh_skipped": (
            args.skip_manifest_refresh
        ),
        "stages": [
            result.as_dict()
            for result in results
        ],
        "stage_count": len(results),
        "successful_stage_count": sum(
            1
            for result in results
            if result.successful
        ),
        "unhandled_error": unhandled_error,
        "final_status": final_status,
    }

    report_path, latest_path = write_report(
        root,
        payload,
    )

    print()
    print("=" * 79)
    print("SOUHRN STATUS PIPELINE")
    print("=" * 79)

    for result in results:
        print(
            f"{result.key:<4} | "
            f"{str(result.actual_status or 'NO_STATUS'):<48} | "
            f"{'READY' if result.successful else 'BLOCKED'}"
        )

    if unhandled_error:
        print(f"ERROR              : {unhandled_error}")

    print(f"STAGES             : {len(results)}")
    print(
        "SUCCESSFUL         : "
        f"{sum(1 for result in results if result.successful)}"
    )
    print(f"REPORT             : {report_path}")
    print(f"LATEST REPORT      : {latest_path}")
    print(f"FINAL STATUS       : {final_status}")

    return 0 if all_successful else 1


if __name__ == "__main__":
    raise SystemExit(main())
