-- create_v_media_sources_ready_for_ingest_v1.sql
--
-- CO TO DĚLÁ:
-- Vytvoří view všech schválených media zdrojů,
-- které jsou připravené pro ingest pipeline.
--
-- KAM TO VEDE:
-- public.v_media_sources_ready_for_ingest
--
-- K ČEMU TO BUDE:
-- Workers a ingest pipeline budou číst právě toto view.
--
-- Díky tomu:
-- - ingest nebude brát pending/rejected zdroje
-- - vše půjde přes approval workflow
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Automatické rozšiřování:
-- - článků
-- - videí
-- - highlights
-- - lokálních sportovních médií
--
-- Budoucnost:
-- automatický discovery worker
-- auto health checks
-- AI source recommendation

DROP VIEW IF EXISTS public.v_media_sources_ready_for_ingest;

CREATE VIEW public.v_media_sources_ready_for_ingest AS
SELECT
    id,
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
    trust_level,
    discovery_score,

    has_rss,
    has_sitemap,
    has_article_content,
    has_video_content,

    next_action,

    created_at,
    updated_at

FROM ops.media_source_discovery_candidates
WHERE review_status = 'approved'
  AND is_reachable = true
ORDER BY
    discovery_score DESC NULLS LAST,
    source_name;