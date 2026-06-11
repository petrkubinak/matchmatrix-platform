/*
MATCHMATRIX SQL 19_2_K
PC2 Master Harvest Roadmap V1

CO TO JE:
- Master roadmapa pro PC2 harvest.
- Spojuje Sport Coverage Planner + Detail Harvest Queue + Missing Provider Matrix.

K ČEMU TO JE:
- Jedno hlavní místo, kde uvidíme:
  SPORT
  NEXT HARVEST LAYER
  CORE %
  PEOPLE %
  MEDIA %
  ODDS %
  PROVIDER GAPY
  PHOTO/LOGO STAV
  PRIORITU
  DALŠÍ AKCI

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center
- Harvest Readiness Dashboard
- Provider Command Center

JAK SE TO VYUŽIJE:
- PC2 nebude stahovat naslepo.
- Harvest půjde podle pořadí CORE -> PEOPLE -> MEDIA -> ODDS -> CONTEXT.
- Roadmapa určí další sport/vrstvu/provider.
*/

-- =====================================================
-- 1) MASTER ROADMAP VIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_master_harvest_roadmap_v1 AS
WITH provider_gaps AS (
    SELECT
        sport_code,

        COUNT(*) AS provider_gap_total,

        COUNT(*) FILTER (
            WHERE current_status = 'MISSING'
        ) AS provider_missing_count,

        COUNT(*) FILTER (
            WHERE current_status = 'RESEARCH_REQUIRED'
        ) AS provider_research_required_count,

        COUNT(*) FILTER (
            WHERE current_status = 'PARTIAL'
        ) AS provider_partial_count,

        COUNT(*) FILTER (
            WHERE access_type = 'FREE'
        ) AS free_provider_candidates,

        COUNT(*) FILTER (
            WHERE access_type = 'LIMITED_FREE'
        ) AS limited_free_provider_candidates,

        COUNT(*) FILTER (
            WHERE access_type = 'PAID'
        ) AS paid_provider_candidates

    FROM ops.provider_missing_matrix
    GROUP BY sport_code
),
photo_readiness AS (
    SELECT
        sport_code,

        COUNT(*) AS photo_rows,

        COUNT(*) FILTER (
            WHERE pc2_status = 'LICENSE_REVIEW'
        ) AS photo_license_review_count,

        COUNT(*) FILTER (
            WHERE pc2_status = 'WAIT_FOR_PAID'
        ) AS photo_wait_for_paid_count

    FROM ops.v_pc2_photo_harvest_readiness_v1
    GROUP BY sport_code
)
SELECT
    q.sport_code,
    q.sport_name,

    q.next_harvest_layer,
    q.execution_bucket,
    q.harvest_priority,

    q.core_pct,
    q.people_pct,
    q.media_pct,
    q.odds_pct,
    q.total_pct,

    COALESCE(pg.provider_gap_total, 0) AS provider_gap_total,
    COALESCE(pg.provider_missing_count, 0) AS provider_missing_count,
    COALESCE(pg.provider_research_required_count, 0) AS provider_research_required_count,
    COALESCE(pg.provider_partial_count, 0) AS provider_partial_count,

    COALESCE(pg.free_provider_candidates, 0) AS free_provider_candidates,
    COALESCE(pg.limited_free_provider_candidates, 0) AS limited_free_provider_candidates,
    COALESCE(pg.paid_provider_candidates, 0) AS paid_provider_candidates,

    COALESCE(pr.photo_rows, 0) AS photo_rows,
    COALESCE(pr.photo_license_review_count, 0) AS photo_license_review_count,
    COALESCE(pr.photo_wait_for_paid_count, 0) AS photo_wait_for_paid_count,

    q.dependency_rule,

    CASE
        WHEN q.next_harvest_layer = 'CORE'
            THEN 'CORE_FIRST'

        WHEN q.next_harvest_layer = 'PEOPLE'
            THEN 'PEOPLE_AFTER_CORE'

        WHEN q.next_harvest_layer = 'MEDIA'
            THEN 'MEDIA_AFTER_PEOPLE'

        WHEN q.next_harvest_layer = 'ODDS'
            THEN 'ODDS_AFTER_MATCHES'

        ELSE 'CONTEXT_READY'
    END AS roadmap_bucket,

    CASE
        WHEN q.next_harvest_layer = 'CORE'
            THEN 'Spustit CORE harvest/backfill: ligy, týmy, zápasy, tabulky.'

        WHEN q.next_harvest_layer = 'PEOPLE'
            THEN 'Spustit People harvest pouze pro existující CORE ligy/týmy/zápasy.'

        WHEN q.next_harvest_layer = 'MEDIA'
            THEN 'Spustit Media harvest podle existujících lig, týmů, hráčů a zápasů.'

        WHEN q.next_harvest_layer = 'ODDS'
            THEN 'Spustit Odds harvest pouze pro existující zápasy.'

        ELSE 'Připraveno pro Context Engine.'
    END AS pc2_next_action_cs,

    CASE
        WHEN q.next_harvest_layer = 'CORE'
            THEN 1

        WHEN q.next_harvest_layer = 'PEOPLE'
            THEN 2

        WHEN q.next_harvest_layer = 'MEDIA'
            THEN 3

        WHEN q.next_harvest_layer = 'ODDS'
            THEN 4

        ELSE 5
    END AS pc2_execution_order,

    now() AS generated_at

FROM ops.v_sport_detail_harvest_queue_v1 q
LEFT JOIN provider_gaps pg
    ON pg.sport_code = q.sport_code
LEFT JOIN photo_readiness pr
    ON pr.sport_code = q.sport_code
ORDER BY
    pc2_execution_order,
    q.harvest_priority,
    q.sport_code;


-- =====================================================
-- 2) MASTER SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_master_harvest_roadmap_summary_v1 AS
SELECT
    next_harvest_layer,
    roadmap_bucket,
    COUNT(*) AS sports_count,

    SUM(provider_gap_total) AS provider_gap_total,
    SUM(provider_missing_count) AS provider_missing_count,
    SUM(provider_research_required_count) AS provider_research_required_count,
    SUM(provider_partial_count) AS provider_partial_count,

    SUM(free_provider_candidates) AS free_provider_candidates,
    SUM(limited_free_provider_candidates) AS limited_free_provider_candidates,
    SUM(paid_provider_candidates) AS paid_provider_candidates,

    SUM(photo_license_review_count) AS photo_license_review_count,
    SUM(photo_wait_for_paid_count) AS photo_wait_for_paid_count

FROM ops.v_pc2_master_harvest_roadmap_v1
GROUP BY
    next_harvest_layer,
    roadmap_bucket
ORDER BY
    MIN(pc2_execution_order);


-- =====================================================
-- 3) NEXT ACTION QUEUE
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_master_next_action_queue_v1 AS
SELECT
    sport_code,
    sport_name,
    next_harvest_layer,
    roadmap_bucket,
    pc2_execution_order,
    harvest_priority,

    core_pct,
    people_pct,
    media_pct,
    odds_pct,
    total_pct,

    provider_gap_total,
    provider_missing_count,
    provider_research_required_count,
    paid_provider_candidates,

    photo_license_review_count,
    photo_wait_for_paid_count,

    dependency_rule,
    pc2_next_action_cs

FROM ops.v_pc2_master_harvest_roadmap_v1
ORDER BY
    pc2_execution_order,
    harvest_priority,
    sport_code;


-- =====================================================
-- 4) PANEL SUMMARY KPIs
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_master_harvest_kpi_v1 AS
SELECT
    COUNT(*) AS total_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'CORE'
    ) AS core_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'PEOPLE'
    ) AS people_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'MEDIA'
    ) AS media_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'ODDS'
    ) AS odds_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'CONTEXT'
    ) AS context_ready_sports,

    SUM(provider_gap_total) AS total_provider_gaps,

    SUM(photo_license_review_count) AS total_photo_license_review,

    SUM(photo_wait_for_paid_count) AS total_photo_wait_for_paid

FROM ops.v_pc2_master_harvest_roadmap_v1;


-- =====================================================
-- 5) QUICK CHECK
-- =====================================================

SELECT
    next_harvest_layer,
    roadmap_bucket,
    sports_count,
    provider_gap_total,
    photo_license_review_count,
    photo_wait_for_paid_count
FROM ops.v_pc2_master_harvest_roadmap_summary_v1
ORDER BY roadmap_bucket;