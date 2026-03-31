-- =========================================================
-- MatchMatrix
-- Oprava: mm_ui_run_tickets() - deduplikace odds
-- Soubor: C:\MatchMatrix-platform\db\debug\fix_mm_ui_run_tickets_dedup_odds.sql
-- Spouštět v DBeaveru
--
-- Cíl:
-- pro každý bookmaker + match + market_outcome vzít jen 1 odds řádek
-- priorita:
--   1) nejnovější collected_at
--   2) při shodě vyšší odd_value
-- =========================================================

CREATE OR REPLACE FUNCTION public.mm_ui_run_tickets(p_run_id bigint)
RETURNS TABLE(
    run_id bigint,
    ticket_index integer,
    bookmaker_id integer,
    total_odd numeric,
    items jsonb
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_template_id bigint;
    v_bookmaker_id int;
BEGIN
    SELECT gr.template_id, gr.bookmaker_id
      INTO v_template_id, v_bookmaker_id
    FROM public.generated_runs gr
    WHERE gr.id = p_run_id;

    IF v_template_id IS NULL THEN
        RAISE EXCEPTION 'Run % not found', p_run_id;
    END IF;

    RETURN QUERY
    WITH ticket_matches AS (
        SELECT
            gtb.run_id,
            gtb.ticket_index AS ti,
            gtb.block_index,
            tbm.match_id
        FROM public.generated_ticket_blocks gtb
        JOIN public.template_block_matches tbm
          ON tbm.template_id = v_template_id
         AND tbm.block_index = gtb.block_index
        WHERE gtb.run_id = p_run_id
    ),

    -- DEDUP: pro bookmaker + match + market_outcome nech jen 1 odds řádek
    latest_odds AS (
        SELECT DISTINCT ON (o.match_id, o.market_outcome_id, o.bookmaker_id)
            o.match_id,
            o.market_outcome_id,
            o.bookmaker_id,
            o.odd_value,
            o.collected_at
        FROM public.odds o
        WHERE o.bookmaker_id = v_bookmaker_id
          AND o.odd_value IS NOT NULL
          AND o.odd_value > 0
        ORDER BY
            o.match_id,
            o.market_outcome_id,
            o.bookmaker_id,
            o.collected_at DESC NULLS LAST,
            o.odd_value DESC
    ),

    ticket_odds AS (
        SELECT
            gtb.run_id,
            gtb.ticket_index AS ti,
            tm.block_index,
            tm.match_id,
            gtb.market_outcome_id,
            lo.odd_value,
            lo.collected_at
        FROM public.generated_ticket_blocks gtb
        JOIN ticket_matches tm
          ON tm.run_id = gtb.run_id
         AND tm.ti = gtb.ticket_index
         AND tm.block_index = gtb.block_index
        LEFT JOIN latest_odds lo
          ON lo.match_id = tm.match_id
         AND lo.market_outcome_id = gtb.market_outcome_id
         AND lo.bookmaker_id = v_bookmaker_id
        WHERE gtb.run_id = p_run_id
    ),

    agg AS (
        SELECT
            p_run_id AS run_id,
            to1.ti AS ticket_index,
            v_bookmaker_id AS bookmaker_id,
            EXP(SUM(LN(NULLIF(to1.odd_value, 0))))::numeric AS total_odd,
            jsonb_agg(
                jsonb_build_object(
                    'block_index', to1.block_index,
                    'match_id', to1.match_id,
                    'market_outcome_id', to1.market_outcome_id,
                    'odd', to1.odd_value
                )
                ORDER BY to1.block_index, to1.match_id
            ) AS items
        FROM ticket_odds to1
        GROUP BY to1.ti
    )

    SELECT
        a.run_id,
        a.ticket_index,
        a.bookmaker_id,
        a.total_odd,
        a.items
    FROM agg a
    ORDER BY a.ticket_index;

END;
$$;

-- volitelná kontrola definice po změně
SELECT pg_get_functiondef('public.mm_ui_run_tickets(bigint)'::regprocedure);