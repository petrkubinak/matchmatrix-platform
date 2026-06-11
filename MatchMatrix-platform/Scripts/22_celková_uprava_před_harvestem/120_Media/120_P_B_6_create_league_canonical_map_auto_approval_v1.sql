/*
MATCHMATRIX SQL 120_P_B_6
LEAGUE CANONICAL MAP AUTO APPROVAL V1 - FIXED CAST

CO TO JE:
- Automatické naplnění canonical_league_map
  z auditovaných AUTO_APPROVE kandidátů.

K ČEMU TO JE:
- Vytvoří skutečnou League Identity Layer.

KDE TO UVIDÍME:
- Match Context Engine
- Media Layer
- Odds Layer
- Ticket Engine
- AI Search

JAK SE TO VYUŽIJE:
- Všechny providery budou odkazovat
  na jednu canonical ligu.
*/

INSERT INTO public.canonical_league_map (
    canonical_league_id,
    provider,
    provider_league_id,
    status,
    note,
    created_at
)
SELECT
    suggested_canonical_league_id::bigint,
    ext_source,
    ext_league_id::bigint,
    'ACTIVE',
    '120_P_B_6_AUTO_APPROVED',
    NOW()
FROM ops.v_league_canonical_candidates_v1 c
WHERE governance_role IN ('MASTER','CANDIDATE')
  AND ext_source IS NOT NULL
  AND ext_league_id IS NOT NULL
  AND ext_league_id ~ '^[0-9]+$'
  AND NOT EXISTS (
        SELECT 1
        FROM public.canonical_league_map x
        WHERE x.provider = c.ext_source
          AND x.provider_league_id = c.ext_league_id::bigint
  );