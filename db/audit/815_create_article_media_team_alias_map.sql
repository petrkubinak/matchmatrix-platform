-- 815_create_article_media_team_alias_map.sql
-- ARTICLE -> MEDIA TEAM ALIAS MAP V1

CREATE TABLE IF NOT EXISTS public.article_media_team_alias_map (
    id BIGSERIAL PRIMARY KEY,
    article_id BIGINT NOT NULL REFERENCES public.articles(id),
    media_team_alias_rule_id BIGINT NOT NULL REFERENCES public.media_team_alias_rules(id),
    match_method TEXT NOT NULL DEFAULT 'url_slug',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_article_media_team_alias_map
ON public.article_media_team_alias_map (article_id, media_team_alias_rule_id);

INSERT INTO public.article_media_team_alias_map (
    article_id,
    media_team_alias_rule_id,
    match_method
)
SELECT DISTINCT
    a.id,
    r.id,
    'url_slug'
FROM public.articles a
JOIN public.media_team_alias_rules r
  ON r.is_active = true
 AND r.sport_code = 'HK'
 AND r.provider = 'nhl_official_site'
 AND lower(a.url) LIKE '%' || r.alias_slug || '%'
ON CONFLICT (article_id, media_team_alias_rule_id)
DO NOTHING;

-- kontrola
SELECT
    COUNT(*) AS article_media_team_alias_maps
FROM public.article_media_team_alias_map;

-- ukázky
SELECT
    a.id AS article_id,
    r.team_name,
    r.alias_slug,
    a.url
FROM public.article_media_team_alias_map m
JOIN public.articles a
  ON a.id = m.article_id
JOIN public.media_team_alias_rules r
  ON r.id = m.media_team_alias_rule_id
ORDER BY a.id DESC
LIMIT 30;