-- 901_create_stg_media_articles_v1.sql
-- MEDIA / ARTICLES staging tabulka

CREATE TABLE IF NOT EXISTS staging.stg_media_articles (
    id bigserial PRIMARY KEY,

    provider text NOT NULL,
    source_name text NOT NULL,
    source_type text NOT NULL DEFAULT 'rss',

    title text NOT NULL,
    url text NOT NULL,
    summary text NULL,
    raw_text text NULL,
    raw_html text NULL,

    author_name text NULL,
    published_at timestamptz NULL,
    language_code text NULL,
    country_code text NULL,

    external_article_id text NULL,
    payload_json jsonb NULL,
    payload_hash text NULL,

    parse_status text NOT NULL DEFAULT 'pending',
    parse_message text NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_media_articles_provider_url
ON staging.stg_media_articles (provider, url);