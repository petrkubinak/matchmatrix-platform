# -*- coding: utf-8 -*-
r"""
436_auto_safe_seeder_v3.py

AUTO SAFE seeder V3 pro MatchMatrix.

Podporované strategie:
- AUTO_SAFE_01
- AUTO_SAFE_02
- AUTO_SAFE_03

Co umí:
1) podle strategy_code sestaví template
2) udělá runtime preview
3) vygeneruje run
4) uloží run do history
5) zapíše audit do ticket_generation_runs

Spouštění:
C:\Python314\python.exe C:\MatchMatrix-platform\workers\436_auto_safe_seeder_v3.py --strategy-code AUTO_SAFE_01
C:\Python314\python.exe C:\MatchMatrix-platform\workers\436_auto_safe_seeder_v3.py --strategy-code AUTO_SAFE_02
C:\Python314\python.exe C:\MatchMatrix-platform\workers\436_auto_safe_seeder_v3.py --strategy-code AUTO_SAFE_03
"""

from __future__ import annotations

import argparse
import os
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

BOOKMAKER_ID = 36
MAX_TICKETS = 5000
STAKE = Decimal("100")


SAFE_01_SQL = """
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

SAFE_02_SQL = """
BEGIN;

SET LOCAL session_replication_role = replica;

INSERT INTO public.templates (id, name, max_variable_blocks)
VALUES (202, 'AUTO SAFE_02', 3)
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    max_variable_blocks = EXCLUDED.max_variable_blocks;

DELETE FROM public.template_fixed_picks
WHERE template_id = 202;

DELETE FROM public.template_block_matches
WHERE template_id = 202;

DELETE FROM public.template_blocks
WHERE template_id = 202;

DROP TABLE IF EXISTS tmp_safe02_selection;

CREATE TEMP TABLE tmp_safe02_selection AS
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
    WHERE fp.rn <= 5
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
WHERE bp.rn IN (1, 2)

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
WHERE bp.rn IN (3, 4);

INSERT INTO public.template_blocks (template_id, block_index, block_type)
VALUES
    (202, 1, 'VARIABLE'),
    (202, 2, 'VARIABLE');

INSERT INTO public.template_block_matches (template_id, block_index, match_id, market_id)
SELECT
    202,
    CASE s.block_code
        WHEN 'A' THEN 1
        WHEN 'B' THEN 2
    END,
    s.match_id,
    public.mm_market_h2h_id()
FROM tmp_safe02_selection s
WHERE s.item_type = 'BLOCK';

INSERT INTO public.template_fixed_picks (
    template_id,
    match_id,
    market_id,
    market_outcome_id
)
SELECT
    202,
    s.match_id,
    public.mm_market_h2h_id(),
    mo.id
FROM tmp_safe02_selection s
JOIN public.market_outcomes mo
  ON mo.market_id = public.mm_market_h2h_id()
 AND mo.code = s.recommended_pick_code
WHERE s.item_type = 'FIX';

COMMIT;
"""

SAFE_03_SQL = """
BEGIN;

SET LOCAL session_replication_role = replica;

INSERT INTO public.templates (id, name, max_variable_blocks)
VALUES (203, 'AUTO SAFE_03', 3)
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    max_variable_blocks = EXCLUDED.max_variable_blocks;

DELETE FROM public.template_fixed_picks
WHERE template_id = 203;

DELETE FROM public.template_block_matches
WHERE template_id = 203;

DELETE FROM public.template_blocks
WHERE template_id = 203;

DROP TABLE IF EXISTS tmp_safe03_selection;

CREATE TEMP TABLE tmp_safe03_selection AS
WITH fix_pool AS (
    SELECT
        v.*,
        ROW_NUMBER() OVER (
            ORDER BY v.favorite_odd ASC, v.kickoff ASC, v.match_id ASC
        ) AS rn
    FROM public.v_auto_ticket_candidates_safe v
    WHERE v.candidate_type = 'FIX_SAFE'
      AND v.strategy_fit = 'SAFE_03'
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
    WHERE fp.rn <= 3
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
    (203, 1, 'VARIABLE'),
    (203, 2, 'VARIABLE');

INSERT INTO public.template_block_matches (template_id, block_index, match_id, market_id)
SELECT
    203,
    CASE s.block_code
        WHEN 'A' THEN 1
        WHEN 'B' THEN 2
    END,
    s.match_id,
    public.mm_market_h2h_id()
FROM tmp_safe03_selection s
WHERE s.item_type = 'BLOCK';

INSERT INTO public.template_fixed_picks (
    template_id,
    match_id,
    market_id,
    market_outcome_id
)
SELECT
    203,
    s.match_id,
    public.mm_market_h2h_id(),
    mo.id
FROM tmp_safe03_selection s
JOIN public.market_outcomes mo
  ON mo.market_id = public.mm_market_h2h_id()
 AND mo.code = s.recommended_pick_code
WHERE s.item_type = 'FIX';

COMMIT;
"""


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


def create_generation_run(strategy_code: str, requested_matches_count: int, template_id: int) -> int:
    row = fetchone(
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
        (strategy_code, requested_matches_count, template_id, BOOKMAKER_ID),
    )
    if not row or row.get("id") is None:
        raise RuntimeError("Nepodařilo se vytvořit ticket_generation_runs řádek.")
    return int(row["id"])


def update_generation_run(
    generation_run_id: int,
    candidate_count: int,
    variant_count: int,
    run_id: int,
    max_odd,
    min_odd,
) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE public.ticket_generation_runs
                SET
                    generated_candidates_count = %s,
                    generated_variants_count = %s,
                    result_json = jsonb_build_object(
                        'run_id', %s,
                        'tickets', %s,
                        'max_odd', %s,
                        'min_odd', %s
                    )
                WHERE id = %s
                """,
                (
                    candidate_count,
                    variant_count,
                    run_id,
                    variant_count,
                    max_odd,
                    min_odd,
                    generation_run_id,
                ),
            )
        conn.commit()


def main():
    parser = argparse.ArgumentParser(description="MatchMatrix AUTO SAFE Seeder V3")
    parser.add_argument(
        "--strategy-code",
        required=True,
        choices=sorted(STRATEGY_CONFIG.keys()),
        help="AUTO_SAFE_01 nebo AUTO_SAFE_02 nebo AUTO_SAFE_03",
    )
    args = parser.parse_args()

    strategy_code = args.strategy_code
    cfg = STRATEGY_CONFIG[strategy_code]
    template_id = cfg["template_id"]
    requested_matches_count = cfg["requested_matches_count"]
    expected_fix_rows = cfg["expected_fix_rows"]
    expected_block_rows = cfg["expected_block_rows"]
    build_sql = cfg["build_sql"]

    print("RUNNING FILE:", os.path.abspath(__file__))
    print("=" * 72)
    print("MATCHMATRIX AUTO SAFE SEEDER V3")
    print("=" * 72)
    print(f"STRATEGY CODE : {strategy_code}")
    print(f"TEMPLATE ID   : {template_id}")
    print(f"BOOKMAKER ID  : {BOOKMAKER_ID}")
    print(f"MAX TICKETS   : {MAX_TICKETS}")
    print(f"STAKE         : {STAKE}")
    print("=" * 72)

    print("[0/5] Vytvářím generation run log...")
    generation_run_id = create_generation_run(
        strategy_code=strategy_code,
        requested_matches_count=requested_matches_count,
        template_id=template_id,
    )
    print(f"  generation_run_id : {generation_run_id}")

    print("[1/5] Sestavuji template...")
    execute_script(build_sql)

    fixed_rows = fetchall(
        """
        SELECT template_id, match_id, market_id, market_outcome_id
        FROM public.template_fixed_picks
        WHERE template_id = %s
        ORDER BY match_id
        """,
        (template_id,),
    )
    block_rows = fetchall(
        """
        SELECT template_id, block_index, match_id, market_id
        FROM public.template_block_matches
        WHERE template_id = %s
        ORDER BY block_index, match_id
        """,
        (template_id,),
    )

    print(f"  FIX rows   : {len(fixed_rows)}")
    print(f"  BLOCK rows : {len(block_rows)}")

    if len(fixed_rows) != expected_fix_rows:
        print(f"ERROR: Očekával jsem {expected_fix_rows} FIX řádků.")
        sys.exit(1)

    if len(block_rows) != expected_block_rows:
        print(f"ERROR: Očekával jsem {expected_block_rows} BLOCK řádků.")
        sys.exit(1)

    print("[2/5] Dělám runtime preview...")
    preview = fetchone(
        "SELECT * FROM public.mm_preview_run(%s, %s)",
        (template_id, BOOKMAKER_ID),
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

    print("[3/5] Generuji run...")
    run_row = fetchone(
        "SELECT public.mm_generate_run_engine(%s, %s, %s, %s) AS run_id",
        (template_id, BOOKMAKER_ID, MAX_TICKETS, None),
    )
    if not run_row or run_row.get("run_id") is None:
        print("ERROR: Generate nevrátil run_id.")
        sys.exit(1)

    run_id = int(run_row["run_id"])
    print(f"  run_id : {run_id}")

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
    update_generation_run(
        generation_run_id=generation_run_id,
        candidate_count=len(fixed_rows) + len(block_rows),
        variant_count=len(history_rows),
        run_id=run_id,
        max_odd=(summary.get("max_total_odd") if summary else None),
        min_odd=(summary.get("min_total_odd") if summary else None),
    )

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