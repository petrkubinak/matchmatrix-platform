-- =========================================================
-- MATCHMATRIX MEDIA SOURCE DISCOVERY TEMPLATE V1
-- =========================================================
--
-- CO TO DĚLÁ:
-- Tento script slouží pro ruční přidání nového media zdroje
-- do MEDIA SOURCE DISCOVERY systému.
--
-- Zdroj se NEPŘIDÁ přímo do ostrého ingestu.
-- Nejprve se uloží jako kandidát ke kontrole.
--
-- =========================================================
-- KAM TO VEDE:
-- ops.media_source_discovery_candidates
--
-- =========================================================
-- K ČEMU TO BUDE:
--
-- MatchMatrix bude umět:
--
-- ✔ rozšiřovat zdroje z celého světa
-- ✔ přidávat lokální sportovní weby
-- ✔ přidávat oficiální ligové zdroje
-- ✔ přidávat klubové zdroje
-- ✔ přidávat video/highlight weby
-- ✔ přidávat RSS / sitemap / custom scraper zdroje
--
-- Tento systém je základ pro:
--
-- DISCOVERY
-- → REVIEW
-- → APPROVAL
-- → INGEST
--
-- =========================================================
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- League page:
-- - články
-- - highlights
-- - live updates
--
-- Team page:
-- - klubové zprávy
-- - videa
-- - preview/recap
--
-- Player page:
-- - články o hráči
-- - highlights
-- - rozhovory
--
-- Homepage:
-- - personalized feed
-- - trending media
-- - global sport news
--
-- Mobilní aplikace:
-- - reels/highlights
-- - personalized sports feed
--
-- =========================================================
-- JAK TO FUNGUJE:
--
-- 1) Přidáme kandidátní zdroj
-- 2) Zdroj se zkontroluje
-- 3) review_status:
--    pending
--    approved
--    rejected
--
-- 4) Approved zdroje:
--    → public.content_sources
--    → ingest workers
--
-- =========================================================
-- DOPORUČENÉ source_type:
--
-- official_site
-- rss
-- sports_media
-- youtube
-- social
-- blog
-- federation
--
-- =========================================================
-- DOPORUČENÉ SECTION TYPES:
--
-- ARTICLE
-- VIDEO
-- LIVE
-- PHOTO
-- SOCIAL
-- PROFILE
-- ANALYSIS
-- OFFICIAL
--
-- =========================================================
-- PŘÍKLAD:
-- Sport.cz Fotbal
-- =========================================================

INSERT INTO ops.media_source_discovery_candidates (
    query_text,
    sport_code,
    country_code,
    language_code,

    source_name,
    source_url,
    source_domain,
    source_type,

    primary_section_code,
    detected_sections,

    is_official_candidate,
    trust_level,
    discovery_score,
    evidence_note,

    review_status,

    is_reachable,
    has_article_content,
    has_video_content,

    next_action
)
VALUES (
    'Sport.cz football news',

    'FB',
    'CZ',
    'cs',

    'Sport.cz Fotbal',
    'https://www.sport.cz/fotbal/',
    'sport.cz',
    'sports_media',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','LIVE'],

    false,
    'medium',
    70,

    'Czech sports media source for football.',

    'pending',

    true,
    true,
    true,

    'review_source'
)

ON CONFLICT (source_url)
DO NOTHING;


-- =========================================================
-- KONTROLA
-- =========================================================

SELECT
    review_status,
    source_name,
    source_domain,
    sport_code,
    source_type,
    primary_section_code,
    next_action
FROM ops.media_source_discovery_candidates
ORDER BY created_at DESC
LIMIT 20;