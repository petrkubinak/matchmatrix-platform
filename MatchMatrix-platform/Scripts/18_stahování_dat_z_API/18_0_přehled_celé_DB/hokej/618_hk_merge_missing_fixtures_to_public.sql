-- 618_hk_merge_missing_fixtures_to_public.sql
-- HK fixtures merge: staging.stg_provider_fixtures -> public.matches

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
    sport_id
)
SELECT
    l.id AS league_id,
    th.team_id AS home_team_id,
    ta.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,
    'api_hockey' AS ext_source,
    f.external_fixture_id AS ext_match_id,

    CASE
        WHEN f.status_text IN ('FT', 'AOT', 'AP', 'AW') THEN 'FINISHED'
        WHEN f.status_text IN ('CANC') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,

    NULLIF(f.home_score, '')::int AS home_score,
    NULLIF(f.away_score, '')::int AS away_score,
    f.season,
    l.sport_id

FROM staging.stg_provider_fixtures f
JOIN public.leagues l
  ON l.ext_source = 'api_hockey'
 AND l.ext_league_id = f.external_league_id
JOIN public.team_provider_map th
  ON th.provider = 'api_hockey'
 AND th.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map ta
  ON ta.provider = 'api_hockey'
 AND ta.provider_team_id = f.away_team_external_id
LEFT JOIN public.matches m
  ON m.ext_source = 'api_hockey'
 AND m.ext_match_id = f.external_fixture_id
WHERE f.provider = 'api_hockey'
  AND m.id IS NULL;