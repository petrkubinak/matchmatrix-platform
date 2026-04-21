-- =====================================================================
-- 257_export_duplicate_provider_id_cases.sql
-- Najdi provider duplicate pripady typu Arsenal
-- =====================================================================

WITH stg AS (
    SELECT DISTINCT
        s.provider,
        s.external_team_id,
        s.team_name,
        LOWER(BTRIM(s.team_name)) AS team_name_norm
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
),
team_match AS (
    SELECT
        stg.provider,
        stg.external_team_id,
        stg.team_name,
        t.id AS team_id,
        t.name AS canonical_team_name
    FROM stg
    JOIN public.teams t
      ON LOWER(BTRIM(t.name)) = stg.team_name_norm
),
existing_map AS (
    SELECT
        m.provider,
        m.team_id,
        m.provider_team_id AS existing_provider_team_id
    FROM public.team_provider_map m
    WHERE m.provider = 'api_football'
)
SELECT
    tm.provider,
    tm.external_team_id AS new_provider_team_id,
    em.existing_provider_team_id,
    tm.team_id,
    tm.team_name,
    tm.canonical_team_name
FROM team_match tm
JOIN existing_map em
  ON em.provider = tm.provider
 AND em.team_id = tm.team_id
WHERE tm.external_team_id <> em.existing_provider_team_id
ORDER BY tm.team_name, tm.external_team_id;