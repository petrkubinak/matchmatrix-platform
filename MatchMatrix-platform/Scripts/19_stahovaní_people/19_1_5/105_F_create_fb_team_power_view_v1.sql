/*
===============================================================================
MATCHMATRIX 105_F - CREATE FB TEAM POWER VIEW V1
===============================================================================

Co view dělá:
- spojuje výsledkovou formu týmu s formou hráčů
- počítá první FB TEAM POWER SCORE

K čemu slouží:
- TEAM POWER ENGINE
- AI prediction
- match preview
- betting analytics
- team ranking

Web/app využití:
- síla týmu
- forma týmu
- confidence
- power ranking
===============================================================================
*/

CREATE OR REPLACE VIEW public.v_fb_team_power_v1 AS

WITH base AS (
    SELECT
        rf.team_id,
        rf.team_name,
        rf.sport_id,

        rf.matches_last_5,
        rf.wins_last_5,
        rf.draws_last_5,
        rf.losses_last_5,
        rf.goals_for_last_5,
        rf.goals_against_last_5,
        rf.results_form_score,
        rf.results_form_tier,

        pf.active_players_count,
        pf.weighted_team_form_score,
        pf.weighted_team_momentum_score,
        pf.confidence_tier,
        pf.confidence_multiplier,
        pf.adjusted_team_power_score AS player_based_power_score,

        -- normalizace výsledkové formy na rozumnější rozsah
        LEAST(rf.results_form_score, 150) AS normalized_results_score

    FROM public.v_team_results_form_v1 rf

    LEFT JOIN public.v_team_player_form_v3 pf
        ON pf.team_id = rf.team_id
       AND pf.sport_id = rf.sport_id

    WHERE rf.sport_id = 1
),

scored AS (
    SELECT
        b.*,

        ROUND(
            (
                COALESCE(b.normalized_results_score, 0) * 0.60
                +
                COALESCE(b.player_based_power_score, 0) * 0.40
            ),
            2
        ) AS fb_team_power_score

    FROM base b
)

SELECT
    s.*,

    CASE
        WHEN s.fb_team_power_score >= 100 THEN 'ELITE'
        WHEN s.fb_team_power_score >= 80 THEN 'STRONG'
        WHEN s.fb_team_power_score >= 60 THEN 'AVERAGE'
        ELSE 'WEAK'
    END AS fb_team_power_tier,

    CASE
        WHEN s.fb_team_power_score >= 100 THEN '🔥'
        WHEN s.fb_team_power_score >= 80 THEN '📈'
        WHEN s.fb_team_power_score >= 60 THEN '⚪'
        ELSE '❄'
    END AS fb_team_power_icon,

    now() AS generated_at

FROM scored s;