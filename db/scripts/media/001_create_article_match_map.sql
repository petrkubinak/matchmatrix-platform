CREATE TABLE IF NOT EXISTS public.article_match_map
(
    id bigserial PRIMARY KEY,

    article_id bigint NOT NULL,
    match_id bigint NOT NULL,

    created_at timestamptz DEFAULT NOW(),

    CONSTRAINT uq_article_match
        UNIQUE(article_id, match_id)
);

CREATE INDEX IF NOT EXISTS idx_article_match_map_article
ON public.article_match_map(article_id);

CREATE INDEX IF NOT EXISTS idx_article_match_map_match
ON public.article_match_map(match_id);