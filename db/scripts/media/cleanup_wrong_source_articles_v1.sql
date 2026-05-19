-- cleanup_wrong_source_articles_v1.sql
--
-- CO TO DĚLÁ:
-- Označí špatně zařazené články:
-- například source_name = NBA,
-- ale URL vede na nhl.com.
--
-- NIC NEMAŽE.
-- Jen:
-- - vypne feed eligibility
-- - sníží quality score
-- - přidá quality_reason
--
-- KAM TO VEDE:
-- public.articles
-- staging.stg_media_articles
--
-- K ČEMU TO BUDE:
-- Vyčistí homepage feed a video feed.
-- Zabrání zobrazování NHL článků jako NBA obsahu.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Čistý homepage feed
-- Správné ligové feedy
-- Lepší doporučování obsahu
-- Správné trending výpočty

-- ============================================
-- STAGING
-- ============================================

UPDATE staging.stg_media_articles
SET
    article_quality_score = 0,
    article_quality_reason =
        COALESCE(article_quality_reason, '') ||
        ' | source_url_mismatch',
    updated_at = now()
WHERE lower(source_name) = 'nba'
  AND lower(url) LIKE '%nhl.com%';


-- ============================================
-- PUBLIC
-- ============================================

UPDATE public.articles a
SET
    is_feed_eligible = false,
    article_quality_score = 0,
    article_quality_reason =
        COALESCE(article_quality_reason, '') ||
        ' | source_url_mismatch',
    updated_at = now()
FROM public.content_sources cs
WHERE cs.id = a.content_source_id
  AND lower(cs.name) = 'nba'
  AND lower(a.url) LIKE '%nhl.com%';


-- ============================================
-- KONTROLA
-- ============================================

SELECT
    COUNT(*) AS cleaned_articles
FROM public.articles a
JOIN public.content_sources cs
    ON cs.id = a.content_source_id
WHERE lower(cs.name) = 'nba'
  AND lower(a.url) LIKE '%nhl.com%'
  AND is_feed_eligible = false;