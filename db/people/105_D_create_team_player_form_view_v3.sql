/*
===============================================================================
MATCHMATRIX 105_D - CREATE TEAM PLAYER FORM VIEW V3
===============================================================================

Co view dělá:
- přidává confidence layer k team form
- zabraňuje zkreslení při malém počtu hráčů
- připravuje AI-ready team reliability model

K čemu slouží:
- TEAM POWER ENGINE
- AI prediction confidence
- homepage quality
- team analytics

Web/app využití:
- team confidence
- reliability indicator
- warning for low sample size
===============================================================================
*/

CREATE OR REPLACE VIEW public.v_team_player_form_v3 AS

WITH base AS (
    SELECT *
    FROM public.v_team_player_form_v2
)

SELECT
    b.*,

    CASE
        WHEN b.active_players_count >= 10 THEN 'HIGH'
        WHEN b.active_players_count >= 6 THEN 'MEDIUM'
        WHEN b.active_players_count >= 2 THEN 'LOW'
        ELSE 'VERY_LOW'
    END AS confidence_tier,

    CASE
        WHEN b.active_players_count >= 10 THEN '🟢'
        WHEN b.active_players_count >= 6 THEN '🟡'
        WHEN b.active_players_count >= 2 THEN '🟠'
        ELSE '🔴'
    END AS confidence_icon,

    CASE
        WHEN b.active_players_count >= 10 THEN 1.00
        WHEN b.active_players_count >= 6 THEN 0.75
        WHEN b.active_players_count >= 2 THEN 0.45
        ELSE 0.20
    END AS confidence_multiplier,

    ROUND(
        b.weighted_team_form_score *
        CASE
            WHEN b.active_players_count >= 10 THEN 1.00
            WHEN b.active_players_count >= 6 THEN 0.75
            WHEN b.active_players_count >= 2 THEN 0.45
            ELSE 0.20
        END,
        2
    ) AS adjusted_team_power_score,

    CASE
        WHEN (
            b.weighted_team_form_score *
            CASE
                WHEN b.active_players_count >= 10 THEN 1.00
                WHEN b.active_players_count >= 6 THEN 0.75
                WHEN b.active_players_count >= 2 THEN 0.45
                ELSE 0.20
            END
        ) >= 85 THEN 'ELITE'

        WHEN (
            b.weighted_team_form_score *
            CASE
                WHEN b.active_players_count >= 10 THEN 1.00
                WHEN b.active_players_count >= 6 THEN 0.75
                WHEN b.active_players_count >= 2 THEN 0.45
                ELSE 0.20
            END
        ) >= 70 THEN 'STRONG'

        WHEN (
            b.weighted_team_form_score *
            CASE
                WHEN b.active_players_count >= 10 THEN 1.00
                WHEN b.active_players_count >= 6 THEN 0.75
                WHEN b.active_players_count >= 2 THEN 0.45
                ELSE 0.20
            END
        ) >= 55 THEN 'AVERAGE'

        ELSE 'WEAK'
    END AS final_team_power_tier

FROM base b;