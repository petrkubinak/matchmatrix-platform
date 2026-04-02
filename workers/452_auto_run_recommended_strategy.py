# -*- coding: utf-8 -*-
"""
452_auto_run_recommended_strategy.py

Načte aktuálně doporučenou strategii z:
public.v_strategy_recommendation_current

A následně spustí:
workers/436_auto_safe_seeder_v3.py --strategy-code <doporučená_strategie>
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")
SAFE_WORKER = BASE_DIR / "workers" / "436_auto_safe_seeder_v3.py"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def fetch_recommended_strategy() -> str:
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                SELECT strategy_code
                FROM public.v_strategy_recommendation_current
                LIMIT 1
                """
            )
            row = cur.fetchone()

    if not row or not row.get("strategy_code"):
        raise RuntimeError("Nebyla nalezena doporučená strategie ve view public.v_strategy_recommendation_current.")

    return str(row["strategy_code"])


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX - AUTO RUN RECOMMENDED STRATEGY")
    print("=" * 80)
    print(f"BASE_DIR   : {BASE_DIR}")
    print(f"PYTHON_EXE : {PYTHON_EXE}")
    print(f"WORKER     : {SAFE_WORKER}")
    print("=" * 80)

    if not PYTHON_EXE.exists():
        print(f"ERROR: Python nebyl nalezen: {PYTHON_EXE}")
        return 2

    if not SAFE_WORKER.exists():
        print(f"ERROR: Worker nebyl nalezen: {SAFE_WORKER}")
        return 3

    try:
        strategy_code = fetch_recommended_strategy()
    except Exception as e:
        print(f"ERROR: {e}")
        return 4

    print(f"DOPORUČENÁ STRATEGIE : {strategy_code}")

    cmd = [
        str(PYTHON_EXE),
        str(SAFE_WORKER),
        "--strategy-code",
        strategy_code,
    ]

    print("-" * 80)
    print("RUN:", " ".join(cmd))
    print("-" * 80)

    completed = subprocess.run(cmd, cwd=str(BASE_DIR))

    print("=" * 80)
    print(f"RC : {completed.returncode}")
    print("=" * 80)

    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())