SELECT
    l.name AS league_name,
    COUNT(DISTINCT m.season) AS seasons_loaded,
    MIN(m.season) AS first_season,
    MAX(m.season) AS last_season,
    COUNT(*) AS total_matches
FROM ops.ingest_targets t
JOIN public.leagues l
  ON l.id = t.canonical_league_id
LEFT JOIN public.matches m
  ON m.league_id = l.id
WHERE t.sport_code = 'FB'
  AND t.provider = 'football_data'
GROUP BY l.name
ORDER BY seasons_loaded DESC, total_matches DESC, league_name;