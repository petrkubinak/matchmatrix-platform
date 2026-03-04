--kolik targetů se skutečně zpracovalo v run_id = 23
SELECT COUNT(*) AS rows_in_staging
FROM staging.api_football_fixtures
WHERE run_id = 23;

--kolik distinct fixture_id přišlo (bez duplicit
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT fixture_id) AS distinct_fixtures
FROM staging.api_football_fixtures
WHERE run_id = 23;

--kolik se mergnulo do canonical public.matches
SELECT COUNT(*) AS matches_2024_loaded
FROM public.matches
WHERE ext_source = 'api_football'
  AND season = '2024';

--Bonus (rychlá kontrola “pokrytí” všech 71 lig)
SELECT
  t.provider_league_id,
  t.notes,
  COUNT(f.fixture_id) AS fixtures_loaded
FROM ops.ingest_targets t
LEFT JOIN staging.api_football_fixtures f
  ON f.run_id = 23
 AND f.league_id = t.provider_league_id
 AND f.season = CAST(t.season AS int)
WHERE t.enabled = true
GROUP BY t.provider_league_id, t.notes
ORDER BY fixtures_loaded ASC, t.provider_league_id;

SELECT ext_source, COUNT(*)
FROM public.matches
WHERE season = '2024'
GROUP BY ext_source
ORDER BY COUNT(*) DESC;

SELECT
  COUNT(DISTINCT f.fixture_id) AS staging_distinct,
  COUNT(DISTINCT f.fixture_id) FILTER (WHERE m.id IS NOT NULL) AS in_matches
FROM staging.api_football_fixtures f
LEFT JOIN public.matches m
  ON m.ext_source = 'api_football'
 AND m.ext_match_id = f.fixture_id::text
WHERE f.run_id = 23;

BEGIN;

-- Rozděl pouze EU_exact_v1 (jen enabled)
UPDATE ops.ingest_targets
SET run_group = 'EU_exact_v1_' || (abs(hashtext(provider_league_id)) % 4)::text
WHERE enabled = true
  AND run_group = 'EU_exact_v1';

COMMIT;

--Ověření počtů v bucketech
SELECT run_group, COUNT(*)
FROM ops.ingest_targets
WHERE enabled = true
  AND run_group LIKE 'EU_exact_v1_%'
GROUP BY run_group
ORDER BY run_group;

--vypsat obsah bucketu, který chceš použít (např. _2)
SELECT provider_league_id, notes, tier
FROM ops.ingest_targets
WHERE enabled = true
  AND run_group = 'EU_exact_v1_2'
ORDER BY tier, provider_league_id::int;


--Teď jen přepnout season na 2023 pro těch 29 lig
BEGIN;

UPDATE ops.ingest_targets
SET season = '2023'
WHERE enabled = true
  AND run_group IN (
        'EU_top',
        'EU_major_v4_A',
        'EU_exact_v1_2'
  );

COMMIT;

