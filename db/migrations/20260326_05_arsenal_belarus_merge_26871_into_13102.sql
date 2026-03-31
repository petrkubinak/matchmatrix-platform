-- =====================================================================
-- MatchMatrix
-- Arsenal Belarus safe merge: 26871 -> 13102
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_05_arsenal_belarus_merge_26871_into_13102.sql
-- Spouštět v DBeaveru
-- =====================================================================

ROLLBACK;
BEGIN;

-- master = 13102   (Arsenal Belarus / silnější větev s více zápasy)
-- old    = 26871   (api_sport větev stejného běloruského klubu)

-- ============================================================
-- 0) KONTROLA VSTUPU
-- ============================================================

SELECT 'PRE_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (13102, 26871)
ORDER BY t.id;

SELECT 'PRE_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (13102, 26871)
ORDER BY pm.team_id, pm.provider;

SELECT 'PRE_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (13102, 26871)
ORDER BY a.team_id, a.alias;

SELECT 'PRE_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id IN (13102, 26871)
GROUP BY x.team_id
ORDER BY x.team_id;

-- ============================================================
-- 1) LEAGUE_TEAMS
-- nejdřív odstranit budoucí duplicity
-- ============================================================

DELETE FROM public.league_teams old_lt
WHERE old_lt.team_id = 26871
  AND EXISTS (
      SELECT 1
      FROM public.league_teams new_lt
      WHERE new_lt.team_id = 13102
        AND new_lt.league_id = old_lt.league_id
        AND COALESCE(new_lt.season::text, '') = COALESCE(old_lt.season::text, '')
  );

UPDATE public.league_teams
SET team_id = 13102
WHERE team_id = 26871;

-- ============================================================
-- 2) MATCHES
-- ============================================================

UPDATE public.matches
SET home_team_id = 13102
WHERE home_team_id = 26871;

UPDATE public.matches
SET away_team_id = 13102
WHERE away_team_id = 26871;

-- ============================================================
-- 3) TEAM_ALIASES
-- nejdřív odstranit duplicitní aliasy
-- ============================================================

DELETE FROM public.team_aliases old_a
WHERE old_a.team_id = 26871
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases new_a
      WHERE new_a.team_id = 13102
        AND lower(btrim(new_a.alias)) = lower(btrim(old_a.alias))
  );

UPDATE public.team_aliases
SET team_id = 13102
WHERE team_id = 26871;

-- Bezpečnostní alias
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 13102, 'Arsenal', 'canonical_merge'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 13102
      AND lower(btrim(a.alias)) = lower(btrim('Arsenal'))
);

-- ============================================================
-- 4) TEAM_PROVIDER_MAP
-- pokud už master má stejný provider, starý smažeme
-- jinak přesuneme
-- ============================================================

DELETE FROM public.team_provider_map old_pm
WHERE old_pm.team_id = 26871
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map new_pm
      WHERE new_pm.team_id = 13102
        AND new_pm.provider = old_pm.provider
  );

UPDATE public.team_provider_map
SET team_id = 13102,
    updated_at = now()
WHERE team_id = 26871;

-- ============================================================
-- 5) SMAZAT STAROU VĚTEV, pokud už nikde nezůstala
-- ============================================================

DELETE FROM public.teams t
WHERE t.id = 26871
  AND NOT EXISTS (SELECT 1 FROM public.team_provider_map x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.team_aliases x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.league_teams x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.matches x WHERE x.home_team_id = t.id OR x.away_team_id = t.id);

-- ============================================================
-- 6) KONTROLA PO MERGI
-- ============================================================

SELECT 'POST_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (13102, 26871)
ORDER BY t.id;

SELECT 'POST_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (13102, 26871)
ORDER BY pm.team_id, pm.provider;

SELECT 'POST_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (13102, 26871)
ORDER BY a.team_id, a.alias;

SELECT 'POST_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id IN (13102, 26871)
GROUP BY x.team_id
ORDER BY x.team_id;

COMMIT;