SELECT
    l.provider,
    l.external_league_id,
    l.league_name,
    l.country_name

FROM staging.stg_provider_leagues l
LEFT JOIN public.league_provider_map pm
    ON pm.provider = l.provider
   AND pm.provider_league_id = l.external_league_id

WHERE l.provider = 'api_football'
  AND l.sport_code = 'football'
  AND pm.league_id IS NULL

  -- 🔥 pouze ligy, které reálně používáme
  AND EXISTS (
      SELECT 1
      FROM ops.ingest_targets t
      WHERE t.provider = l.provider
        AND t.provider_league_id = l.external_league_id
  )

ORDER BY l.league_name;