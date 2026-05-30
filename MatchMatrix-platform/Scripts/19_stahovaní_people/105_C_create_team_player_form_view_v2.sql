/*
===============================================================================
MATCHMATRIX 105_C - CREATE TEAM PLAYER FORM VIEW V2
===============================================================================

Co view dělá:
- vážená týmová forma podle hráčů a jejich odehraných minut
- filtruje hráče, kteří odehráli alespoň 60 minut za posledních 5 zápasů
- vážený průměr form_score podle minutes_last_5
- odděluje počet hráčů v kádru (squadu) a aktivních hráčů s relevantní minutáží
- přidává realistický týmový form_score

K čemu slouží:
- TEAM POWER ENGINE
- AI prediction
- team momentum
- squad strength
- fantasy/team analytics

Web/app využití:
- TEAM FORM
- HOT TEAM
- TEAM MOMENTUM
- PLAYER IMPACT
===============================================================================
*/

CREATE OR REPLACE VIEW public.v_team_player_form_v2 AS

WITH player_filtered AS (
    SELECT
        pf.player_id,
        p.team_id,
        p.name AS player_name,
        pf.form_score,
        pf.momentum_score,
        pf.minutes_last_5,
        pf.sport_id
    FROM public.player_form pf
    JOIN public.players p
        ON p.id = pf.player_id
    WHERE p.team_id IS NOT NULL
      AND pf.minutes_last_5 >= 60 -- Minimální účast pro relevantní formu
),

team_agg AS (
    SELECT
        pf.team_id,
        pf.sport_id,

        COUNT(*) AS squad_count, -- Celkový počet hráčů v kádru s formou
        COUNT(*) FILTER (WHERE pf.minutes_last_5 >= 60) AS active_players_count, -- Aktivní hráči

        -- Vážený průměr form_score podle odehraných minut
        ROUND(
            SUM(pf.form_score * pf.minutes_last_5) /
            NULLIF(SUM(pf.minutes_last_5), 0),
            2
        ) AS weighted_team_form_score,

        -- Vážený průměr momentum_score podle odehraných minut
        ROUND(
            SUM(pf.momentum_score * pf.minutes_last_5) /
            NULLIF(SUM(pf.minutes_last_5), 0),
            2
        ) AS weighted_team_momentum_score,

        SUM(pf.minutes_last_5) AS total_minutes_last_5,

        -- Počet "hot" a "good" hráčů
        COUNT(*) FILTER (WHERE pf.form_score >= 90) AS hot_players_count,
        COUNT(*) FILTER (WHERE pf.form_score >= 75) AS good_players_count

    FROM player_filtered pf
    GROUP BY pf.team_id, pf.sport_id
)

SELECT
    ta.team_id,

    t.name AS team_name,
    t.logo_url,

    ta.sport_id,

    s.code AS sport_code,
    s.name AS sport_name,

    ta.squad_count,
    ta.active_players_count,

    ta.weighted_team_form_score,
    ta.weighted_team_momentum_score,

    ta.total_minutes_last_5,

    ta.hot_players_count,
    ta.good_players_count,

    CASE
        WHEN ta.weighted_team_form_score >= 90 THEN 'HOT'
        WHEN ta.weighted_team_form_score >= 75 THEN 'GOOD'
        WHEN ta.weighted_team_form_score >= 55 THEN 'AVERAGE'
        ELSE 'COLD'
    END AS team_form_tier,

    CASE
        WHEN ta.weighted_team_form_score >= 90 THEN '🔥'
        WHEN ta.weighted_team_form_score >= 75 THEN '📈'
        WHEN ta.weighted_team_form_score >= 55 THEN '⚪'
        ELSE '❄'
    END AS team_form_icon,

    now() AS generated_at

FROM team_agg ta

JOIN public.teams t
    ON t.id = ta.team_id

LEFT JOIN public.sports s
    ON s.id = ta.sport_id;