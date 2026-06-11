/*
MATCHMATRIX SQL 23_3_J

PC2 MEDIA PROVIDER AUDIT V1

CO TO JE:
- Audit připravenosti MEDIA vrstvy pro PC2.
- Pracuje podle skutečné struktury staging.stg_media_articles.

K ČEMU TO JE:
- Zjistit, které media zdroje už máme.
- Zjistit, zda zdroje dávají články, thumbnail obrázky a videa.
- Připravit PHASE_3_MEDIA_HISTORY po CORE a PEOPLE historii.

KDE TO UVIDÍME:
- OPS Panel
- Media Command Center
- PC2 Dashboard
- Harvest Ready

JAK SE TO VYUŽIJE:
- Pro články.
- Pro videa.
- Pro thumbnail/foto zdroje.
- Později pro player/team/stadium media enrichment.

NAVAZUJE NA:
- 23_3_H_create_pc2_phase2_people_harvest_queue_v1.sql
- 23_3_I_create_pc2_phase2_people_execution_plan_v1.sql

DALŠÍ KROK:
- 23_3_K_create_pc2_media_execution_plan_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_media_provider_audit_v1;

CREATE OR REPLACE VIEW ops.v_pc2_media_provider_audit_v1 AS

SELECT
    provider,
    source_name,
    source_type,
    content_type,

    COUNT(*) AS total_articles,

    COUNT(*) FILTER (
        WHERE is_filtered = false
           OR is_filtered IS NULL
    ) AS usable_articles,

    COUNT(*) FILTER (
        WHERE thumbnail_url IS NOT NULL
          AND thumbnail_url <> ''
    ) AS articles_with_thumbnail,

    COUNT(*) FILTER (
        WHERE is_video = true
           OR video_url IS NOT NULL
    ) AS video_articles,

    COUNT(*) FILTER (
        WHERE article_quality_score >= 70
    ) AS high_quality_articles,

    MIN(published_at) AS oldest_article_at,
    MAX(published_at) AS newest_article_at,

    MIN(created_at) AS first_seen_at,
    MAX(updated_at) AS last_updated_at,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE thumbnail_url IS NOT NULL
              AND thumbnail_url <> ''
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS thumbnail_coverage_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_video = true
               OR video_url IS NOT NULL
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS video_coverage_pct,

    ROUND(
        AVG(article_quality_score)::numeric,
        2
    ) AS avg_quality_score,

    CASE
        WHEN COUNT(*) >= 100
         AND COUNT(*) FILTER (
                WHERE thumbnail_url IS NOT NULL
                  AND thumbnail_url <> ''
             ) >= 20
            THEN 'READY'

        WHEN COUNT(*) >= 20
            THEN 'PARTIAL'

        WHEN COUNT(*) > 0
            THEN 'LOW_VOLUME'

        ELSE 'EMPTY'
    END AS media_readiness_status,

    CASE
        WHEN COUNT(*) >= 100
         AND COUNT(*) FILTER (
                WHERE thumbnail_url IS NOT NULL
                  AND thumbnail_url <> ''
             ) >= 20
            THEN 'Lze použít jako media zdroj pro PC2.'

        WHEN COUNT(*) >= 20
            THEN 'Zdroj existuje, ale je potřeba rozšířit objem nebo thumbnail coverage.'

        WHEN COUNT(*) > 0
            THEN 'Nízký objem, vhodné pouze jako doplňkový zdroj.'

        ELSE 'Bez dat.'
    END AS recommended_next_step,

    now() AS refreshed_at

FROM staging.stg_media_articles

GROUP BY
    provider,
    source_name,
    source_type,
    content_type;