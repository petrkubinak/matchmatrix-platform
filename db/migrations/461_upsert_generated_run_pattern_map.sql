-- 461_upsert_generated_run_pattern_map.sql
-- Naplnění mapování run -> pattern

INSERT INTO public.generated_run_pattern_map (
    run_id,
    pattern_id,
    pattern_code
)
SELECT
    v.run_id,
    tpc.id AS pattern_id,
    v.pattern_code
FROM public.v_generated_run_pattern_candidates v
JOIN public.ticket_pattern_catalog tpc
  ON tpc.pattern_code = v.pattern_code

ON CONFLICT (run_id) DO UPDATE
SET
    pattern_id = EXCLUDED.pattern_id,
    pattern_code = EXCLUDED.pattern_code;