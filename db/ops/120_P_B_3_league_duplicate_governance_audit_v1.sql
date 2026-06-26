/*
MATCHMATRIX SQL 120_P_B_3 League Duplicate Governance Audit V1

CO TO JE:
- Audit duplicitních názvů lig podle sportu, země a providerů.

K ČEMU TO JE:
- Rozliší skutečné duplicity od soutěží se stejným názvem v jiných zemích.

KDE TO UVIDÍME:
- OPS / League Governance / Match Context Engine.

JAK SE TO VYUŽIJE:
- Připraví bezpečný merge/canonical plán lig.
*/

CREATE OR REPLACE VIEW ops.v_league_duplicate_governance_audit_v1 AS
SELECT
    lower(trim(l.name)) AS league_name_key,
    l.name AS league_name,
    l.sport_id,
    COALESCE(l.country, 'UNKNOWN') AS country,
    COUNT(*) AS league_count,
    STRING_AGG(l.id::text, ', ' ORDER BY l.id::text) AS league_ids,
    STRING_AGG(DISTINCT COALESCE(l.ext_source, 'NULL'), ', ' ORDER BY COALESCE(l.ext_source, 'NULL')) AS sources,
    MIN(l.id) AS suggested_master_league_id,

    CASE
        WHEN COUNT(*) = 1 THEN 'UNIQUE'
        WHEN COUNT(DISTINCT COALESCE(l.country, 'UNKNOWN')) > 1 THEN 'SAME_NAME_DIFFERENT_COUNTRY'
        WHEN COUNT(DISTINCT COALESCE(l.ext_source, 'NULL')) > 1 THEN 'POSSIBLE_PROVIDER_DUPLICATE'
        ELSE 'POSSIBLE_INTERNAL_DUPLICATE'
    END AS duplicate_status,

    now() AS audited_at

FROM public.leagues l
GROUP BY
    lower(trim(l.name)),
    l.name,
    l.sport_id,
    COALESCE(l.country, 'UNKNOWN')
HAVING COUNT(*) > 1;