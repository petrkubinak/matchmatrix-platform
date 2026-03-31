-- =====================================================================
-- MatchMatrix
-- Bournemouth safe merge - fix aliases
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_03_bournemouth_only_safe_merge_fix_aliases.sql
-- Spouštět v DBeaveru
-- =====================================================================

ROLLBACK;
BEGIN;

-- ============================================================
-- 0) KONTROLA VSTUPU
-- ============================================================

SELECT 'PRE_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (11905, 948);

SELECT 'PRE_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (11905, 948)
ORDER BY pm.team_id, pm.provider;

SELECT 'PRE_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (11905, 948)
ORDER BY a.team_id, a.alias;

-- ============================================================
-- 1) LEAGUE_TEAMS
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
-- 2) MATCHES
-- ============================================================

UPDATE public.matches
SET home_team_id = 11905
WHERE home_team_id = 948;

UPDATE public.matches
SET away_team_id = 11905
WHERE away_team_id = 948;

-- ============================================================
-- 3) TEAM_ALIASES
-- Nejprve smažeme aliasy na staré větvi, které už na masteru existují
-- ============================================================

DELETE FROM public.team_aliases old_a
WHERE old_a.team_id = 948
  AND EXISTS (
      SELECT 1
      FROM public.team_aliases new_a
      WHERE new_a.team_id = 11905
        AND lower(btrim(new_a.alias)) = lower(btrim(old_a.alias))
  );

-- Zbývající aliasy bezpečně přesuneme
UPDATE public.team_aliases
SET team_id = 11905
WHERE team_id = 948;

-- Bezpečnostní insert jen pokud alias chybí
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 11905, 'Bournemouth', 'canonical_merge'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 11905
      AND lower(btrim(a.alias)) = lower(btrim('Bournemouth'))
);

-- ============================================================
-- 4) TEAM_PROVIDER_MAP
-- ============================================================

DELETE FROM public.team_provider_map old_pm
WHERE old_pm.team_id = 948
  AND EXISTS (
      SELECT 1
      FROM public.team_provider_map new_pm
      WHERE new_pm.team_id = 11905
        AND new_pm.provider = old_pm.provider
  );

UPDATE public.team_provider_map
SET team_id = 11905,
    updated_at = now()
WHERE team_id = 948;

-- ============================================================
-- 5) SMAZÁNÍ STARÉ VĚTVE, pokud už je čistá
-- ============================================================

DELETE FROM public.teams t
WHERE t.id = 948
  AND NOT EXISTS (SELECT 1 FROM public.team_provider_map x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.team_aliases x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.league_teams x WHERE x.team_id = t.id)
  AND NOT EXISTS (SELECT 1 FROM public.matches x WHERE x.home_team_id = t.id OR x.away_team_id = t.id);

-- ============================================================
-- 6) KONTROLA PO MERGI
-- ============================================================

SELECT 'POST_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (11905, 948);

SELECT 'POST_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (11905, 948)
ORDER BY pm.team_id, pm.provider;

SELECT 'POST_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (11905, 948)
ORDER BY a.team_id, a.alias;

COMMIT;