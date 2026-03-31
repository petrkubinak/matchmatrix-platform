-- =====================================================================
-- MatchMatrix
-- Cleanup manual seed team_id = 1 into canonical Arsenal 11910
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_09_cleanup_team_1_into_11910.sql
-- Spouštět v DBeaveru
-- =====================================================================

ROLLBACK;
BEGIN;

-- old    = 1
-- target = 11910

-- ============================================================
-- 0) VSTUPNÍ KONTROLA
-- ============================================================

SELECT 'PRE_TEAM_1' AS section, t.*
FROM public.teams t
WHERE t.id IN (1, 11910)
ORDER BY t.id;

SELECT 'PRE_TEAM_1_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (1, 11910)
ORDER BY pm.team_id, pm.provider;

SELECT 'PRE_TEAM_1_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (1, 11910)
ORDER BY a.team_id, a.alias;

SELECT 'PRE_TEAM_1_LEAGUE_TEAMS' AS section, lt.*
FROM public.league_teams lt
WHERE lt.team_id IN (1, 11910)
ORDER BY lt.team_id, lt.league_id, lt.season;

SELECT 'PRE_TEAM_1_MATCH_REFCOUNT' AS section, COUNT(*) AS cnt
FROM public.matches
WHERE home_team_id = 1 OR away_team_id = 1;

-- ============================================================
-- 1) TEAM_ALIASES
-- nejdřív odstranit duplicitní aliasy, které už na 11910 jsou
-- ============================================================

DELETE FROM public.team_aliases old_a
WHERE old_a.team_id = 1
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases new_a
      WHERE new_a.team_id = 11910
        AND lower(btrim(new_a.alias)) = lower(btrim(old_a.alias))
  );

-- zbytek aliasů přesunout na canonical Arsenal
UPDATE public.team_aliases
SET team_id = 11910
WHERE team_id = 1;

-- bezpečnostní alias pro theodds
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 11910, 'arsenal', 'theodds'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 11910
      AND lower(btrim(a.alias)) = lower(btrim('arsenal'))
);

-- ============================================================
-- 2) TEAM_PROVIDER_MAP
-- kdyby tam přece jen něco viselo
-- ============================================================

DELETE FROM public.team_provider_map old_pm
WHERE old_pm.team_id = 1
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map new_pm
      WHERE new_pm.team_id = 11910
        AND new_pm.provider = old_pm.provider
  );

UPDATE public.team_provider_map
SET team_id = 11910,
    updated_at = now()
WHERE team_id = 1;

-- ============================================================
-- 3) LEAGUE_TEAMS
-- kdyby tam přece jen něco viselo
-- ============================================================

DELETE FROM public.league_teams old_lt
WHERE old_lt.team_id = 1
  AND EXISTS (
      SELECT 1
      FROM public.league_teams new_lt
      WHERE new_lt.team_id = 11910
        AND new_lt.league_id = old_lt.league_id
        AND COALESCE(new_lt.season::text, '') = COALESCE(old_lt.season::text, '')
  );

UPDATE public.league_teams
SET team_id = 11910
WHERE team_id = 1;

-- ============================================================
-- 4) MATCHES
-- kdyby tam přece jen něco viselo
-- ============================================================

UPDATE public.matches
SET home_team_id = 11910
WHERE home_team_id = 1;

UPDATE public.matches
SET away_team_id = 11910
WHERE away_team_id = 1;

-- ============================================================
-- 5) SMAZAT STAROU SEED VĚTEV, jen pokud už je čistá
-- ============================================================

DELETE FROM public.teams t
WHERE t.id = 1
  AND NOT EXISTS (SELECT 1 FROM public.team_provider_map x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.team_aliases x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.league_teams x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.matches x WHERE x.home_team_id = t.id OR x.away_team_id = t.id);

-- ============================================================
-- 6) KONTROLA PO CLEANUPU
-- ============================================================

SELECT 'POST_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (1, 11910)
ORDER BY t.id;

SELECT 'POST_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (1, 11910)
ORDER BY pm.team_id, pm.provider;

SELECT 'POST_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (1, 11910)
ORDER BY a.team_id, a.alias;

SELECT 'POST_LEAGUE_TEAMS' AS section, lt.*
FROM public.league_teams lt
WHERE lt.team_id IN (1, 11910)
ORDER BY lt.team_id, lt.league_id, lt.season;

SELECT 'POST_MATCH_REFCOUNT_TEAM_1' AS section, COUNT(*) AS cnt
FROM public.matches
WHERE home_team_id = 1 OR away_team_id = 1;

COMMIT;