-- seed_media_source_discovery_candidates_v1.sql
--
-- CO TO DĚLÁ:
-- Vloží první testovací kandidátní media zdroje
-- pro automatický MEDIA DISCOVERY systém.
--
-- KAM TO VEDE:
-- ops.media_source_discovery_candidates
--
-- K ČEMU TO BUDE:
-- Otestujeme workflow:
--
-- DISCOVERY
-- → REVIEW
-- → APPROVAL
-- → CONTENT SOURCE
-- → INGEST
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Budoucí automatické rozšiřování:
-- - článků
-- - videí
-- - highlights
-- - lokálních zdrojů
-- - klubových zdrojů
-- - národních sportovních webů

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
    has_rss,
    has_sitemap,
    has_video_content,
    has_article_content,

    next_action
)
VALUES

-- =====================================================
-- OFFICIAL
-- =====================================================

(
    'NBA official news',
    'BK',
    'US',
    'en',

    'NBA Official',
    'https://www.nba.com/news',
    'nba.com',
    'official_site',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','LIVE','OFFICIAL'],

    true,
    'high',
    95,

    'Official NBA news and highlights source.',

    'approved',

    true,
    false,
    false,
    true,
    true,

    'expand_ingest'
),

(
    'NHL official news',
    'HK',
    'US',
    'en',

    'NHL Official',
    'https://www.nhl.com/news',
    'nhl.com',
    'official_site',

    'VIDEO',
    ARRAY['ARTICLE','VIDEO','OFFICIAL'],

    true,
    'high',
    95,

    'Official NHL media source.',

    'approved',

    true,
    false,
    false,
    true,
    true,

    'expand_ingest'
),

(
    'UEFA news',
    'FB',
    'EU',
    'en',

    'UEFA Official',
    'https://www.uefa.com/news-media/',
    'uefa.com',
    'official_site',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','OFFICIAL'],

    true,
    'high',
    90,

    'Official UEFA source.',

    'approved',

    true,
    false,
    false,
    true,
    true,

    'custom_scraper_needed'
),

-- =====================================================
-- TRUSTED MEDIA
-- =====================================================

(
    'ESPN NBA',
    'BK',
    'US',
    'en',

    'ESPN NBA',
    'https://www.espn.com/nba/',
    'espn.com',
    'sports_media',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','ANALYSIS','LIVE'],

    false,
    'high',
    90,

    'Major global sports media.',

    'pending',

    true,
    true,
    true,
    true,
    true,

    'rss_test'
),

(
    'The Athletic NBA',
    'BK',
    'US',
    'en',

    'The Athletic NBA',
    'https://www.nytimes.com/athletic/nba/',
    'nytimes.com',
    'sports_media',

    'ANALYSIS',
    ARRAY['ARTICLE','ANALYSIS'],

    false,
    'high',
    85,

    'Premium analysis source.',

    'pending',

    true,
    false,
    true,
    false,
    true,

    'paywall_check'
),

(
    'BBC Sport Football',
    'FB',
    'GB',
    'en',

    'BBC Sport Football',
    'https://www.bbc.com/sport/football',
    'bbc.com',
    'sports_media',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','LIVE'],

    false,
    'high',
    88,

    'Trusted football news source.',

    'pending',

    true,
    true,
    true,
    true,
    true,

    'rss_test'
),

(
    'Kicker Bundesliga',
    'FB',
    'DE',
    'de',

    'Kicker',
    'https://www.kicker.de/bundesliga',
    'kicker.de',
    'sports_media',

    'ARTICLE',
    ARRAY['ARTICLE','ANALYSIS','LIVE'],

    false,
    'high',
    82,

    'Major German football media.',

    'pending',

    true,
    false,
    true,
    false,
    true,

    'scraper_test'
),

(
    'Marca LaLiga',
    'FB',
    'ES',
    'es',

    'Marca',
    'https://www.marca.com/en/football/spanish-football.html',
    'marca.com',
    'sports_media',

    'ARTICLE',
    ARRAY['ARTICLE','VIDEO','LIVE'],

    false,
    'high',
    82,

    'Spanish football media.',

    'pending',

    true,
    false,
    true,
    true,
    true,

    'scraper_test'
)

ON CONFLICT (source_url)
DO NOTHING;


-- =====================================================
-- KONTROLA
-- =====================================================

SELECT
    review_status,
    COUNT(*) AS sources
FROM ops.media_source_discovery_candidates
GROUP BY review_status
ORDER BY review_status;