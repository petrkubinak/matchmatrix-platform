# MATCHMATRIX WORKER LAUNCHER V1.1
# =========================================================
# Účel:
# Bezpečné orchestration spouštění MatchMatrix workerů.
#
# Použití:
# - MATCHMATRIX CONTROL PANEL V16.3
# - RUN SELECTED
# - COPY COMMAND
# - execution metadata
# - log viewer
#
# Co skript dělá:
# - whitelist workerů
# - build command
# - bezpečné subprocess spuštění
# - timeout protection
# - stdout/stderr capture
# - runtime metadata
#
# Budoucí využití:
# - scheduler execution
# - autonomous orchestration
# - live monitoring
# - retry manager
# =========================================================

from __future__ import annotations

import subprocess
import time
import os
import psycopg2
from pathlib import Path
from typing import List, Dict, Any


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

LOG_DIR = BASE_DIR / "runtime_logs"
LOG_DIR.mkdir(exist_ok=True)

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

# =========================================================
# POVOLENÉ WORKERY
# =========================================================

ALLOWED_WORKERS = {
    "run_ingest_cycle_v3":
        BASE_DIR / "workers" / "run_ingest_cycle_v3.py",

    "run_people_pipeline_v22_from_planner":
        BASE_DIR / "workers" / "run_people_pipeline_v22_from_planner.py",

    "run_media_pipeline_v1":
        BASE_DIR / "workers" / "run_media_pipeline_v1.py",

    "run_unified_staging_to_public_merge_v3":
        BASE_DIR / "workers" / "run_unified_staging_to_public_merge_v3.py",
}


# =========================================================
# BUILD COMMAND
# =========================================================

def build_command(
    worker_key: str,
    args: List[str] | None = None
) -> List[str]:

    if worker_key not in ALLOWED_WORKERS:
        raise ValueError(f"Worker není povolený: {worker_key}")

    worker_path = ALLOWED_WORKERS[worker_key]

    if not PYTHON_EXE.exists():
        raise FileNotFoundError(f"Python nenalezen: {PYTHON_EXE}")

    if not worker_path.exists():
        raise FileNotFoundError(f"Worker nenalezen: {worker_path}")

    cmd = [str(PYTHON_EXE), str(worker_path)]

    if args:
        cmd.extend(args)

    return cmd


# =========================================================
# COMMAND AS TEXT
# =========================================================

def command_to_text(
    worker_key: str,
    args: List[str] | None = None
) -> str:

    cmd = build_command(worker_key, args)

    return " ".join(
        f'"{x}"' if " " in x else x
        for x in cmd
    )

# =========================================================
# SAVE EXECUTION HISTORY
# =========================================================

def save_execution_history(
    worker_name: str,
    status: str,
    duration_sec: float,
    return_code: int,
    command_text: str,
    log_file: str,
    stdout_text: str,
    stderr_text: str,
):

    try:

        conn = psycopg2.connect(**DB_CONFIG)

        with conn:

            with conn.cursor() as cur:

                cur.execute(
                    """
                    INSERT INTO ops.runtime_execution_history (
                        worker_name,
                        status,
                        duration_sec,
                        return_code,
                        command_text,
                        log_file,
                        stdout_preview,
                        stderr_preview
                    )
                    VALUES (
                        %s,%s,%s,%s,%s,%s,%s,%s
                    )
                    """,
                    (
                        worker_name,
                        status,
                        duration_sec,
                        return_code,
                        command_text,
                        log_file,
                        stdout_text[:5000],
                        stderr_text[:5000],
                    )
                )

        conn.close()

    except Exception as exc:

        print("SAVE EXECUTION HISTORY ERROR:")
        print(exc)


# =========================================================
# ACTIVE WORKER TRACKING
# =========================================================

def register_active_worker(
    worker_name: str,
    command_text: str,
):

    conn = psycopg2.connect(**DB_CONFIG)

    with conn:

        with conn.cursor() as cur:

            cur.execute(
                """
                INSERT INTO ops.active_worker_runs (
                    worker_name,
                    pid,
                    owner_id,
                    lock_name,
                    execution_state,
                    command_text
                )
                VALUES (
                    %s,%s,%s,%s,%s,%s
                )
                RETURNING id
                """,
                (
                    worker_name,
                    os.getpid(),
                    os.environ.get("USERNAME", "unknown"),
                    worker_name,
                    "RUNNING",
                    command_text
                )
            )

            row_id = cur.fetchone()[0]

    conn.close()

    return row_id


def unregister_active_worker(
    active_run_id: int
):

    conn = psycopg2.connect(**DB_CONFIG)

    with conn:

        with conn.cursor() as cur:

            cur.execute(
                """
                DELETE
                FROM ops.active_worker_runs
                WHERE id = %s
                """,
                (active_run_id,)
            )

    conn.close()

# =========================================================
# RUN WORKER
# =========================================================

def run_worker(
    worker_key: str,
    args: List[str] | None = None,
    timeout_sec: int = 600,
) -> Dict[str, Any]:

    cmd = build_command(worker_key, args)

    started = time.time()

    active_run_id = register_active_worker(
        worker_name=worker_key,
        command_text=" ".join(cmd)
    )

    process = subprocess.run(
        cmd,
        cwd=str(BASE_DIR),
        capture_output=True,
        text=True,
        timeout=timeout_sec,
        shell=False,
    )

    finished = time.time()

    duration = round(finished - started, 2)

    timestamp = int(time.time())

    log_file = LOG_DIR / f"{worker_key}_{timestamp}.log"

    log_text = f"""
=========================================================
MATCHMATRIX EXECUTION LOG
=========================================================

WORKER:
{worker_key}

COMMAND:
{' '.join(cmd)}

RETURN CODE:
{process.returncode}

DURATION:
{duration} sec

=========================================================
STDOUT
=========================================================

{process.stdout}

=========================================================
STDERR
=========================================================

{process.stderr}
"""

    log_file.write_text(log_text, encoding="utf-8")

    status = "SUCCESS"

    if process.returncode != 0:
        status = "ERROR"

    elif process.stderr.strip():
        status = "WARNING"

    unregister_active_worker(
        active_run_id
    )

    save_execution_history(
        worker_name=worker_key,
        status=status,
        duration_sec=duration,
        return_code=process.returncode,
        command_text=" ".join(cmd),
        log_file=str(log_file),
        stdout_text=process.stdout,
        stderr_text=process.stderr,
    )

    return {
        "success": process.returncode == 0,
        "return_code": process.returncode,
        "duration_sec": duration,
        "stdout": process.stdout,
        "stderr": process.stderr,
        "log_file": str(log_file),
        "command": " ".join(cmd),
    }


# =========================================================
# TEST
# =========================================================

if __name__ == "__main__":

    print("=" * 60)
    print("MATCHMATRIX WORKER LAUNCHER V1.1")
    print("=" * 60)

    print("\nPOVOLENÉ WORKERY:\n")

    for key, path in ALLOWED_WORKERS.items():
        print(f"- {key}")
        print(f"  {path}")

    print("\nTEST COPY COMMAND:\n")

    test_cmd = command_to_text(
        "run_media_pipeline_v1",
        ["--source", "official_site"]
    )

    print(test_cmd)

    print("\nHOTOVO")