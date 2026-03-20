ROLLBACK;
BEGIN;

-- =========================================================
-- 152_seed_fb_eu_run_group.sql
-- Označení evropských football targetů do vrstvy FB_EU
-- TOP ligy zůstávají ve FOOTBALL_MAINTENANCE_TOP
-- =========================================================

UPDATE ops.ingest_targets t
SET run_group = 'FB_EU'
FROM public.leagues l
JOIN public.countries c
  ON c.id = l.country_id
WHERE t.sport_code = 'FB'
  AND t.canonical_league_id = l.id
  AND c.continent_code = 'EU'
  AND COALESCE(t.run_group, '') NOT IN ('FOOTBALL_MAINTENANCE_TOP', 'FB_EU');

COMMIT;

-- kontrola
SELECT
    t.run_group,
    COUNT(*) AS cnt
FROM ops.ingest_targets t
WHERE t.sport_code = 'FB'
GROUP BY t.run_group
ORDER BY t.run_group;