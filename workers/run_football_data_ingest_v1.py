# -*- coding: utf-8 -*-
"""
run_football_data_ingest_v1.py

Wrapper pro spuštění Football-Data ingestu z provider složky.

Cíl:
- nespouštět provider script přímo z panelu
- mít jednotný worker vstup pro MatchMatrix Control Panel
- vracet čitelný log + return code

Spouští:
C:\MatchMatrix-platform\ingest\Football-Data\football_data_pull_V6.py
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")
FOOTBALL_DATA_SCRIPT = PROJECT_ROOT / "ingest" / "Football-Data" / "football_data_pull_V6.py"


def print_header() -> None:
    print("=" * 80)
    print("MATCHMATRIX - FOOTBALL-DATA INGEST WORKER V1")
    print("=" * 80)
    print(f"PROJECT_ROOT          : {PROJECT_ROOT}")
    print(f"PYTHON_EXE            : {PYTHON_EXE}")
    print(f"FOOTBALL_DATA_SCRIPT  : {FOOTBALL_DATA_SCRIPT}")
    print("=" * 80)


def validate_environment(env: dict[str, str]) -> int:
    if not PYTHON_EXE.exists():
        print(f"ERROR: Python nebyl nalezen: {PYTHON_EXE}")
        return 2

    if not FOOTBALL_DATA_SCRIPT.exists():
        print(f"ERROR: Football-Data script nebyl nalezen: {FOOTBALL_DATA_SCRIPT}")
        return 3

    token = env.get("FOOTBALL_DATA_TOKEN", "").strip()
    if not token:
        print("ERROR: Chybí env FOOTBALL_DATA_TOKEN")
        return 4

    print("ENV CHECK OK")
    print("FOOTBALL_DATA_TOKEN present: YES")
    return 0


def build_command() -> list[str]:
    return [
        str(PYTHON_EXE),
        str(FOOTBALL_DATA_SCRIPT),
    ]


def main() -> int:
    print_header()

    env = os.environ.copy()

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
    print(f"FOOTBALL-DATA INGEST FINISHED | RC = {process.returncode}")
    print("=" * 80)

    return int(process.returncode)


if __name__ == "__main__":
    sys.exit(main())