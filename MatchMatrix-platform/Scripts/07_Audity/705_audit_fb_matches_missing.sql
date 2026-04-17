SELECT
    f.external_fixture_id,
    f.fixture_date,
    f.home_team_external_id,
    f.away_team_external_id,
    m.id AS match_id,
    m.home_team_id,
    m.away_team_id,
    m.kickoff,
    m.ext_match_id
FROM staging.stg_provider_fixtures f
LEFT JOIN public.matches m
    ON m.ext_source = f.provider
   AND m.ext_match_id = f.external_fixture_id
WHERE f.provider = 'api_football'
  AND f.sport_code = 'football'
  AND m.id IS NULL
ORDER BY f.fixture_date DESC NULLS LAST;