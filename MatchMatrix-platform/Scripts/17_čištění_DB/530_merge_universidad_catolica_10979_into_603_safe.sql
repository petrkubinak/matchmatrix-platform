BEGIN;

-- 530_merge_universidad_catolica_10979_into_603_safe.sql
-- Cíl:
-- Bezpečně sloučit duplicitní větev:
--   10979 = Universidad Catolica
-- do canonical týmu:
--   603   = CD Universidad Católica
--
-- Důvod:
-- preferred lookup bere self_team_name z public.teams,
-- takže dokud existuje team 10979, resolver vrací špatný canonical_team_id.

-- =========================================================
-- 1) KONTROLA PŘED ZÁSAHEM
-- =========================================================
SELECT 'teams' AS src, t.id::text AS ref_key, t.name AS detail
FROM public.teams t
WHERE t.id IN (603, 10979)

UNION ALL

SELECT 'team_aliases' AS src,
       (a.team_id::text || ' | ' || a.alias) AS ref_key,
       coalesce(a.source, '') AS detail
FROM public.team_aliases a
WHERE a.team_id IN (603, 10979)

UNION ALL

SELECT 'team_provider_map' AS src,
       (tpm.team_id::text || ' | ' || tpm.provider || ' | ' || tpm.provider_team_id::text) AS ref_key,
       '' AS detail
FROM public.team_provider_map tpm
WHERE tpm.team_id IN (603, 10979)

UNION ALL

SELECT 'matches_home' AS src,
       m.id::text AS ref_key,
       (m.home_team_id::text || ' vs ' || m.away_team_id::text) AS detail
FROM public.matches m
WHERE m.home_team_id IN (603, 10979)

UNION ALL

SELECT 'matches_away' AS src,
       m.id::text AS ref_key,
       (m.home_team_id::text || ' vs ' || m.away_team_id::text) AS detail
FROM public.matches m
WHERE m.away_team_id IN (603, 10979)

ORDER BY src, ref_key;

-- =========================================================
-- 2) ODSTRANĚNÍ KONFLIKTU V TEAM_PROVIDER_MAP
--    (oba týmy mají football_data mapu)
-- =========================================================
-- Necháme canonical tým 603 a starou mapu na 10979 smažeme.
DELETE FROM public.team_provider_map
WHERE team_id = 10979
  AND provider = 'football_data';

-- Kontrola po delete
SELECT
    team_id,
    provider,
    provider_team_id
FROM public.team_provider_map
WHERE team_id IN (603, 10979)
ORDER BY provider, team_id;

-- =========================================================
-- 3) SAFE MERGE PŘES EXISTUJÍCÍ FUNKCI
-- =========================================================
SELECT public.merge_team(
    10979,                         -- old team
    603,                           -- new canonical team
    'safe merge Universidad Catolica -> CD Universidad Católica',
    'audit_530_merge',
    true,                          -- smazat starý tým
    true                           -- vytvořit alias ze starého názvu
);

-- =========================================================
-- 4) KONTROLA PO MERGE
-- =========================================================
SELECT 'teams' AS src, t.id::text AS ref_key, t.name AS detail
FROM public.teams t
WHERE t.id IN (603, 10979)

UNION ALL

SELECT 'team_aliases' AS src,
       (a.team_id::text || ' | ' || a.alias) AS ref_key,
       coalesce(a.source, '') AS detail
FROM public.team_aliases a
WHERE a.team_id IN (603, 10979)

UNION ALL

SELECT 'team_provider_map' AS src,
       (tpm.team_id::text || ' | ' || tpm.provider || ' | ' || tpm.provider_team_id::text) AS ref_key,
       '' AS detail
FROM public.team_provider_map tpm
WHERE tpm.team_id IN (603, 10979)

UNION ALL

SELECT 'matches_home' AS src,
       m.id::text AS ref_key,
       (m.home_team_id::text || ' vs ' || m.away_team_id::text) AS detail
FROM public.matches m
WHERE m.home_team_id IN (603, 10979)

UNION ALL

SELECT 'matches_away' AS src,
       m.id::text AS ref_key,
       (m.home_team_id::text || ' vs ' || m.away_team_id::text) AS detail
FROM public.matches m
WHERE m.away_team_id IN (603, 10979)

ORDER BY src, ref_key;

COMMIT;