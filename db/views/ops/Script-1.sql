/*
===============================================================================
MATCHMATRIX SQL 120_P_B_8 UNMAPPED LEAGUE AUDIT V1
===============================================================================

CO TO JE:
- Audit lig, které nejsou pokryté League Canonical Governance.
- Rozděluje ligy podle důvodu, proč nejsou namapované
  do public.canonical_league_map.

K ČEMU TO JE:
- Zjistit, proč ještě 2007 lig není součástí
  canonical vrstvy.
- Odhalit další kandidáty pro League Governance.
- Najít providery s nestandardními ID.

KDE TO UVIDÍME:
- OPS Governance Dashboard
- League Governance Dashboard
- Match Context Engine
- Provider Governance Audit

JAK SE TO VYUŽIJE:
- Rozšíření canonical_league_map.
- Automatické mapování dalších providerů.
- Match Context Engine.
- Media Layer.
- Odds Layer.
- Ticket Engine.
- AI Search.

OČEKÁVANÝ VÝSTUP:
- NO_PROVIDER_LEAGUE_ID
- NON_NUMERIC_PROVIDER_ID
- NUMERIC_BUT_UNMAPPED

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_unmapped_league_audit_v1 AS
WITH numeric_leagues AS (
    SELECT
        id,
        name,
        sport_id,
        country,
        ext_source,
        ext_league_id,
        ext_league_id::bigint AS ext_league_id_bigint
    FROM public.leagues
    WHERE ext_league_id ~ '^[0-9]+$'
),
mapped_numeric AS (
    SELECT DISTINCT nl.id
    FROM numeric_leagues nl
    JOIN public.canonical_league_map c
      ON c.provider = nl.ext_source
     AND c.provider_league_id = nl.ext_league_id_bigint
)
SELECT
    l.id AS league_id,
    l.name AS league_name,
    l.sport_id,
    l.country,
    l.ext_source,
    l.ext_league_id,

    CASE
        WHEN l.ext_league_id IS NULL THEN 'NO_PROVIDER_LEAGUE_ID'
        WHEN l.ext_league_id !~ '^[0-9]+$' THEN 'NON_NUMERIC_PROVIDER_ID'
        WHEN mn.id IS NULL THEN 'NUMERIC_BUT_UNMAPPED'
        ELSE 'MAPPED'
    END AS unmapped_reason,

    now() AS audited_at
FROM public.leagues l
LEFT JOIN mapped_numeric mn
    ON mn.id = l.id
WHERE mn.id IS NULL;