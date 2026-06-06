/*
===============================================================================
MATCHMATRIX SQL 117_F
MEDIA MATCH LINK AUDIT V1

CO TO JE:
- Auditní view článků, které ještě nejsou propojené na konkrétní zápas.

K ČEMU TO JE:
- Najít články vhodné pro doplnění public.article_match_map.
- Zjistit potenciál Media vrstvy pro napojení článků na zápasy.
- Identifikovat feed-ready články bez match linku.

KDE TO UVIDÍME:
- OPS Panel
- Mission Control
- Harvest Dashboard
- Media Audit
- Budoucí Admin Web

JAK SE TO VYUŽIJE:
- zvýšení MEDIA READY skóre
- article → match linking
- budoucí AI entity matcher
- homepage a match detail feed
- doporučení pro media worker

ZDROJ DAT:
- public.articles
- public.article_match_map

VÝSTUP:
- match_link_status
- age_days
- is_feed_eligible
- is_video
- quality_score
- article_quality_score
- candidate_priority

VLIV NA HARVEST:
- Přímý
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_media_match_link_audit_v1 AS
SELECT
    a.id AS article_id,
    a.content_source_id,
    a.title,
    a.url,
    a.published_at,
    a.language_code,
    a.content_type,
    a.is_video,
    a.video_url,
    a.thumbnail_url,
    a.is_feed_eligible,
    a.quality_score,
    a.article_quality_score,
    a.hot_score,
    a.velocity_score,
    a.entity_count,

    CASE
        WHEN am.article_id IS NULL THEN 'NOT_LINKED'
        ELSE 'LINKED'
    END AS match_link_status,

    CASE
        WHEN a.published_at IS NOT NULL
        THEN CURRENT_DATE - DATE(a.published_at)
        ELSE NULL
    END AS age_days,

    CASE
        WHEN am.article_id IS NULL
         AND COALESCE(a.is_feed_eligible, false) = true
         AND COALESCE(a.article_quality_score, 0) >= 70
        THEN 'HIGH'

        WHEN am.article_id IS NULL
         AND COALESCE(a.article_quality_score, 0) >= 50
        THEN 'MEDIUM'

        WHEN am.article_id IS NULL
        THEN 'LOW'

        ELSE 'LINKED'
    END AS candidate_priority

FROM public.articles a
LEFT JOIN public.article_match_map am
       ON am.article_id = a.id;