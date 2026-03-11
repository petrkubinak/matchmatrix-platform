CREATE OR REPLACE FUNCTION public.fn_refresh_ticket_run_settlements()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

INSERT INTO public.ticket_run_settlements (

    run_id,
    ticket_index,
    matches_count,
    hits_count,
    miss_count,
    void_count,
    pending_count,
    total_odd,
    ticket_result_status

)

SELECT

    run_id,
    ticket_index,
    matches_count,
    hits_count,
    miss_count,
    void_count,
    pending_count,
    total_odd,
    ticket_result_status

FROM public.vw_ticket_summary

ON CONFLICT (run_id, ticket_index)

DO UPDATE SET

matches_count = EXCLUDED.matches_count,
hits_count = EXCLUDED.hits_count,
miss_count = EXCLUDED.miss_count,
void_count = EXCLUDED.void_count,
pending_count = EXCLUDED.pending_count,
total_odd = EXCLUDED.total_odd,
ticket_result_status = EXCLUDED.ticket_result_status,
settled_at = now();

END;
$$;