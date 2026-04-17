SELECT
    l.provider,
    l.external_league_id,
    l.league_name,
    l.country_name,
    l.season,
    pm.league_id AS mapped_league_id

FROM staging.stg_provider_leagues l
LEFT JOIN public.league_provider_map pm
    ON pm.provider = l.provider
   AND pm.provider_league_id = l.external_league_id

WHERE l.provider = 'api_football'
  AND l.sport_code = 'football'

ORDER BY
    CASE WHEN pm.league_id IS NULL THEN 0 ELSE 1 END,
    l.league_name,
    l.season;