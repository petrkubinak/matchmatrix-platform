/*
===============================================================================
MATCHMATRIX SQL 120_P_B_10 LEAGUE GOVERNANCE FINAL AUDIT V1
===============================================================================

CO TO JE:
- Finální audit využití canonical lig.

K ČEMU TO JE:
- Ověření reálného dopadu League Governance.

KDE TO UVIDÍME:
- OPS Dashboard
- Governance Dashboard
- Match Context Engine

JAK SE TO VYUŽIJE:
- Určení připravenosti League Layer.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_league_governance_final_audit_v1 AS

SELECT
    COUNT(DISTINCT clm.canonical_league_id) AS canonical_leagues,
    COUNT(*) AS provider_mappings,

    (
        SELECT COUNT(*)
        FROM public.matches
    ) AS matches_total,

    (
        SELECT COUNT(*)
        FROM public.teams
    ) AS teams_total,

    (
        SELECT COUNT(*)
        FROM public.articles
    ) AS articles_total,

    NOW() AS audited_at

FROM public.canonical_league_map clm;