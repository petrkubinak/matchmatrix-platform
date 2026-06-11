/*
MATCHMATRIX SQL 19_2_I
Sport Coverage Harvest Planner V1

CO TO JE:
- Planner, který určuje další harvest vrstvu podle skutečného pokrytí sportu.
- Navazuje na Sport Completion a People Pipeline.

K ČEMU TO JE:
- Aby harvest běžel správně:
  CORE -> PEOPLE -> MEDIA -> CONTEXT
- Aby se nestahovala People/Media vrstva bez navázaného Core základu.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Harvest Readiness
- Provider Command Center
- Sport Completion

JAK SE TO VYUŽIJE:
- PC2 bude spouštět pouze smysluplné harvest joby.
*/

CREATE OR REPLACE VIEW ops.v_sport_coverage_harvest_planner_v1 AS
WITH sc AS (
    SELECT
        to_jsonb(x) AS j
    FROM ops.v_sport_completion_dashboard_v2 x
),
pp AS (
    SELECT
        to_jsonb(x) AS j
    FROM ops.v_people_pipeline_summary_v1 x
),
base AS (
    SELECT
        COALESCE(sc.j->>'sport_code', sc.j->>'code') AS sport_code,
        COALESCE(sc.j->>'sport_name', sc.j->>'name') AS sport_name,

        COALESCE((sc.j->>'core_completion_pct')::numeric, (sc.j->>'core_pct')::numeric, 0) AS core_pct,
        COALESCE((sc.j->>'people_completion_pct')::numeric, (sc.j->>'people_pct')::numeric, 0) AS sport_people_pct,
        COALESCE((sc.j->>'media_completion_pct')::numeric, (sc.j->>'media_pct')::numeric, 0) AS media_pct,
        COALESCE((sc.j->>'odds_completion_pct')::numeric, (sc.j->>'odds_pct')::numeric, 0) AS odds_pct,
        COALESCE((sc.j->>'overall_completion_pct')::numeric, (sc.j->>'total_completion_pct')::numeric, 0) AS total_pct,

        COALESCE(sc.j->>'readiness_status', sc.j->>'status', 'UNKNOWN') AS readiness_status,
        COALESCE((sc.j->>'priority_rank')::int, (sc.j->>'priority')::int, 999) AS priority_rank,
        COALESCE(sc.j->>'next_focus', sc.j->>'recommended_next_layer', 'UNKNOWN') AS current_next_focus
    FROM sc
),
people AS (
    SELECT
        COALESCE(pp.j->>'sport_code', pp.j->>'code') AS sport_code,
        COALESCE((pp.j->>'people_completion_pct')::numeric, (pp.j->>'completion_pct')::numeric, 0) AS people_pipeline_pct,
        COALESCE(pp.j->>'people_status', pp.j->>'status', 'UNKNOWN') AS people_pipeline_status
    FROM pp
)
SELECT
    b.sport_code,
    b.sport_name,

    b.core_pct,
    GREATEST(b.sport_people_pct, COALESCE(p.people_pipeline_pct,0)) AS people_pct,
    b.media_pct,
    b.odds_pct,
    b.total_pct,

    b.readiness_status,
    COALESCE(p.people_pipeline_status, 'UNKNOWN') AS people_pipeline_status,

    CASE
        WHEN b.core_pct < 90 THEN 'CORE'
        WHEN GREATEST(b.sport_people_pct, COALESCE(p.people_pipeline_pct,0)) < 80 THEN 'PEOPLE'
        WHEN b.media_pct < 60 THEN 'MEDIA'
        WHEN b.odds_pct < 60 THEN 'ODDS'
        ELSE 'CONTEXT'
    END AS next_harvest_layer,

    CASE
        WHEN b.core_pct < 90 THEN 'Doplnit Core: leagues, teams, matches.'
        WHEN GREATEST(b.sport_people_pct, COALESCE(p.people_pipeline_pct,0)) < 80 THEN 'Doplnit People podle staženého Core.'
        WHEN b.media_pct < 60 THEN 'Doplnit Media podle Core + People vazeb.'
        WHEN b.odds_pct < 60 THEN 'Doplnit Odds podle existujících matches.'
        ELSE 'Sport je připraven pro Context Engine.'
    END AS next_action_cs,

    CASE
        WHEN b.core_pct < 90 THEN 1
        WHEN GREATEST(b.sport_people_pct, COALESCE(p.people_pipeline_pct,0)) < 80 THEN 2
        WHEN b.media_pct < 60 THEN 3
        WHEN b.odds_pct < 60 THEN 4
        ELSE 5
    END AS harvest_priority,

    b.priority_rank

FROM base b
LEFT JOIN people p
    ON p.sport_code = b.sport_code
ORDER BY
    harvest_priority,
    priority_rank,
    sport_code;


CREATE OR REPLACE VIEW ops.v_sport_coverage_harvest_summary_v1 AS
SELECT
    next_harvest_layer,
    COUNT(*) AS sports_count
FROM ops.v_sport_coverage_harvest_planner_v1
GROUP BY next_harvest_layer
ORDER BY
    MIN(harvest_priority);


CREATE OR REPLACE VIEW ops.v_pc2_dependency_harvest_queue_v1 AS
SELECT
    sport_code,
    sport_name,
    next_harvest_layer,
    harvest_priority,
    core_pct,
    people_pct,
    media_pct,
    odds_pct,
    total_pct,
    next_action_cs
FROM ops.v_sport_coverage_harvest_planner_v1
ORDER BY
    harvest_priority,
    priority_rank,
    sport_code;


SELECT *
FROM ops.v_sport_coverage_harvest_summary_v1;