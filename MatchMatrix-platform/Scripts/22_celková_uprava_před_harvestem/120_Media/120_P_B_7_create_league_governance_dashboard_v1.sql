/*
MATCHMATRIX SQL 120_P_B_7
LEAGUE GOVERNANCE DASHBOARD V1

CO TO JE:
- Souhrnný dashboard League Governance.

K ČEMU TO JE:
- Rychlá kontrola stavu canonical lig.

KDE TO UVIDÍME:
- OPS Panel V18
- Governance sekce
- AI doporučení

JAK SE TO VYUŽIJE:
- Kontrola pokrytí providerů
- Vyhledání nemapovaných lig
- Match Context Engine
- Media Layer
- Odds Layer
*/

CREATE OR REPLACE VIEW ops.v_league_governance_dashboard_v1 AS
WITH canonical_stats AS (
    SELECT
        COUNT(*) AS canonical_mappings,
        COUNT(DISTINCT canonical_league_id) AS canonical_leagues
    FROM public.canonical_league_map
),

league_stats AS (
    SELECT
        COUNT(*) AS total_leagues
    FROM public.leagues
),

provider_stats AS (
    SELECT
        COUNT(DISTINCT provider) AS provider_count
    FROM public.canonical_league_map
),

numeric_leagues AS (
    SELECT
        id,
        ext_source,
        ext_league_id::bigint AS ext_league_id_bigint
    FROM public.leagues
    WHERE ext_league_id ~ '^[0-9]+$'
),

mapped_numeric_leagues AS (
    SELECT DISTINCT
        nl.id
    FROM numeric_leagues nl
    JOIN public.canonical_league_map c
        ON c.provider = nl.ext_source
       AND c.provider_league_id = nl.ext_league_id_bigint
),

unmapped AS (
    SELECT
        COUNT(*) AS unmapped_leagues
    FROM public.leagues l
    WHERE NOT EXISTS (
        SELECT 1
        FROM mapped_numeric_leagues m
        WHERE m.id = l.id
    )
)

SELECT
    ls.total_leagues,
    cs.canonical_leagues,
    cs.canonical_mappings,
    ps.provider_count,
    u.unmapped_leagues,

    ROUND(
        (cs.canonical_mappings::numeric / NULLIF(ls.total_leagues,0)) * 100,
        2
    ) AS mapping_coverage_pct,

    NOW() AS audited_at

FROM league_stats ls
CROSS JOIN canonical_stats cs
CROSS JOIN provider_stats ps
CROSS JOIN unmapped u;