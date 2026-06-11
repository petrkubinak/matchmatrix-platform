/*
MATCHMATRIX SQL 120_P_B League Canonical Coverage Audit V1

CO TO JE:
- Audit canonical mapování lig.

K ČEMU TO JE:
- Ověří, kolik lig má provider/canonical vazby a kde hrozí duplicitní ligy.

KDE TO UVIDÍME:
- OPS / Match Context Engine / League Governance.

JAK SE TO VYUŽIJE:
- Resolver bude moct bezpečně filtrovat články a zápasy přes canonical league.
*/

CREATE OR REPLACE VIEW ops.v_league_canonical_coverage_audit_v1 AS
WITH league_base AS (
    SELECT
        l.id AS league_id,
        l.name AS league_name,
        l.sport_id,
        l.ext_source,
        l.ext_league_id
    FROM public.leagues l
),
canonical_counts AS (
    SELECT
        clm.canonical_league_id AS league_id,
        COUNT(*) AS canonical_provider_links
    FROM public.canonical_league_map clm
    GROUP BY clm.canonical_league_id
),
provider_counts AS (
    SELECT
        l.id AS league_id,
        COUNT(*) FILTER (WHERE l.ext_source IS NOT NULL OR l.ext_league_id IS NOT NULL) AS direct_provider_signals
    FROM public.leagues l
    GROUP BY l.id
)
SELECT
    lb.league_id,
    lb.league_name,
    lb.sport_id,
    lb.ext_source,
    lb.ext_league_id,

    COALESCE(cc.canonical_provider_links, 0) AS canonical_provider_links,
    COALESCE(pc.direct_provider_signals, 0) AS direct_provider_signals,

    CASE
        WHEN COALESCE(cc.canonical_provider_links, 0) > 0
            THEN 'CANONICAL_MAPPED'
        WHEN COALESCE(pc.direct_provider_signals, 0) > 0
            THEN 'DIRECT_PROVIDER_ONLY'
        ELSE 'NO_CANONICAL_MAPPING'
    END AS canonical_coverage_status,

    now() AS audited_at

FROM league_base lb
LEFT JOIN canonical_counts cc
    ON cc.league_id = lb.league_id
LEFT JOIN provider_counts pc
    ON pc.league_id = lb.league_id;