/*
MATCHMATRIX SQL 111_S
AUTONOMOUS OPS BRAIN V2

CO TO JE:
- Brain už není závislý na autonomous queue.
- Kandidáty generuje přímo z AI recommendation engine.

K ČEMU TO JE:
- Queue je často prázdná.
- AI recommendation obsahuje reálné kandidáty.

KDE TO UVIDÍME:
- ops.v_autonomous_ops_brain_v2

JAK SE TO VYUŽIJE:
- Panel
- Launcher
- Budoucí Autonomous OPS Brain
*/

CREATE OR REPLACE VIEW ops.v_autonomous_ops_brain_v2 AS
WITH candidates AS (

    SELECT
        recommendation_rank,

        provider,
        sport_code,
        entity,
        league_id,
        season,
        run_group,

        empty_runs,
        empty_pct,

        ai_decision,
        ai_risk_level,
        ai_reason,
        autonomous_safe,

        generated_at

    FROM ops.v_panel_ai_recommendations_v1

),

brain AS (

    SELECT

        c.recommendation_rank,

        c.provider,
        c.sport_code,
        c.entity,
        c.league_id,
        c.season,
        c.run_group,

        c.empty_runs,
        c.empty_pct,

        c.ai_decision,
        c.ai_risk_level,
        c.ai_reason,
        c.autonomous_safe,
        c.generated_at,

        s.sport_name,
        s.total_pct,
        s.sport_readiness,
        s.recommended_focus,

        CASE

            WHEN c.ai_decision = 'POZASTAVIT'
                THEN 0

            WHEN c.ai_decision = 'POČKAT'
                THEN 25

            WHEN c.ai_decision = 'OPATRNÝ RETRY'
                THEN 75

            ELSE 50

        END

        +

        CASE

            WHEN s.recommended_focus = 'MEDIA_LAYER'
                THEN 25

            WHEN s.recommended_focus = 'PEOPLE_LAYER'
                THEN 20

            WHEN s.recommended_focus = 'ODDS_LAYER'
                THEN 15

            WHEN s.recommended_focus = 'CORE_HARVEST'
                THEN 5

            ELSE 0

        END

        -

        COALESCE(c.empty_runs,0) * 5

        AS brain_score

    FROM candidates c

    LEFT JOIN ops.v_sport_completion_dashboard_v2 s
        ON s.sport_code = c.sport_code

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            brain_score DESC,
            recommendation_rank ASC
    ) AS brain_rank,

    provider,
    sport_code,
    sport_name,

    entity,
    league_id,
    season,
    run_group,

    total_pct,
    sport_readiness,
    recommended_focus,

    ai_decision,
    ai_risk_level,
    autonomous_safe,

    empty_runs,
    empty_pct,

    brain_score,

    CASE

        WHEN brain_score >= 80
            THEN 'RUN'

        WHEN brain_score >= 50
            THEN 'RUN_WITH_CAUTION'

        WHEN brain_score >= 20
            THEN 'WAIT'

        ELSE 'HOLD'

    END AS brain_decision,

    ai_reason,

    generated_at

FROM brain

ORDER BY
    brain_rank;