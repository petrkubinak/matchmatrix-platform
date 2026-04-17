SELECT
    COUNT(*) AS stg_api_football_fixtures,
    COUNT(DISTINCT external_fixture_id) AS stg_api_football_distinct_fixtures
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football'
  AND sport_code = 'football';

SELECT
    COUNT(*) AS public_matches_total,
    COUNT(*) FILTER (WHERE ext_source = 'football_data') AS football_data_matches,
    COUNT(*) FILTER (WHERE ext_source = 'football_data_uk') AS football_data_uk_matches
FROM public.matches;