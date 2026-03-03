-- =========================
-- MATCHMATRIX DAILY STATUS
-- =========================

-- A) Providers + mapování lig
SELECT DISTINCT provider
FROM public.league_provider_map
ORDER BY 1;

SELECT provider, COUNT(*) AS league_count
FROM public.league_provider_map
GROUP BY provider
ORDER BY 2 DESC;

-- B) Aktivní ingest targets
SELECT provider, run_group, COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE enabled = true
GROUP BY provider, run_group
ORDER BY provider, run_group;

-- C) Job runy (poslední 30)
SELECT id, job_code, status, started_at, finished_at, COALESCE(message,'') AS message
FROM ops.job_runs
ORDER BY id DESC
LIMIT 30;

-- D) Import plan sezóny (aktivní)
SELECT provider, season, COUNT(*) AS cnt,
       SUM(CASE WHEN enabled THEN 1 ELSE 0 END) AS enabled_cnt
FROM ops.league_import_plan
GROUP BY provider, season
ORDER BY season DESC, provider;

-- E) Volitelné metriky – jen pokud tabulky existují
DO $$
BEGIN
  IF to_regclass('public.fixtures') IS NOT NULL THEN
    RAISE NOTICE 'fixtures: %',
      (SELECT json_agg(t) FROM (
        SELECT provider, COUNT(*) AS fixtures_cnt
        FROM public.fixtures
        GROUP BY provider
        ORDER BY 2 DESC
      ) t);
  ELSE
    RAISE NOTICE 'public.fixtures does not exist - skipping';
  END IF;

  IF to_regclass('public.teams') IS NOT NULL THEN
    RAISE NOTICE 'teams_total: %',
      (SELECT COUNT(*) FROM public.teams);
  ELSE
    RAISE NOTICE 'public.teams does not exist - skipping';
  END IF;
END $$;