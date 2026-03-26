-- 039_audit_multisport_planner_unification.sql
-- Cíl:
-- rychlý audit planneru pro VB / HK / BK
-- a kontrola, zda jsou teams + fixtures seeded konzistentně.

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

-- detail nahoře řazených jobů
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
LIMIT 200;