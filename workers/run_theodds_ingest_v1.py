# -*- coding: utf-8 -*-
"""
run_theodds_ingest_v1.py

Wrapper pro spuštění TheOdds ingestu z provider složky.

Cíl:
- nespouštět provider script přímo z panelu
- mít jednotný worker vstup pro MatchMatrix Control Panel
- vracet čitelný log + return code

Spouští:
C:\MatchMatrix-platform\ingest\TheOdds\theodds_parse_multi_FINAL.py
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")
THEODDS_SCRIPT = PROJECT_ROOT / "ingest" / "TheOdds" / "theodds_parse_multi_FINAL.py"


def print_header() -> None:
    print("=" * 80)
    print("MATCHMATRIX - THEODDS INGEST WORKER V1")
    print("=" * 80)
    print(f"PROJECT_ROOT   : {PROJECT_ROOT}")
    print(f"PYTHON_EXE     : {PYTHON_EXE}")
    print(f"THEODDS_SCRIPT : {THEODDS_SCRIPT}")
    print("=" * 80)


def validate_environment() -> int:
    if not PYTHON_EXE.exists():
        print(f"ERROR: Python nebyl nalezen: {PYTHON_EXE}")
        return 2

    if not THEODDS_SCRIPT.exists():
        print(f"ERROR: TheOdds script nebyl nalezen: {THEODDS_SCRIPT}")
        return 3

    db_dsn = os.environ.get("DB_DSN", "").strip()
    api_key = os.environ.get("THEODDS_API_KEY", "").strip()

    if not db_dsn:
        print("ERROR: Chybí env DB_DSN")
        return 4

    if not api_key:
        print("ERROR: Chybí env THEODDS_API_KEY")
        return 5

    print("ENV CHECK OK")
    print(f"DB_DSN present         : YES")
    print(f"THEODDS_API_KEY present: YES")
    return 0


def build_command() -> list[str]:
    return [
        str(PYTHON_EXE),
        str(THEODDS_SCRIPT),
    ]


def main() -> int:
    print_header()

    rc = validate_environment()
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
    )

    print("=" * 80)
    print(f"THEODDS INGEST FINISHED | RC = {process.returncode}")
    print("=" * 80)

    return int(process.returncode)


if __name__ == "__main__":
    sys.exit(main())