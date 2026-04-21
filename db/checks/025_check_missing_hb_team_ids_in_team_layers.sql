WITH missing_ids AS (
    SELECT DISTINCT external_team_id
    FROM (
        SELECT sf.home_team_external_id AS external_team_id
        FROM staging.stg_provider_fixtures sf
        LEFT JOIN public.team_provider_map htp
          ON htp.provider = sf.provider
         AND htp.provider_team_id = sf.home_team_external_id
        WHERE sf.provider = 'api_handball'
          AND htp.team_id IS NULL

        UNION

        SELECT sf.away_team_external_id AS external_team_id
        FROM staging.stg_provider_fixtures sf
        LEFT JOIN public.team_provider_map atp
          ON atp.provider = sf.provider
         AND atp.provider_team_id = sf.away_team_external_id
        WHERE sf.provider = 'api_handball'
          AND atp.team_id IS NULL
    ) x
)
SELECT
    m.external_team_id,
    CASE WHEN spt.id IS NOT NULL THEN 1 ELSE 0 END AS in_stg_provider_teams,
    CASE WHEN tpm.team_id IS NOT NULL THEN 1 ELSE 0 END AS in_team_provider_map
FROM missing_ids m
LEFT JOIN staging.stg_provider_teams spt
  ON spt.provider = 'api_handball'
 AND spt.external_team_id = m.external_team_id
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = 'api_handball'
 AND tpm.provider_team_id = m.external_team_id
ORDER BY
    in_stg_provider_teams,
    in_team_provider_map,
    m.external_team_id;