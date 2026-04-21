-- =====================================================================
-- 255_insert_should_now_be_mappable.sql
-- Finalni single match insert
-- =====================================================================

INSERT INTO public.team_provider_map (
    provider,
    provider_team_id,
    team_id,
    created_at,
    updated_at
)
SELECT
    'api_football',
    '9419',
    118199,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '9419'
);