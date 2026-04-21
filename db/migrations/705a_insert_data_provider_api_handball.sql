-- 705a_insert_data_provider_api_handball.sql
-- Cíl:
-- Založit provider api_handball do public.data_providers,
-- aby šel použít v league_provider_map / team_provider_map.

INSERT INTO public.data_providers (
    code,
    name
)
SELECT
    'api_handball',
    'API-Handball'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.data_providers
    WHERE code = 'api_handball'
);

-- kontrola
SELECT *
FROM public.data_providers
WHERE code = 'api_handball';