-- 458_create_v_generated_run_pattern_candidates.sql
-- Preview patternů pro existující generated runy
-- Zatím NIC nezapisuje.
-- Jen dopočítá pattern_code a pattern metadata nad existujícími runy.

CREATE OR REPLACE VIEW public.v_generated_run_pattern_candidates AS
WITH run_base AS (
    SELECT
        gr.id AS run_id,
        gr.template_id,
        gr.bookmaker_id,
        gr.created_at
    FROM public.generated_runs gr
),

fixed_part AS (
    SELECT
        rb.run_id,
        rb.template_id,
        tfp.match_id,
        tfp.market_id,
        NULL::int AS block_index,
        'FIX'::text AS item_kind
    FROM run_base rb
    JOIN public.template_fixed_picks tfp
      ON tfp.template_id = rb.template_id
),

block_part AS (
    SELECT
        rb.run_id,
        rb.template_id,
        tbm.match_id,
        tbm.market_id,
        tbm.block_index,
        'BLOCK'::text AS item_kind
    FROM run_base rb
    JOIN public.template_block_matches tbm
      ON tbm.template_id = rb.template_id
),

all_items AS (
    SELECT * FROM fixed_part
    UNION ALL
    SELECT * FROM block_part
),

fix_stats AS (
    SELECT
        run_id,
        COUNT(*)::int AS fix_count
    FROM fixed_part
    GROUP BY run_id
),

block_sizes AS (
    SELECT
        run_id,
        COUNT(DISTINCT block_index)::int AS variable_block_count,
        STRING_AGG(match_cnt::text, '+' ORDER BY block_index) AS block_size_signature,
        MAX(match_cnt)::int AS max_matches_in_block
    FROM (
        SELECT
            run_id,
            block_index,
            COUNT(*)::int AS match_cnt
        FROM block_part
        GROUP BY run_id, block_index
    ) x
    GROUP BY run_id
),

match_stats AS (
    SELECT
        ai.run_id,
        COUNT(DISTINCT ai.match_id)::int AS total_match_count
    FROM all_items ai
    GROUP BY ai.run_id
),

sport_stats AS (
    SELECT
        ai.run_id,
        CASE
            WHEN COUNT(DISTINCT m.sport_id) = 1 THEN 'SINGLE_SPORT'
            ELSE 'MULTI_SPORT'
        END AS sport_scope,
        STRING_AGG(DISTINCT m.sport_id::text, '+' ORDER BY m.sport_id::text) AS sport_codes
    FROM all_items ai
    JOIN public.matches m
      ON m.id = ai.match_id
    GROUP BY ai.run_id
),

market_stats AS (
    SELECT
        ai.run_id,
        CASE
            WHEN COUNT(DISTINCT ai.market_id) = 1 THEN
                'MARKET_' || MIN(ai.market_id)::text
            ELSE
                'MIX'
        END AS market_family
    FROM all_items ai
    GROUP BY ai.run_id
),

final_calc AS (
    SELECT
        rb.run_id,
        rb.template_id,
        rb.bookmaker_id,
        rb.created_at,

        COALESCE(fs.fix_count, 0) AS fix_count,
        COALESCE(bs.variable_block_count, 0) AS variable_block_count,
        COALESCE(bs.block_size_signature, '0') AS block_size_signature,
        COALESCE(bs.max_matches_in_block, 0) AS max_matches_in_block,
        COALESCE(ms.total_match_count, 0) AS total_match_count,

        COALESCE(ss.sport_scope, 'UNKNOWN') AS sport_scope,
        COALESCE(ss.sport_codes, 'UNKNOWN') AS sport_codes,
        COALESCE(mks.market_family, 'UNKNOWN') AS market_family,

        CASE
            WHEN COALESCE(bs.variable_block_count, 0) = 0
                 AND COALESCE(fs.fix_count, 0) BETWEEN 1 AND 15
                THEN CASE
                    WHEN COALESCE(fs.fix_count, 0) <= 3 THEN 'LOW'
                    WHEN COALESCE(fs.fix_count, 0) <= 8 THEN 'MID'
                    ELSE 'HIGH'
                END
            WHEN COALESCE(bs.variable_block_count, 0) > 0
                THEN CASE
                    WHEN COALESCE(bs.variable_block_count, 0) = 1 THEN 'MID'
                    WHEN COALESCE(bs.variable_block_count, 0) = 2 THEN 'MID'
                    WHEN COALESCE(bs.variable_block_count, 0) = 3 THEN 'HIGH'
                    ELSE 'MIX'
                END
            ELSE 'MIX'
        END AS risk_profile
    FROM run_base rb
    LEFT JOIN fix_stats fs
      ON fs.run_id = rb.run_id
    LEFT JOIN block_sizes bs
      ON bs.run_id = rb.run_id
    LEFT JOIN match_stats ms
      ON ms.run_id = rb.run_id
    LEFT JOIN sport_stats ss
      ON ss.run_id = rb.run_id
    LEFT JOIN market_stats mks
      ON mks.run_id = rb.run_id
)

SELECT
    fc.run_id,
    fc.template_id,
    fc.bookmaker_id,
    fc.created_at,

    (
        'FIX' || fc.fix_count::text ||
        '_BL' || fc.variable_block_count::text ||
        '_' || REPLACE(fc.block_size_signature, '+', '_') ||
        '_' || fc.market_family ||
        '_' || fc.sport_scope ||
        '_' || REPLACE(fc.sport_codes, '+', '_') ||
        '_T' || fc.total_match_count::text
    ) AS pattern_code,

    'PREMATCH_GENERIC'::text AS ticket_type,
    fc.market_family,
    fc.sport_scope,
    fc.sport_codes,
    fc.fix_count,
    fc.variable_block_count,
    fc.block_size_signature,
    fc.max_matches_in_block,
    fc.total_match_count,
    fc.risk_profile
FROM final_calc fc
ORDER BY fc.run_id DESC;