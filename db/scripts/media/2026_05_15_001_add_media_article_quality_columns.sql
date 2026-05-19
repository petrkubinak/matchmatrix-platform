-- MATCHMATRIX MEDIA QUALITY FILTER V1
-- KROK 1: rozšíření staging.stg_media_articles o quality/filter sloupce

ALTER TABLE staging.stg_media_articles
ADD COLUMN IF NOT EXISTS article_quality_score integer,
ADD COLUMN IF NOT EXISTS article_quality_reason text,
ADD COLUMN IF NOT EXISTS is_filtered boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS filter_reason text;

COMMENT ON COLUMN staging.stg_media_articles.article_quality_score
IS 'MEDIA quality score 0-100. Vyšší = kvalitnější článek pro public/articles feed.';

COMMENT ON COLUMN staging.stg_media_articles.article_quality_reason
IS 'Textové vysvětlení, proč článek dostal dané quality score.';

COMMENT ON COLUMN staging.stg_media_articles.is_filtered
IS 'TRUE = článek nemá být mergován do public.articles. Data ve staging zůstávají zachovaná.';

COMMENT ON COLUMN staging.stg_media_articles.filter_reason
IS 'Důvod filtrování článku, např. category_page, fantasy, newsletter, pressroom, generic_hub.';