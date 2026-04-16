-- =====================================================================
-- 277_direct_provider_map_insert_safe_encoding_cases_next.sql
-- Dalsi safe direct insert pro potvrzene encoding klubove pripady
-- =====================================================================

-- 9877 = Almud?var -> 27515 = Almudévar
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT
    27515,
    'api_football',
    '9877',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '9877'
);

-- 9881 = Bin?far -> 26488 = Binéfar
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT
    26488,
    'api_football',
    '9881',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '9881'
);