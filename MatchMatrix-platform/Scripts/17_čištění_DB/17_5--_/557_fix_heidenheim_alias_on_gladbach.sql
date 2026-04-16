-- 557_fix_heidenheim_alias_on_gladbach.sql
-- Cíl:
-- odstranit chybné Heidenheim aliasy z Borussia Mönchengladbach (530)
-- a správně je navázat na 1. FC Heidenheim 1846 (534)

BEGIN;

-- =========================================================
-- A) před kontrola
-- =========================================================
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (530, 534)
  AND lower(ta.alias) IN (
      lower('1. FC Heidenheim'),
      lower('1 heidenheim'),
      lower('heidenheim'),
      lower('1 fc heidenheim 1846')
  )
ORDER BY ta.team_id, ta.alias, ta.source;

-- =========================================================
-- B) smazat špatné aliasy z 530
-- =========================================================
DELETE FROM public.team_aliases
WHERE team_id = 530
  AND lower(alias) IN (
      lower('1. FC Heidenheim'),
      lower('1 heidenheim')
  );

-- =========================================================
-- C) doplnit aliasy na 534, pokud chybí
-- =========================================================
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 534, '1. FC Heidenheim', 'fix_557'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 534
      AND lower(alias) = lower('1. FC Heidenheim')
);

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 534, '1 heidenheim', 'fix_557'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 534
      AND lower(alias) = lower('1 heidenheim')
);

-- =========================================================
-- D) po kontrole
-- =========================================================
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (530, 534)
  AND lower(ta.alias) IN (
      lower('1. FC Heidenheim'),
      lower('1 heidenheim'),
      lower('heidenheim'),
      lower('1 fc heidenheim 1846')
  )
ORDER BY ta.team_id, ta.alias, ta.source;

COMMIT;