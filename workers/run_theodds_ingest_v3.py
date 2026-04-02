# -*- coding: utf-8 -*-
"""
run_theodds_ingest_v3.py

Wrapper pro spuštění TheOdds ingestu z provider složky.

V3:
- zachová architekturu V2 (worker = wrapper)
- spouští nový parser theodds_parse_multi_V3.py
- zachová THEODDS_API_KEY z prostředí
- nastaví bezpečný fallback DB_DSN
- vypíše čitelný log + return code
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")
THEODDS_SCRIPT = PROJECT_ROOT / "ingest" / "TheOdds" / "theodds_parse_multi_V3.py"

DEFAULT_DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


def print_header() -> None:
    print("=" * 80)
    print("MATCHMATRIX - THEODDS INGEST WORKER V3")
    print("=" * 80)
    print(f"PROJECT_ROOT   : {PROJECT_ROOT}")
    print(f"PYTHON_EXE     : {PYTHON_EXE}")
    print(f"THEODDS_SCRIPT : {THEODDS_SCRIPT}")
    print("=" * 80)


def validate_environment(env: dict[str, str]) -> int:
    if not PYTHON_EXE.exists():
        print(f"ERROR: Python nebyl nalezen: {PYTHON_EXE}")
        return 2

    if not THEODDS_SCRIPT.exists():
        print(f"ERROR: TheOdds script nebyl nalezen: {THEODDS_SCRIPT}")
        return 3

    api_key = env.get("THEODDS_API_KEY", "").strip()
    if not api_key:
        print("ERROR: Chybí env THEODDS_API_KEY")
        return 5

    print("ENV CHECK OK")
    print("DB_DSN present         : YES")
    print("THEODDS_API_KEY present: YES")
    return 0


def build_command() -> list[str]:
    return [
        str(PYTHON_EXE),
        str(THEODDS_SCRIPT),
    ]


def main() -> int:
    print_header()

    env = os.environ.copy()

    raw_dsn = env.get("DB_DSN", "").strip()
    if not raw_dsn or raw_dsn.lower().startswith("set "):
        env["DB_DSN"] = DEFAULT_DB_DSN
        print("DB_DSN byl prázdný nebo neplatný -> použit fallback DSN.")
    else:
        print("DB_DSN z prostředí ponechán.")

    rc = validate_environment(env)
    if rc != 0:
        return rc

    cmd = build_command()

    print("-" * 80)
    print("RUN:")
    print(" ".join(cmd))
    print("-" * 80)

    process = subprocess.run(
        cmd,
        cwd=str(PROJECT_ROOT),
        env=env,
    )

    print("=" * 80)
    print(f"THEODDS INGEST FINISHED | RC = {process.returncode}")
    print("=" * 80)

    return int(process.returncode)


if __name__ == "__main__":
    sys.exit(main())