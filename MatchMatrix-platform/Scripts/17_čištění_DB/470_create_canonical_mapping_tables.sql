-- 470_create_canonical_mapping_tables.sql

-- =====================================================
-- 1) Canonical leagues mapping
-- =====================================================
CREATE TABLE IF NOT EXISTS public.canonical_league_map (
    id BIGSERIAL PRIMARY KEY,

    canonical_league_id BIGINT NOT NULL,
    provider TEXT NOT NULL,
    provider_league_id BIGINT NOT NULL,

    status TEXT DEFAULT 'pending', -- auto / manual / confirmed
    note TEXT,

    created_at TIMESTAMP DEFAULT now()
);

-- =====================================================
-- 2) Canonical teams mapping
-- =====================================================
CREATE TABLE IF NOT EXISTS public.canonical_team_map (
    id BIGSERIAL PRIMARY KEY,

    canonical_team_id BIGINT NOT NULL,
    provider TEXT NOT NULL,
    provider_team_id BIGINT NOT NULL,

    status TEXT DEFAULT 'pending', -- auto / manual / confirmed
    note TEXT,

    created_at TIMESTAMP DEFAULT now()
);

-- =====================================================
-- indexy
-- =====================================================
CREATE UNIQUE INDEX IF NOT EXISTS ux_canonical_league_map
ON public.canonical_league_map(canonical_league_id, provider, provider_league_id);

CREATE UNIQUE INDEX IF NOT EXISTS ux_canonical_team_map
ON public.canonical_team_map(canonical_team_id, provider, provider_team_id);