-- ============================================================================
-- 089_insert_missing_team_provider_map.sql
-- OPRAVENÁ VERZE
-- Cíl:
--   Doplnit mapování týmů (provider → team_id)
-- ============================================================================

INSERT INTO public.team_provider_map (
    provider,
    provider_team_id,
    team_id,
    created_at,
    updated_at
)
SELECT
    t.ext_source AS provider,
    t.ext_team_id AS provider_team_id,
    t.id AS team_id,
    NOW(),
    NOW()
FROM public.teams t
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = t.ext_source
 AND tpm.provider_team_id = t.ext_team_id
WHERE t.ext_source IS NOT NULL
  AND t.ext_team_id IS NOT NULL
  AND tpm.team_id IS NULL;