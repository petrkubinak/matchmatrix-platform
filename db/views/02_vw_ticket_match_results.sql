CREATE OR REPLACE VIEW public.vw_ticket_match_results AS
SELECT
    vgtm.run_id,
    vgtm.ticket_index,
    vgtm.source_type,
    vgtm.block_index,
    vgtm.match_id,
    vgtm.market_id,
    vgtm.market_outcome_id,
    mo.code AS picked_outcome_code,

    m.status AS match_status,
    m.home_score,
    m.away_score,
    m.kickoff,

    CASE
        WHEN m.status <> 'FINISHED' THEN NULL
        WHEN m.home_score IS NULL OR m.away_score IS NULL THEN NULL
        WHEN m.home_score > m.away_score THEN '1'
        WHEN m.home_score = m.away_score THEN 'X'
        WHEN m.home_score < m.away_score THEN '2'
        ELSE NULL
    END AS actual_outcome_code

FROM public.vw_generated_ticket_matches vgtm
JOIN public.market_outcomes mo
  ON mo.id = vgtm.market_outcome_id
JOIN public.matches m
  ON m.id = vgtm.match_id;