SELECT
    sf.external_league_id,
    sf.home_team_external_id,
    sf.away_team_external_id,
    COUNT(*) AS fixtures_cnt
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
GROUP BY
    sf.external_league_id,
    sf.home_team_external_id,
    sf.away_team_external_id
ORDER BY fixtures_cnt DESC, sf.external_league_id
LIMIT 100;

SELECT
    missing_side,
    external_team_id,
    COUNT(*) AS cnt
FROM (
    SELECT
        'home' AS missing_side,
        sf.home_team_external_id AS external_team_id
    FROM staging.stg_provider_fixtures sf
    LEFT JOIN public.team_provider_map htp
      ON htp.provider = sf.provider
     AND htp.provider_team_id = sf.home_team_external_id
    WHERE sf.provider = 'api_handball'
      AND htp.team_id IS NULL

    UNION ALL

    SELECT
        'away' AS missing_side,
        sf.away_team_external_id AS external_team_id
    FROM staging.stg_provider_fixtures sf
    LEFT JOIN public.team_provider_map atp
      ON atp.provider = sf.provider
     AND atp.provider_team_id = sf.away_team_external_id
    WHERE sf.provider = 'api_handball'
      AND atp.team_id IS NULL
) x
GROUP BY missing_side, external_team_id
ORDER BY cnt DESC, external_team_id
LIMIT 100;

SELECT
    sf.external_league_id,
    COUNT(*) AS missing_rows
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
ORDER BY missing_rows DESC, sf.external_league_id;