-- 470_seed_canonical_league_team_mapping.sql
-- KANONIZACE: league + team mapping
-- ⚠ zatím jen INSERT + SELECT (žádné UPDATE/DELETE)

-- =====================================================
-- 1) vytvoření mapping tabulky (pokud neexistuje)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.canonical_provider_map (
    id BIGSERIAL PRIMARY KEY,

    entity_type TEXT, -- 'league' / 'team'

    canonical_id BIGINT,
    provider TEXT,
    provider_id BIGINT,

    status TEXT DEFAULT 'AUTO', -- AUTO / MANUAL / REVIEW
    note TEXT,

    created_at TIMESTAMP DEFAULT now()
);

-- =====================================================
-- 2) LEAGUE MAPPING (AUTO)
-- =====================================================
INSERT INTO public.canonical_provider_map (
    entity_type,
    canonical_id,
    provider,
    provider_id,
    status,
    note
)
SELECT
    'league',
    fd.id,
    'api_football',
    api.id,
    'AUTO',
    'name+country match'
FROM public.leagues fd
JOIN public.leagues api
  ON lower(trim(fd.name)) = lower(trim(api.name))
 AND COALESCE(lower(trim(fd.country)), '') = COALESCE(lower(trim(api.country)), '')
WHERE fd.ext_source IN ('football_data', 'football_data_uk')
  AND api.ext_source = 'api_football'
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3) TEAM MAPPING (AUTO – exact name)
-- =====================================================
INSERT INTO public.canonical_provider_map (
    entity_type,
    canonical_id,
    provider,
    provider_id,
    status,
    note
)
SELECT DISTINCT
    'team',
    fd.id,
    'api_football',
    api.id,
    'AUTO',
    'exact name match'
FROM public.teams fd
JOIN public.teams api
  ON lower(trim(fd.name)) = lower(trim(api.name))
WHERE fd.ext_source IN ('football_data', 'football_data_uk')
  AND api.ext_source = 'api_football'
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4) TEAM MAPPING (REVIEW – podobné názvy)
-- =====================================================
INSERT INTO public.canonical_provider_map (
    entity_type,
    canonical_id,
    provider,
    provider_id,
    status,
    note
)
SELECT DISTINCT
    'team',
    fd.id,
    'api_football',
    api.id,
    'REVIEW',
    'partial name match'
FROM public.teams fd
JOIN public.teams api
  ON lower(fd.name) LIKE '%' || lower(api.name) || '%'
WHERE fd.ext_source IN ('football_data', 'football_data_uk')
  AND api.ext_source = 'api_football'
  AND fd.id NOT IN (
        SELECT canonical_id
        FROM public.canonical_provider_map
        WHERE entity_type = 'team'
    );

-- =====================================================
-- 5) kontrola
-- =====================================================
SELECT
    entity_type,
    status,
    COUNT(*) 
FROM public.canonical_provider_map
GROUP BY entity_type, status
ORDER BY entity_type, status;