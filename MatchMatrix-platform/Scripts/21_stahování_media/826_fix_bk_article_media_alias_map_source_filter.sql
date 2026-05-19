-- 826_fix_bk_article_media_alias_map_source_filter.sql
-- Rebuild BK alias map with strict source filter

DELETE FROM public.article_media_team_alias_map m
USING public.media_team_alias_rules r
WHERE r.id = m.media_team_alias_rule_id
  AND r.sport_code = 'BK';

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
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
JOIN public.media_team_alias_rules r
  ON r.is_active = true
 AND r.sport_code = 'BK'
 AND r.provider = 'nba_official_site'
 AND cs.name = 'NBA'
 AND cs.source_type = 'official_site'
 AND lower(a.url) LIKE '%' || lower(r.alias_slug) || '%'
ON CONFLICT (article_id, media_team_alias_rule_id)
DO NOTHING;

-- kontrola
SELECT
    COUNT(*) AS bk_article_media_alias_maps
FROM public.article_media_team_alias_map m
JOIN public.media_team_alias_rules r
  ON r.id = m.media_team_alias_rule_id
WHERE r.sport_code = 'BK';

-- kontrola cross-source
SELECT
    COUNT(*) AS bad_cross_source_maps
FROM public.article_media_team_alias_map m
JOIN public.articles a
  ON a.id = m.article_id
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
JOIN public.media_team_alias_rules r
  ON r.id = m.media_team_alias_rule_id
WHERE cs.name <> 'NBA'
  AND r.provider = 'nba_official_site';