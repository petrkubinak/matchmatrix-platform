-- 744_ck_fixtures_public_merge_v3.sql

WITH ck_src AS (
    SELECT
        f.external_fixture_id,
        f.external_league_id,
        f.home_team_external_id,
        f.away_team_external_id,
        f.fixture_date,
        f.season,

        CASE
            WHEN f.home_score IS NULL OR trim(f.home_score) = '' THEN NULL
            WHEN split_part(f.home_score, '/', 1) ~ '^[0-9]+$'
                THEN split_part(f.home_score, '/', 1)::integer
            ELSE NULL
        END AS home_runs,

        CASE
            WHEN f.away_score IS NULL OR trim(f.away_score) = '' THEN NULL
            WHEN split_part(f.away_score, '/', 1) ~ '^[0-9]+$'
                THEN split_part(f.away_score, '/', 1)::integer
            ELSE NULL
        END AS away_runs
    FROM staging.stg_provider_fixtures f
    WHERE f.provider = 'api_cricket'
      AND f.sport_code = 'CK'
),
ck_ready AS (
    SELECT
        l.id AS league_id,
        th.team_id AS home_team_id,
        ta.team_id AS away_team_id,
        s.fixture_date AS kickoff,
        s.external_fixture_id AS ext_match_id,
        s.home_runs,
        s.away_runs,
        s.season,
        CASE
            WHEN s.home_runs IS NOT NULL AND s.away_runs IS NOT NULL THEN 'FINISHED'
            WHEN s.home_runs IS NOT NULL OR s.away_runs IS NOT NULL THEN 'LIVE'
            ELSE 'SCHEDULED'
        END AS match_status
    FROM ck_src s
    JOIN public.team_provider_map th
        ON th.provider = 'api_cricket'
       AND th.provider_team_id = s.home_team_external_id
    JOIN public.team_provider_map ta
        ON ta.provider = 'api_cricket'
       AND ta.provider_team_id = s.away_team_external_id
    JOIN public.leagues l
        ON l.ext_source = 'api_cricket'
       AND l.ext_league_id = s.external_league_id
       AND l.sport_id = 14
)
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
    r.league_id,
    r.home_team_id,
    r.away_team_id,
    r.kickoff,
    'api_cricket' AS ext_source,
    r.ext_match_id,
    r.match_status,
    r.home_runs,
    r.away_runs,
    r.season,
    14 AS sport_id,
    now() AS updated_at
FROM ck_ready r
LEFT JOIN public.matches m
    ON m.ext_source = 'api_cricket'
   AND m.ext_match_id = r.ext_match_id
WHERE m.id IS NULL;