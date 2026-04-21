-- 709_merge_api_tennis_fixtures_to_public_matches_with_teams.sql
-- TN fixtures -> public.matches přes public.teams

BEGIN;

INSERT INTO public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    ext_source,
    ext_match_id,
    status,
    home_score,
    away_score,
    season,
    sport_id,
    updated_at
)
SELECT
    NULL::integer AS league_id,
    th.id AS home_team_id,
    ta.id AS away_team_id,
    (f.match_time AT TIME ZONE 'UTC')::timestamp AS kickoff,
    'api_tennis' AS ext_source,
    f.provider_match_id AS ext_match_id,
    CASE
        WHEN f.status ILIKE 'inprogress:%' THEN 'LIVE'
        WHEN f.status ILIKE 'finished%' THEN 'FINISHED'
        WHEN f.status ILIKE 'notstarted%' THEN 'SCHEDULED'
        ELSE 'SCHEDULED'
    END AS status,
    NULL::integer AS home_score,
    NULL::integer AS away_score,
    NULL::text AS season,
    s.id AS sport_id,
    now()
FROM staging.api_tennis_fixtures f
JOIN public.sports s
  ON s.code = 'TN'
JOIN public.teams th
  ON th.ext_source = 'api_tennis'
 AND th.ext_team_id = 'player:' || lower(trim(f.player_1))
JOIN public.teams ta
  ON ta.ext_source = 'api_tennis'
 AND ta.ext_team_id = 'player:' || lower(trim(f.player_2))
LEFT JOIN public.matches m
  ON m.ext_source = 'api_tennis'
 AND m.ext_match_id = f.provider_match_id
WHERE f.run_id = 1776783947
  AND f.provider_match_id IS NOT NULL
  AND m.id IS NULL;

UPDATE public.matches m
SET
    home_team_id = th.id,
    away_team_id = ta.id,
    kickoff = (f.match_time AT TIME ZONE 'UTC')::timestamp,
    status = CASE
        WHEN f.status ILIKE 'inprogress:%' THEN 'LIVE'
        WHEN f.status ILIKE 'finished%' THEN 'FINISHED'
        WHEN f.status ILIKE 'notstarted%' THEN 'SCHEDULED'
        ELSE 'SCHEDULED'
    END,
    updated_at = now()
FROM staging.api_tennis_fixtures f
JOIN public.teams th
  ON th.ext_source = 'api_tennis'
 AND th.ext_team_id = 'player:' || lower(trim(f.player_1))
JOIN public.teams ta
  ON ta.ext_source = 'api_tennis'
 AND ta.ext_team_id = 'player:' || lower(trim(f.player_2))
WHERE m.ext_source = 'api_tennis'
  AND m.ext_match_id = f.provider_match_id
  AND f.run_id = 1776783947;

COMMIT;