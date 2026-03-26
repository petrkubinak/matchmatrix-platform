-- 040_unify_multisport_planner_teams_fixtures.sql
-- Cíl:
-- 1) doplnit chybějící BK teams planner joby z ingest_targets
-- 2) sjednotit základní priority teams/fixtures pro VB/HK/BK
-- 3) ponechat ručně zvýhodněné funkční targety beze změny

-- =========================================================
-- 1) DOPLNĚNÍ BK TEAMS Z ingest_targets
-- =========================================================
INSERT INTO ops.ingest_planner
(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    created_at,
    updated_at
)
SELECT
    t.provider,
    t.sport_code,
    'teams' AS entity,
    t.provider_league_id,
    t.season,
    'pending' AS status,
    0 AS attempts,
    2020 AS priority,
    t.run_group,
    now(),
    now()
FROM ops.ingest_targets t
WHERE t.provider = 'api_sport'
  AND t.sport_code = 'BK'
  AND t.run_group = 'BK_TOP'
  AND COALESCE(t.enabled, true) = true
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = 'teams'
        AND p.provider_league_id = t.provider_league_id
        AND COALESCE(p.season, '') = COALESCE(t.season, '')
        AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
  );

-- =========================================================
-- 2) SJEDNOCENÍ PRIORIT PRO VB
-- =========================================================
UPDATE ops.ingest_planner
SET
    priority = 20,
    updated_at = now()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'teams'
  AND run_group = 'VB_CORE'
  AND priority <> 20;

UPDATE ops.ingest_planner
SET
    priority = 30,
    updated_at = now()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'fixtures'
  AND run_group = 'VB_CORE'
  AND priority <> 30;

-- =========================================================
-- 3) SJEDNOCENÍ PRIORIT PRO HK
-- základní priority necháme 2020 / 2030,
-- ale NEPŘEPISUJEME ručně zvýhodněné funkční targety 1000 / 1010 / 5000
-- =========================================================
UPDATE ops.ingest_planner
SET
    priority = 2020,
    updated_at = now()
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'teams'
  AND run_group = 'HK_TOP'
  AND priority NOT IN (1000, 5000);

UPDATE ops.ingest_planner
SET
    priority = 2030,
    updated_at = now()
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures'
  AND run_group = 'HK_TOP'
  AND priority NOT IN (1010, 5000);

-- =========================================================
-- 4) SJEDNOCENÍ PRIORIT PRO BK
-- standard teams/fixtures, ale nepřepisovat už zvýhodněný 117/2023-2024 a odsunutý 40
-- =========================================================
UPDATE ops.ingest_planner
SET
    priority = 2020,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
  AND run_group = 'BK_TOP'
  AND priority <> 2020;

UPDATE ops.ingest_planner
SET
    priority = 2030,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
  AND run_group = 'BK_TOP'
  AND priority NOT IN (1010, 5000);

-- =========================================================
-- 5) KONTROLA
-- =========================================================
SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS cnt
FROM ops.ingest_planner
WHERE
    (provider = 'api_volleyball' AND sport_code = 'VB')
    OR (provider = 'api_hockey' AND sport_code = 'HK')
    OR (provider = 'api_sport' AND sport_code = 'BK')
GROUP BY
    provider,
    sport_code,
    entity,
    run_group,
    status
ORDER BY
    provider,
    sport_code,
    entity,
    run_group,
    status;

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    updated_at
FROM ops.ingest_planner
WHERE
    (provider = 'api_volleyball' AND sport_code = 'VB')
    OR (provider = 'api_hockey' AND sport_code = 'HK')
    OR (provider = 'api_sport' AND sport_code = 'BK')
ORDER BY
    provider,
    sport_code,
    entity,
    priority,
    id
LIMIT 250;