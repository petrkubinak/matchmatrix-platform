-- =====================================================================
-- 275_export_remaining_encoding_cases.sql
-- Aktualni zbyvajici encoding pripady po direct insert batchi
-- =====================================================================

WITH base AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND NOT EXISTS (
          SELECT 1
          FROM public.team_provider_map m
          WHERE m.provider = s.provider
            AND m.provider_team_id = s.external_team_id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM public.teams t
          WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(s.team_name))
      )
)
SELECT
    provider,
    external_team_id,
    team_name
FROM base
WHERE team_name ~ '\?'
ORDER BY team_name;