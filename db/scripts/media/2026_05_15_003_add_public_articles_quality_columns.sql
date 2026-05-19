ALTER TABLE public.articles
ADD COLUMN IF NOT EXISTS article_quality_score integer,
ADD COLUMN IF NOT EXISTS article_quality_reason text;

COMMENT ON COLUMN public.articles.article_quality_score
IS 'Canonical media quality score 0-100.';

COMMENT ON COLUMN public.articles.article_quality_reason
IS 'Canonical explanation of article quality scoring.';