-- create_v_media_source_discovery_review_v1.sql
--
-- CO TO DĚLÁ:
-- Vytvoří přehled kandidátních media zdrojů pro kontrolu a schvalování.
--
-- KAM TO VEDE:
-- public.v_media_source_discovery_review
--
-- K ČEMU TO BUDE:
-- Admin/panel uvidí:
-- - které zdroje jsou approved
-- - které čekají pending
-- - jaký mají trust level
-- - jaké typy obsahu umí
-- - co je další akce
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Admin panel:
-- /admin/media/source-discovery
--
-- Budoucí workflow:
-- pending → approved → content_sources → ingest

DROP VIEW IF EXISTS public.v_media_source_discovery_review;

CREATE VIEW public.v_media_source_discovery_review AS
SELECT
    id,
    review_status,
    trust_level,
    discovery_score,

    sport_code,
    country_code,
    language_code,

    source_name,
    source_domain,
    source_url,
    source_type,

    primary_section_code,
    detected_sections,

    is_official_candidate,
    is_reachable,
    has_rss,
    has_sitemap,
    has_article_content,
    has_video_content,

    evidence_note,
    next_action,

    reviewed_by,
    reviewed_at,
    review_note,

    created_at,
    updated_at

FROM ops.media_source_discovery_candidates
ORDER BY
    CASE review_status
        WHEN 'pending' THEN 1
        WHEN 'approved' THEN 2
        WHEN 'rejected' THEN 3
        ELSE 4
    END,
    discovery_score DESC NULLS LAST,
    source_name;