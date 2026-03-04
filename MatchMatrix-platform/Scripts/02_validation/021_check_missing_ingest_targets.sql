-- 02_validation/021_check_missing_ingest_targets.sql
SELECT
  l.id   AS league_id,
  l.name AS league_name,
  c.name AS country,
  sp.code AS sport,
  lpm.provider,
  lpm.provider_league_id
FROM public.leagues l
JOIN public.sports sp ON sp.id = l.sport_id
LEFT JOIN public.countries c ON c.id = l.country_id
JOIN public.league_provider_map lpm
  ON lpm.league_id = l.id
 AND lpm.provider = 'api_football'
LEFT JOIN ops.ingest_targets it
  ON it.canonical_league_id = l.id
 AND it.provider = 'api_football'
WHERE sp.code = 'football'
  AND it.id IS NULL
ORDER BY c.name, l.name;