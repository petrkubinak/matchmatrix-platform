-- =====================================================
-- 238_seed_data_provider_api_sport.sql
-- Účel:
--   Doplnit chybějící provider 'api_sport' do public.data_providers
--   pro FK public.league_provider_map(provider) -> public.data_providers(code)
-- =====================================================

INSERT INTO public.data_providers (code, name)
SELECT
    'api_sport',
    'API-Sport Generic'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.data_providers
    WHERE code = 'api_sport'
);

-- =====================================================
-- KONTROLA
-- =====================================================

SELECT code, name
FROM public.data_providers
WHERE code = 'api_sport';