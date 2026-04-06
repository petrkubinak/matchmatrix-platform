-- =====================================================================
-- 579_fix_mapping_gap_senior_preference.sql
-- Účel:
-- potvrdit a zpevnit senior mapping pro:
--   1) Czech Republic -> Czechia (117)
--   2) Sporting Cristal -> CS Cristal (10991)
--
-- Bez merge.
-- Jen bezpečné alias / cleanup / kontrola konfliktů.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- A) Czech Republic -> team_id 117 (Czechia)
-- ---------------------------------------------------------------------

-- smaž případné duplicitní aliasy "Czech Republic" na jiných team_id
DELETE FROM public.team_aliases a
WHERE lower(public.unaccent(a.alias)) = lower(public.unaccent('Czech Republic'))
  AND a.team_id <> 117;

-- zajisti alias na správném senior team_id
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 117, 'Czech Republic', 'fix_579_senior_preference'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 117
      AND lower(public.unaccent(a.alias)) = lower(public.unaccent('Czech Republic'))
);

-- ---------------------------------------------------------------------
-- B) Sporting Cristal -> team_id 10991 (CS Cristal)
-- ---------------------------------------------------------------------

-- smaž případné duplicitní aliasy "Sporting Cristal" na jiných team_id
DELETE FROM public.team_aliases a
WHERE lower(public.unaccent(a.alias)) = lower(public.unaccent('Sporting Cristal'))
  AND a.team_id <> 10991;

-- zajisti alias na správném senior team_id
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 10991, 'Sporting Cristal', 'fix_579_senior_preference'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 10991
      AND lower(public.unaccent(a.alias)) = lower(public.unaccent('Sporting Cristal'))
);

COMMIT;