-- 708_seed_api_tennis_participants_to_teams.sql
-- TN participants (players / doubles pairs) -> public.teams + public.team_provider_map

BEGIN;

-- =========================================================
-- 1) Home participants do public.teams
-- =========================================================
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    logo_url,
    created_at,
    updated_at
)
SELECT DISTINCT
    f.player_1 AS name,
    'api_tennis' AS ext_source,
    'player:' || lower(trim(f.player_1)) AS ext_team_id,
    NULL::text AS logo_url,
    now(),
    now()
FROM staging.api_tennis_fixtures f
LEFT JOIN public.teams t
  ON t.ext_source = 'api_tennis'
 AND t.ext_team_id = 'player:' || lower(trim(f.player_1))
WHERE f.run_id = 1776783947
  AND f.player_1 IS NOT NULL
  AND t.id IS NULL;

-- =========================================================
-- 2) Away participants do public.teams
-- =========================================================
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    logo_url,
    created_at,
    updated_at
)
SELECT DISTINCT
    f.player_2 AS name,
    'api_tennis' AS ext_source,
    'player:' || lower(trim(f.player_2)) AS ext_team_id,
    NULL::text AS logo_url,
    now(),
    now()
FROM staging.api_tennis_fixtures f
LEFT JOIN public.teams t
  ON t.ext_source = 'api_tennis'
 AND t.ext_team_id = 'player:' || lower(trim(f.player_2))
WHERE f.run_id = 1776783947
  AND f.player_2 IS NOT NULL
  AND t.id IS NULL;

-- =========================================================
-- 3) team_provider_map pro home participants
-- =========================================================
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT DISTINCT
    t.id AS team_id,
    'api_tennis' AS provider,
    'player:' || lower(trim(f.player_1)) AS provider_team_id,
    now(),
    now()
FROM staging.api_tennis_fixtures f
JOIN public.teams t
  ON t.ext_source = 'api_tennis'
 AND t.ext_team_id = 'player:' || lower(trim(f.player_1))
LEFT JOIN public.team_provider_map m
  ON m.provider = 'api_tennis'
 AND m.provider_team_id = 'player:' || lower(trim(f.player_1))
WHERE f.run_id = 1776783947
  AND f.player_1 IS NOT NULL
  AND m.team_id IS NULL;

-- =========================================================
-- 4) team_provider_map pro away participants
-- =========================================================
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT DISTINCT
    t.id AS team_id,
    'api_tennis' AS provider,
    'player:' || lower(trim(f.player_2)) AS provider_team_id,
    now(),
    now()
FROM staging.api_tennis_fixtures f
JOIN public.teams t
  ON t.ext_source = 'api_tennis'
 AND t.ext_team_id = 'player:' || lower(trim(f.player_2))
LEFT JOIN public.team_provider_map m
  ON m.provider = 'api_tennis'
 AND m.provider_team_id = 'player:' || lower(trim(f.player_2))
WHERE f.run_id = 1776783947
  AND f.player_2 IS NOT NULL
  AND m.team_id IS NULL;

COMMIT;