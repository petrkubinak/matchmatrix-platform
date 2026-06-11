/*
MATCHMATRIX SQL 19_3_I
PC2 Planner Job Seeder V1

CO TO JE:
- Vloží reálné joby do ops.ingest_planner pro PC2 frontu.

K ČEMU TO JE:
- PC2 tlačítko už spouští worker správně.
- Worker ale nenašel žádný job.
- Tento skript doplní joby pro run_group PC2_*.

KDE TO UVIDÍME:
- OPS Panel V18.17
- PC2 Command Center
- ops.v_ingest_planner_queue
- ops.ingest_planner

JAK SE TO VYUŽIJE:
- Panel spustí PC2 příkaz.
- run_ingest_planner_jobs.py najde job podle sport/entity/run_group.
- Worker zpracuje planner joby.
*/

INSERT INTO ops.ingest_planner
(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    created_at,
    updated_at
)
SELECT
    v.provider,
    v.sport_code,
    v.entity,
    v.provider_league_id,
    v.season,
    v.run_group,
    v.priority,
    'pending',
    0,
    now(),
    now(),
    now()
FROM (
    VALUES
    ('api_handball', 'HB', 'fixtures', NULL, '2024', 'PC2_CORE_HB', 10),
    ('api_handball', 'HB', 'fixtures', NULL, '2025', 'PC2_CORE_HB', 10),

    ('api_tennis', 'TN', 'fixtures', NULL, '2024', 'PC2_CORE_TN', 10),
    ('api_tennis', 'TN', 'fixtures', NULL, '2025', 'PC2_CORE_TN', 10),

    ('api_american_football', 'AFB', 'players', NULL, '2024', 'PC2_PEOPLE_AFB', 20),
    ('api_basketball', 'BK', 'players', NULL, '2024', 'PC2_PEOPLE_BK', 20),
    ('api_baseball', 'BSB', 'players', NULL, '2024', 'PC2_PEOPLE_BSB', 20),
    ('api_cricket', 'CK', 'players', NULL, '2024', 'PC2_PEOPLE_CK', 20),
    ('api_hockey', 'HK', 'players', NULL, '2024', 'PC2_PEOPLE_HK', 20),
    ('api_volleyball', 'VB', 'players', NULL, '2024', 'PC2_PEOPLE_VB', 20),

    ('official_site', 'FB', 'media', NULL, '2024', 'PC2_MEDIA_FB', 30)
) AS v(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority
)
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_planner p
    WHERE p.provider = v.provider
      AND p.sport_code = v.sport_code
      AND p.entity = v.entity
      AND COALESCE(p.provider_league_id, '') = COALESCE(v.provider_league_id, '')
      AND COALESCE(p.season, '') = COALESCE(v.season, '')
      AND p.run_group = v.run_group
);


SELECT
    provider,
    sport_code,
    entity,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE run_group LIKE 'PC2_%'
ORDER BY
    priority,
    sport_code,
    entity,
    season;