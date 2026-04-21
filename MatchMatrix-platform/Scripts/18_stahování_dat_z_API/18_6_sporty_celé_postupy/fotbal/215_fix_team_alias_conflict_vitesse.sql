-- =====================================================================
-- 215_fix_team_alias_conflict_vitesse.sql
-- Safe cleanup duplicitních aliasů před merge:
-- old team = 13027
-- new team = 1113
-- =====================================================================

-- 1) Náhled konfliktních aliasů
SELECT
    olda.team_id AS old_team_id,
    newa.team_id AS new_team_id,
    olda.alias   AS old_alias,
    newa.alias   AS new_alias
FROM public.team_aliases olda
JOIN public.team_aliases newa
  ON LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias))
WHERE olda.team_id = 13027
  AND newa.team_id = 1113
ORDER BY LOWER(BTRIM(olda.alias)), olda.alias;

-- 2) Smazání jen těch aliasů ze starého týmu,
--    které už na novém týmu existují ve stejném alias_norm
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 13027
  AND newa.team_id = 1113
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));

-- 3) Kontrola po cleanupu
SELECT
    olda.team_id AS old_team_id,
    newa.team_id AS new_team_id,
    olda.alias   AS old_alias,
    newa.alias   AS new_alias
FROM public.team_aliases olda
JOIN public.team_aliases newa
  ON LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias))
WHERE olda.team_id = 13027
  AND newa.team_id = 1113
ORDER BY LOWER(BTRIM(olda.alias)), olda.alias;

-- 4) Až bude kontrola prázdná, pusť merge znovu
SELECT public.merge_team(
    13027,
    1113,
    'merge Vitesse dup after alias cleanup',
    'FB_MULTI_MATCH',
    true,
    true
);