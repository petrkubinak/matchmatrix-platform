-- 322_mm_ticket_scenario_rating_view.sql
-- Celkové hodnocení scénářů (rating + slovní interpretace)

CREATE OR REPLACE VIEW public.v_mm_ticket_scenario_rating AS
SELECT
    s.id AS scenario_id,
    s.generated_run_id,
    s.scenario_name,

    sf.sport_count,
    sf.sport_signature,
    sf.league_count,

    s.estimated_hit_probability,
    s.estimated_total_ev,
    s.avg_ticket_odd,
    s.roi_percent,

    -- 🎯 SCORE (0–100)
    ROUND((
        COALESCE(s.estimated_hit_probability, 0) * 40
        + COALESCE(s.estimated_total_ev, 0) * 25
        + CASE 
            WHEN sf.sport_count = 1 THEN 15
            WHEN sf.sport_count = 2 THEN 10
            ELSE 5
          END
        + CASE 
            WHEN sf.league_count = 1 THEN 10
            WHEN sf.league_count <= 3 THEN 7
            ELSE 3
          END
        + CASE 
            WHEN s.avg_ticket_odd BETWEEN 2 AND 6 THEN 10
            WHEN s.avg_ticket_odd < 2 THEN 5
            ELSE 6
          END
    )::numeric, 2) AS scenario_score,

    -- 🧠 TEXT HODNOCENÍ
    CASE
        WHEN s.estimated_hit_probability IS NULL THEN 'Bez dat'
        WHEN s.estimated_hit_probability >= 0.60 THEN 'Velmi silný tiket'
        WHEN s.estimated_hit_probability >= 0.45 THEN 'Solidní tiket'
        WHEN s.estimated_hit_probability >= 0.30 THEN 'Rizikovější tiket'
        ELSE 'Velmi rizikový tiket'
    END AS prediction_label,

    CASE
        WHEN sf.sport_count = 1 THEN 'Konzistentní (1 sport)'
        WHEN sf.sport_count = 2 THEN 'Mírně diverzifikovaný'
        ELSE 'Vysoce diverzifikovaný'
    END AS sport_eval,

    CASE
        WHEN sf.league_count = 1 THEN 'Jedna soutěž'
        WHEN sf.league_count <= 3 THEN 'Více soutěží'
        ELSE 'Silně rozptýlené'
    END AS league_eval,

    CASE
        WHEN s.estimated_total_ev > 0 THEN 'Pozitivní EV'
        WHEN s.estimated_total_ev = 0 THEN 'Neutrální EV'
        ELSE 'Negativní EV'
    END AS ev_eval

FROM public.mm_ticket_scenarios s
LEFT JOIN public.v_mm_ticket_scenario_sport_features sf
    ON sf.scenario_id = s.id;