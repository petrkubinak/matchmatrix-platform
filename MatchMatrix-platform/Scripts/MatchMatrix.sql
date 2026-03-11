BEGIN;

-- =========================================================
-- MatchMatrix / TicketMatrix
-- Generate ticket variants for 3-block model (1 / 0 / 2)
--
-- INPUT:
--   nahraď hodnotu v CTE params.ticket_id
--
-- LOGIKA:
--   - konstanty = pevné
--   - bloky A/B/C = každému bloku se přiřadí 1 / 0 / 2
--   - max 27 variant
-- =========================================================

WITH params AS (
    SELECT 1::bigint AS ticket_id   -- <<< ZDE změň ticket_id
),

-- ---------------------------------------------------------
-- 0) Smazání starých variant pro ticket
-- ---------------------------------------------------------
deleted_variants AS (
    DELETE FROM public.ticket_variants tv
    USING params p
    WHERE tv.ticket_id = p.ticket_id
    RETURNING tv.id
),

-- ---------------------------------------------------------
-- 1) Přehled bloků tiketu
-- ---------------------------------------------------------
ticket_blocks_src AS (
    SELECT
        tb.id AS block_id,
        tb.ticket_id,
        tb.block_code,
        tb.sort_order
    FROM public.ticket_blocks tb
    JOIN params p
      ON p.ticket_id = tb.ticket_id
),

block_count AS (
    SELECT COUNT(*)::int AS cnt
    FROM ticket_blocks_src
),

-- ---------------------------------------------------------
-- 2) Variant grid podle počtu bloků
--    A/B/C mohou nabývat jen 1 / 0 / 2
-- ---------------------------------------------------------
variant_grid AS (
    -- 1 blok
    SELECT
        1::int AS blocks_count,
        a.outcome_code AS a_choice,
        NULL::text AS b_choice,
        NULL::text AS c_choice
    FROM (VALUES ('1'),('0'),('2')) a(outcome_code)

    UNION ALL

    -- 2 bloky
    SELECT
        2::int AS blocks_count,
        a.outcome_code AS a_choice,
        b.outcome_code AS b_choice,
        NULL::text AS c_choice
    FROM (VALUES ('1'),('0'),('2')) a(outcome_code)
    CROSS JOIN (VALUES ('1'),('0'),('2')) b(outcome_code)

    UNION ALL

    -- 3 bloky
    SELECT
        3::int AS blocks_count,
        a.outcome_code AS a_choice,
        b.outcome_code AS b_choice,
        c.outcome_code AS c_choice
    FROM (VALUES ('1'),('0'),('2')) a(outcome_code)
    CROSS JOIN (VALUES ('1'),('0'),('2')) b(outcome_code)
    CROSS JOIN (VALUES ('1'),('0'),('2')) c(outcome_code)
),

selected_variant_grid AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                vg.a_choice,
                COALESCE(vg.b_choice, ''),
                COALESCE(vg.c_choice, '')
        )::int AS variant_no,
        vg.a_choice,
        vg.b_choice,
        vg.c_choice
    FROM variant_grid vg
    CROSS JOIN block_count bc
    WHERE vg.blocks_count = bc.cnt
),

-- ---------------------------------------------------------
-- 3) Insert ticket_variants
-- ---------------------------------------------------------
inserted_variants AS (
    INSERT INTO public.ticket_variants (
        ticket_id,
        variant_no,
        total_matches_count,
        total_odds,
        probability,
        expected_value,
        hit_result,
        created_at
    )
    SELECT
        p.ticket_id,
        svg.variant_no,
        0,
        NULL,
        NULL,
        NULL,
        'pending',
        now()
    FROM selected_variant_grid svg
    CROSS JOIN params p
    RETURNING id, ticket_id, variant_no
),

-- ---------------------------------------------------------
-- 4) Insert variant -> block choice
-- ---------------------------------------------------------
inserted_variant_block_choices AS (
    INSERT INTO public.ticket_variant_block_choices (
        variant_id,
        block_id,
        chosen_outcome_code,
        created_at
    )
    SELECT
        iv.id AS variant_id,
        tbs.block_id,
        CASE
            WHEN tbs.block_code = 'A' THEN svg.a_choice
            WHEN tbs.block_code = 'B' THEN svg.b_choice
            WHEN tbs.block_code = 'C' THEN svg.c_choice
        END AS chosen_outcome_code,
        now()
    FROM inserted_variants iv
    JOIN selected_variant_grid svg
      ON svg.variant_no = iv.variant_no
    JOIN ticket_blocks_src tbs
      ON tbs.ticket_id = iv.ticket_id
    RETURNING id
),

-- ---------------------------------------------------------
-- 5) Insert constant matches into every variant
-- ---------------------------------------------------------
inserted_constant_variant_matches AS (
    INSERT INTO public.ticket_variant_matches (
        variant_id,
        match_id,
        source_type,
        block_id,
        market_id,
        outcome_code,
        bookmaker_id,
        bookmaker_odds,
        model_probability,
        expected_value,
        created_at
    )
    SELECT
        iv.id AS variant_id,
        tc.match_id,
        'constant' AS source_type,
        NULL::bigint AS block_id,
        tc.market_id,
        tc.outcome_code,
        tc.bookmaker_id,
        tc.bookmaker_odds,
        tc.model_probability,
        tc.expected_value,
        now()
    FROM inserted_variants iv
    JOIN public.ticket_constants tc
      ON tc.ticket_id = iv.ticket_id
    RETURNING id
),

-- ---------------------------------------------------------
-- 6) Insert block matches into every variant
--    outcome = choice of the block in this variant
--    model_probability = prob_1 / prob_0 / prob_2
-- ---------------------------------------------------------
inserted_block_variant_matches AS (
    INSERT INTO public.ticket_variant_matches (
        variant_id,
        match_id,
        source_type,
        block_id,
        market_id,
        outcome_code,
        bookmaker_id,
        bookmaker_odds,
        model_probability,
        expected_value,
        created_at
    )
    SELECT
        iv.id AS variant_id,
        tbm.match_id,
        'block' AS source_type,
        tbm.block_id,
        tbm.market_id,
        tvbc.chosen_outcome_code AS outcome_code,
        tbm.bookmaker_id,
        tbm.bookmaker_odds,
        CASE tvbc.chosen_outcome_code
            WHEN '1' THEN tbm.prob_1
            WHEN '0' THEN tbm.prob_0
            WHEN '2' THEN tbm.prob_2
        END AS model_probability,
        NULL::numeric AS expected_value,
        now()
    FROM inserted_variants iv
    JOIN public.ticket_variant_block_choices tvbc
      ON tvbc.variant_id = iv.id
    JOIN public.ticket_block_matches tbm
      ON tbm.block_id = tvbc.block_id
    RETURNING id
),

-- ---------------------------------------------------------
-- 7) Recompute totals for each variant
-- ---------------------------------------------------------
variant_agg AS (
    SELECT
        tvm.variant_id,
        COUNT(*)::int AS total_matches_count,
        EXP(SUM(LN(NULLIF(tvm.bookmaker_odds, 0))))::numeric(12,4) AS total_odds,
        EXP(SUM(LN(NULLIF(tvm.model_probability, 0))))::numeric(12,8) AS probability
    FROM public.ticket_variant_matches tvm
    JOIN inserted_variants iv
      ON iv.id = tvm.variant_id
    GROUP BY tvm.variant_id
),

updated_variants AS (
    UPDATE public.ticket_variants tv
       SET total_matches_count = va.total_matches_count,
           total_odds          = va.total_odds,
           probability         = va.probability,
           expected_value      = CASE
                                   WHEN va.total_odds IS NOT NULL
                                    AND va.probability IS NOT NULL
                                   THEN (va.probability * va.total_odds) - (1 - va.probability)
                                   ELSE NULL
                                 END
    FROM variant_agg va
    WHERE tv.id = va.variant_id
    RETURNING tv.id
)

-- ---------------------------------------------------------
-- 8) Update ticket header
-- ---------------------------------------------------------
UPDATE public.tickets t
   SET constants_count = (
           SELECT COUNT(*)
           FROM public.ticket_constants tc
           WHERE tc.ticket_id = t.id
       ),
       blocks_count = (
           SELECT COUNT(*)
           FROM public.ticket_blocks tb
           WHERE tb.ticket_id = t.id
       ),
       variants_generated = (
           SELECT COUNT(*)
           FROM public.ticket_variants tv
           WHERE tv.ticket_id = t.id
       ),
       updated_at = now()
FROM params p
WHERE t.id = p.ticket_id;

COMMIT;