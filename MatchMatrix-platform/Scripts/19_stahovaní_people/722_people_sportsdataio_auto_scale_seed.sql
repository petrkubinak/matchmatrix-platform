-- ============================================================
-- MATCHMATRIX - PEOPLE SPORTSDATAIO AUTO SCALE SEED
-- ============================================================

-- HK / BSB / BK / MMA přes SportsDataIO fallback
-- Pozor: SportsDataIO endpoints nejsou stránkované, 1 job = 1 full pull.

INSERT INTO ops.ingest_planner (
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
VALUES
    ('sportsdataio', 'HK',  'players', NULL, '2024', 'PEOPLE_AUTO_SPORTSDATAIO_2024', 2, 'pending', 0, NULL, now(), now()),
    ('sportsdataio', 'BSB', 'players', NULL, '2024', 'PEOPLE_AUTO_SPORTSDATAIO_2024', 2, 'pending', 0, NULL, now(), now()),
    ('sportsdataio', 'BK',  'players', NULL, '2024', 'PEOPLE_AUTO_SPORTSDATAIO_2024', 2, 'pending', 0, NULL, now(), now()),
    ('sportsdataio', 'MMA', 'players', NULL, '2024', 'PEOPLE_AUTO_SPORTSDATAIO_2024', 3, 'pending', 0, NULL, now(), now())
ON CONFLICT DO NOTHING;

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE run_group = 'PEOPLE_AUTO_SPORTSDATAIO_2024'
GROUP BY provider, sport_code, entity, run_group, status
ORDER BY sport_code;