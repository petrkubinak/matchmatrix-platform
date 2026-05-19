ALTER TABLE staging.stg_media_articles
ADD COLUMN IF NOT EXISTS content_type text DEFAULT 'article';