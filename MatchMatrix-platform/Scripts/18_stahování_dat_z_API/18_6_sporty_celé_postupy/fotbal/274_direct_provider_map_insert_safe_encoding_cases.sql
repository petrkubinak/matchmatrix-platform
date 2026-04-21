-- =====================================================================
-- 274_direct_provider_map_insert_safe_encoding_cases.sql
-- Safe direct insert do provider_map bez team_aliases
-- =====================================================================

-- 9878 = Atl?tico Monz?n -> 27517 = Atlético Monzón
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT
    27517,
    'api_football',
    '9878',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '9878'
);

-- 5530 = Cura?ao -> 669 = Curaçao
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT
    669,
    'api_football',
    '5530',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '5530'
);

-- 777 = T?rkiye -> 119 = Turkey
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT
    119,
    'api_football',
    '777',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map
    WHERE provider = 'api_football'
      AND provider_team_id = '777'
);