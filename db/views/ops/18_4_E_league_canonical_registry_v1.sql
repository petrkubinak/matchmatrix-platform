/*
MATCHMATRIX SQL 18_4_E
LEAGUE CANONICAL REGISTRY V1

CO TO JE:
- Vytvoří centrální registry vrstvu pro canonical ligy.
- Vytvoří mapovací tabulku provider lig na canonical/master ligu.

K ČEMU TO JE:
- Aby se ligy z různých providerů neslučovaly fyzicky mazáním.
- Aby MatchMatrix věděl, že například:
    football_data Premier League
    api_football Premier League
    api_sport Premier League
  patří pod jednu canonical soutěž.

KDE TO UVIDÍME:
- ops.league_canonical_registry
- ops.league_provider_map
- ops.v_league_canonical_registry_summary_v1

JAK SE TO VYUŽIJE:
- AI Search
- Match Context Engine
- Team/League detail
- Odds linker
- Media linker
- Ticket Engine
- budoucí webová stránka ligy

DŮLEŽITÉ:
- Tento skript NIC nemaže.
- Tento skript NIC nepřepisuje v public.matches.
- Pouze vytvoří bezpečnou registry a mapovací vrstvu.
*/

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.league_canonical_registry (
    canonical_league_id BIGINT PRIMARY KEY,
    sport_id INTEGER NOT NULL,
    canonical_name TEXT NOT NULL,
    canonical_country TEXT,
    canonical_source TEXT,
    canonical_ext_league_id TEXT,
    registry_status TEXT NOT NULL DEFAULT 'ACTIVE',
    governance_status TEXT NOT NULL DEFAULT 'CONTROLLED_HOLD',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.league_provider_map (
    id BIGSERIAL PRIMARY KEY,
    canonical_league_id BIGINT NOT NULL,
    provider_league_id BIGINT NOT NULL,
    sport_id INTEGER NOT NULL,
    provider TEXT,
    provider_ext_league_id TEXT,
    provider_league_name TEXT NOT NULL,
    provider_country TEXT,
    map_status TEXT NOT NULL DEFAULT 'ACTIVE',
    map_confidence TEXT NOT NULL DEFAULT 'HIGH',
    map_reason TEXT NOT NULL DEFAULT 'LEAGUE_CANONICAL_GOVERNANCE',
    dependency_status TEXT,
    recommended_action TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_league_provider_map UNIQUE (provider_league_id)
);

INSERT INTO ops.league_canonical_registry (
    canonical_league_id,
    sport_id,
    canonical_name,
    canonical_country,
    canonical_source,
    canonical_ext_league_id,
    registry_status,
    governance_status,
    notes
)
SELECT DISTINCT
    master.league_id AS canonical_league_id,
    master.sport_id,
    master.league_name AS canonical_name,
    master.country AS canonical_country,
    master.ext_source AS canonical_source,
    master.ext_league_id AS canonical_ext_league_id,
    'ACTIVE' AS registry_status,
    'CONTROLLED_HOLD' AS governance_status,
    'Created from 18_4 League Canonical Governance. No physical merge.' AS notes
FROM ops.v_league_canonical_governance_audit_v1 master
WHERE master.canonical_role = 'MASTER_CANDIDATE'
ON CONFLICT (canonical_league_id) DO UPDATE SET
    sport_id = EXCLUDED.sport_id,
    canonical_name = EXCLUDED.canonical_name,
    canonical_country = EXCLUDED.canonical_country,
    canonical_source = EXCLUDED.canonical_source,
    canonical_ext_league_id = EXCLUDED.canonical_ext_league_id,
    updated_at = now();

INSERT INTO ops.league_provider_map (
    canonical_league_id,
    provider_league_id,
    sport_id,
    provider,
    provider_ext_league_id,
    provider_league_name,
    provider_country,
    map_status,
    map_confidence,
    map_reason,
    dependency_status,
    recommended_action
)
SELECT
    master.league_id AS canonical_league_id,
    item.league_id AS provider_league_id,
    item.sport_id,
    item.ext_source AS provider,
    item.ext_league_id AS provider_ext_league_id,
    item.league_name AS provider_league_name,
    item.country AS provider_country,
    'ACTIVE' AS map_status,
    CASE
        WHEN dep.recommended_action = 'SAFE_PROVIDER_MAP_CANDIDATE' THEN 'HIGH'
        WHEN dep.recommended_action = 'HOLD_DEPENDENCY_REVIEW' THEN 'MEDIUM_HOLD'
        ELSE 'REVIEW'
    END AS map_confidence,
    'LEAGUE_CANONICAL_GOVERNANCE' AS map_reason,
    dep.dependency_status,
    dep.recommended_action
FROM ops.v_league_canonical_governance_audit_v1 item
JOIN ops.v_league_canonical_governance_audit_v1 master
  ON master.audit_group_key = item.audit_group_key
 AND master.canonical_role = 'MASTER_CANDIDATE'
LEFT JOIN ops.v_league_dependency_audit_v1 dep
  ON dep.league_id = item.league_id
WHERE item.governance_issue <> 'OK'
ON CONFLICT (provider_league_id) DO UPDATE SET
    canonical_league_id = EXCLUDED.canonical_league_id,
    sport_id = EXCLUDED.sport_id,
    provider = EXCLUDED.provider,
    provider_ext_league_id = EXCLUDED.provider_ext_league_id,
    provider_league_name = EXCLUDED.provider_league_name,
    provider_country = EXCLUDED.provider_country,
    map_status = EXCLUDED.map_status,
    map_confidence = EXCLUDED.map_confidence,
    map_reason = EXCLUDED.map_reason,
    dependency_status = EXCLUDED.dependency_status,
    recommended_action = EXCLUDED.recommended_action,
    updated_at = now();

DROP VIEW IF EXISTS ops.v_league_canonical_registry_summary_v1;

CREATE OR REPLACE VIEW ops.v_league_canonical_registry_summary_v1 AS
SELECT
    lpm.map_confidence,
    lpm.dependency_status,
    lpm.recommended_action,
    count(*) AS provider_map_rows,
    count(DISTINCT lpm.canonical_league_id) AS canonical_leagues,
    count(DISTINCT lpm.provider) AS providers
FROM ops.league_provider_map lpm
GROUP BY
    lpm.map_confidence,
    lpm.dependency_status,
    lpm.recommended_action
ORDER BY provider_map_rows DESC;