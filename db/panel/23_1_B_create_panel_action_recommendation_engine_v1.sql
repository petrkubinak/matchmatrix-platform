/*
MATCHMATRIX SQL 23_1_B

PANEL ACTION RECOMMENDATION ENGINE V1

CO TO JE:
- První AI doporučovací vrstva pro MatchMatrix Operační Centrum.

K ČEMU TO JE:
- Panel nebude pouze ukazovat stav.
- Panel navrhne další krok.
- Panel navrhne worker.
- Panel odhadne přínos.

KDE TO UVIDÍME:
- MatchMatrix Operační Centrum
- Dashboard
- Sport Completion
- Roadmap

JAK SE TO VYUŽIJE:
- Denní řízení projektu
- Prioritizace vývoje
- Návrh workerů
- Doporučení další akce
*/

DROP VIEW IF EXISTS ops.v_panel_action_recommendations_v1;

CREATE OR REPLACE VIEW ops.v_panel_action_recommendations_v1 AS

WITH completion AS (

    SELECT
        sport_code,
        sport_name,
        core_pct,
        people_pct,
        media_pct,
        odds_pct,
        total_pct,
        sport_readiness,
        top_priority_rank,
        recommended_focus,
        updated_at

    FROM ops.v_sport_completion_dashboard_v2
),

recommendations AS (

    SELECT

        sport_code,
        sport_name,

        CASE

            WHEN people_pct <= media_pct
             AND people_pct <= odds_pct
             AND people_pct <= core_pct
            THEN 'PEOPLE'

            WHEN media_pct <= odds_pct
             AND media_pct <= core_pct
            THEN 'MEDIA'

            WHEN odds_pct <= core_pct
            THEN 'ODDS'

            ELSE 'CORE'

        END AS weakest_layer,

        core_pct,
        people_pct,
        media_pct,
        odds_pct,
        total_pct,

        sport_readiness,
        top_priority_rank,
        recommended_focus,
        updated_at

    FROM completion
)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            total_pct ASC,
            top_priority_rank ASC NULLS LAST,
            sport_code
    ) AS recommendation_rank,

    sport_code,
    sport_name,

    weakest_layer,

    CASE

        WHEN weakest_layer = 'PEOPLE'
        THEN 'Chybí nebo jsou slabá data hráčů.'

        WHEN weakest_layer = 'MEDIA'
        THEN 'Chybí články, videa nebo mediální zdroje.'

        WHEN weakest_layer = 'ODDS'
        THEN 'Nízké pokrytí kurzů.'

        ELSE
        'Nedostatečné Core pokrytí.'
    END AS problem_description,

    CASE

        WHEN weakest_layer = 'PEOPLE'
        THEN 'Najít nebo rozšířit provider hráčů.'

        WHEN weakest_layer = 'MEDIA'
        THEN 'Rozšířit media ingest a zdroje.'

        WHEN weakest_layer = 'ODDS'
        THEN 'Rozšířit odds providery.'

        ELSE
        'Spustit Core ingest a backfill.'
    END AS recommended_action,

    CASE

        WHEN weakest_layer = 'PEOPLE'
        THEN lower(sport_name) || '_players_worker_v1.py'

        WHEN weakest_layer = 'MEDIA'
        THEN lower(sport_name) || '_media_expansion_worker_v1.py'

        WHEN weakest_layer = 'ODDS'
        THEN lower(sport_name) || '_odds_expansion_worker_v1.py'

        ELSE
        lower(sport_name) || '_core_backfill_worker_v1.py'

    END AS proposed_worker,

    CASE

        WHEN weakest_layer = 'PEOPLE' THEN '+4 %'
        WHEN weakest_layer = 'MEDIA'  THEN '+2 %'
        WHEN weakest_layer = 'ODDS'   THEN '+1 %'
        ELSE '+3 %'

    END AS estimated_project_gain,

    CASE

        WHEN total_pct < 25 THEN 'CRITICAL'
        WHEN total_pct < 50 THEN 'HIGH'
        WHEN total_pct < 75 THEN 'MEDIUM'
        ELSE 'LOW'

    END AS priority_level,

    total_pct,
    sport_readiness,
    recommended_focus,
    updated_at

FROM recommendations;