-- 825_cleanup_cross_source_media_alias_map.sql
-- Cleanup cross-source bad media alias mappings

DELETE FROM public.article_media_team_alias_map m
USING public.articles a,
      public.content_sources cs,
      public.media_team_alias_rules r
WHERE m.article_id = a.id
  AND a.content_source_id = cs.id
  AND m.media_team_alias_rule_id = r.id
  AND cs.name = 'NHL'
  AND r.provider = 'nba_official_site';

-- kontrola
SELECT
    COUNT(*) AS bad_cross_source_maps_left
FROM public.article_media_team_alias_map m
JOIN public.articles a
  ON a.id = m.article_id
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
JOIN public.media_team_alias_rules r
  ON r.id = m.media_team_alias_rule_id
WHERE cs.name = 'NHL'
  AND r.provider = 'nba_official_site';