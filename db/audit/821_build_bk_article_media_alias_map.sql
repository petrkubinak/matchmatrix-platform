-- 821_build_bk_article_media_alias_map.sql
-- BK / NBA ARTICLE MEDIA ALIAS MAP

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
 AND r.sport_code = 'BK'
 AND r.provider = 'nba_official_site'
 AND lower(a.url) LIKE '%' || r.alias_slug || '%'
ON CONFLICT (article_id, media_team_alias_rule_id)
DO NOTHING;

-- kontrola
SELECT
    COUNT(*) AS bk_article_media_alias_maps
FROM public.article_media_team_alias_map m
JOIN public.media_team_alias_rules r
  ON r.id = m.media_team_alias_rule_id
WHERE r.sport_code = 'BK';

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
WHERE r.sport_code = 'BK'
ORDER BY a.id DESC
LIMIT 30;