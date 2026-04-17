SELECT
    f.provider,
    f.external_fixture_id,
    f.external_league_id,
    f.home_team_external_id,
    ht.team_id AS mapped_home_team_id,
    f.away_team_external_id,
    at.team_id AS mapped_away_team_id,
    f.fixture_date,
    f.status_text
FROM staging.stg_provider_fixtures f
LEFT JOIN public.team_provider_map ht
    ON ht.provider = f.provider
   AND ht.provider_team_id = f.home_team_external_id
LEFT JOIN public.team_provider_map at
    ON at.provider = f.provider
   AND at.provider_team_id = f.away_team_external_id
WHERE f.provider = 'api_football'
  AND f.sport_code = 'football'
  AND (
       ht.team_id IS NULL
    OR at.team_id IS NULL
  )
ORDER BY f.fixture_date DESC NULLS LAST, f.external_fixture_id;