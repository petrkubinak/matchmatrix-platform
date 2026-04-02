-- 457_create_ticket_pattern_catalog.sql
-- Katalog obecných typů / vzorů tiketů pro budoucí hodnocení úspěšnosti

CREATE TABLE IF NOT EXISTS public.ticket_pattern_catalog (
    id bigserial PRIMARY KEY,

    pattern_code text NOT NULL UNIQUE,              -- např. FIX4_BL2_1_1_PREMATCH_1X2
    ticket_type text NOT NULL,                      -- PREMATCH_1X2 / LIVE / BTTS / OU ...
    market_family text NOT NULL,                    -- 1X2 / DC / BTTS / OU / MIX
    sport_scope text NOT NULL,                      -- SINGLE_SPORT / MULTI_SPORT
    sport_codes text NOT NULL,                      -- např. FB nebo FB+HK nebo MIX
    fix_count integer NOT NULL DEFAULT 0,
    variable_block_count integer NOT NULL DEFAULT 0,
    block_size_signature text NOT NULL,             -- např. 0 | 1 | 1+1 | 1+2 | 3+3+3
    total_match_count integer NOT NULL DEFAULT 0,
    risk_profile text,                              -- LOW / MID / HIGH / MIX
    notes text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);