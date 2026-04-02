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

SELECT *
FROM tmp_safe02_selection
ORDER BY
    CASE item_type WHEN 'FIX' THEN 1 ELSE 2 END,
    block_code NULLS FIRST,
    kickoff,
    match_id;

SELECT *
FROM public.template_blocks
WHERE template_id = 202
ORDER BY block_index;

SELECT *
FROM public.template_block_matches
WHERE template_id = 202
ORDER BY block_index, match_id;

SELECT *
FROM public.template_fixed_picks
WHERE template_id = 202
ORDER BY match_id;