/*
MATCHMATRIX SQL 23_3_K

PC2 MEDIA EXECUTION PLAN V1

CO TO JE:
- Operační plán třetí fáze PC2: MEDIA HISTORY.

K ČEMU TO JE:
- Převádí media audit na konkrétní pořadí práce.
- Odděluje READY zdroje, PARTIAL zdroje a LOW_VOLUME zdroje.
- Připravuje plán pro články, videa a thumbnaily.
- Odděluje budoucí media asset plán pro fotky hráčů, trenérů, týmů a stadionů.

KDE TO UVIDÍME:
- OPS Panel
- Media Command Center
- PC2 Dashboard
- Harvest Ready

JAK SE TO VYUŽIJE:
- Po CORE a PEOPLE historii.
- Nejprve se použijí READY zdroje.
- Potom se rozšíří PARTIAL zdroje.
- LOW_VOLUME zdroje půjdou do crawler review.
- Fotky hráčů/trenérů/stadionů půjdou do samostatné media asset fronty.

NAVAZUJE NA:
- 23_3_J_create_pc2_media_provider_audit_v1.sql

DALŠÍ KROK:
- 23_3_L_create_pc2_media_asset_plan_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_media_execution_plan_v1;

CREATE OR REPLACE VIEW ops.v_pc2_media_execution_plan_v1 AS

WITH planned AS (
    SELECT
        provider,
        source_name,
        source_type,
        content_type,
        total_articles,
        usable_articles,
        articles_with_thumbnail,
        video_articles,
        thumbnail_coverage_pct,
        video_coverage_pct,
        avg_quality_score,
        media_readiness_status,
        recommended_next_step,
        CASE
            WHEN media_readiness_status = 'READY' THEN 1
            WHEN media_readiness_status = 'PARTIAL' THEN 2
            WHEN media_readiness_status = 'LOW_VOLUME' THEN 3
            ELSE 4
        END AS media_priority,
        CASE
            WHEN content_type = 'article' THEN 1
            WHEN content_type = 'video' THEN 2
            ELSE 3
        END AS content_priority
    FROM ops.v_pc2_media_provider_audit_v1
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            media_priority,
            content_priority,
            total_articles DESC,
            provider,
            source_name
    ) AS execution_order,

    provider,
    source_name,
    source_type,
    content_type,

    total_articles,
    usable_articles,
    articles_with_thumbnail,
    video_articles,
    thumbnail_coverage_pct,
    video_coverage_pct,
    avg_quality_score,

    media_readiness_status,

    CASE
        WHEN media_readiness_status = 'READY'
            THEN 'RUN_MEDIA_HISTORY'

        WHEN media_readiness_status = 'PARTIAL'
            THEN 'EXPAND_SOURCE_VOLUME'

        WHEN media_readiness_status = 'LOW_VOLUME'
            THEN 'CRAWLER_REVIEW'

        ELSE
            'MANUAL_REVIEW'
    END AS execution_action,

    recommended_next_step,

    CASE
        WHEN media_readiness_status = 'READY'
            THEN 'PHASE_3_READY'

        WHEN media_readiness_status = 'PARTIAL'
            THEN 'PHASE_3_EXPAND'

        WHEN media_readiness_status = 'LOW_VOLUME'
            THEN 'PHASE_3_FIX_SOURCE'

        ELSE
            'PHASE_3_REVIEW'
    END AS pc2_media_phase,

    now() AS refreshed_at

FROM planned;