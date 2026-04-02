-- 459_upsert_ticket_pattern_catalog_from_runs.sql
-- Naplnění / aktualizace ticket_pattern_catalog z dopočtených run patternů

INSERT INTO public.ticket_pattern_catalog (
    pattern_code,
    ticket_type,
    market_family,
    sport_scope,
    sport_codes,
    fix_count,
    variable_block_count,
    block_size_signature,
    total_match_count,
    risk_profile,
    notes
)
SELECT DISTINCT
    v.pattern_code,
    v.ticket_type,
    v.market_family,
    v.sport_scope,
    v.sport_codes,
    v.fix_count,
    v.variable_block_count,
    v.block_size_signature,
    v.total_match_count,
    v.risk_profile,
    'auto-upsert from v_generated_run_pattern_candidates'
FROM public.v_generated_run_pattern_candidates v
ON CONFLICT (pattern_code) DO UPDATE
SET
    ticket_type = EXCLUDED.ticket_type,
    market_family = EXCLUDED.market_family,
    sport_scope = EXCLUDED.sport_scope,
    sport_codes = EXCLUDED.sport_codes,
    fix_count = EXCLUDED.fix_count,
    variable_block_count = EXCLUDED.variable_block_count,
    block_size_signature = EXCLUDED.block_size_signature,
    total_match_count = EXCLUDED.total_match_count,
    risk_profile = EXCLUDED.risk_profile,
    notes = EXCLUDED.notes,
    updated_at = now();