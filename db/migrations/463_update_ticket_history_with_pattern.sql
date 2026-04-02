-- 463_update_ticket_history_with_pattern.sql
-- Naplnění patternu do ticket_history_base podle run_id

UPDATE public.ticket_history_base thb
SET
    pattern_id = grpm.pattern_id,
    pattern_code = grpm.pattern_code
FROM public.generated_run_pattern_map grpm
WHERE thb.run_id = grpm.run_id;