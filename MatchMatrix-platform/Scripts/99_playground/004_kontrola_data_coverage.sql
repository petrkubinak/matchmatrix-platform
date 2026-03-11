SELECT *
FROM public.vw_ticket_summary
ORDER BY run_id DESC, ticket_index
LIMIT 100;

SELECT *
FROM public.vw_ticket_settlement_detail
WHERE run_id = 1
  AND ticket_index = 1
ORDER BY block_index NULLS LAST, match_id;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ticket_settlements'
ORDER BY ordinal_position;

SELECT public.fn_refresh_ticket_run_settlements();

SELECT *
FROM public.vw_ticket_summary
LIMIT 20;

SELECT COUNT(*)
FROM odds;

SELECT COUNT(*)
FROM odds
WHERE match_id IN (
    SELECT match_id
    FROM vw_generated_ticket_matches
);

SELECT *
FROM vw_data_coverage
LIMIT 50;

SELECT code, name, enabled
FROM ops.jobs
ORDER BY code;