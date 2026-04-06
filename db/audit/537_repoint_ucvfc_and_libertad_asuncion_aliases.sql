BEGIN;

-- 537_repoint_ucvfc_and_libertad_asuncion_aliases.sql
-- Cíl:
-- Přepojit TheOdds aliasy:
--   UCV FC            -> 35254 (Universidad Central de Venezuela FC)
--   Libertad Asuncion -> 35255 (Club Libertad Asuncion)

-- =========================================================
-- 1) Kontrola před změnou
-- =========================================================
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE public.unaccent(lower(a.alias)) IN ('ucv fc', 'libertad asuncion')
ORDER BY a.alias, a.team_id, a.id;

-- =========================================================
-- 2) Smazat případné konfliktní aliasy na cílových týmech
-- =========================================================
DELETE FROM public.team_aliases
WHERE (team_id = 35254 AND public.unaccent(lower(alias)) = 'ucv fc')
   OR (team_id = 35255 AND public.unaccent(lower(alias)) = 'libertad asuncion');

-- =========================================================
-- 3) Repoint UCV FC -> 35254
-- =========================================================
UPDATE public.team_aliases
SET team_id = 35254,
    source  = 'audit_537_alias_repoint'
WHERE team_id = 27876
  AND public.unaccent(lower(alias)) = 'ucv fc';

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35254, 'UCV FC', 'audit_537_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35254
      AND public.unaccent(lower(a.alias)) = 'ucv fc'
);

-- =========================================================
-- 4) Repoint Libertad Asuncion -> 35255
-- =========================================================
UPDATE public.team_aliases
SET team_id = 35255,
    source  = 'audit_537_alias_repoint'
WHERE team_id = 25942
  AND public.unaccent(lower(alias)) = 'libertad asuncion';

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT 35255, 'Libertad Asuncion', 'audit_537_alias_repoint'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = 35255
      AND public.unaccent(lower(a.alias)) = 'libertad asuncion'
);

-- =========================================================
-- 5) Kontrola po změně
-- =========================================================
SELECT
    a.id,
    a.team_id,
    t.name AS team_name,
    a.alias,
    a.source
FROM public.team_aliases a
JOIN public.teams t
  ON t.id = a.team_id
WHERE public.unaccent(lower(a.alias)) IN ('ucv fc', 'libertad asuncion')
ORDER BY a.alias, a.team_id, a.id;

COMMIT;