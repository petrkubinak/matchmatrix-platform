SELECT
    id,
    job_code,
    status,
    started_at,
    finished_at,
    message
FROM ops.job_runs
ORDER BY id DESC
LIMIT 10;

SELECT
    season,
    COUNT(*) AS matches
FROM public.matches
GROUP BY season
ORDER BY season DESC;

CREATE VIEW ops.api_football_coverage AS
SELECT
    l.name,
    COUNT(m.id) matches
FROM ops.ingest_targets t
JOIN public.leagues l
  ON l.ext_league_id::text = t.provider_league_id
LEFT JOIN public.matches m
  ON m.league_id = l.id
 AND m.ext_source='api_football'
WHERE t.provider='api_football'
GROUP BY l.name
ORDER BY matches DESC;