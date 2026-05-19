-- 617_hk_insert_missing_teams_from_fixtures.sql
-- Doplnění chybějících HK týmů z fixtures payloadu do public.teams + public.team_provider_map

WITH missing_fixtures AS (
    SELECT f.*
    FROM staging.stg_provider_fixtures f
    LEFT JOIN public.matches m
        ON m.ext_source = 'api_hockey'
       AND m.ext_match_id = f.external_fixture_id
    WHERE f.provider = 'api_hockey'
      AND m.id IS NULL
),
games AS (
    SELECT
        p.id AS raw_payload_id,
        jsonb_array_elements(p.payload_json -> 'response') AS game
    FROM staging.stg_api_payloads p
    WHERE p.provider = 'api_hockey'
      AND p.entity_type = 'fixtures'
),
missing_teams AS (
    SELECT DISTINCT
        mf.home_team_external_id AS provider_team_id,
        g.game -> 'teams' -> 'home' ->> 'name' AS team_name
    FROM missing_fixtures mf
    JOIN games g
      ON g.raw_payload_id = mf.raw_payload_id
     AND g.game ->> 'id' = mf.external_fixture_id
    LEFT JOIN public.team_provider_map tpm
      ON tpm.provider = 'api_hockey'
     AND tpm.provider_team_id = mf.home_team_external_id
    WHERE tpm.team_id IS NULL

    UNION

    SELECT DISTINCT
        mf.away_team_external_id AS provider_team_id,
        g.game -> 'teams' -> 'away' ->> 'name' AS team_name
    FROM missing_fixtures mf
    JOIN games g
      ON g.raw_payload_id = mf.raw_payload_id
     AND g.game ->> 'id' = mf.external_fixture_id
    LEFT JOIN public.team_provider_map tpm
      ON tpm.provider = 'api_hockey'
     AND tpm.provider_team_id = mf.away_team_external_id
    WHERE tpm.team_id IS NULL
),
inserted_teams AS (
    INSERT INTO public.teams (
        name,
        ext_source,
        ext_team_id
    )
    SELECT
        mt.team_name,
        'api_hockey',
        mt.provider_team_id
    FROM missing_teams mt
    WHERE NOT EXISTS (
        SELECT 1
        FROM public.teams t
        WHERE t.ext_source = 'api_hockey'
          AND t.ext_team_id = mt.provider_team_id
    )
    RETURNING id, ext_team_id
)
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    t.id,
    'api_hockey',
    t.ext_team_id
FROM public.teams t
JOIN missing_teams mt
  ON mt.provider_team_id = t.ext_team_id
WHERE t.ext_source = 'api_hockey'
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map x
      WHERE x.provider = 'api_hockey'
        AND x.provider_team_id = t.ext_team_id
  );