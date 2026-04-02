# -*- coding: utf-8 -*-
"""
427_auto_safe_seeder_v2.py

AUTO SAFE seeder V2 pro MatchMatrix.

Co umí:
1) sestaví template 201 podle SAFE_01 pravidel
2) udělá preview přes mm_preview_run
3) vygeneruje run přes mm_generate_run_engine
4) uloží run do history přes mm_save_generated_run_full
5) vypíše souhrn

Poznámka:
- v ticket_history_base se zatím source_system pravděpodobně uloží jako "ticket_studio",
  protože to tak nyní nastavuje DB logika mm_save_generated_run_full().
"""

from __future__ import annotations

import sys
from decimal import Decimal
from typing import Optional

import psycopg2
from psycopg2.extras import RealDictCursor


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

TEMPLATE_ID = 201
BOOKMAKER_ID = 36
MAX_TICKETS = 5000
STAKE = Decimal("100")
STRATEGY_CODE = "AUTO_SAFE_01"

BUILD_TEMPLATE_SQL = """
BEGIN;

SET LOCAL session_replication_role = replica;

INSERT INTO public.templates (id, name, max_variable_blocks)
VALUES (201, 'AUTO SAFE_01', 3)
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    max_variable_blocks = EXCLUDED.max_variable_blocks;

DELETE FROM public.template_fixed_picks
WHERE template_id = 201;

DELETE FROM public.template_block_matches
WHERE template_id = 201;

DELETE FROM public.template_blocks
WHERE template_id = 201;

DROP TABLE IF EXISTS tmp_safe01_selection;

CREATE TEMP TABLE tmp_safe01_selection AS
WITH fix_pool AS (
    SELECT
        v.*,
        ROW_NUMBER() OVER (
            ORDER BY v.favorite_odd ASC, v.kickoff ASC, v.match_id ASC
        ) AS rn
    FROM public.v_auto_ticket_candidates_safe v
    WHERE v.candidate_type = 'FIX_SAFE'
      AND v.strategy_fit = 'SAFE_01_OR_SAFE_02'
),
selected_fix AS (
    SELECT
        'FIX'::text AS item_type,
        NULL::text AS block_code,
        fp.match_id,
        fp.recommended_pick_code,
        fp.favorite_odd,
        fp.kickoff,
        fp.league_name,
        fp.home_team,
        fp.away_team
    FROM fix_pool fp
    WHERE fp.rn <= 4
),
block_pool AS (
    SELECT
        v.*,
        ROW_NUMBER() OVER (
            ORDER BY v.balanced_high_score DESC, v.kickoff ASC, v.match_id ASC
        ) AS rn
    FROM public.v_auto_ticket_candidates_safe v
    WHERE v.candidate_type = 'BLOCK_SAFE'
      AND v.match_id NOT IN (SELECT match_id FROM selected_fix)
)
SELECT
    'FIX'::text AS item_type,
    NULL::text AS block_code,
    sf.match_id,
    sf.recommended_pick_code,
    sf.favorite_odd,
    sf.kickoff,
    sf.league_name,
    sf.home_team,
    sf.away_team
FROM selected_fix sf

UNION ALL

SELECT
    'BLOCK'::text AS item_type,
    'A'::text AS block_code,
    bp.match_id,
    NULL::text AS recommended_pick_code,
    bp.favorite_odd,
    bp.kickoff,
    bp.league_name,
    bp.home_team,
    bp.away_team
FROM block_pool bp
WHERE bp.rn = 1

UNION ALL

SELECT
    'BLOCK'::text AS item_type,
    'B'::text AS block_code,
    bp.match_id,
    NULL::text AS recommended_pick_code,
    bp.favorite_odd,
    bp.kickoff,
    bp.league_name,
    bp.home_team,
    bp.away_team
FROM block_pool bp
WHERE bp.rn = 2;

INSERT INTO public.template_blocks (template_id, block_index, block_type)
VALUES
    (201, 1, 'VARIABLE'),
    (201, 2, 'VARIABLE');

INSERT INTO public.template_block_matches (template_id, block_index, match_id, market_id)
SELECT
    201,
    CASE s.block_code
        WHEN 'A' THEN 1
        WHEN 'B' THEN 2
    END,
    s.match_id,
    public.mm_market_h2h_id()
FROM tmp_safe01_selection s
WHERE s.item_type = 'BLOCK';

INSERT INTO public.template_fixed_picks (
    template_id,
    match_id,
    market_id,
    market_outcome_id
)
SELECT
    201,
    s.match_id,
    public.mm_market_h2h_id(),
    mo.id
FROM tmp_safe01_selection s
JOIN public.market_outcomes mo
  ON mo.market_id = public.mm_market_h2h_id()
 AND mo.code = s.recommended_pick_code
WHERE s.item_type = 'FIX';

COMMIT;
"""


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def fetchone(sql: str, params: tuple = ()) -> Optional[dict]:
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            row = cur.fetchone()
            return dict(row) if row else None


def fetchall(sql: str, params: tuple = ()) -> list[dict]:
    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
            return [dict(r) for r in rows]


def execute_script(sql: str) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()


def main():
    print("=" * 72)
    print("MATCHMATRIX AUTO SAFE SEEDER V2")
    print("=" * 72)
    print(f"TEMPLATE ID  : {TEMPLATE_ID}")
    print(f"BOOKMAKER ID : {BOOKMAKER_ID}")
    print(f"MAX TICKETS  : {MAX_TICKETS}")
    print(f"STAKE        : {STAKE}")
    print("=" * 72)

    # 0) 
    print("[0/5] Vytvářím generation run log...")

    gen_run = fetchone(
        """
        INSERT INTO public.ticket_generation_runs (
            user_id,
            strategy_code,
            requested_matches_count,
            generated_candidates_count,
            generated_variants_count,
            filters_json,
            result_json
        )
        VALUES (
            NULL,
            %s,
            %s,
            NULL,
            NULL,
            jsonb_build_object(
                'template_id', %s,
                'bookmaker_id', %s
            ),
            '{}'::jsonb
        )
        RETURNING id
        """,
        (STRATEGY_CODE, 6, TEMPLATE_ID, BOOKMAKER_ID),
    )

    if not gen_run:
        print("ERROR: Nepodařilo se vytvořit generation run.")
        sys.exit(1)

    generation_run_id = gen_run["id"]
    print(f"  generation_run_id : {generation_run_id}")

    # 1) Build template 201
    print("[1/5] Sestavuji template 201 podle SAFE_01...")
    execute_script(BUILD_TEMPLATE_SQL)

    fixed_rows = fetchall(
        """
        SELECT template_id, match_id, market_id, market_outcome_id
        FROM public.template_fixed_picks
        WHERE template_id = %s
        ORDER BY match_id
        """,
        (TEMPLATE_ID,),
    )
    block_rows = fetchall(
        """
        SELECT template_id, block_index, match_id, market_id
        FROM public.template_block_matches
        WHERE template_id = %s
        ORDER BY block_index, match_id
        """,
        (TEMPLATE_ID,),
    )

    print(f"  FIX rows   : {len(fixed_rows)}")
    print(f"  BLOCK rows : {len(block_rows)}")

    if len(fixed_rows) != 4:
        print("ERROR: Očekával jsem 4 FIX řádky.")
        sys.exit(1)

    if len(block_rows) != 2:
        print("ERROR: Očekával jsem 2 BLOCK řádky.")
        sys.exit(1)

    # 2) Preview
    print("[2/5] Dělám runtime preview...")
    preview = fetchone(
        "SELECT * FROM public.mm_preview_run(%s, %s)",
        (TEMPLATE_ID, BOOKMAKER_ID),
    )
    if not preview:
        print("ERROR: Preview nevrátil žádná data.")
        sys.exit(1)

    print(f"  variable_blocks   : {preview.get('variable_blocks')}")
    print(f"  fixed_picks       : {preview.get('fixed_picks')}")
    print(f"  estimated_tickets : {preview.get('estimated_tickets')}")
    print(f"  preview_warnings  : {preview.get('preview_warnings')}")

    warnings = preview.get("preview_warnings") or []
    non_limit_warnings = [w for w in warnings if not str(w).startswith("LIMIT:")]
    if non_limit_warnings:
        print("ERROR: Preview obsahuje validační warningy, run nebude spuštěn.")
        sys.exit(1)

    # 3) Generate run
    print("[3/5] Generuji run...")
    run_row = fetchone(
        "SELECT public.mm_generate_run_engine(%s, %s, %s, %s) AS run_id",
        (TEMPLATE_ID, BOOKMAKER_ID, MAX_TICKETS, None),
    )
    if not run_row or run_row.get("run_id") is None:
        print("ERROR: Generate nevrátil run_id.")
        sys.exit(1)

    run_id = int(run_row["run_id"])
    print(f"  run_id : {run_id}")

    # 4) Save full run
    print("[4/5] Ukládám run do history...")
    save_row = fetchone(
        "SELECT * FROM public.mm_save_generated_run_full(%s)",
        (run_id,),
    )
    if not save_row:
        print("ERROR: mm_save_generated_run_full nevrátil výsledek.")
        sys.exit(1)

    print(f"  out_run_id                : {save_row.get('out_run_id')}")
    print(f"  out_ticket_ref_id         : {save_row.get('out_ticket_ref_id')}")
    print(f"  out_tickets_rows          : {save_row.get('out_tickets_rows')}")
    print(f"  out_ticket_blocks_rows    : {save_row.get('out_ticket_blocks_rows')}")
    print(f"  out_ticket_block_matches  : {save_row.get('out_ticket_block_matches_rows')}")
    print(f"  out_history_inserted_rows : {save_row.get('out_history_inserted_rows')}")
    print(f"  out_history_updated_rows  : {save_row.get('out_history_updated_rows')}")
    print(f"  out_status_text           : {save_row.get('out_status_text')}")

    # 5) Summary
    print("[5/5] Načítám summary...")
    summary = fetchone(
        "SELECT * FROM public.mm_ui_run_summary(%s, %s)",
        (run_id, STAKE),
    )
    history_rows = fetchall(
        """
        SELECT id, run_id, ticket_index, source_system, ticket_size, total_odd, probability, created_at
        FROM public.ticket_history_base
        WHERE run_id = %s
        ORDER BY ticket_index
        """,
        (run_id,),
    )

    print("[6/5] Ukládám výsledky do generation_runs...")

    execute_script(f"""
    UPDATE public.ticket_generation_runs
    SET
        generated_candidates_count = {len(fixed_rows) + len(block_rows)},
        generated_variants_count = {len(history_rows)},
        result_json = jsonb_build_object(
            'run_id', {run_id},
            'tickets', {len(history_rows)},
            'max_odd', {summary.get('max_total_odd') if summary else 'NULL'},
            'min_odd', {summary.get('min_total_odd') if summary else 'NULL'}
        )
    WHERE id = {generation_run_id};
    """)

    if summary:
        print(f"  tickets_count    : {summary.get('tickets_count')}")
        print(f"  total_stake      : {summary.get('total_stake')}")
        print(f"  max_total_odd    : {summary.get('max_total_odd')}")
        print(f"  min_total_odd    : {summary.get('min_total_odd')}")
        print(f"  avg_total_odd    : {summary.get('avg_total_odd')}")
        print(f"  max_possible_win : {summary.get('max_possible_win')}")

    print(f"  history_rows     : {len(history_rows)}")
    if history_rows:
        print(f"  source_system    : {history_rows[0].get('source_system')}")

    print("=" * 72)
    print("DONE")
    print("=" * 72)


if __name__ == "__main__":
    main()