-- 428_audit_ticket_generation_runs.sql
-- Kontrola struktury a stavu ticket_generation_runs
-- před napojením AUTO SAFE workeru

SELECT
    id,
    user_id,
    strategy_code,
    requested_matches_count,
    generated_candidates_count,
    generated_variants_count,
    filters_json,
    result_json,
    created_at
FROM public.ticket_generation_runs
ORDER BY created_at DESC, id DESC
LIMIT 20;