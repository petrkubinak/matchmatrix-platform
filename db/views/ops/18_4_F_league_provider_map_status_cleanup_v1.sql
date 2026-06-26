/*
MATCHMATRIX SQL 18_4_F
LEAGUE PROVIDER MAP STATUS CLEANUP V1

CO TO JE:
- Zpřesní statusy v ops.league_provider_map.
- MASTER ligy označí jako CANONICAL_MASTER.
- SAFE merge kandidáty nechá jako HIGH.
- HOLD ligy nechá jako MEDIUM_HOLD.

K ČEMU TO JE:
- Aby League Governance rozlišovala:
    1) hlavní canonical ligu
    2) bezpečnou provider mapu
    3) ligu s reálnými závislostmi v HOLD

KDE TO UVIDÍME:
- ops.league_provider_map
- ops.v_league_canonical_registry_summary_v1

JAK SE TO VYUŽIJE:
- AI Search
- Match Context Engine
- League Detail
- Provider linker
- Odds linker
- Media linker
- Ticket Engine

DŮLEŽITÉ:
- Skript nic nemaže.
- Skript nepřepisuje public.matches.
- Pouze čistí governance status mapování.
*/

UPDATE ops.league_provider_map lpm
SET
    map_confidence = 'CANONICAL_MASTER',
    map_reason = 'LEAGUE_CANONICAL_MASTER',
    updated_at = now()
WHERE lpm.provider_league_id = lpm.canonical_league_id;

UPDATE ops.league_provider_map lpm
SET
    map_confidence = 'HIGH',
    map_reason = 'SAFE_PROVIDER_LEAGUE_MAP',
    updated_at = now()
WHERE lpm.provider_league_id <> lpm.canonical_league_id
  AND lpm.recommended_action = 'SAFE_PROVIDER_MAP_CANDIDATE';

UPDATE ops.league_provider_map lpm
SET
    map_confidence = 'MEDIUM_HOLD',
    map_reason = 'HOLD_DEPENDENCY_REVIEW',
    updated_at = now()
WHERE lpm.provider_league_id <> lpm.canonical_league_id
  AND lpm.recommended_action = 'HOLD_DEPENDENCY_REVIEW';

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