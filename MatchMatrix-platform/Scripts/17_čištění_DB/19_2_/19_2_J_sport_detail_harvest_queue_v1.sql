/*
MATCHMATRIX SQL 19_2_J
Sport Detail Harvest Queue V1

CO TO JE:
- Detailní PC2 harvest fronta podle sportů a vrstev.
- Navazuje na 19_2_I Sport Coverage Harvest Planner.

K ČEMU TO JE:
- Abychom přesně viděli:
  SPORT
  NEXT LAYER
  CORE %
  PEOPLE %
  MEDIA %
  ODDS %
  PRIORITU
  DOPORUČENOU AKCI

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Harvest Readiness
- Harvest Command Center
- Sport Completion

JAK SE TO VYUŽIJE:
- PC2 nebude spouštět harvest naslepo.
- Nejdříve se doplní CORE.
- Potom PEOPLE podle CORE.
- Potom MEDIA podle CORE + PEOPLE.
- Potom ODDS podle existujících matches.
*/

-- =====================================================
-- 1) DETAIL FRONTY PRO PC2
-- =====================================================

CREATE OR REPLACE VIEW ops.v_sport_detail_harvest_queue_v1 AS
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

    CASE
        WHEN next_harvest_layer = 'CORE' THEN '1_CORE_FIRST'
        WHEN next_harvest_layer = 'PEOPLE' THEN '2_PEOPLE_AFTER_CORE'
        WHEN next_harvest_layer = 'MEDIA' THEN '3_MEDIA_AFTER_PEOPLE'
        WHEN next_harvest_layer = 'ODDS' THEN '4_ODDS_AFTER_MATCHES'
        ELSE '5_CONTEXT_READY'
    END AS execution_bucket,

    CASE
        WHEN next_harvest_layer = 'CORE'
            THEN 'Doplnit základní data: leagues, teams, matches, standings.'

        WHEN next_harvest_layer = 'PEOPLE'
            THEN 'Doplnit hráče, trenéry, profily a statistiky podle existující CORE vrstvy.'

        WHEN next_harvest_layer = 'MEDIA'
            THEN 'Doplnit články, media, fotky a loga podle existujících lig, týmů a hráčů.'

        WHEN next_harvest_layer = 'ODDS'
            THEN 'Doplnit kurzy podle existujících zápasů.'

        ELSE 'Sport je připraven na Match Context Engine.'
    END AS detailed_action_cs,

    CASE
        WHEN next_harvest_layer = 'CORE'
            THEN 'BLOCK_PEOPLE_MEDIA_UNTIL_CORE_READY'

        WHEN next_harvest_layer = 'PEOPLE'
            THEN 'ALLOW_PEOPLE_BLOCK_MEDIA_CONTEXT'

        WHEN next_harvest_layer = 'MEDIA'
            THEN 'ALLOW_MEDIA_BLOCK_CONTEXT'

        WHEN next_harvest_layer = 'ODDS'
            THEN 'ALLOW_ODDS_IF_MATCHES_EXIST'

        ELSE 'ALLOW_CONTEXT_ENGINE'
    END AS dependency_rule,

    CASE
        WHEN next_harvest_layer = 'CORE' THEN true
        ELSE false
    END AS core_required_now,

    CASE
        WHEN next_harvest_layer = 'PEOPLE' THEN true
        ELSE false
    END AS people_required_now,

    CASE
        WHEN next_harvest_layer = 'MEDIA' THEN true
        ELSE false
    END AS media_required_now,

    CASE
        WHEN next_harvest_layer = 'ODDS' THEN true
        ELSE false
    END AS odds_required_now,

    now() AS generated_at

FROM ops.v_sport_coverage_harvest_planner_v1
ORDER BY
    harvest_priority,
    sport_code;


-- =====================================================
-- 2) SUMMARY PODLE VRSTEV
-- =====================================================

CREATE OR REPLACE VIEW ops.v_sport_detail_harvest_queue_summary_v1 AS
SELECT
    next_harvest_layer,
    execution_bucket,
    COUNT(*) AS sports_count,
    MIN(core_pct) AS min_core_pct,
    MIN(people_pct) AS min_people_pct,
    MIN(media_pct) AS min_media_pct,
    MIN(odds_pct) AS min_odds_pct
FROM ops.v_sport_detail_harvest_queue_v1
GROUP BY
    next_harvest_layer,
    execution_bucket
ORDER BY
    execution_bucket;


-- =====================================================
-- 3) CORE QUEUE
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_core_harvest_queue_v1 AS
SELECT *
FROM ops.v_sport_detail_harvest_queue_v1
WHERE next_harvest_layer = 'CORE'
ORDER BY
    harvest_priority,
    sport_code;


-- =====================================================
-- 4) PEOPLE QUEUE
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_people_harvest_queue_v1 AS
SELECT *
FROM ops.v_sport_detail_harvest_queue_v1
WHERE next_harvest_layer = 'PEOPLE'
ORDER BY
    harvest_priority,
    sport_code;


-- =====================================================
-- 5) MEDIA QUEUE
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_media_harvest_queue_v1 AS
SELECT *
FROM ops.v_sport_detail_harvest_queue_v1
WHERE next_harvest_layer = 'MEDIA'
ORDER BY
    harvest_priority,
    sport_code;


-- =====================================================
-- 6) QUICK CHECK
-- =====================================================

SELECT
    next_harvest_layer,
    execution_bucket,
    sports_count
FROM ops.v_sport_detail_harvest_queue_summary_v1
ORDER BY execution_bucket;