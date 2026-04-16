-- =====================================================================
-- 294_insert_missing_canonical_clubs_batch_final_95.sql
-- Teměř finalni sweep chybejicich canonical klubu (SAFE)
-- =====================================================================

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
SELECT
    s.team_name,
    'api_football_missing_canonical',
    s.external_team_id,
    NOW(),
    NOW(),
    NULL
FROM (
    SELECT DISTINCT
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
    ORDER BY s.team_name
    LIMIT 95
) s;