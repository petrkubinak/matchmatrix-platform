-- =====================================================
-- 241_seed_data_provider_api_volleyball.sql
-- Účel:
--   Doplnit chybějící provider 'api_volleyball' do public.data_providers
--   pro FK public.league_provider_map(provider) -> public.data_providers(code)
-- =====================================================

INSERT INTO public.data_providers (code, name)
SELECT
    'api_volleyball',
    'API-Volleyball'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.data_providers
    WHERE code = 'api_volleyball'
);

-- =====================================================
-- KONTROLA
-- =====================================================

SELECT code, name
FROM public.data_providers
WHERE code = 'api_volleyball';