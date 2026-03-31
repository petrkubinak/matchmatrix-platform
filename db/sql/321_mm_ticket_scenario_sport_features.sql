-- 321_mm_ticket_scenario_sport_features.sql
-- Sportové feature scénářů a variant

CREATE OR REPLACE VIEW public.v_mm_ticket_scenario_sport_features AS
SELECT
    s.id AS scenario_id,
    s.generated_run_id,
    s.scenario_mode,
    s.scenario_name,

    COUNT(DISTINCT sp.id) AS sport_count,
    STRING_AGG(DISTINCT sp.code, '+' ORDER BY sp.code) AS sport_signature,

    COUNT(DISTINCT l.id) AS league_count,
    STRING_AGG(DISTINCT l.name, ' | ' ORDER BY l.name) AS league_signature

FROM public.mm_ticket_scenarios s
LEFT JOIN public.mm_ticket_scenario_blocks sb
    ON sb.scenario_id = s.id
LEFT JOIN public.mm_ticket_scenario_block_matches sbm
    ON sbm.block_id = sb.id
LEFT JOIN public.matches m
    ON m.id = sbm.match_id
LEFT JOIN public.leagues l
    ON l.id = m.league_id
LEFT JOIN public.sports sp
    ON sp.id = l.sport_id
GROUP BY
    s.id,
    s.generated_run_id,
    s.scenario_mode,
    s.scenario_name;