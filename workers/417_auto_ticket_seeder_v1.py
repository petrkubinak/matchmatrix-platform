# -*- coding: utf-8 -*-
"""
417_auto_ticket_seeder_v1.py

První jednoduchý AUTO ticket seeder pro MatchMatrix.
Cíl:
- vzít existující template
- spustit runtime generate
- uložit run do history
- logovat výsledek

Určeno pro ruční / testovací spouštění z VS terminálu.
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


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def fetchone(sql: str, params: tuple = ()) -> dict | None:
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            row = cur.fetchone()
            return dict(row) if row else None


def execute_scalar(sql: str, params: tuple = ()):
    row = fetchone(sql, params)
    if not row:
        return None
    return list(row.values())[0]


def main():
    parser = argparse.ArgumentParser(description="MatchMatrix AUTO ticket seeder V1")
    parser.add_argument("--template-id", type=int, required=True, help="ID šablony")
    parser.add_argument("--bookmaker-id", type=int, required=True, help="ID bookmakeru")
    parser.add_argument("--max-tickets", type=int, default=5000, help="Max tiketů")
    parser.add_argument("--min-probability", type=str, default="", help="Min. pravděpodobnost, např. 0.01")
    parser.add_argument("--stake", type=str, default="100", help="Vklad na 1 tiket")
    args = parser.parse_args()

    template_id = args.template_id
    bookmaker_id = args.bookmaker_id
    max_tickets = args.max_tickets
    min_probability = Decimal(args.min_probability) if args.min_probability.strip() else None
    stake = Decimal(args.stake)

    print("=" * 72)
    print("MATCHMATRIX AUTO TICKET SEEDER V1")
    print("=" * 72)
    print(f"TEMPLATE ID     : {template_id}")
    print(f"BOOKMAKER ID    : {bookmaker_id}")
    print(f"MAX TICKETS     : {max_tickets}")
    print(f"MIN PROBABILITY : {min_probability}")
    print(f"STAKE           : {stake}")
    print("=" * 72)

    # 1) Preview
    preview = fetchone(
        "SELECT * FROM public.mm_preview_run(%s, %s)",
        (template_id, bookmaker_id),
    )
    if not preview:
        print("ERROR: Preview nevrátil žádná data.")
        sys.exit(1)

    print("PREVIEW")
    print(f"  variable_blocks   : {preview.get('variable_blocks')}")
    print(f"  fixed_picks       : {preview.get('fixed_picks')}")
    print(f"  estimated_tickets : {preview.get('estimated_tickets')}")
    print(f"  warnings          : {preview.get('preview_warnings')}")

    warnings = preview.get("preview_warnings") or []
    non_limit_warnings = [w for w in warnings if not str(w).startswith("LIMIT:")]
    if non_limit_warnings:
        print("ERROR: Preview obsahuje validační warningy, run nebude spuštěn.")
        sys.exit(1)

    # 2) Generate
    run_id = execute_scalar(
        "SELECT public.mm_generate_run_engine(%s, %s, %s, %s) AS run_id",
        (template_id, bookmaker_id, max_tickets, min_probability),
    )
    if run_id is None:
        print("ERROR: Generate nevrátil run_id.")
        sys.exit(1)

    print(f"GENERATED RUN ID : {run_id}")

    # 3) Save full run do history
    save_result = fetchone(
        "SELECT * FROM public.mm_save_generated_run_full(%s)",
        (run_id,),
    )
    if not save_result:
        print("ERROR: mm_save_generated_run_full nevrátil výsledek.")
        sys.exit(1)

    print("SAVE RESULT")
    print(f"  out_run_id                : {save_result.get('out_run_id')}")
    print(f"  out_ticket_ref_id         : {save_result.get('out_ticket_ref_id')}")
    print(f"  out_tickets_rows          : {save_result.get('out_tickets_rows')}")
    print(f"  out_ticket_blocks_rows    : {save_result.get('out_ticket_blocks_rows')}")
    print(f"  out_ticket_block_matches  : {save_result.get('out_ticket_block_matches_rows')}")
    print(f"  out_history_inserted_rows : {save_result.get('out_history_inserted_rows')}")
    print(f"  out_history_updated_rows  : {save_result.get('out_history_updated_rows')}")
    print(f"  out_status_text           : {save_result.get('out_status_text')}")

    # 4) Summary
    summary = fetchone(
        "SELECT * FROM public.mm_ui_run_summary(%s, %s)",
        (run_id, stake),
    )

    if summary:
        print("SUMMARY")
        print(f"  tickets_count    : {summary.get('tickets_count')}")
        print(f"  total_stake      : {summary.get('total_stake')}")
        print(f"  max_total_odd    : {summary.get('max_total_odd')}")
        print(f"  min_total_odd    : {summary.get('min_total_odd')}")
        print(f"  avg_total_odd    : {summary.get('avg_total_odd')}")
        print(f"  max_possible_win : {summary.get('max_possible_win')}")

    print("=" * 72)
    print("DONE")
    print("=" * 72)


if __name__ == "__main__":
    main()