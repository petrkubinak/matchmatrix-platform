-- ==================================
-- MATCHMATRIX WEEKLY DEEP DIAGNOSTICS
-- ==================================

-- 1) Duplicitní mapování (pokud by se někde rozbilo)
SELECT provider, provider_league_id, COUNT(*) AS cnt
FROM public.league_provider_map
GROUP BY provider, provider_league_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- 2) Ingest targets bez canonical league (nemělo by nastat)
SELECT t.*
FROM ops.ingest_targets t
LEFT JOIN public.leagues l ON l.id = t.canonical_league_id
WHERE t.enabled = true
  AND l.id IS NULL
ORDER BY t.provider, t.run_group
LIMIT 200;

-- 3) Poslední chyby v job_runs
SELECT id, job_code, status, started_at, finished_at, COALESCE(message,'') AS message
FROM ops.job_runs
WHERE status NOT IN ('SUCCESS','OK')
ORDER BY id DESC
LIMIT 100;

-- 4) Přehled největších run_groupů
SELECT provider, run_group, COUNT(*) AS cnt,
       SUM(CASE WHEN enabled THEN 1 ELSE 0 END) AS enabled_cnt
FROM ops.ingest_targets
GROUP BY provider, run_group
ORDER BY cnt DESC;

-- 5) Import plan: disabled položky (ať víš, co je mimo ingest)
SELECT provider, season, COUNT(*) AS disabled_cnt
FROM ops.league_import_plan
WHERE enabled = false
GROUP BY provider, season
ORDER BY season DESC, provider;