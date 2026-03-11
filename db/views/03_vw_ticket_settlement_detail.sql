CREATE OR REPLACE VIEW public.vw_ticket_settlement_detail AS
SELECT
    vtmr.run_id,
    vtmr.ticket_index,
    vtmr.source_type,
    vtmr.block_index,
    vtmr.match_id,
    vtmr.market_id,
    vtmr.market_outcome_id,
    vtmr.picked_outcome_code,
    vtmr.match_status,
    vtmr.home_score,
    vtmr.away_score,
    vtmr.kickoff,
    vtmr.actual_outcome_code,

    CASE
        WHEN vtmr.match_status IN ('SCHEDULED', 'LIVE') THEN 'pending'
        WHEN vtmr.match_status IN ('CANCELLED', 'POSTPONED') THEN 'void'
        WHEN vtmr.match_status = 'FINISHED'
             AND vtmr.actual_outcome_code = vtmr.picked_outcome_code THEN 'hit'
        WHEN vtmr.match_status = 'FINISHED'
             AND vtmr.actual_outcome_code <> vtmr.picked_outcome_code THEN 'miss'
        ELSE 'pending'
    END AS item_result_status

FROM public.vw_ticket_match_results vtmr;