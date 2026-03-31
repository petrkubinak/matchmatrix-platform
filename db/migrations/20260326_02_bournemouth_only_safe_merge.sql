-- =====================================================================
-- MatchMatrix
-- Bournemouth only safe merge
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_02_bournemouth_only_safe_merge.sql
-- Spouštět v DBeaveru
-- =====================================================================

-- Pokud předchozí blok spadl, nejdřív ukončíme rozbitou transakci
ROLLBACK;

BEGIN;

-- ============================================================
-- 0) KONTROLA VSTUPU
-- master = 11905
-- old    = 948
-- ============================================================

SELECT 'PRE_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (11905, 948);

SELECT 'PRE_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (11905, 948)
ORDER BY pm.team_id, pm.provider;

SELECT 'PRE_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id IN (11905, 948)
GROUP BY x.team_id
ORDER BY x.team_id;

-- ============================================================
-- 1) BACKUP DO TEMP TABULEK
-- ============================================================

CREATE TEMP TABLE bak_bournemouth_team_provider_map AS
SELECT *
FROM public.team_provider_map
WHERE team_id IN (11905, 948);

CREATE TEMP TABLE bak_bournemouth_team_aliases AS
SELECT *
FROM public.team_aliases
WHERE team_id IN (11905, 948);

CREATE TEMP TABLE bak_bournemouth_league_teams AS
SELECT *
FROM public.league_teams
WHERE team_id IN (11905, 948);

CREATE TEMP TABLE bak_bournemouth_matches AS
SELECT *
FROM public.matches
WHERE home_team_id IN (11905, 948)
   OR away_team_id IN (11905, 948);

-- ============================================================
-- 2) LEAGUE_TEAMS - odstranit budoucí duplicity
-- ============================================================

DELETE FROM public.league_teams old_lt
WHERE old_lt.team_id = 948
  AND EXISTS (
      SELECT 1
      FROM public.league_teams new_lt
      WHERE new_lt.team_id = 11905
        AND new_lt.league_id = old_lt.league_id
        AND COALESCE(new_lt.season::text, '') = COALESCE(old_lt.season::text, '')
  );

UPDATE public.league_teams
SET team_id = 11905
WHERE team_id = 948;

-- ============================================================
-- 3) MATCHES
-- ============================================================

UPDATE public.matches
SET home_team_id = 11905
WHERE home_team_id = 948;

UPDATE public.matches
SET away_team_id = 11905
WHERE away_team_id = 948;

-- ============================================================
-- 4) TEAM_ALIASES
-- ============================================================

UPDATE public.team_aliases
SET team_id = 11905
WHERE team_id = 948;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 11905, 'Bournemouth', 'canonical_merge'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 11905
      AND lower(a.alias) = lower('Bournemouth')
);

-- ============================================================
-- 5) TEAM_PROVIDER_MAP
-- Důležité:
-- nepřepisujeme naslepo vše,
-- nejdřív smažeme starý provider jen pokud už na masteru existuje
-- ============================================================

-- Pokud master už má stejný provider, starý řádek smažeme
DELETE FROM public.team_provider_map old_pm
WHERE old_pm.team_id = 948
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map new_pm
      WHERE new_pm.team_id = 11905
        AND new_pm.provider = old_pm.provider
  );

-- Zbývající providery přesuneme na master
UPDATE public.team_provider_map
SET team_id = 11905,
    updated_at = now()
WHERE team_id = 948;

-- ============================================================
-- 6) VOLITELNĚ SMAZAT STAROU TEAM VĚTEV
-- jen pokud už opravdu nikde nezůstala použitá
-- ============================================================

DELETE FROM public.teams t
WHERE t.id = 948
  AND NOT EXISTS (SELECT 1 FROM public.team_provider_map x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.team_aliases x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.league_teams x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.matches x WHERE x.home_team_id = t.id OR x.away_team_id = t.id);

-- ============================================================
-- 7) KONTROLA PO MERGI
-- ============================================================

SELECT 'POST_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (11905, 948);

SELECT 'POST_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (11905, 948)
ORDER BY pm.team_id, pm.provider;

SELECT 'POST_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id IN (11905, 948)
GROUP BY x.team_id
ORDER BY x.team_id;

COMMIT;