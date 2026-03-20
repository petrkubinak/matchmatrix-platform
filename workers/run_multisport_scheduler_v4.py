from __future__ import annotations

import os
import subprocess
from datetime import datetime

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

UNIFIED_INGEST = os.path.join(BASE_DIR, "ingest", "run_unified_ingest_v1.py")

# ============================================================
# MATCHMATRIX MULTISPORT SCHEDULER V4
# ============================================================
# V1 scheduler je jednoduchý runner seznamu jobů.
# Zatím:
# - bez DB queue
# - bez retry tabulek
# - bez persistence
# Ale:
# - má jasný job list
# - dá se spustit z panelu
# - je připravený pro rozšíření
# ============================================================

JOBS = [
    {
        "name": "Football leagues",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "leagues",
        ],
    },
    {
        "name": "Football teams",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "teams",
        ],
    },
    {
        "name": "Football fixtures",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "fixtures",
            "--season", "2025",
        ],
    },
    {
        "name": "Football odds",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "odds",
        ],
    },
    {
        "name": "Football players",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "players",
        ],
    },
    {
        "name": "Hockey leagues",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_hockey",
            "--sport", "hockey",
            "--entity", "leagues",
        ],
    },
    {
        "name": "Hockey teams",
        "command": [
            PYTHON_EXE, UNIFIED_INGEST,
            "--provider", "api_hockey",
            "--sport", "hockey",
            "--entity", "teams",
        ],
    },
]


def run_job(job: dict) -> int:
    print("=" * 70)
    print(f"JOB START: {job['name']}")
    print(f"TIME     : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("COMMAND  :", " ".join(job["command"]))
    print("=" * 70)

    process = subprocess.Popen(
        job["command"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=BASE_DIR
    )

    assert process.stdout is not None
    for line in process.stdout:
        print(line.rstrip())

    process.wait()

    print("-" * 70)
    print(f"JOB END  : {job['name']}")
    print(f"RETURNCODE: {process.returncode}")
    print("-" * 70)

    return process.returncode


def main() -> int:
    print("=" * 70)
    print("MATCHMATRIX MULTISPORT SCHEDULER V4")
    print("=" * 70)

    failed = 0

    for job in JOBS:
        rc = run_job(job)
        if rc != 0:
            failed += 1

    print("=" * 70)
    print("SCHEDULER SUMMARY")
    print(f"TOTAL JOBS : {len(JOBS)}")
    print(f"FAILED     : {failed}")
    print(f"SUCCESS    : {len(JOBS) - failed}")
    print("=" * 70)

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())