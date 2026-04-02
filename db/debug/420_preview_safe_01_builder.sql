-- 420_preview_safe_01_builder.sql
-- První preview builder pro SAFE_01
-- SAFE_01 = 4 fix + blok A (1 zápas) + blok B (1 zápas)

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
    SELECT *
    FROM fix_pool
    WHERE rn <= 4
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
),
selected_block_a AS (
    SELECT *
    FROM block_pool
    WHERE rn = 1
),
selected_block_b AS (
    SELECT *
    FROM block_pool
    WHERE rn = 2
),
final_rows AS (
    SELECT
        'FIX'::text AS item_type,
        NULL::text AS block_code,
        sf.match_id,
        sf.kickoff,
        sf.league_name,
        sf.home_team,
        sf.away_team,
        sf.recommended_pick_code AS pick_code,
        sf.favorite_odd AS selected_odd,
        sf.favorite_odd,
        sf.outsider_odd,
        sf.home_away_gap,
        sf.avg_side_odd,
        sf.balanced_high_score
    FROM selected_fix sf

    UNION ALL

    SELECT
        'BLOCK'::text AS item_type,
        'A'::text AS block_code,
        sb.match_id,
        sb.kickoff,
        sb.league_name,
        sb.home_team,
        sb.away_team,
        NULL::text AS pick_code,
        NULL::numeric AS selected_odd,
        sb.favorite_odd,
        sb.outsider_odd,
        sb.home_away_gap,
        sb.avg_side_odd,
        sb.balanced_high_score
    FROM selected_block_a sb

    UNION ALL

    SELECT
        'BLOCK'::text AS item_type,
        'B'::text AS block_code,
        sb.match_id,
        sb.kickoff,
        sb.league_name,
        sb.home_team,
        sb.away_team,
        NULL::text AS pick_code,
        NULL::numeric AS selected_odd,
        sb.favorite_odd,
        sb.outsider_odd,
        sb.home_away_gap,
        sb.avg_side_odd,
        sb.balanced_high_score
    FROM selected_block_b sb
)
SELECT *
FROM final_rows
ORDER BY
    CASE item_type WHEN 'FIX' THEN 1 ELSE 2 END,
    block_code NULLS FIRST,
    kickoff,
    match_id;