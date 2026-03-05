-- 1) kolik mapování máš pro api_football
SELECT COUNT(*) 
FROM public.league_provider_map
WHERE provider = 'api_football';

-- 2) kolik ingest targets je zapnuto pro api_football
SELECT COUNT(*)
FROM ops.ingest_targets
WHERE provider='api_football' AND enabled=true;

-- 3) import plan pro api_football (kolik řádků)
SELECT COUNT(*)
FROM ops.league_import_plan
WHERE provider='api_football';

SELECT *
FROM public.league_provider_map
WHERE provider='api_football'
ORDER BY updated_at DESC
LIMIT 50;

SELECT provider, COUNT(*)
FROM ops.ingest_targets
WHERE provider='api_football'
  AND enabled=true
GROUP BY provider;

SELECT DISTINCT run_group
FROM ops.ingest_targets
WHERE provider='api_football' AND enabled=true
ORDER BY 1;

