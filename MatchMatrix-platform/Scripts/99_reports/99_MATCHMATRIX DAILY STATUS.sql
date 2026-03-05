-- =========================
-- MATCHMATRIX DAILY STATUS
-- =========================

-- A) Základ: providery + mapování lig
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

-- E) Rychlé sanity: fixtures / teams (pokud tabulky existují)
-- Pokud by ti to padalo na "relation does not exist", tyhle dva bloky zakomentuj.
SELECT provider, COUNT(*) AS fixtures_cnt
FROM public.fixtures
GROUP BY provider
ORDER BY 2 DESC;

SELECT COUNT(*) AS total_teams
FROM public.teams;