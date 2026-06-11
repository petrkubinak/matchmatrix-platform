/*
===============================================================================
MATCHMATRIX SQL 120_P_B_9 SECOND WAVE LEAGUE CANDIDATE AUDIT V1
===============================================================================

CO TO JE:
- Druhá vlna auditu nemapovaných lig po prvním auto-approval insertu.

K ČEMU TO JE:
- Zjistí, jestli mezi 1990 numeric unmapped ligami ještě existují
  další bezpečné canonical skupiny.

KDE TO UVIDÍME:
- OPS / League Governance Dashboard
- Match Context Engine příprava
- Provider Coverage Audit

JAK SE TO VYUŽIJE:
- Rozhodne, jestli můžeme spustit druhou vlnu canonical mapování,
  nebo jestli zbývající ligy jsou samostatné unikátní soutěže.

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_second_wave_league_candidate_audit_v1 AS

SELECT
    lower(trim(league_name)) AS league_name_key,
    sport_id,
    country,
    COUNT(*) AS league_count,
    STRING_AGG(league_id::text, ', ' ORDER BY league_id::text) AS league_ids,
    STRING_AGG(DISTINCT COALESCE(ext_source, 'NULL'), ', ' ORDER BY COALESCE(ext_source, 'NULL')) AS sources,
    MIN(league_id) AS suggested_master_league_id,
    NOW() AS audited_at

FROM ops.v_unmapped_league_audit_v1

WHERE unmapped_reason = 'NUMERIC_BUT_UNMAPPED'

GROUP BY
    lower(trim(league_name)),
    sport_id,
    country

HAVING COUNT(*) > 1;