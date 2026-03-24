-- 224_check_fb_bootstrap_teams_effect.sql

-- 1) Stav planneru pro teams bootstrap
SELECT
    entity,
    run_group,
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND entity = 'teams'
GROUP BY entity, run_group, status
ORDER BY status;

-- 2) Poslední teams bootstrap joby
SELECT
    id,
    provider_league_id,
    season,
    status,
    attempts,
    last_attempt,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND entity = 'teams'
ORDER BY updated_at DESC
LIMIT 20;

-- 3) Kolik týmů je ve staging provider teams
SELECT COUNT(*) AS stg_provider_teams_count
FROM staging.stg_provider_teams;

-- 4) Kolik mapování týmů máme pro api_football
SELECT COUNT(*) AS team_provider_map_api_football
FROM public.team_provider_map
WHERE provider = 'api_football';

-- 5) Posledních 20 týmů z mapování api_football
SELECT
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
FROM public.team_provider_map
WHERE provider = 'api_football'
ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST
LIMIT 20;