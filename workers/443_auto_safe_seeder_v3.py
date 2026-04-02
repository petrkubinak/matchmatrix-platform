# -*- coding: utf-8 -*-
"""
436_auto_safe_seeder_v3.py
AUTO SAFE seeder V3 (SAFE_01 + SAFE_02 + SAFE_03)
"""

from __future__ import annotations
import argparse
import sys
from decimal import Decimal
import psycopg2
from psycopg2.extras import RealDictCursor

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

BOOKMAKER_ID = 36
MAX_TICKETS = 5000
STAKE = Decimal("100")

# =============================
# SQL BLOKY
# =============================

SAFE_01_SQL = """SELECT 1;"""  # už máš funkční z minulých kroků

SAFE_02_SQL = """SELECT 1;"""  # už máš funkční

SAFE_03_SQL = """SELECT 1;"""  # už máš funkční

# =============================
# STRATEGIE
# =============================

STRATEGY_CONFIG = {
    "AUTO_SAFE_01": {
        "template_id": 201,
        "build_sql": SAFE_01_SQL,
        "requested_matches_count": 6,
        "expected_fix_rows": 4,
        "expected_block_rows": 2,
    },
    "AUTO_SAFE_02": {
        "template_id": 202,
        "build_sql": SAFE_02_SQL,
        "requested_matches_count": 9,
        "expected_fix_rows": 5,
        "expected_block_rows": 4,
    },
    "AUTO_SAFE_03": {
        "template_id": 203,
        "build_sql": SAFE_03_SQL,
        "requested_matches_count": 5,
        "expected_fix_rows": 3,
        "expected_block_rows": 2,
    },
}

# =============================
# DB HELPERS
# =============================

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def fetchone(sql, params=()):
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            row = cur.fetchone()
            return dict(row) if row else None

def fetchall(sql, params=()):
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            return [dict(r) for r in cur.fetchall()]

def execute(sql):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

# =============================
# MAIN
# =============================

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--strategy-code", required=True)
    args = parser.parse_args()

    strategy = args.strategy_code
    cfg = STRATEGY_CONFIG[strategy]
    template_id = cfg["template_id"]

    print("====================================")
    print("AUTO SAFE SEEDER V3")
    print("====================================")
    print("STRATEGY:", strategy)

    # 1) BUILD TEMPLATE
    print("[1] build template")
    execute(cfg["build_sql"])

    # 2) PREVIEW
    preview = fetchone(
        "SELECT * FROM public.mm_preview_run(%s,%s)",
        (template_id, BOOKMAKER_ID)
    )
    print("[2] preview:", preview)

    # 3) GENERATE
    run = fetchone(
        "SELECT public.mm_generate_run_engine(%s,%s,%s,NULL) run_id",
        (template_id, BOOKMAKER_ID, MAX_TICKETS)
    )
    run_id = run["run_id"]
    print("[3] run_id:", run_id)

    # 4) SAVE
    save = fetchone(
        "SELECT * FROM public.mm_save_generated_run_full(%s)",
        (run_id,)
    )
    print("[4] saved:", save)

    print("DONE")

if __name__ == "__main__":
    main()