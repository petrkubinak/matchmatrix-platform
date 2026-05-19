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
    l.id,
    th.team_id,
    ta.team_id,
    f.fixture_date::timestamp,
    'api_hockey',
    f.external_fixture_id,
    CASE
        WHEN f.status_text IN ('FT', 'AOT', 'AP') THEN 'FINISHED'
        WHEN f.status_text = 'CANC' THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END,
    CASE WHEN f.status_text IN ('FT', 'AOT', 'AP')
         THEN NULLIF(f.home_score, '')::int ELSE NULL END,
    CASE WHEN f.status_text IN ('FT', 'AOT', 'AP')
         THEN NULLIF(f.away_score, '')::int ELSE NULL END,
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