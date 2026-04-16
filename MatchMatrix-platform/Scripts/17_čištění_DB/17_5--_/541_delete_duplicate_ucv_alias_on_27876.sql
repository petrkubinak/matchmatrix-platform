BEGIN;

-- 541_delete_duplicate_ucv_alias_on_27876.sql
-- Cíl:
-- smazat konfliktní aliasy na starém týmu 27876,
-- které už existují na cílovém 35254

-- 1) kontrola před
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE a.team_id IN (27876, 35254)
  AND lower(btrim(a.alias)) IN ('ucv', 'ucv fc')
ORDER BY lower(btrim(a.alias)), a.team_id, a.id;

-- 2) smazat duplicitní aliasy na 27876
DELETE FROM public.team_aliases
WHERE team_id = 27876
  AND lower(btrim(alias)) IN (
      SELECT lower(btrim(alias))
      FROM public.team_aliases
      WHERE team_id = 35254
  );

-- 3) kontrola po delete
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE a.team_id IN (27876, 35254)
  AND lower(btrim(a.alias)) IN ('ucv', 'ucv fc')
ORDER BY lower(btrim(a.alias)), a.team_id, a.id;

COMMIT;