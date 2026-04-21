SELECT
    COUNT(*) AS hb_fixtures_missing_team_map
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.team_provider_map htp
  ON htp.provider = sf.provider
 AND htp.provider_team_id = sf.home_team_external_id
LEFT JOIN public.team_provider_map atp
  ON atp.provider = sf.provider
 AND atp.provider_team_id = sf.away_team_external_id
WHERE sf.provider = 'api_handball'
  AND (
      htp.team_id IS NULL
      OR atp.team_id IS NULL
  );

SELECT
    sf.external_league_id,
    COUNT(*) AS missing_cnt
FROM staging.stg_provider_fixtures sf
LEFT JOIN public.team_provider_map htp
  ON htp.provider = sf.provider
 AND htp.provider_team_id = sf.home_team_external_id
LEFT JOIN public.team_provider_map atp
  ON atp.provider = sf.provider
 AND atp.provider_team_id = sf.away_team_external_id
WHERE sf.provider = 'api_handball'
  AND (
      htp.team_id IS NULL
      OR atp.team_id IS NULL
  )
GROUP BY sf.external_league_id
ORDER BY missing_cnt DESC, sf.external_league_id;