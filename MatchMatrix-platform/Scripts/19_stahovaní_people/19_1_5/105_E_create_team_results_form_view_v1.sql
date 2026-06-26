/*
===============================================================================
MATCHMATRIX 105_E - CREATE TEAM RESULTS FORM VIEW V1
===============================================================================

Co view dělá:
- počítá formu týmu z výsledků zápasů

K čemu slouží:
- TEAM POWER ENGINE
- AI prediction
- match previews
- momentum
- betting analytics

Web/app využití:
- posledních 5 zápasů
- W/D/L forma
- goals trend
- home/away strength
===============================================================================
*/

CREATE OR REPLACE VIEW public.v_team_results_form_v1 AS

WITH all_team_matches AS (

    -- -----------------------------------------------------------------------
    -- HOME TEAM
    -- -----------------------------------------------------------------------

    SELECT
        m.id AS match_id,
        m.sport_id,
        m.league_id,

        m.home_team_id AS team_id,
        t.name AS team_name,

        m.kickoff,
        m.status,

        m.home_score AS goals_for,
        m.away_score AS goals_against,

        CASE
            WHEN m.home_score > m.away_score THEN 'W'
            WHEN m.home_score = m.away_score THEN 'D'
            ELSE 'L'
        END AS result,

        CASE
            WHEN m.home_score > m.away_score THEN 3
            WHEN m.home_score = m.away_score THEN 1
            ELSE 0
        END AS points,

        'HOME' AS venue

    FROM public.matches m

    JOIN public.teams t
        ON t.id = m.home_team_id

    WHERE m.status = 'FINISHED'

    UNION ALL

    -- -----------------------------------------------------------------------
    -- AWAY TEAM
    -- -----------------------------------------------------------------------

    SELECT
        m.id AS match_id,
        m.sport_id,
        m.league_id,

        m.away_team_id AS team_id,
        t.name AS team_name,

        m.kickoff,
        m.status,

        m.away_score AS goals_for,
        m.home_score AS goals_against,

        CASE
            WHEN m.away_score > m.home_score THEN 'W'
            WHEN m.away_score = m.home_score THEN 'D'
            ELSE 'L'
        END AS result,

        CASE
            WHEN m.away_score > m.home_score THEN 3
            WHEN m.away_score = m.home_score THEN 1
            ELSE 0
        END AS points,

        'AWAY' AS venue

    FROM public.matches m

    JOIN public.teams t
        ON t.id = m.away_team_id

    WHERE m.status = 'FINISHED'
),

ranked AS (
    SELECT
        atm.*,

        ROW_NUMBER() OVER (
            PARTITION BY atm.team_id
            ORDER BY atm.kickoff DESC, atm.match_id DESC
        ) AS rn

    FROM all_team_matches atm
),

agg AS (
    SELECT
        r.team_id,
        r.team_name,
        r.sport_id,

        COUNT(*) FILTER (WHERE rn <= 5) AS matches_last_5,

        COUNT(*) FILTER (
            WHERE rn <= 5
              AND result = 'W'
        ) AS wins_last_5,

        COUNT(*) FILTER (
            WHERE rn <= 5
              AND result = 'D'
        ) AS draws_last_5,

        COUNT(*) FILTER (
            WHERE rn <= 5
              AND result = 'L'
        ) AS losses_last_5,

        COALESCE(SUM(points) FILTER (WHERE rn <= 5), 0) AS points_last_5,

        COALESCE(SUM(goals_for) FILTER (WHERE rn <= 5), 0) AS goals_for_last_5,

        COALESCE(SUM(goals_against) FILTER (WHERE rn <= 5), 0) AS goals_against_last_5,

        ROUND(
            AVG(goals_for) FILTER (WHERE rn <= 5),
            2
        ) AS avg_goals_for_last_5,

        ROUND(
            AVG(goals_against) FILTER (WHERE rn <= 5),
            2
        ) AS avg_goals_against_last_5

    FROM ranked r
    WHERE rn <= 5
    GROUP BY
        r.team_id,
        r.team_name,
        r.sport_id
)

SELECT
    a.*,

    ROUND(
        (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ),
        2
    ) AS results_form_score,

    CASE
        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 70 THEN 'HOT'

        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 50 THEN 'GOOD'

        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 30 THEN 'AVERAGE'

        ELSE 'COLD'
    END AS results_form_tier,

    CASE
        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 70 THEN '🔥'

        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 50 THEN '📈'

        WHEN (
            points_last_5 * 8
            + goals_for_last_5 * 2
            - goals_against_last_5 * 1.5
        ) >= 30 THEN '⚪'

        ELSE '❄'
    END AS results_form_icon,

    now() AS generated_at

FROM agg a;