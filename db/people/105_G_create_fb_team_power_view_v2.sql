/*
===============================================================================
MATCHMATRIX 105_G - CREATE FB TEAM POWER VIEW V2
===============================================================================

Co view dělá:
- spojuje výsledkovou formu týmu a formu hráčů
- přidává confidence/reliability vrstvu
- rozlišuje, jestli výpočet stojí na:
  1) výsledcích + hráčích
  2) pouze výsledcích
  3) nízkém vzorku dat

K čemu slouží:
- TEAM POWER ENGINE
- AI prediction
- match preview
- betting analytics
- quality-aware ranking

Web/app využití:
- síla týmu
- forma týmu
- confidence label
- upozornění na nízkou datovou jistotu
===============================================================================
*/

CREATE OR REPLACE VIEW public.v_fb_team_power_v2 AS

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

        LEAST(rf.results_form_score, 150) AS normalized_results_score,

        pf.active_players_count,
        pf.weighted_team_form_score,
        pf.weighted_team_momentum_score,
        pf.confidence_tier AS player_form_confidence_tier,
        pf.confidence_multiplier AS player_form_confidence_multiplier,
        pf.adjusted_team_power_score AS player_based_power_score

    FROM public.v_team_results_form_v1 rf

    LEFT JOIN public.v_team_player_form_v3 pf
        ON pf.team_id = rf.team_id
       AND pf.sport_id = rf.sport_id

    WHERE rf.sport_id = 1
),

scored AS (
    SELECT
        b.*,

        CASE
            WHEN b.player_based_power_score IS NOT NULL THEN
                ROUND(
                    (
                        COALESCE(b.normalized_results_score, 0) * 0.60
                        +
                        COALESCE(b.player_based_power_score, 0) * 0.40
                    ),
                    2
                )
            ELSE
                ROUND(
                    COALESCE(b.normalized_results_score, 0) * 0.60,
                    2
                )
        END AS fb_team_power_score,

        CASE
            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 10
                 AND b.matches_last_5 >= 5
                THEN 'HIGH'

            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 6
                 AND b.matches_last_5 >= 5
                THEN 'MEDIUM'

            WHEN b.matches_last_5 >= 5
                THEN 'RESULTS_ONLY'

            ELSE 'LOW'
        END AS power_confidence_tier,

        CASE
            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 10
                 AND b.matches_last_5 >= 5
                THEN '🟢'

            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 6
                 AND b.matches_last_5 >= 5
                THEN '🟡'

            WHEN b.matches_last_5 >= 5
                THEN '🔵'

            ELSE '🔴'
        END AS power_confidence_icon,

        CASE
            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 10
                 AND b.matches_last_5 >= 5
                THEN 'Results + player form, high sample.'

            WHEN b.player_based_power_score IS NOT NULL
                 AND b.active_players_count >= 6
                 AND b.matches_last_5 >= 5
                THEN 'Results + player form, medium sample.'

            WHEN b.matches_last_5 >= 5
                THEN 'Results only. Player form missing or insufficient.'

            ELSE 'Low sample. Use carefully.'
        END AS power_confidence_note

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