/*
MATCHMATRIX SQL 18_4_G
LEAGUE GOVERNANCE FINAL DASHBOARD V1

CO TO JE:
- Finální dashboard League Governance.

K ČEMU TO JE:
- Ukáže finální stav canonical lig, provider map a HOLD lig.
- Potvrdí, že ligy jsou pod kontrolou bez fyzického mazání.

KDE TO UVIDÍME:
- ops.v_league_governance_final_dashboard_v1

JAK SE TO VYUŽIJE:
- OPS Panel
- League detail
- Match Context Engine
- AI Search
- Odds linker
- Ticket Engine
*/

DROP VIEW IF EXISTS ops.v_league_governance_final_dashboard_v1;

CREATE OR REPLACE VIEW ops.v_league_governance_final_dashboard_v1 AS
SELECT
    map_confidence AS governance_status,
    dependency_status,
    recommended_action,
    count(*) AS league_map_rows,
    count(DISTINCT canonical_league_id) AS canonical_leagues,
    count(DISTINCT provider_league_id) AS provider_leagues,
    count(DISTINCT provider) AS providers,
    now() AS refreshed_at
FROM ops.league_provider_map
GROUP BY
    map_confidence,
    dependency_status,
    recommended_action
ORDER BY league_map_rows DESC;