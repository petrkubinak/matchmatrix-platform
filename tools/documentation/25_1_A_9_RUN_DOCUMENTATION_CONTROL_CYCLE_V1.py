#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MATCHMATRIX STANDARDNÍ HLAVIČKA

CO:
Spouští celý read-only kontrolní cyklus dokumentačního systému MatchMatrix
jediným příkazem.

K ČEMU:
- znovu sestaví kanonický importní manifest pomocí 25_1_A_5,
- ověří integritu databázového importu pomocí 25_1_A_7,
- sestaví synchronizační plán pomocí 25_1_A_8,
- zastaví se při prvním neúspěšném kroku,
- ověří očekávané FINAL STATUS jednotlivých nástrojů,
- vytvoří společný JSON report celého kontrolního cyklu,
- databázový obsah dokumentů nemění,
- vynucuje UTF-8 pro výstup všech podřízených Python skriptů.

KDE:
tools/documentation/25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py

JAK:
Standardní spuštění:
    py -3.14 .\\tools\\documentation\\25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py

Volitelné PostgreSQL DSN pro A7 a A8:
    py -3.14 .\\tools\\documentation\\25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py ^
      --dsn "host=localhost port=5432 dbname=matchmatrix user=postgres"

Volitelně lze přeskočit obnovu manifestu:
    py -3.14 .\\tools\\documentation\\25_1_A_9_RUN_DOCUMENTATION_CONTROL_CYCLE_V1.py ^
      --skip-manifest-refresh

Výstup:
- terminálový přehled jednotlivých kroků,
- reports/documentation/document_control_cycle_YYYYMMDD_HHMMSS.json,
- reports/documentation/document_control_cycle_latest.json.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import traceback
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Sequence


REPORT_PREFIX = "document_control_cycle"

SCRIPT_MANIFEST = "25_1_A_5_BUILD_DOCUMENT_IMPORT_MANIFEST_V1.py"
SCRIPT_VERIFY = "25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py"
SCRIPT_SYNC = "25_1_A_8_BUILD_DOCUMENT_SYNC_PLAN_V1.py"

MANIFEST_LATEST = Path(
    "reports/documentation/document_import_manifest_latest.json"
)
VERIFY_LATEST = Path(
    "reports/documentation/document_import_verification_latest.json"
)
SYNC_LATEST = Path(
    "reports/documentation/document_sync_plan_latest.json"
)

EXPECTED_MANIFEST_STATUS = "DOCUMENT_IMPORT_MANIFEST_READY"
EXPECTED_VERIFY_STATUS = "DOCUMENTATION_IMPORT_VERIFIED"
EXPECTED_SYNC_STATUS = "DOCUMENT_SYNC_PLAN_IN_SYNC"

FINAL_READY = "DOCUMENTATION_CONTROL_CYCLE_READY"
FINAL_BLOCKED = "DOCUMENTATION_CONTROL_CYCLE_BLOCKED"


@dataclass
class Stage:
    key: str
    title: str
    script_name: str
    expected_status: str
    result_path: Path
    arguments: list[str] = field(default_factory=list)


@dataclass
class StageResult:
    key: str
    title: str
    script_name: str
    command: list[str]
    started_at: str
    finished_at: str
    return_code: int
    expected_status: str
    actual_status: str | None
    status_match: bool
    report_path: str
    report_exists: bool
    report_refreshed: bool
    stdout_tail: list[str]
    error: str | None = None

    @property
    def successful(self) -> bool:
        return (
            self.return_code == 0
            and self.report_exists
            and self.report_refreshed
            and self.status_match
            and self.error is None
        )

    def as_dict(self) -> dict[str, Any]:
        return {
            "key": self.key,
            "title": self.title,
            "script_name": self.script_name,
            "command": self.command,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
            "return_code": self.return_code,
            "expected_status": self.expected_status,
            "actual_status": self.actual_status,
            "status_match": self.status_match,
            "successful": self.successful,
            "report_path": self.report_path,
            "report_exists": self.report_exists,
            "report_refreshed": self.report_refreshed,
            "stdout_tail": self.stdout_tail,
            "error": self.error,
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Spustí celý kontrolní cyklus dokumentace MatchMatrix."
        )
    )
    parser.add_argument(
        "--dsn",
        help=(
            "Volitelné PostgreSQL DSN předané nástrojům A7 a A8. "
            "Heslo se do reportu neukládá."
        ),
    )
    parser.add_argument(
        "--skip-manifest-refresh",
        action="store_true",
        help=(
            "Přeskočí A5 a použije existující "
            "document_import_manifest_latest.json."
        ),
    )
    parser.add_argument(
        "--stdout-tail-lines",
        type=int,
        default=40,
        help="Počet posledních řádků každého kroku uložených do reportu.",
    )
    return parser.parse_args()


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def iso_now() -> str:
    return utc_now().isoformat()


def safe_command_for_report(command: Sequence[str]) -> list[str]:
    result: list[str] = []
    hide_next = False

    for item in command:
        if hide_next:
            result.append("<REDACTED_DSN>")
            hide_next = False
            continue

        result.append(item)
        if item == "--dsn":
            hide_next = True

    return result


def load_json(path: Path) -> dict[str, Any]:
    data = path.read_bytes()
    return json.loads(data.decode("utf-8-sig"))


def file_mtime_ns(path: Path) -> int | None:
    try:
        return path.stat().st_mtime_ns
    except FileNotFoundError:
        return None


def stream_process(
    command: list[str],
    *,
    cwd: Path,
) -> tuple[int, list[str]]:
    """
    Spustí podřízený nástroj, průběžně předává jeho výstup uživateli
    a současně jej uchová pro společný report.
    """
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

    output_lines: list[str] = []
    assert process.stdout is not None

    for line in process.stdout:
        print(line, end="")
        output_lines.append(line.rstrip("\r\n"))

    return_code = process.wait()
    return return_code, output_lines


def run_stage(
    *,
    root: Path,
    tools_dir: Path,
    stage: Stage,
    stdout_tail_lines: int,
) -> StageResult:
    script_path = tools_dir / stage.script_name
    result_path = root / stage.result_path

    started = utc_now()
    previous_mtime = file_mtime_ns(result_path)

    print()
    print("=" * 79)
    print(f"KROK {stage.key}: {stage.title}")
    print("=" * 79)

    if not script_path.is_file():
        finished = utc_now()
        return StageResult(
            key=stage.key,
            title=stage.title,
            script_name=stage.script_name,
            command=[],
            started_at=started.isoformat(),
            finished_at=finished.isoformat(),
            return_code=2,
            expected_status=stage.expected_status,
            actual_status=None,
            status_match=False,
            report_path=str(result_path),
            report_exists=False,
            report_refreshed=False,
            stdout_tail=[],
            error=f"Řídicí skript nebyl nalezen: {script_path}",
        )

    command = [
        sys.executable,
        str(script_path),
        *stage.arguments,
    ]

    try:
        return_code, output_lines = stream_process(
            command,
            cwd=root,
        )
    except Exception as exc:
        finished = utc_now()
        return StageResult(
            key=stage.key,
            title=stage.title,
            script_name=stage.script_name,
            command=safe_command_for_report(command),
            started_at=started.isoformat(),
            finished_at=finished.isoformat(),
            return_code=2,
            expected_status=stage.expected_status,
            actual_status=None,
            status_match=False,
            report_path=str(result_path),
            report_exists=result_path.is_file(),
            report_refreshed=False,
            stdout_tail=[],
            error=f"{type(exc).__name__}: {exc}",
        )

    finished = utc_now()
    current_mtime = file_mtime_ns(result_path)
    report_exists = current_mtime is not None

    if previous_mtime is None:
        report_refreshed = report_exists
    else:
        report_refreshed = (
            current_mtime is not None
            and current_mtime > previous_mtime
        )

    actual_status: str | None = None
    error: str | None = None

    if report_exists:
        try:
            payload = load_json(result_path)
            actual_status = payload.get("final_status")
        except Exception as exc:
            error = (
                f"Nelze načíst výstupní JSON {result_path}: "
                f"{type(exc).__name__}: {exc}"
            )
    else:
        error = f"Výstupní JSON nebyl vytvořen: {result_path}"

    status_match = actual_status == stage.expected_status

    return StageResult(
        key=stage.key,
        title=stage.title,
        script_name=stage.script_name,
        command=safe_command_for_report(command),
        started_at=started.isoformat(),
        finished_at=finished.isoformat(),
        return_code=return_code,
        expected_status=stage.expected_status,
        actual_status=actual_status,
        status_match=status_match,
        report_path=str(result_path),
        report_exists=report_exists,
        report_refreshed=report_refreshed,
        stdout_tail=output_lines[-max(stdout_tail_lines, 0):],
        error=error,
    )


def write_report(
    root: Path,
    payload: dict[str, Any],
) -> tuple[Path, Path]:
    reports_dir = root / "reports" / "documentation"
    reports_dir.mkdir(parents=True, exist_ok=True)

    timestamp = utc_now().astimezone().strftime("%Y%m%d_%H%M%S")
    timestamped = reports_dir / f"{REPORT_PREFIX}_{timestamp}.json"
    latest = reports_dir / f"{REPORT_PREFIX}_latest.json"

    encoded = json.dumps(
        payload,
        ensure_ascii=False,
        indent=2,
    )
    timestamped.write_text(encoded, encoding="utf-8")
    latest.write_text(encoded, encoding="utf-8")

    return timestamped, latest


def build_stages(
    *,
    root: Path,
    dsn: str | None,
    skip_manifest_refresh: bool,
) -> list[Stage]:
    stages: list[Stage] = []

    if not skip_manifest_refresh:
        stages.append(
            Stage(
                key="A5",
                title="Sestavení kanonického importního manifestu",
                script_name=SCRIPT_MANIFEST,
                expected_status=EXPECTED_MANIFEST_STATUS,
                result_path=MANIFEST_LATEST,
            )
        )
    else:
        manifest_path = root / MANIFEST_LATEST
        if not manifest_path.is_file():
            raise FileNotFoundError(
                "--skip-manifest-refresh nelze použít, protože "
                f"manifest neexistuje: {manifest_path}"
            )

        manifest = load_json(manifest_path)
        actual_status = manifest.get("final_status")
        if actual_status != EXPECTED_MANIFEST_STATUS:
            raise RuntimeError(
                "Existující manifest není připraven. "
                f"Očekáváno {EXPECTED_MANIFEST_STATUS}, "
                f"nalezeno {actual_status}."
            )

    verify_arguments: list[str] = []
    sync_arguments: list[str] = []

    if dsn:
        verify_arguments.extend(["--dsn", dsn])
        sync_arguments.extend(["--dsn", dsn])

    stages.extend(
        [
            Stage(
                key="A7",
                title="Ověření integrity databázového importu",
                script_name=SCRIPT_VERIFY,
                expected_status=EXPECTED_VERIFY_STATUS,
                result_path=VERIFY_LATEST,
                arguments=verify_arguments,
            ),
            Stage(
                key="A8",
                title="Sestavení synchronizačního plánu",
                script_name=SCRIPT_SYNC,
                expected_status=EXPECTED_SYNC_STATUS,
                result_path=SYNC_LATEST,
                arguments=sync_arguments,
            ),
        ]
    )

    return stages


def main() -> int:
    args = parse_args()
    root = project_root()
    tools_dir = root / "tools" / "documentation"
    started_at = iso_now()

    print("MATCHMATRIX DOCUMENTATION CONTROL CYCLE")
    print("=" * 79)
    print(f"PROJECT_ROOT       : {root}")
    print(f"PYTHON             : {sys.executable}")
    print(
        "MANIFEST REFRESH   : "
        f"{'SKIPPED' if args.skip_manifest_refresh else 'ENABLED'}"
    )
    print("DATABASE WRITES    : DISABLED")
    print()

    results: list[StageResult] = []
    unhandled_error: str | None = None

    try:
        stages = build_stages(
            root=root,
            dsn=args.dsn,
            skip_manifest_refresh=args.skip_manifest_refresh,
        )

        for stage in stages:
            result = run_stage(
                root=root,
                tools_dir=tools_dir,
                stage=stage,
                stdout_tail_lines=args.stdout_tail_lines,
            )
            results.append(result)

            print()
            print(f"{stage.key} RETURN CODE       : {result.return_code}")
            print(f"{stage.key} EXPECTED STATUS   : {result.expected_status}")
            print(f"{stage.key} ACTUAL STATUS     : {result.actual_status}")
            print(f"{stage.key} REPORT REFRESHED  : {result.report_refreshed}")
            print(
                f"{stage.key} RESULT            : "
                f"{'READY' if result.successful else 'BLOCKED'}"
            )

            if not result.successful:
                break

    except Exception as exc:
        unhandled_error = f"{type(exc).__name__}: {exc}"
        print()
        print("CONTROL CYCLE ERROR")
        print("-" * 79)
        print(unhandled_error)
        print(traceback.format_exc())

    all_successful = (
        bool(results)
        and all(result.successful for result in results)
        and results[-1].key == "A8"
        and unhandled_error is None
    )
    final_status = FINAL_READY if all_successful else FINAL_BLOCKED

    finished_at = iso_now()
    payload = {
        "started_at": started_at,
        "finished_at": finished_at,
        "project_root": str(root),
        "python_executable": sys.executable,
        "manifest_refresh_skipped": args.skip_manifest_refresh,
        "database_writes": False,
        "stages": [result.as_dict() for result in results],
        "stage_count": len(results),
        "successful_stage_count": sum(
            1 for result in results if result.successful
        ),
        "unhandled_error": unhandled_error,
        "final_status": final_status,
    }

    report_path, latest_path = write_report(root, payload)

    print()
    print("=" * 79)
    print("SOUHRN KONTROLNÍHO CYKLU")
    print("=" * 79)
    for result in results:
        print(
            f"{result.key:<4} | "
            f"{result.actual_status or 'NO_STATUS':<40} | "
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
